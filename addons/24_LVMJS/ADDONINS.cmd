/* Installation of LVM and JFS support on Warp 4                     */
/*                                                                   */
/* For LVM support place the following files in this directory:      */
/* lvm.msg, lvmh.msg, lvm.exe, lvm.dll, os2lvm.dmd, lvmalert.exe     */
/* extendfs.exe, os2dasd.dmd (from WSeB, ECS or MCP)                 */
/*                                                                   */
/* You also need to put vcu.exe and vcu.msg here if you did not      */
/* manually convert your conventional partitions to volumes.         */
/*                                                                   */
/* For JFS support place the following files in this directory       */
/* ujfs.dll, uconv.dll, jfs.msg, jfsh.msg, jfs.ifs, jfschk32.exe     */
/*                                                                   */
/* These files can be found in Wseb, eCS, CP, Wseb fixpak 1/2        */
/* You must have a Wseb/eCS/CP license to use these files!           */
/*                                                                   */
/* You must have fixpak 13 or higher installed/incorporated          */
/*                                                                   */
/* Optionally, you can install the graphical (JAVA) interface for    */
/* LVM by adding the following WSeB/MCP files:                       */
/* engine.dll, harddisk.gif, lvmgui.zip, lvm_gui.ico, remdisk.gif    */
/*                                                                   */
/* !! If you want to install JFS without LVM unzip the following     */
/* !! JFS files in following order into this directory:              */
/*                                                                   */
/* 1. From WseB 4.5 fixpak (xr?e00?.adk) take NLS specific files:    */
/*    JFS.MSG, JFSH.MSG	(contained in jfs_msg.zip)                   */
/* 2. From testcase take jfs_01989_2.zip, unzip all 16 files without */
/*    path (actually only the 14 executables essential here)	     */
/* 3. From testcase jfs20040618.zip (JFS.IFS with BldLevel 14.100c)  */
/*    unzip without path and overwrite jfs.ifs and jfs.TDF.          */
/* 4. From Pavel take the patched UJFS.DLL out of UJFS05092004.ZIP   */
/*    ujfs.dll (just overwrite the existing file)		     */
/* 5. From testcase JFS1026.ZIP unzip without path TRC012F.TFF       */
/*                                                                   */
/* Please be sure that unicode.sys is present on your system!	     */
/*                                                                   */
/* 04.21.2001: added code to disable VFAT driver                     */
/* 06.20.2001: removed hardcoded path to vcu.exe                     */
/* 07.15.2001: improved script with lvmalert.exe and extendfs.exe    */
/*             and with graphical (java) interface                   */
/* 10.06.2001: run vcu unattended                                    */
/* 05.26.2002: added support for uninstallation                      */
/* 09.30.2002: added uconv.dll                                       */
/* 12.03.2003: uconv.dll should not be copied if it exists           */
/* 08.19.2004: vcu files made optional                               */
/* 07.10.2005: made LVM files optional                               */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* check */
Say 'Checking install files...'
if stream(inst_dir'\lvm.exe', 'c', 'query exists') = '' & stream(inst_dir'\jfs.ifs', 'c', 'query exists') = '' then exit 9

/* create volumes as needed */
if stream(inst_dir'\vcu.exe', 'c', 'query exists') <> '' then do

	/* create temporary command file to run VCU */
	Say 'Creating LVM volumes...'
	tmpcmd = target'\temp.cmd'
	'@del 'tmpcmd' >nul 2>>&1'
	call sysfiletree source'\updcd\addons\vcu.exe', 'tmp.', 'FSO'
	call lineout tmpcmd, '/* rexx */'
	call lineout tmpcmd, 'say ""'
	call lineout tmpcmd, 'say "This procedure will call VCU and create the compatibility volumes."'
	call lineout tmpcmd, 'say "Caution: do not reboot the system until the Add-On installation finishes!"'
	call lineout tmpcmd, 'say ""'
	call lineout tmpcmd, '"@'tmp.1' /CID"'
	call lineout tmpcmd, '"@echo VCU completed: "'rc'" > 'target'\vcuflag.flg"'
	call lineout tmpcmd
	
	/* run cmd file */
	'@del 'target'\vcuflag.flg'
	call RxFuncAdd 'SysSleep', 'RexxUtil', 'SysSleep'
	'start "Create Compatibility Volumes" /f /c 'tmpcmd 
	
	/* wait for result or time out */
	i = 0
	do while i < 60 & stream(target'\vcuflag.flg', 'c', 'query exists') = ''
		'@echo Waiting 60s for VCU to complete. Current wait: 'i's >> 'product_log
		call syssleep 1
		i = i + 1
	end
	
	/* log what happened */
	if i = 60 then do
		'@echo VCU timed out, installation will be aborted. >> 'product_log
		exit 8
	end
	else do
		l = linein(target'\vcuflag.flg')
		call lineout target'\vcuflag.flg'
		parse var l . . retcode
		if datatype(retcode) = 'NUM' & retcode >=0 & retcode <=1 then 
			'@echo VCU completed with return code 'retcode', installation will continue.  >> 'product_log
		else do
			'@echo VCU completed with return code 'retcode', installation will be aborted.  >> 'product_log
			exit retcode
		end
	end

	/* clean up the mess */
	'@del 'tmpcmd' >nul 2>>&1'
	'@del 'target'\vcuflag.flg >nul 2>>&1'

