/* Acrobat Reader installation script                                      */
/*                                                                         */
/* Unzip acro2?30.exe in this directory or place the Innotek               */
/* distribution file here under the name of install.exe. If you use        */
/* the Innotek version do not forget to add the Innotek runtime to         */
/* 17_INORT.                                                               */
/*                                                                         */
/* 08.11.2001: added copy of NPPDFOS2.DLL to Netscape\Program\Plugins      */
/* 05.25.2002: added support for uninstallation                            */
/* 06.16.2003: added support for the Innotek reader                        */
/* 03.13.2004: added support for latest (4.05 R4) Innotek reader           */
/* 09.18.2004: removed runtime installation                                */
/* 09.29.2005: aligned with os2mt                                          */
/* 10.01.2005: fix find_key                                                */
/* 03.02.2006: added support for Innotek 5.1 preview                       */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
product_rsp       = value("PRODUCT_RSP"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
NS_DIR            = value("NS_DIR"           , ,"OS2ENVIRONMENT")

/* define other parameters */
dest_dir          = product_drv'\'product_path
ns_plugin_dir     = NS_DIR||'\program\plugins\.'

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' then exit 9

/* install innotek reader */
if stream(inst_dir'\install.exe', 'c', 'query size') > 500000 then do

	/* CID install reader */
	Say
	Say 'Running CID installer...'
	'@'inst_dir'\install.exe /directory='dest_dir' /unattended >> 'product_log

	/* copy NPPDFOS2.DLL to netscape directory */
	if NS_DIR <> '' then do
		Say
		Say 'Copying plug-in to 'ns_plugin_dir
		'@copy 'dest_dir'\nparos2*.dll 'ns_plugin_dir' >> 'product_log
	end

	/* copy NPPDFOS2.DLL to mozilla directory */
	plugins  = find_key('USER Mozilla Plugins')
	if plugins <> '' then do
		Say
		Say 'Copying plug-in to 'plugins
		'@copy 'dest_dir'\nparos2*.dll 'plugins'\. >> 'product_log
	end

end
/* install adobe reader */
else do
	/* create response file */
	'@echo FILE='dest_dir'               >  'product_rsp
	'@echo CFGUPDATE=MANUAL              >> 'product_rsp
	'@echo OVERWRITE=YES                 >> 'product_rsp
	'@echo SAVEBACKUP=NO                 >> 'product_rsp
	'@echo DELETEBACKUP=YES              >> 'product_rsp

	/* CID install */
	inst_dir'\INSTALL /L1:'product_log' /L2:'product_log' /X /R:'product_rsp

	/* copy NPPDFOS2.DLL to netscape directory */
	if NS_DIR <> '' then '@copy 'dest_dir'\browser\nppdfos2.dll 'ns_plugin_dir'\.'

	/* copy NPPDFOS2.DLL to mozilla directory */
	plugins  = find_key('USER Mozilla Plugins')
	if plugins <> '' then '@copy 'dest_dir'\browser\nppdfos2.dll 'plugins'\.'
end

/* ready */
Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	plugins  = find_key('USER Mozilla Plugins')
	if stream(inst_dir'\install.exe', 'c', 'query size') < 500000 then do
		dest_dir = product_drv'\'product_path
		cdir = directory()
		call directory dest_dir
		'uninst.exe'
		call directory cdir
		call deldir dest_dir
		'@del 'NS_DIR'\program\plugins\nppdfos2.dll'
		'@del 'plugins'\nparos2.dll'
	end
	else do
		call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
		call SysDestroyObject '<WPS_SHELLLINK_DESKTOP_Acrobat Reader 4>'
		call deldir dest_dir
		'@del 'NS_DIR'\program\plugins\nparos2.dll'
		'@del 'plugins'\nparos2.dll'
	end

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
