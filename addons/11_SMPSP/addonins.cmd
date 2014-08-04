/* Install SMP support on Warp 4                                      */
/* Place the following SMP files from WSeB fixpak2 in this directory: */
/* OS2LDR, OS2APIC.PSD, DOSCALL1.DLL, OS2KRNL (unpack the files       */
/* LDRSMP.___, DCALLSMP.___, KRNLSMP.___ and OS2APIC.PSD from         */
/* FIX\OS2.1 and FIX\OS2.3 unpack2.exe).                              */
/* Place an updated version (from ACP/MCP/eCS) of PMDD.SYS here.      */
/* ?:\os2\attrib.exe should be present on the target system           */
/* 06.23.2001: attrib.exe info/check has been                         */
/* 05.19.2002: added support for uninstallation                       */

/* get command line parameters */
parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\OS2KRNL', 'c', 'query exists') = '' then exit 9

/* attrib.exe should be present */
if stream(target'\OS2\attrib.exe', 'c', 'query exists') = '' then exit 8

/* remove attributes */
'@attrib -r -s -h 'target'\os2krnl              >> 'product_log' 2>>&1'
'@attrib -r -s -h 'target'\os2ldr               >> 'product_log' 2>>&1'
'@attrib -r -s -h 'target'\os2\dll\doscall1.dll >> 'product_log' 2>>&1'
'@attrib -r -s -h 'target'\os2\boot\pmdd.sys    >> 'product_log' 2>>&1'

/* copy SMP files but do not overwrite them if they are already there */
if stream(target'\OS2\INSTALL\SMP\OS2KRNL', 'c', 'query exists') = '' then do
	'@mkdir 'target'\OS2\INSTALL\SMP 	                  		>> 'product_log' 2>>&1'
	'@copy 'inst_dir'\os2krnl 'target'\os2\install\smp\.  		>> 'product_log' 2>>&1'
	'@copy 'inst_dir'\os2ldr 'target'\os2\install\smp\.   		>> 'product_log' 2>>&1'
	'@copy 'inst_dir'\doscall1.dll 'target'\os2\install\smp\. >> 'product_log' 2>>&1'
	'@copy 'inst_dir'\pmdd.sys 'target'\os2\install\smp\. 		>> 'product_log' 2>>&1'
	'@copy 'inst_dir'\os2apic.psd 'target'\os2\install\smp\.  >> 'product_log' 2>>&1'
end
/* backup UNI files */
if stream(target'\OS2\INSTALL\UNI\OS2KRNL', 'c', 'query exists') = '' then do
	'@mkdir 'target'\OS2\INSTALL\UNI 	                  		>> 'product_log' 2>>&1'
	'@copy 'target'\os2krnl 'target'\os2\install\uni\.  		>> 'product_log' 2>>&1'
	'@copy 'target'\os2ldr 'target'\os2\install\uni\.   		>> 'product_log' 2>>&1'
	'@copy 'target'\os2\dll\doscall1.dll 'target'\os2\install\uni\. >> 'product_log' 2>>&1'
	'@copy 'target'\os2\boot\pmdd.sys 'target'\os2\install\uni\. 		>> 'product_log' 2>>&1'
end

/* unlock doscall1.dll */
'@copy 'source'\updcd\bin\unlock.exe 'target'\os2\.              >> 'product_log' 2>>&1'
'@unlock 'target'\os2\dll\doscall1.dll                           >> 'product_log' 2>>&1'

/* install SMP files */
'@copy 'target'\os2\install\smp\os2krnl      'target'\.          >> 'product_log' 2>>&1'
'@copy 'target'\os2\install\smp\os2ldr       'target'\.          >> 'product_log' 2>>&1'
'@copy 'target'\os2\install\smp\doscall1.dll 'target'\os2\dll\.  >> 'product_log' 2>>&1'
'@copy 'target'\os2\install\smp\pmdd.sys     'target'\os2\boot\. >> 'product_log' 2>>&1'
'@copy 'target'\os2\install\smp\os2apic.psd  'target'\os2\boot\. >> 'product_log' 2>>&1'

/* put back attributes */
'@attrib +r +s +h 'target'\os2krnl >> 'product_log' 2>>&1'
'@attrib +r +s +h 'target'\os2ldr  >> 'product_log' 2>>&1'

/* scan config.sys */
cfgfile = target'\config.sys'
gevonden = 0
do while lines(cfgfile)
	l = linein(cfgfile)
	if pos('OS2APIC.PSD', translate(l)) > 0 then do
		gevonden = 1
		leave
	end
end
rc = lineout(cfgfile)

/* backup and update config.sys */
if gevonden = 0 then do
	'@copy 'cfgfile target'\os2\install\config.smp' 
	'@echo REM UpdCD       >> 'target'\config.sys'
	'@echo PSD=OS2APIC.PSD >> 'target'\config.sys'
end