end

dest_dir = target'\OS2'
if stream(inst_dir'\lvm.exe', 'c', 'query exists') <> '' then do

	/* backup */
	Say 'Backing up OS2Dasd.Dmd...'
	'@copy 'dest_dir'\BOOT\os2dasd.dmd 'dest_dir'\BOOT\os2dasd.sav >> 'product_log

	/* copy obligatory LVM files */
	Say 'Copying LVM files...'
	'@copy 'inst_dir'\lvm.exe      'dest_dir'\.        >> 'product_log
	'@copy 'inst_dir'\extendfs.exe 'dest_dir'\.        >> 'product_log
	'@copy 'inst_dir'\lvm.msg      'dest_dir'\system\. >> 'product_log
	'@copy 'inst_dir'\lvmh.msg     'dest_dir'\system\. >> 'product_log
	'@copy 'inst_dir'\lvmalert.exe 'dest_dir'\system\. >> 'product_log
	'@copy 'inst_dir'\lvm.dll      'dest_dir'\DLL\.    >> 'product_log
	'@copy 'inst_dir'\os2lvm.dmd   'dest_dir'\BOOT\.   >> 'product_log
	'@copy 'inst_dir'\os2dasd.dmd  'dest_dir'\BOOT\.   >> 'product_log

end

/* copy optional LVM files */
if stream(inst_dir'\engine.dll',   'c', 'query exists') <> '' then '@copy 'inst_dir'\engine.dll      'dest_dir'\DLL\.         >> 'product_log
if stream(inst_dir'\remdisk.gif',  'c', 'query exists') <> '' then '@copy 'inst_dir'\remdisk.gif     'dest_dir'\javaapps\.    >> 'product_log
if stream(inst_dir'\lvmgui.zip',   'c', 'query exists') <> '' then '@copy 'inst_dir'\lvmgui.zip      'dest_dir'\javaapps\.    >> 'product_log
if stream(inst_dir'\harddisk.gif', 'c', 'query exists') <> '' then do
	'@mkdir 'dest_dir'\javaapps'  
	'@copy 'inst_dir'\harddisk.gif    'dest_dir'\javaapps\. >> 'product_log
end
if stream(inst_dir'\vcu.exe', 'c', 'query exists') <> '' then do
	'@copy 'inst_dir'\vcu.exe 'dest_dir'\. >> 'product_log
	'@copy 'inst_dir'\vcu.msg 'dest_dir'\. >> 'product_log
end
if stream(inst_dir'\lvm_gui.ico',  'c', 'query exists') <> '' then do
	'@copy 'inst_dir'\lvm_gui.ico     'dest_dir'\javaapps\. >> 'product_log
	call RxFuncAdd 'SysCreateObject', 'REXXUTIL', 'SysCreateObject'
	call SysCreateObject "WPProgram", "Logical Volume Manager", "<WP_CONFIG>", "EXENAME=JAVAPM.EXE;PARAMETERS=-nojit lvmgui;STARTUPDIR="target"\OS2\JAVAAPPS;ICONFILE="target"\OS2\JAVAAPPS\LVM_GUI.ICO;OBJECTID=<LVM_GUI>", "R"
	'@echo Result SysCreateObject: 'result' >> 'product_log
end

