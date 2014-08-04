/* ODIN installation script                                        */
/*                                                                 */
/* Works with WarpIn 1.0.7 or higher only if you use WPI distro!   */
/*                                                                 */
/* Place the ODIN package here under the name odin.wpi or odin.zip */
/* Optional: place the Warp 3 fix here under the name warp3fix.zip */
/* Optional: unzip the content of odinapp.zip here                 */
/* Optional: place os2krnl.sym here                                */
/* Optional: place odingui as gui.zip here                         */
/*                                                                 */
/* 01.11.2002: made variables local                                */
/* 02.16.2002: added support for zip distribution                  */
/* 05.25.2002: added support for uninstallation                    */
/* 10.17.2004: added support for unofficial warp3 fix available in */
/*             the updcd yahoo group file section                  */
/* 02.21.2005: added support for odinapp.zip                       */
/* 02.26.2005: improved uninstallation                             */
/* 05.12.2005: CID install for WPI packages                        */
/* 05.28.2005: improved CID installation/uninstallation            */
/* 09.30.2005: aligned with os2mt                                  */
/* 12.04.2005: added support for odingui                           */
/* 12.10.2005: dont install win32k.sys when os2krnl.sym is missing */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")

/* set warpin environment */
call value "WARPIN_IFEXISTINGOLDER","OVERWRITE","OS2ENVIRONMENT"
call value "WARPIN_IFEXISTINGNEWER","SKIP",     "OS2ENVIRONMENT"
call value "WARPIN_IFSAMEDATE"     ,"SKIP",     "OS2ENVIRONMENT"
xcd = 'temp.xcd'

/* check if we are in uninstall mode */
dest_dir = product_drv'\'product_path
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\odin.wpi', 'c', 'query exists') = '' & stream(inst_dir'\odin.zip', 'c', 'query exists') = '' then exit 9

Say
Say 'Odin installation starting. Please wait...'

/* install optional warp3 fix */
if stream(inst_dir'\warp3fix.zip', 'c', 'query exists') <> '' then do
	/* do not install it on warp4 or higher */
	if stream(target'\os2\system\REGCONV.EXE', 'c', 'query exists') = '' then do
		Say 'Installing Warp3 fixes. Please wait...'
		'@unzip -oC 'inst_dir'\warp3fix.zip *.dll -d 'target'\os2\dll\. >> 'product_log' 2>>&1'
		'@unzip -oC 'inst_dir'\warp3fix.zip *.sym -d 'target'\os2\dll\. >> 'product_log' 2>>&1'
		'@unzip -oC 'inst_dir'\warp3fix.zip *.exe -d 'target'\os2\.     >> 'product_log' 2>>&1'
	end
end

/* do nothing if package does not exist */
if stream(inst_dir'\odin.wpi', 'c', 'query exists') <> '' then call install_wpi
else if stream(inst_dir'\odin.zip', 'c', 'query exists') <> '' then call install_zip

Say 'Installating optional packages. Please wait...'

/* copy optional sym file */
if stream(inst_dir'\os2krnl.sym', 'c', 'query exists') <> '' then do
	'@copy 'inst_dir'\os2krnl.sym 'target'\. >> 'product_log' 2>>&1'
end

/* install optional odinapp */
if stream(inst_dir'\setup.exe', 'c', 'query exists') <> '' then do
	'@'dest_dir'\system32\pe.exe 'inst_dir'\setup.exe >> 'product_log' 2>>&1'
end

/* install optional odigui */
if stream(inst_dir'\gui.zip', 'c', 'query exists') <> '' then do
	'@unzip -o 'inst_dir'\gui.zip -d 'dest_dir' >> 'product_log' 2>>&1'
	cdir = directory()
	call directory dest_dir
	'@call setup.cmd >> 'product_log' 2>>&1'
	call directory cdir
end

Say 'Odin has been installed. Please reboot your system.'
Say

exit

/* install wpi distribution */
install_wpi: 

	/* switch to warpin dir */
	cdir = directory()
	rc   = directory(get_ini_key(warpin path))

	/* get package ID's */
	call get_package_id 'odin.wpi odin.wis'

	/* check */
	if p.0 > 3 then '@echo Warning! There are more than 3 packages in this (odin.wpi) WPI file!!! >> 'product_log

	/* create CID file */
	call create_cid_file xcd' install odin.wpi CREATEOBJECTSCONFIGSYS'

	/* install */
	Say 'Installing files. Please wait...'
	'@wic -i 'xcd' >> 'product_log' 2>>&1'
	'@del 'xcd' >nul 2>>&1'

	/* finish */
	rc = directory(cdir)

	/* make uninstall flag */
	'@echo WPI BASE - DO NOT DELETE! > 'dest_dir'\odininst.txt'

return