/* create rexx program to switch between kernels */
rexxpgm = target'\OS2\SWCHKRNL.CMD'
'@del 'rexxpgm' >nul 2>>&1'
call lineout rexxpgm, "/* Switch between SMP and UNI kernels        */"
call lineout rexxpgm, "/* Use with UpdCD only. Z. Kadar, 03.21.2001 */"
call lineout rexxpgm, " "
call lineout rexxpgm, "parse upper arg drive mode"
call lineout rexxpgm, " "
call lineout rexxpgm, "if drive = '' | mode = '' then do"
call lineout rexxpgm, "	say 'Switch between SMP and UNI kernel'"
call lineout rexxpgm, "	say 'Usage  : swchkrnl <drive> <SMP/UNI>'"
call lineout rexxpgm, "	say 'Example: swchkrnl C: SMP (switch to SMP kernel on drive C:)'"
call lineout rexxpgm, "	say '         swchkrnl E: UNI (switch to UNI kernel on drive E:)'"
call lineout rexxpgm, "	exit 1"
call lineout rexxpgm, "end"
call lineout rexxpgm, " "
call lineout rexxpgm, "select "
call lineout rexxpgm, "	when mode = 'SMP' then do"
call lineout rexxpgm, "		if stream(drive'\os2\install\smp\os2krnl', 'c', 'query exists') <> '' then do"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2krnl              '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2ldr               '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2\dll\doscall1.dll '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2\boot\pmdd.sys    '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2\boot\os2apic.psd '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\smp\os2krnl      'drive'\.          '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\smp\os2ldr       'drive'\.          '"
call lineout rexxpgm, "			'@unlock 'drive'\os2\dll\doscall1.dll                          '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\smp\doscall1.dll 'drive'\os2\dll\.  '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\smp\pmdd.sys     'drive'\os2\boot\. '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\smp\os2apic.psd  'drive'\os2\boot\. '"
call lineout rexxpgm, "			'@attrib +r +s +h 'drive'\os2krnl '"
call lineout rexxpgm, "			'@attrib +r +s +h 'drive'\os2ldr  '"
call lineout rexxpgm, "			/* scan config sys */"
call lineout rexxpgm, "			cfgfile = drive'\config.sys'"
call lineout rexxpgm, "			gevonden = 0"
call lineout rexxpgm, "			do while lines(cfgfile)"
call lineout rexxpgm, "				l = linein(cfgfile)"
call lineout rexxpgm, "				if pos('OS2APIC.PSD', translate(l)) > 0 then do"
call lineout rexxpgm, "					gevonden = 1"
call lineout rexxpgm, "					leave"
call lineout rexxpgm, "				end"
call lineout rexxpgm, "			end"
call lineout rexxpgm, "			rc = lineout(cfgfile)"
call lineout rexxpgm, "			/* update config.sys */"
call lineout rexxpgm, "			if gevonden = 0 then do"
call lineout rexxpgm, "				'@echo PSD=OS2APIC.PSD >> 'drive'\config.sys'"
call lineout rexxpgm, "			end"
call lineout rexxpgm, "		end"
call lineout rexxpgm, "		else do"
call lineout rexxpgm, "			say 'The necessary SMP files are not installed on this system!'"
call lineout rexxpgm, "			say 'Please install SMP support using Selective Install for AddOn Products.'"
call lineout rexxpgm, "			exit 3"
call lineout rexxpgm, "		end"
call lineout rexxpgm, "	end"
call lineout rexxpgm, "	when mode = 'UNI' then do"
call lineout rexxpgm, "		if stream(drive'\os2\install\uni\os2krnl', 'c', 'query exists') <> '' then do"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2krnl              '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2ldr               '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2\dll\doscall1.dll '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2\boot\pmdd.sys    '"
call lineout rexxpgm, "			'@attrib -r -s -h 'drive'\os2\boot\os2apic.psd '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\uni\os2krnl      'drive'\.          '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\uni\os2ldr       'drive'\.          '"
call lineout rexxpgm, "			'@unlock 'drive'\os2\dll\doscall1.dll                          '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\uni\doscall1.dll 'drive'\os2\dll\.  '"
call lineout rexxpgm, "			'@copy 'drive'\os2\install\uni\pmdd.sys     'drive'\os2\boot\. '"
call lineout rexxpgm, "			'@attrib +r +s +h 'drive'\os2krnl '"
call lineout rexxpgm, "			'@attrib +r +s +h 'drive'\os2ldr  '"
call lineout rexxpgm, "			/* change config.sys */"
call lineout rexxpgm, "			cfgfile = drive'\config.sys'"
call lineout rexxpgm, "			q = 1"
call lineout rexxpgm, "			do while lines(cfgfile)"
call lineout rexxpgm, "				l.q = linein(cfgfile)"
call lineout rexxpgm, "				if pos('OS2APIC.PSD', translate(l.q)) = 0 then q = q+1"
call lineout rexxpgm, "			end"
call lineout rexxpgm, "			rc = lineout(cfgfile)"
call lineout rexxpgm, "			'@del 'cfgfile"
call lineout rexxpgm, "			l.0 = q-1"
call lineout rexxpgm, "			do i = 1 to l.0"
call lineout rexxpgm, "				rc = lineout(cfgfile, l.i)"
call lineout rexxpgm, "			end"
call lineout rexxpgm, "			rc = lineout(cfgfile)"
call lineout rexxpgm, "		end"
call lineout rexxpgm, "		else do"
call lineout rexxpgm, "			say 'The necessary UNI files are not found on this system!'"
call lineout rexxpgm, "			say 'Please install SMP support using Selective Install for AddOn Products.'"
call lineout rexxpgm, "			exit 4"
call lineout rexxpgm, "		end"
call lineout rexxpgm, "	end"
call lineout rexxpgm, "	otherwise do"
call lineout rexxpgm, "		say 'Unknown mode 'mode'. Exiting...'"
call lineout rexxpgm, "		exit 2"
call lineout rexxpgm, "	end"
call lineout rexxpgm, "end"
call lineout rexxpgm, " "
call lineout rexxpgm, "exit"
call lineout rexxpgm, " "
call lineout rexxpgm

exit

/* uninstall mode */
uninstall:

	'call 'target'\OS2\SWCHKRNL.CMD 'target' UNI'

return