/* load config.sys */
Say 'Reading Config.Sys...'
lvm_found = 0
jfs_found = 0
cfgfile = target'\config.sys'
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('BASEDEV=OS2LVM.DMD', translate(l.q)) > 0 then lvm_found = 1
	if pos('\OS2\JFS.IFS',       translate(l.q)) > 0 then jfs_found = 1
	if stream(inst_dir'\lvm.exe', 'c', 'query exists') <> '' then do
		/* remove VFAT */
		if pos('BASEDEV=MWDD32.SYS', translate(l.q)) > 0 then iterate
		if pos('VFAT-OS2.IFS',       translate(l.q)) > 0 then iterate
		if pos('VFAT_LW.EXE',        translate(l.q)) > 0 then iterate
		if pos('BASEDEV=EXT2FLT.FLT',translate(l.q)) > 0 then iterate
	end
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

if stream(inst_dir'\lvm.exe', 'c', 'query exists') <> '' then do

	/* backup config.sys */
	Say 'Backing up Config.Sys...'
	'@copy 'cfgfile target'\os2\install\config.lvm' 
	'@del 'cfgfile

	/* write new config.sys */
	Say 'Updating Config.Sys with LVM info...'
	do q=1 to l.0
		if pos('BASEDEV=OS2DASD.DMD', translate(l.q)) > 0 & lvm_found = 0 then do
			/* add driver */
			rc = lineout(cfgfile, l.q)
			rc = lineout(cfgfile, ' ')
			rc = lineout(cfgfile, 'REM UpdCD')
			rc = lineout(cfgfile, 'BASEDEV=OS2LVM.DMD')
			rc = lineout(cfgfile, 'RUN='target'\OS2\SYSTEM\LVMALERT.EXE')
			rc = lineout(cfgfile, 'RUN='target'\OS2\EXTENDFS.EXE *')
			lvm_found = 1
		end
		else if pos('BASEDEV=DANIDASD.DMD', translate(l.q)) > 0 & lvm_found = 0 then do
			/* add drivers */
			rc = lineout(cfgfile, ' ')
			rc = lineout(cfgfile, 'REM UpdCD')
			rc = lineout(cfgfile, 'BASEDEV=OS2DASD.DMD')
			rc = lineout(cfgfile, 'BASEDEV=OS2LVM.DMD')
			rc = lineout(cfgfile, 'RUN='target'\OS2\SYSTEM\LVMALERT.EXE')
			rc = lineout(cfgfile, 'RUN='target'\OS2\EXTENDFS.EXE *')
			lvm_found = 1
		end
		/* add LVMGUI.ZIP to CLASSPATH */
		else if pos('CLASSPATH', translate(l.q)) > 0 & stream(inst_dir'\lvmgui.zip', 'c', 'query exists') <> '' then do
			rc = lineout(cfgfile, 'SET CLASSPATH='target'\OS2\JAVAAPPS\LVMGUI.ZIP;'substr(l.q, pos('=', l.q)+1))
		end
		/* remove partfilter */
		else if pos('PARTFILT.FLT', translate(l.q)) = 0 then rc = lineout(cfgfile, l.q)
	end
	rc = lineout(cfgfile)

end

/* check */
if stream(inst_dir'\jfs.ifs', 'c', 'query exists') = '' then exit

/* copy obligatory JFS files */
Say 'Copying JFS files...'
'@copy 'inst_dir'\ujfs.dll     'dest_dir'\DLL\.  >> 'product_log
'@copy 'inst_dir'\jfs.msg      'dest_dir'\.      >> 'product_log
'@copy 'inst_dir'\jfsh.msg     'dest_dir'\.      >> 'product_log
'@copy 'inst_dir'\jfs.ifs      'dest_dir'\.      >> 'product_log
'@copy 'inst_dir'\jfschk32.exe 'dest_dir'\.      >> 'product_log