/* install zip distribution */
install_zip:

	/* unzip files */
	Say 'Installing files. Please wait...'
	'@unzip -o 'inst_dir'\odin.zip -d 'dest_dir' >> 'product_log' 2>>&1'

	/* create objects */
	call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
	call SysCreateObject 'WPFolder',  'Odin',                                '<WP_DESKTOP>', 'OBJECTID=<ODINFOLDER>;','R'
	call SysCreateObject 'WPProgram', 'Readme',                              '<ODINFOLDER>', 'EXENAME=E.EXE;PARAMETERS='dest_dir'\Readme.txt;','R'
	call SysCreateObject 'WPProgram', 'ChangeLog',                           '<ODINFOLDER>', 'EXENAME=E.EXE;PARAMETERS='dest_dir'\ChangeLog;','R'
	call SysCreateObject 'WPProgram', 'License',                             '<ODINFOLDER>', 'EXENAME=E.EXE;PARAMETERS='dest_dir'\LICENSE.TXT;','R'
	call SysCreateObject 'WPProgram', 'WGSS50 License',                      '<ODINFOLDER>', 'EXENAME=E.EXE;PARAMETERS='dest_dir'\WGSS50.lic;','R'
	call SysCreateObject 'WPProgram', 'Registry Editor',                     '<ODINFOLDER>', 'EXENAME=REGEDIT2.EXE;','R'
	call SysCreateObject 'WPProgram', 'Report Odin Bugs',                    '<ODINFOLDER>', 'EXENAME='dest_dir'\system32\ODINBUG.EXE;ASSOCTYPE=Odin-Logfiles;ASSOCFILTER=odin32_?.log;OBJECTID=<Report_Odin_Bugs>;','R'
	call SysCreateObject 'WPProgram', 'Report Odin Bugs Readme',             '<ODINFOLDER>', 'EXENAME=E.EXE;PARAMETERS='dest_dir'\README.ODINBUG;TITLE=Report Odin Bugs^ReadMe;OBJECTID=<Report_Odin_Bugs_ReadMe>;','R'
	call SysCreateObject 'WPProgram', 'Odin Tool',                           '<ODINFOLDER>', 'EXENAME='dest_dir'\ODINTOOL.EXE;TITLE=Odin Tool;OBJECTID=<Odin_Tool>;','R'
	call SysCreateObject 'WPProgram', 'Odin Tool Readme',                    '<ODINFOLDER>', 'EXENAME=E.EXE;PARAMETERS='dest_dir'\README.ODINTOOL;TITLE=Odin Tool^ReadMe;OBJECTID=<OdinTool readme>;','R'
	call SysCreateObject 'WPProgram', 'Report Odin Bugs Manual',             '<ODINFOLDER>', 'EXENAME=VIEW.EXE;PARAMETERS='dest_dir'\ODINBUG.HLP;TITLE=Report Odin Bugs^Manual;OBJECTID=<Report_Odin_Bugs_Help>;','R'
	call SysCreateObject 'WPProgram', 'Odin Users Manual',                  '<ODINFOLDER>', 'EXENAME=VIEW.EXE;PARAMETERS='dest_dir'\ODINUSER.INF;TITLE=Odin Users^Manual;OBJECTID=<Odin_Users_Manual>;','R'
	call SysCreateObject 'WPUrl',     'Subscribe to odinusers mailing list', '<ODINFOLDER>', 'TITLE=Subscribe to^odinusers mailing list;URL=http://groups.yahoo.com/group/odinusers/join;OBJECTID=<Subscribe_odinusers@yahoogroups>;','R'

	/* update config.sys */
	cfgfile = target'\config.sys'
	q = 1
	found. = 0
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		/* libpath */
		if pos('LIBPATH=', translate(l.q)) > 0 & pos(dest_dir, translate(l.q)) = 0 then do
			lpos = length(l.q)
			if substr(l.q, lpos) = ';' then l.q = l.q || dest_dir';'
			else l.q = l.q || ';' || dest_dir';'
		end
		/* path */
		if pos('SET PATH=', translate(l.q)) > 0 & pos(dest_dir, translate(l.q)) = 0 then do
			lpos = length(l.q)
			if substr(l.q, lpos) = ';' then l.q = l.q || dest_dir';'
			else l.q = l.q || ';' || dest_dir';'
		end
		/* check */
		l = translate(l.q)
		if pos('WIN32K.SYS', l) > 0 & substr(l, 1, 3) <> 'REM' then found.sys = 1
		q=q+1
	end
	rc = lineout(cfgfile)
	l.0 = q-1
	'@copy 'cfgfile target'\os2\install\config.odn >> 'product_log 
	'@del 'cfgfile' >> 'product_log 
	if found.sys = 0 then do
		call lineout cfgfile, 'REM UpdCD'
		if stream(target'\os2krnl.sym', 'C', 'Query Exists') = '' then
			call lineout cfgfile, 'REM DEVICE='dest_dir'\SYSTEM32\Win32k.sys -pe:pe -Dllfixes:D'
		else
			call lineout cfgfile, 'DEVICE='dest_dir'\SYSTEM32\Win32k.sys -pe:pe -Dllfixes:D'
	end
	do q=1 to l.0
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

	/* run odininst */
	cdir = directory()
	call directory dest_dir'\system32'
	Say 'Activating Odin. Please wait...'
	'@odininst.exe >> 'product_log
	call directory cdir

	/* make uninstall flag */
	'@echo ZIP BASE - DO NOT DELETE! > 'dest_dir'\odininst.txt'

