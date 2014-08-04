/* Install script for the DANI IDE driver                              */
/* Place the following files in this directory from the DANI package:  */
/* DaniS506.ADD, DaniS506.DOC, DiskInfo.exe, DumpIDE.EXE               */
/* You may optionally put the up2TB.flt driver in this directory to    */
/* provide support for ultra large drives.                             */
/* 05.20.2002: added support for uninstallation                        */
/* 04.20.2004: added support for up2TB.flt                             */
/* 11.06.2004: up2tb support has been moved to boot image              */
/* 09.30.2005: aligned with os2mt                                      */
/* 10.20.2005: added overwrite mode                                    */

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
if stream(inst_dir'\DaniS506.ADD', 'c', 'query exists') = '' then exit 9

Say
Say 'Updating files...'

/* copy files but do not overwrite them if they are already there */
if stream(target'\os2\boot\DaniS506.ADD', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\DaniS506.ADD 'target'\os2\boot\. >> 'product_log
end
if stream(target'\os2\help\DaniS506.DOC', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\DaniS506.DOC 'target'\os2\help\. >> 'product_log
end
if stream(target'\os2\DiskInfo.exe', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\DiskInfo.exe 'target'\os2\. >> 'product_log
end
if stream(target'\os2\DumpIDE.EXE', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\DumpIDE.EXE  'target'\os2\. >> 'product_log
end

/* change config.sys if needed */
Say 
Say 'Updating Config.Sys...'
cfgfile = target'\config.sys'
q = 1
found. = 0
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('DANIS506.ADD', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM'
		then found.add = 1
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* backup config.sys */
if found.add = 0 | found.flt = 0 then do
	'@copy 'cfgfile target'\os2\install\config.dni' 
	'@del 'cfgfile
	do q=1 to l.0
		if pos('IBM1S506.ADD', translate(l.q)) > 0 then do
			rc = lineout(cfgfile, ' ')
			rc = lineout(cfgfile, 'REM UpdCD')
			if found.add = 0 then do
				/* add DANI driver */
				rc = lineout(cfgfile, 'BASEDEV=DANIS506.ADD')
				/* rem IBM driver out */
				l.q = 'REM UpdCD '||l.q 
			end
		end
		rc = lineout(cfgfile, l.q)
	end
	rc = lineout(cfgfile)
end

Say
Say 'Completed.'

exit

uninstall:

	/* update config.sys */
	found. = 0
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		if pos('REM UPDCD BASEDEV=IBM1S506.ADD', translate(l.q)) > 0 then found.ibmide = 1
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.dni >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('DANIS506.ADD', translate(l.q)) > 0 then iterate
		if pos('UP2TB.FLT',    translate(l.q)) > 0 then l.q = 'REM 'l.q
		if pos('REM UPDCD BASEDEV=IBM1S506.ADD', translate(l.q)) > 0 then l.q = 'BASEDEV=IBM1S506.ADD'
		call lineout cfgfile, l.q
	end
	if found.ibmide = 0 then call lineout cfgfile, 'BASEDEV=IBM1S506.ADD'
	call lineout cfgfile

	/* delete files */
	'del 'target'\os2\boot\danis506.add >> 'product_log
	'del 'target'\os2\help\danis506.doc >> 'product_log
	'del 'target'\os2\DiskInfo.exe      >> 'product_log
	'del 'target'\os2\DumpIDE.EXE       >> 'product_log

return