/* copy optional JFS files */
if stream(inst_dir'\uconv.dll',    'c', 'query exists') <> '' then '@copy 'inst_dir'\uconv.dll		'dest_dir'\DLL\.		>> 'product_log
if stream(inst_dir'\cachejfs.EXE', 'c', 'query exists') <> '' then '@copy 'inst_dir'\cachejfs.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\chklgjfs.EXE', 'c', 'query exists') <> '' then '@copy 'inst_dir'\chklgjfs.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\clrbblks.EXE', 'c', 'query exists') <> '' then '@copy 'inst_dir'\clrbblks.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\cstats.EXE',   'c', 'query exists') <> '' then '@copy 'inst_dir'\cstats.EXE		'dest_dir'\.			>> 'product_log
if stream(inst_dir'\defragfs.EXE', 'c', 'query exists') <> '' then '@copy 'inst_dir'\defragfs.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\dumpfs.EXE',   'c', 'query exists') <> '' then '@copy 'inst_dir'\dumpfs.EXE		'dest_dir'\.			>> 'product_log
if stream(inst_dir'\extendfs.EXE', 'c', 'query exists') <> '' then '@copy 'inst_dir'\extendfs.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\logdump.EXE',  'c', 'query exists') <> '' then '@copy 'inst_dir'\logdump.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\logredo.EXE',  'c', 'query exists') <> '' then '@copy 'inst_dir'\logredo.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\validfs.EXE',  'c', 'query exists') <> '' then '@copy 'inst_dir'\validfs.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\xchkdmp.EXE',  'c', 'query exists') <> '' then '@copy 'inst_dir'\xchkdmp.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\xchklog.EXE',  'c', 'query exists') <> '' then '@copy 'inst_dir'\xchklog.EXE	'dest_dir'\.			>> 'product_log
if stream(inst_dir'\xpeek.EXE',    'c', 'query exists') <> '' then '@copy 'inst_dir'\xpeek.EXE		'dest_dir'\.			>> 'product_log
if stream(inst_dir'\JFS.TDF',      'c', 'query exists') <> '' then '@copy 'inst_dir'\JFS.TDF		'dest_dir'\system\trace\. 	>> 'product_log
if stream(inst_dir'\TRC012F.TFF',  'c', 'query exists') <> '' then '@copy 'inst_dir'\TRC012F.TFF	'dest_dir'\system\trace\. 	>> 'product_log
if stream(inst_dir'\readme.jfs',   'c', 'query exists') <> '' then '@copy 'inst_dir'\readme.jfs		'dest_dir'\help\.	 	>> 'product_log

/* load config.sys */
Say 'Reading Config.Sys...'
cfgfile = target'\config.sys'
q = 1
gevonden_unicode = 0
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('UNICODE.SYS', translate(l.q)) > 0 & substr(translate(l.q),1,3) <> 'REM' then gevonden_unicode = q
	q = q+1
end
call lineout cfgfile
l.0 = q-1

/* check unicode.sys */
if gevonden_unicode = 0 then do
	call RxFuncAdd 'Sysfiletree', 'RexxUtil', 'Sysfiletree'
	call sysfiletree target'\unicode.sys', 'tmp.', 'FSO'
end

/* backup config.sys */
Say 'Backing up Config.Sys...'
'@copy 'cfgfile target'\os2\install\config.jfs' 
'@del 'cfgfile

/* no unicode.sys in old cfg.sys */
if gevonden_unicode = 0 then do
	if tmp.0 > 0 then /* we can repair it */
		call lineout cfgfile, 'DEVICE='tmp.1
	else do
		Say 'Warning: Unicode.Sys was not found on your system!!!'
		'@echo Warning: Unicode.Sys was not found on your system!!! >> 'product_log
	end
end

/* write new config.sys */
Say 'Updating Config.Sys with JFS info...'
/* add JFS driver */
if jfs_found = 0 then do
	call lineout cfgfile, 'IFS='target'\OS2\JFS.IFS /AUTOCHECK:* /LW:5,20,4 /CACHE:8192'
	jfs_found = 1
end
do q=1 to l.0
	call lineout cfgfile, l.q
end
call lineout cfgfile

exit