return

/* get apps key value from OS2.INI */
get_ini_key: procedure

	parse upper arg apps key

	call rxfuncadd sysini, rexxutil, sysini
	call SysIni 'USER', 'All:', 'Apps.'
	do i = 1 to Apps.0	
		if translate(apps.i) = apps then do
			call SysIni 'USER', Apps.i, 'All:', 'Keys'
 	   	do j=1 to Keys.0
 	   		if translate(Keys.j) = key then do
					val = SysIni('USER', Apps.i, Keys.j)
					return val
				end
			end
		end
	end

return ''

uninstall:

	Say
	Say 'Uninstalling Odin, please wait...'

	/* check */
	l = linein(dest_dir'\odininst.txt')
	call lineout dest_dir'\odininst.txt'

	if l = 'WPI BASE - DO NOT DELETE!' then do

		/* change to warpin dir */
		cdir = directory()
		rc   = directory(get_ini_key(warpin path))

		/* delete some files */
		'@del 'dest_dir'\odininst.txt >nul 2>>&1'
		'@del 'dest_dir'\odin.ini     >nul 2>>&1'

		/* uninstall */
		call get_package_id 'odin.wpi odin.wis UNINSTALL'
		call create_cid_file xcd' deinstall odin.wpi'
		'@wic -i 'xcd' >> 'product_log' 2>>&1'
		'@del 'xcd' >nul 2>>&1'
		'@del odin.wis >nul 2>>&1'

		/* restore dir */
		rc = directory(cdir)

		/* remove files/dirs left */	
		call deldir dest_dir

	end
	else do /* ZIP BASE */

		/* delete objects */
		call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
		call SysDestroyObject '<ODINFOLDER>'

		/* update config.sys */
		cfgfile = target'\config.sys'
		q = 1
		do while lines(cfgfile)
			l.q = linein(cfgfile)
			q=q+1
		end
		call lineout cfgfile
		l.0=q-1
		'@copy 'cfgfile target'\os2\install\config.odn >> 'product_log 
		'@del 'cfgfile' >> 'product_log 
		do q=1 to l.0
			if pos('WIN32K.SYS', translate(l.q)) > 0 then iterate
			call lineout cfgfile, l.q
		end
		call lineout cfgfile
		dest_dir = translate(product_drv'\'product_path)
		call remove_from_path cfgfile dest_dir' LIBPATH='
		call remove_from_path cfgfile dest_dir' SET PATH='

		/* delete files */
		call deldir dest_dir
	end

	Say 'Uninstallation has been finished, please reboot your system.'
	Say

return

DelDir: procedure

	parse upper arg Directory
	DirSpec = Directory'\*'

	/* delete subdirectories */
	call RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
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

/* get package id's */
get_package_id:

	parse arg wpi_file wis_file mode
	p. = '0'
	if mode <> 'UNINSTALL' then 
		'@wic 'inst_dir'\'wpi_file' -X 'wis_file' >> 'product_log' 2>>&1'
	i=1
	do while lines(wis_file)
		l = linein(wis_file)
		parse value l with pid '=' p.i
		if pid = 'PACKAGEID' | pid = '	PACKAGEID' then do
			p.i = strip(p.i, 'B', '"')
			i=i+1
		end
	end
	call lineout wis_file
	p.0 = i-1

return

/* create CID file */
create_cid_file: procedure expose inst_dir product_drv product_path p.

	parse arg xcd action wpi_file mode

	'@del 'xcd' >nul 2>>&1'
	call lineout xcd, '<?xml version="1.0" encoding="UTF-8"?>'
	call lineout xcd, '<!DOCTYPE warpincid SYSTEM "warpincid.dtd">'
	call lineout xcd, '<warpincid>'
	call lineout xcd, '<archive'
	call lineout xcd, '    filename="'inst_dir'\'wpi_file'">'
	do i=1 to p.0
		call lineout xcd, '<job'
		call lineout xcd, '    action="'action'"'
		if i > 1 then
			call lineout xcd, '    path="'product_drv'\'product_path'\system32"'
		else
			call lineout xcd, '    path="'product_drv'\'product_path'"'
		call lineout xcd, '    pckid="'p.i'"/>'
	end
	call lineout xcd, '</archive>'
	if action = 'install' then do
		if pos('REGISTERWPSCLASSES', mode) > 0 then do
			call lineout xcd, '<var'
			call lineout xcd, '    key="REGISTERWPSCLASSES"'
			call lineout xcd, '    value="YES"/>'
		end
		if pos('CREATEWPSOBJECTS', mode) > 0 then do
			call lineout xcd, '<var'
			call lineout xcd, '    key="CREATEWPSOBJECTS"'
			call lineout xcd, '    value="YES"/>'
		end
		if pos('CONFIGSYS', mode) > 0 then do
			call lineout xcd, '<var'
			call lineout xcd, '    key="CONFIGSYS"'
			call lineout xcd, '    value="YES"/>'
		end
	end
	call lineout xcd, '</warpincid>'
	call lineout xcd

return
