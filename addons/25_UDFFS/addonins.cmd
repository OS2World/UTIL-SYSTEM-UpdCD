/*                                                                        */
/* Install script for UDF file system.                                    */
/*                                                                        */
/* Unzip the UDF package in a temp directory (e.g. UDF201 -d).            */
/* Place the following files from the temp dir in this directory:         */
/* 1. UDF.IFS, UUDF.DLL (the latter should match the language of your OS) */
/* 2. CDFS.IFS, IBMIDECD.FLT, OS2CDROM.DMD                                */
/* 3. PMFORMAT.EXE, LOCK.EXE, UNLOCK.EXE                                  */
/* 4. README.TXT                                                          */
/*                                                                        */
/* Please be sure that unicode.sys is present on your system!             */
/*                                                                        */
/* Created on 03.22.2001                                                  */
/* 05.20.2002: added support for uninstallation                           */
/* 02.12.2005: updated to support latest UDF distributions                */
/* 05.15.2005: added cdfs.ifs and unicode.sys checks                      */

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
if stream(inst_dir'\UDF.IFS', 'c', 'query exists') = '' then exit 9

/* copy files */
Say 'Adding files...'
'@copy 'inst_dir'\UDF.IFS      'target'\OS2\BOOT\.          >> 'product_log
'@copy 'inst_dir'\UUDF.DLL     'target'\os2\dll\.           >> 'product_log
'@copy 'inst_dir'\PMFORMAT.EXE 'target'\os2\.               >> 'product_log
'@copy 'inst_dir'\LOCK.EXE     'target'\os2\.               >> 'product_log
'@copy 'inst_dir'\UNLOCK.EXE   'target'\os2\.               >> 'product_log
'@copy 'inst_dir'\readme.txt   'target'\os2\help\readme.udf >> 'product_log

/* update os2cdrom.dmd only if we have a newer one */
if build(inst_dir'\os2cdrom.dmd') > build(target'\OS2\BOOT\os2cdrom.dmd') then do
	'@copy 'inst_dir'\os2cdrom.dmd 'target'\os2\boot\. >> 'product_log
end
/* update CDFS.IFS only if we have a newer one */
if build(inst_dir'\CDFS.IFS') > build(target'\OS2\BOOT\CDFS.IFS') then do
	'@copy 'inst_dir'\CDFS.IFS 'target'\os2\boot\. >> 'product_log
end
/* update IBMIDECD.FLT only if we have a newer one */
if build(inst_dir'\IBMIDECD.FLT') > build(target'\OS2\BOOT\IBMIDECD.FLT') then do
	'@copy 'inst_dir'\IBMIDECD.FLT 'target'\os2\boot\. >> 'product_log
end

/* scan config.sys */
Say 'Updating Config.Sys...'
cfgfile = target'\config.sys'
i=1
gevonden_cdfs = 0
gevonden_unicode = 0
do while lines(cfgfile)
	l.i = linein(cfgfile)
	if pos('CDFS.IFS', translate(l.i)) > 0 then gevonden_cdfs = i
	if pos('UNICODE.SYS', translate(l.i)) > 0 then gevonden_unicode = i
	i = i+1
end
l.0 = i-1
call lineout cfgfile

/* check unicode.sys */
if gevonden_unicode = 0 then do
	call RxFuncAdd 'Sysfiletree', 'RexxUtil', 'Sysfiletree'
	call sysfiletree target'\unicode.sys', 'tmp.', 'FSO'
end

/* update config.sys */
'@copy 'cfgfile target'\os2\install\config.udf >> 'product_log 
'@del 'cfgfile' >nul 2>>&1'

/* no unicode.sys in old cfg.sys */
if gevonden_unicode = 0 then do
	if tmp.0 > 0 then /* we can repair it */
		call lineout cfgfile, 'DEVICE='tmp.1
	else do
		Say 'Warning: Unicode.Sys was not found on your system!!!'
		'@echo Warning: Unicode.Sys was not found on your system!!! >> 'product_log
	end
end

/* unicode.sys after cdfs.ifs */
if gevonden_unicode > gevonden_cdfs & gevonden_cdfs <> 0 then do
	call lineout cfgfile, l.gevonden_unicode
	l.gevonden_unicode = ''
end

/* no cdfs.ifs in old cfg.sys */
zoekterm = 'CDFS.IFS'
if gevonden_cdfs = 0 then do
	if gevonden_unicode = 0 then call lineout cfgfile, 'IFS='target'\OS2\BOOT\UDF.IFS'
	else zoekterm = 'UNICODE.SYS'
end

/* udf.ifs before cdfs.ifs */
do i=1 to l.0
	if pos(zoekterm, translate(l.i)) > 0 then do
		if zoekterm = 'CDFS.IFS' then do
			call lineout cfgfile, 'IFS='target'\OS2\BOOT\UDF.IFS'
			call lineout cfgfile, l.i
		end
		else do
			call lineout cfgfile, l.i
			call lineout cfgfile, 'IFS='target'\OS2\BOOT\UDF.IFS'
		end
	end
	else
		if pos('UDF.IFS', translate(l.i)) = 0 then call lineout cfgfile, l.i
end

exit

/* returns build levl input file */
build: procedure 

	parse arg file
	tmp = 'buildlvl.$t$'
	'@bldlevel 'file' > 'tmp' 2>>&1'
	do while lines(tmp)
		l=linein(tmp)
		parse var l rev num
		if translate(rev) = 'REVISION:' then leave
	end
	rc=lineout(tmp)
	'@del 'tmp
	num = space(num)
	if datatype(num) <> 'NUM' then num = 0

return num

uninstall:

	/* update config.sys */
	found. = 0
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'@copy 'cfgfile target'\os2\install\config.udf >> 'product_log 
	'@del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('\OS2\BOOT\UDF.IFS', translate(l.q)) > 0 then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

	/* delete files */
	'@del 'target'\os2\boot\UDF.IFS >> 'product_log
	'@del 'target'\os2\dll\UUDF.DLL >> 'product_log
	'@del 'target'\os2\pmformat.exe >> 'product_log
	'@del 'target'\os2\lock.exe     >> 'product_log
	'@del 'target'\os2\unlock.exe   >> 'product_log

return
