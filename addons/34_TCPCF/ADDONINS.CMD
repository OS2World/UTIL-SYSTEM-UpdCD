/* TcpConfig installation file                                    */
/*                                                                */
/* Works with WarpIn 1.0.7 or higher only!!!                      */
/*                                                                */
/* Place the TCPConfig WPI package here under the name tcpcfg.wpi */
/* 30.01.2005: Created                                            */
/* 13.05.2005: CID install for WPI packages                       */
/* 05.28.2005: improved CID installation/uninstallation           */

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

/* do nothing if package does not exist */
if stream(inst_dir'\tcpcfg.wpi', 'c', 'query exists') = '' & stream(inst_dir'\tcpconfig.wpi', 'c', 'query exists') = '' then exit 9

Say
Say 'TCPConfig installation starting. Please wait...'
if stream(inst_dir'\tcpconfig.wpi', 'c', 'query exists') <> '' then do
	'@copy 'inst_dir'\tcpconfig.wpi 'inst_dir'\tcpcfg.wpi >> 'product_log
	'@del 'inst_dir'\tcpconfig.wpi'
end

/* switch to warpin dir */
cdir = directory()
rc   = directory(get_ini_key(warpin path))

/* get package ID's */
call get_package_id 'tcpcfg.wpi tcpcfg.wis'

/* check */
if p.0 > 1 then '@echo Warning! There is more than 1 packag in this WPI (tcpcfg.wpi) file!!! >> 'product_log

/* create CID file */
call create_cid_file xcd' install tcpcfg.wpi CREATEOBJECTS'

/* install */
Say 'Installing files. Please wait...'
'@wic -i 'xcd' >> 'product_log' 2>>&1'

/* finish */
'@del 'xcd' >nul 2>>&1'
rc = directory(cdir)

Say 'TCPConfig has been installed.'
Say

exit

uninstall:

	Say
	Say 'Uninstalling TCPConfig, please wait...'

	/* change to warpin dir */
	cdir = directory()
	rc   = directory(get_ini_key(warpin path))

	/* delete some files */
	'@del 'product_drv'\'product_path'\TCPCFG.INI 1>nul 2>nul'

	/* uninstall */
	call get_package_id 'tcpcfg.wpi tcpcfg.wis UNINSTALL'
	call create_cid_file xcd' deinstall tcpcfg.wpi'
	'@wic -i 'xcd' >> 'product_log' 2>>&1'
	'@del 'xcd' >nul 2>>&1'
	'@del tcpcfg.wis >nul 2>>&1'

	/* restore dir */
	rc = directory(cdir)

	Say 'Uninstallation has been finished.'
	Say

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
