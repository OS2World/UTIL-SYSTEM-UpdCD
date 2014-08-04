/* InnoTek Flash 5 release 5 (or higher) installation                        */
/*                                                                           */
/* Flash5: place the following file here: flashos2.exe                       */
/* Flash7: unzip flash7?.zip in this directory                               */
/*                                                                           */
/* Be sure the version you are using is CID enabled (type flashos2 /version) */
/* Please not: older versions are not supported any more by this script      */
/* If you still try them your installation will hang...                      */
/* Do not forget to register at http://www.innotek.de !!!                    */
/*                                                                           */
/* 02.15.2002: changed to work with Flash 5                                  */
/* 05.24.2002: added support for uninstallation                              */
/* 06.08.2002: fixed hang when plugins dir were missing                      */
/* 08.23.2002: added path un/installation option                             */
/* 11.15.2002: changed code to support CID installation                      */
/* 09.29.2005: aligned with os2mt                                            */
/* 10.01.2005: fix for find_key                                              */
/* 10.30.2005: support for Flash 7                                           */
/* 11.07.2005: MOZ_PLUGIN_PATH overrides plugin PATH                         */
/* 11.19.2005: Flash 7 will install to util\flash (just like version 5 does) */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
NS_DIR            = value("NS_DIR"           , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\flashos2.exe', 'c', 'query exists') = '' & stream(inst_dir'\flashinst.exe', 'c', 'query exists') = '' then exit 9

/* install */
Say
Say 'Installing Flash...'
plugindir.  = ''
plugindir.1 = find_key('USER Netscap 4.6')'\program\plugins'
plugindir.2 = find_key('USER Mozilla Plugins')
tempdir = strip(value("MOZ_PLUGIN_PATH",,"OS2ENVIRONMENT"),'T','\')
if tempdir <> '' then plugindir.2 = tempdir /* override */
plugindir.0 = 2
pluginsdir  = ''
do i=1 to plugindir.0
	if length(plugindir.i) > 0 then pluginsdir = pluginsdir';'plugindir.i
end
pluginsdir = substr(pluginsdir, 2)
if length(pluginsdir) > 0 then do

	product_dir = product_drv'\'product_path
	cdir = directory()

	/* Flash 5 */
	if stream(inst_dir'\flashos2.exe', 'c', 'query exists') <> '' then do
		'@'inst_dir'\flashos2.exe /d='product_dir' /update=yes /wps=yes /browsers='pluginsdir' >> 'product_log' 2>>&1'
	end

	/* Flash 7 */
	else do
		'@copy 'inst_dir'\*.exe 'product_dir' >> 'product_log' 2>>&1' 
		'@copy 'inst_dir'\*.dll 'product_dir' >> 'product_log' 2>>&1' 
		call directory product_dir
		'@flashinst.exe >> 'product_log' 2>>&1' 
		call deldir 'Common Files'
		call deldir 'Win'
		'@del flashinst.exe >> 'product_log' 2>>&1'
		do i=1 to plugindir.0
			'@copy 'inst_dir'\NPSWF2.dll 'plugindir.i' >> 'product_log' 2>>&1' 
		end
		call directory cdir
	end
end

/* ready */
Say
Say 'Completed.'

exit

/* create object */
CreateObject: procedure expose product_log
    Parse Arg Class, Title, Location, Setup, Collision
    'echo Registering Object ['Title'] >> 'product_log
    rc = SysCreateObject( Class, Title, Location, Setup, Collision )
    If rc <> 1 Then
        'echo Registering Object ['Title' ^| 'Class'] in ['Location'] did not work >> 'product_log
return rc

/* uninstall mode */
uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<INNOTEK_FLASH>"

	/* delete from ini */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	rc = SysIni('USER', 'InnoTek_Flash', 'DELETE:')

	/* del files */
	'call 'source'\updcd\bin\unlock.exe 'NS_DIR'\Program\PlugIns\npswf2.dll'
	'call 'source'\updcd\bin\unlock.exe 'product_drv'\'product_path'\npswf2.exe'
	'call 'source'\updcd\bin\unlock.exe 'product_drv'\'product_path'\flash5.exe'
	'call 'source'\updcd\bin\unlock.exe 'product_drv'\'product_path'\nsIFlash.xpt'
	'del 'NS_DIR'\Program\PlugIns\npswf2.dll'
	'del 'product_drv'\'product_path'\npswf2.dll'
	'del 'product_drv'\'product_path'\flash5.exe'
	'del 'product_drv'\'product_path'\nsIFlash.xpt'
	'del 'product_drv'\'product_path'\readme.txt'
	'del 'product_drv'\'product_path'\license.txt'
	'del 'product_drv'\'product_path'\flashdel.cmd'
	'rmdir 'product_drv'\'product_path

return

/* find out value key belonging to app stored in ini */
find_key: procedure

	parse arg ini app key
	call rxfuncadd sysini, rexxutil, sysini
	call SysIni ini, 'All:', 'Apps.'
	if Result \= 'ERROR:' then
		do i = 1 to Apps.0
			If left(apps.i,7) = app then do 
				call SysIni ini, Apps.i, 'All:', 'Keys'
				if Result \= 'ERROR:' then
					do j=1 to Keys.0
						if Keys.j = key then do
							val = SysIni(ini, Apps.i, Keys.j)
							return strip(val, 'T', x2c('00'))
						end
					end
			end
		end

return ''

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
