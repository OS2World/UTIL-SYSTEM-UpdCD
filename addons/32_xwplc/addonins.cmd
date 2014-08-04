/* XWP installation file                                   */
/*                                                         */
/* Works with WarpIn 1.0.7 or higher only!!!               */
/*                                                         */
/* Place the XWP package here under the name xwp.exe       */
/* Optional: NLS module under the name xwpnls.exe          */
/*                                                         */
/* 05.25.2002: added support for uninstallation            */
/* 07.13.2002: aligned with xwp 0.9.19                     */
/* 05.15.2005: CID install for WPI packages                */
/* 05.28.2005: improved CID installation/uninstallation    */
/* 07.10.2005: NLS package was not fully installed         */
/* 08.14.2006: aligned with XWP 1.0.5                      */

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
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\xwp.exe', 'c', 'query exists') = '' then exit 9

Say
Say 'XWP installation starting. Please wait...'

/* switch to warpin dir */
cdir = directory()
rc   = directory(get_ini_key(warpin path))

/* get package ID's */
call get_package_id 'xwp.exe xwp.wis'

/* create CID file */
call create_cid_file xcd' install xwp.exe REGISTERWPSCLASSES'

/* install files */
Say 'Installing core files. Please wait...'
'@wic -i 'xcd' >> 'product_log' 2>>&1'

/* install nls */
if stream(inst_dir'\xwpnls.exe', 'c', 'query exists') <> '' then do

	/* restart WPS */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	rc = SysINI('USER', 'XWorkplace', 'JustInstalled', 'DELETE:')
	if rc = 0 then do
		Say 'Cannot delete INI key, aborting NLS installation...'
		'@echo Cannot delete INI key, aborting NLS installation... >> 'product_log
		exit 5
	end
	'@'product_drv'\'product_path'\bin\wpsreset.exe -D >> 'product_log' 2>>&1'
	say 'Waiting for WPS to restart...'
	call RxFuncAdd 'SysWaitForShell', 'RexxUtil', 'SysWaitForShell'
	call RxFuncAdd 'SysSleep', 'RexxUtil', 'SysSleep'
	if RxFuncQuery('SysWaitForShell') = 0 then do
		rc = SysWaitForShell('DESKTOPPOPULATED')
	end
	else do
		rc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
		do while rc \= 'ERROR:'
			call SysSleep 2
			rc = SysIni('USER', 'PM_InstallObject', 'ALL:', 'stem')
		end
	end
	call SysSleep 30 /* extra wait */
	
	/* create objects */
	'@call 'product_drv'\'product_path'\install\instl001.cmd >> 'product_log' 2>>&1'

	/* get package ID's */
	call get_package_id 'xwpnls.exe xwpnls.wis'

	/* create CID file */
	call create_cid_file xcd' install xwpnls.exe CREATEWPSOBJECTS'

	/* install */
	Say 'Installing NLS support. Please wait...'
	call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
	'@wic -i 'xcd' >> 'product_log' 2>>&1'

end

/* finish */
'@del 'xcd' >nul 2>>&1'
rc = directory(cdir)
Say 'XWP installation has been finished. Please reboot your system.'
Say

exit

/* uninstall */
uninstall:
	
	Say
	Say 'Uninstalling XWP, please wait...'

	/* switch to warpin dir */
	cdir = directory()
	rc   = directory(get_ini_key(warpin path))

	/* wait for WPS reset */
	call RxFuncAdd SysSleep, RexxUtil, SysSleep
	call SysSleep 10

	/* uninstall nls */
	if stream('xwpnls.wis','c','query exists') <> '' then do
		call get_package_id 'xwpnls.exe xwpnls.wis UNINSTALL'
		call create_cid_file xcd' deinstall xwpnls.exe'
		'@wic -i 'xcd' >> 'product_log' 2>>&1'
		'@del xwpnls.wis >nul 2>>&1'
	end

	/* uninstall */
	rc   = directory(get_ini_key(warpin path))
	call get_package_id 'xwp.exe xwp.wis UNINSTALL'
	call create_cid_file xcd' deinstall xwp.exe'
	'@wic -i 'xcd' >> 'product_log' 2>>&1'
	'@del 'xcd' >nul 2>>&1'
	'@del xwp.wis >nul 2>>&1'

	/* restore dir */
	rc = directory(cdir)	

	/* remove files/dirs left */
	call deldir product_drv'\'product_path

	Say 'Uninstallation has been finished, please reboot your system.'
	Say

return

/* delete dir */
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

/* get package id's */
get_package_id:

	parse arg wpi_file wis_file mode
	p. = '0'
	if mode <> 'UNINSTALL' then 
		'@wic 'inst_dir'\'wpi_file' -X 'wis_file' >> 'product_log' 2>>&1'
	i=1
	do while lines(wis_file) & p.0 < 3 /* install only 1st 3 packages */
		l = linein(wis_file)
		parse value l with pid '=' p.i
		if pid = 'PACKAGEID' | pid = '	PACKAGEID' then do
			p = pos('”', p.i)
			if p > 0 then p.i = left(p.i, p-1) || 'Ã¶' || right(p.i, length(p.i)-p)
			p.i = strip(p.i, 'B', '"')
			p.0 = i
			i=i+1
		end
	end
	call lineout wis_file

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
		call lineout xcd, '    path="'product_drv'\'product_path'"'
		call lineout xcd, '    pckid="'p.i'"/>'
	end
	call lineout xcd, '</archive>'
	if action = 'install' then do
		call lineout xcd, '<var'
		select
			when mode = 'REGISTERWPSCLASSES' then
				call lineout xcd, '    key="REGISTERWPSCLASSES"'
			when mode = 'CREATEWPSOBJECTS' then
				call lineout xcd, '    key="CREATEWPSOBJECTS"'
		end
		call lineout xcd, '    value="YES"/>'
	end
	call lineout xcd, '</warpincid>'
	call lineout xcd

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
