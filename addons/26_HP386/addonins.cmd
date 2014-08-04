/* Install script for the HPFS386 file system. Place the following files */
/* in this directory: hpfs386.ifs, hpfs386.dll, hfs.msg, hfsh.msg        */
/* The files should have a level of LS 4.0 or higher.                    */
/* Last changed on 03.21.2001                                            */
/* 05.20.2002: added support for uninstallation                          */

/* get command line parameters */
parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
cache_size        = value("CACHE_SIZE"       , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\HPFS386.IFS', 'c', 'query exists') = '' then exit 9

/* copy files but do not overwrite them if they are already there */
if stream(target'\IBM386FS\HPFS386.IFS', 'c', 'query exists') = '' then do
	'mkdir 'target'\IBM386FS >nul 2>>&1'
	'copy 'inst_dir'\HPFS386.IFS 'target'\IBM386FS\. >> 'product_log
end
if stream(target'\os2\dll\HPFS386.DLL', 'c', 'query exists') = '' then do
	'copy 'inst_dir'\HPFS386.DLL 'target'\os2\dll\. >> 'product_log
end
if stream(target'\os2\system\HFSH.MSG', 'c', 'query exists') = '' then do
	'copy 'inst_dir'\HFSH.MSG 'target'\os2\system\. >> 'product_log
end
if stream(target'\os2\system\HFS.MSG', 'c', 'query exists') = '' then do
	'copy 'inst_dir'\HFS.MSG 'target'\os2\system\. >> 'product_log
end

/* create HPFS386.INI */
inifile = target'\IBM386FS\HPFS386.INI'
if stream(inifile, 'c', 'query exists') = '' then do
	call lineout inifile, '; This file contains the initialization parameters for the 386 HPFS.'
	call lineout inifile, ' '
	call lineout inifile, '[filesystem]'
	call lineout inifile, 'useallmem = Yes'
	call lineout inifile, 'lanroot = 'target'\IBMLAN'
	call lineout inifile, 'cachesize = 'cache_size
	call lineout inifile, ' '
	call lineout inifile, '[lazywriter]'
	call lineout inifile, 'lazy = *: ON'
	call lineout inifile, 'maxage = 5000'
	call lineout inifile, 'bufferidle = 500'
	call lineout inifile, ' '
	call lineout inifile
end

/* change config.sys if needed */
cfgfile = target'\config.sys'
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('HPFS386.IFS', translate(l.q)) > 0 
		then exit /* the driver is already added, leave the config.sys alone */
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* backup config.sys */
'copy 'cfgfile target'\os2\install\config.386' 
'del 'cfgfile
call lineout cfgfile, 'IFS='target'\IBM386FS\HPFS386.IFS /A:*'
do q=1 to l.0
	if pos('HPFS.IFS', translate(l.q)) > 0 then do
		/* rem HPFS driver out */
		call lineout cfgfile, ' '
		call lineout cfgfile, 'REM UpdCD'
		call lineout cfgfile, 'REM UpdCD 'l.q
	end
	else
		call lineout cfgfile, l.q
end
call lineout cfgfile

exit

uninstall:

	/* update config.sys */
	found. = 0
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		if pos('REM UPDCD', translate(l.q)) > 0 & pos('\OS2\HPFS.IFS', translate(l.q)) > 0 then found.ibmifs = 1
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.386 >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('HPFS386.IFS', translate(l.q)) > 0 then iterate
		if pos('REM UPDCD', translate(l.q)) > 0 & pos('\OS2\HPFS.IFS', translate(l.q)) > 0 then l.q = substr(l.q, 11) 
		call lineout cfgfile, l.q
	end
	if found.ibmifs = 0 then call lineout cfgfile, 'IFS='target'\OS2\HPFS.IFS /CACHE:2048 /CRECL:4 /AUTOCHECK:'substr(target, 1, 1)
	call lineout cfgfile

	/* delete files */
	'del 'target'\os2\dll\HPFS386.DLL >> 'product_log
	'del 'target'\os2\system\HFSH.MSG >> 'product_log
	'del 'target'\os2\system\HFS.MSG  >> 'product_log
	call deldir target'\IBM386FS'

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