uninstall:

	/* check */
	Say 'Uninstalling LVM and/or JFS...'
	if stream(target'\os2\boot\os2dasd.sav', 'c', 'query exists') = '' then do
		Say 'Missing 'target'\os2\boot\os2dasd.sav. LVM cannot be uninstalled.'
	end

	/* del object */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<LVM_GUI>"

	/* update config.sys */
	Say 'Updating Config.Sys...'
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'@copy 'cfgfile target'\os2\install\config.lvm >> 'product_log 
	'@del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('BASEDEV=OS2LVM.DMD', translate(l.q)) > 0       then iterate
		if pos('\OS2\SYSTEM\LVMALERT.EXE', translate(l.q)) > 0 then iterate
		if pos('\OS2\EXTENDFS.EXE', translate(l.q)) > 0        then iterate
		if pos('\OS2\JFS.IFS', translate(l.q)) > 0             then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

	/* remove lvmgui.zip from classpath */
	call remove_from_path cfgfile target'\OS2\JAVAAPPS\LVMGUI.ZIP SET CLASSPATH='

	/* del files */
	Say 'Removing files...'
	dest_dir = target'\OS2'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\vcu.exe'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\lvm.exe'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\jfschk32.exe'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\extendfs.exe'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\dll\lvm.dll'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\dll\engine.dll'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\dll\ujfs.dll'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\dll\uconv.dll'
	'call @'source'\updcd\bin\unlock.exe 'dest_dir'\system\lvmalert.exe'
	'@del 'dest_dir'\vcu.exe             >> 'product_log	
	'@del 'dest_dir'\vcu.msg             >> 'product_log	
	'@del 'dest_dir'\lvm.exe             >> 'product_log	
	'@del 'dest_dir'\jfs.msg             >> 'product_log	
	'@del 'dest_dir'\jfs.ifs             >> 'product_log	
	'@del 'dest_dir'\jfschk32.exe        >> 'product_log	
	'@del 'dest_dir'\jfsh.msg            >> 'product_log	
	'@del 'dest_dir'\extendfs.exe        >> 'product_log	
	'@del 'dest_dir'\system\lvm.msg      >> 'product_log	
	'@del 'dest_dir'\system\lvmh.msg     >> 'product_log	
	'@del 'dest_dir'\system\lvmalert.exe >> 'product_log	
	'@del 'dest_dir'\dll\lvm.dll         >> 'product_log
	'@del 'dest_dir'\dll\engine.dll      >> 'product_log
	'@del 'dest_dir'\dll\ujfs.dll        >> 'product_log
	'@del 'dest_dir'\dll\uconv.dll       >> 'product_log
	'@del 'dest_dir'\boot\os2lvm.dmd     >> 'product_log	
	'@del 'dest_dir'\cachejfs.EXE        >> 'product_log	
	'@del 'dest_dir'\chklgjfs.EXE        >> 'product_log	
	'@del 'dest_dir'\clrbblks.EXE        >> 'product_log	
	'@del 'dest_dir'\cstats.EXE          >> 'product_log	
	'@del 'dest_dir'\defragfs.EXE        >> 'product_log	
	'@del 'dest_dir'\dumpfs.EXE          >> 'product_log	
	'@del 'dest_dir'\extendfs.EXE        >> 'product_log	
	'@del 'dest_dir'\logdump.EXE         >> 'product_log	
	'@del 'dest_dir'\logredo.EXE         >> 'product_log	
	'@del 'dest_dir'\validfs.EXE         >> 'product_log	
	'@del 'dest_dir'\xchkdmp.EXE         >> 'product_log	
	'@del 'dest_dir'\xchklog.EXE         >> 'product_log	
	'@del 'dest_dir'\xpeek.EXE           >> 'product_log	
	'@del 'dest_dir'\system\trace\JFS.TDF     >> 'product_log	
	'@del 'dest_dir'\system\trace\TRC012F.TFF >> 'product_log	
	'@del 'dest_dir'\os2\help\readme.jfs >> 'product_log	
	call deldir dest_dir'\javaapps'

	/* restore os2dasd.sav */
	'@copy 'dest_dir'\BOOT\os2dasd.sav 'dest_dir'\BOOT\os2dasd.dmd >> 'product_log

return

DelDir: procedure

	parse upper arg Directory
	DirSpec = Directory'\*'

	/* delete subdirectories */
	rc = SysFileTree(DirSpec, Subdirs, 'DO', '*****', '-*---')
	do i = 1 to Subdirs.0
   		call DelDir Subdirs.i
	end

	/* delete files */
	rc = SysFileTree(DirSpec, Files, 'FO', '*****', '-*---')
	do i = 1 to Files.0
		'@del "'Files.i'"'
	end

	/* delete directory */
	'@rmdir "'Directory'"'

return

/* remove string from path */
remove_from_path: procedure

	parse upper arg cfgfile rpstr ststr 

	i=1
	do while lines(cfgfile)
		l.i=linein(cfgfile)
		i=i+1
	end
	call lineout cfgfile
	l.0=i-1
	'@del 'cfgfile

	do i=1 to l.0
		/* remove rpstr */
		if substr(translate(l.i), 1, length(ststr)) = ststr & pos(rpstr, translate(l.i)) > 0 then do
			l.i = substr(l.i, 1, pos(rpstr, translate(l.i))-1) || substr(l.i, pos(rpstr, translate(l.i))+length(rpstr))
			/* remove ;; */
			if pos(';;', translate(l.i)) > 0 then 
				l.i = substr(l.i, 1, pos(';;', translate(l.i))-1) || ';' || substr(l.i, pos(';;', translate(l.i))+length(';;'))
		end
		call lineout cfgfile, l.i
	end
	call lineout cfgfile

return
