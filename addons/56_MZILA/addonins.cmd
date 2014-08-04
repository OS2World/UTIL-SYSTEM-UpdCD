/* Installation of Seamonkey 1.0/FireFox 1.0 or higher for OS/2         */
/*                                                                      */
/* Place the Seamonkey distribution zip under the name mozilla.zip, or  */
/* place the Firefox distribution zip under the name firefox.zip, or    */
/* place the Seamonkey distribution exe under the name mozilla.exe here */
/*                                                                      */
/* Place the Innotek GCC runtime under the name libc.exe here           */
/* Place the InnoTek Plug-In Wrapper ipluginw.xpi here                  */
/*                                                                      */
/* Optionally, you may place the Innotek font engine here under the     */
/* name ft2lib.exe                                                      */
/*                                                                      */
/* Optionally, you may place the Thunderbird distribution zip under the */
/* name thunderb.zip here                                               */
/*                                                                      */
/* 07.13.2002: fixed problem with changing back to previous dir         */
/* 12.07.2002: added support for exe installation                       */
/* 08.17.2003: added object creation for zip version                    */
/* 08.19.2003: added \mozilla to icon creation path                     */
/* 08.22.2003: improved plugin installation and uninstallation          */
/* 10.21.2003: added support for Mozilla 1.5 (GCC version)              */
/* 11.02.2003: added support for Innotek font engine                    */
/* 11.23.2003: font engine installation did not work                    */
/* 12.03.2003: switched echo back on after fontlib install              */
/* 28.01.2004: fix for fontlib rc2                                      */
/* 29.01.2004: support for fontlib rc3 or higher                        */
/* 13.03.2004: GCC DLL's were not unzipped when using Mz EXE distrib    */
/* 04.04.2004: uninstalling without installed mozilla deletes all files */
/* 22.08.2004: updated to support (only) version 1.7 or higher          */
/* 18.09.2004: current dir was not restored upon exit                   */
/* 27.09.2004: set default browser and association during zip install   */
/* 02.10.2004: make mozilla the first appl associated with objects      */
/* 10.10.2004: added flash plug-in installation                         */
/* 18.10.2004: support for firefox                                      */
/* 19.03.2005: support for thunderbird                                  */
/* 29.09.2005: aligned with os2mt                                       */
/* 01.10.2005: plugin wrapper was't installed correctly icw mozilla.exe */
/* 05.11.2005: cosmetic changes to avoid echoing to the screen          */
/* 07.11.2005: MOZ_PLUGIN_PATH overrides plugin PATH, support Flash 7   */
/* 10.11.2005: updated to work with ipluginw.xpi                        */
/* 04.12.2005: added cleanup of previous installation                   */
/* 02.26.2006: replaced mozilla support with seamonkey support          */
/* 03.05.2006: fix: mozilla directory was not created                   */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
product_version   = value("PRODUCT_VERSION"  , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
NS_DIR            = value("NS_DIR"           , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

if stream(inst_dir'\mozilla.zip', 'c', 'query exists') = '',
 & stream(inst_dir'\mozilla.exe', 'c', 'query exists') = '',
 & stream(inst_dir'\firefox.zip', 'c', 'query exists') = '',
 then exit 9

/* delete old version */
call RxFuncAdd 'SysFileTree',   'RexxUtil', 'SysFileTree'
call RxFuncAdd 'SysFileDelete', 'RexxUtil', 'SysFileDelete'
old_dir = find_key('USER Mozilla Install Directory')
if old_dir <> '' then do
	Say
	Say 'Deleting old version (preserving profile)...'
	/* delete subdirs */
	call SysFileTree old_dir'\*', 'tmp.', 'DO'
	do i=1 to tmp.0
		call SysFileTree tmp.i'\*profiles*', 'temp.', 'DSO'
		if temp.0 = 0 then do
			Say 'Deleting 'tmp.i
			call deldir tmp.i
		end
	end
	/* delete files from root */
	call SysFileTree old_dir'\*', 'tmp.', 'FO', '*****', '-*---'
	do i=1 to tmp.0
		'@call 'source'\updcd\bin\unlock.exe "'tmp.i'" >nul 2>>&1'
		call SysFileDelete tmp.i
	end
end

/* install GCC runtime */
if stream(inst_dir'\libc.exe', 'c', 'query exists') <> '' then do
	Say
	Say 'Installing GCC run-time...'
	'@'inst_dir'\libc.exe /unattended >> 'product_log' 2>>&1'
end

/* determine browser */
if stream(inst_dir'\mozilla.zip', 'c', 'query exists') <> '' then 
	browser = 'Mozilla'
else 
	browser = 'FireFox'

/* define install dir */
dest_dir = product_drv'\'product_path
dir 	 = dest_dir'\'browser

if stream(inst_dir'\'browser'.zip', 'c', 'query exists') <> '' then do

	/* unzip mozilla/firefox files */
	Say
	Say 'Unpacking files...'
	'@unzip -o 'inst_dir'\'browser'.zip -d 'dest_dir' >> 'product_log' 2>>&1'
	
	/* rename dir if we have seamonkey */
	tmp.1 = product_drv'\$tmp$.txt'
	'@unzip -l 'inst_dir'\'browser'.zip > 'tmp.1
	seamonkey = 0
	do while lines(tmp.1)
		if pos('SEAMONKEY.EXE', translate(linein(tmp.1))) > 0 then do
			seamonkey = 1
			leave
		end
	end
	call lineout tmp.1
	'@del 'tmp.1' >nul 2>>&1'
	if seamonkey = 1 then do
		/* move seamonkey to mozilla */
		'@mkdir 'dest_dir'\mozilla >nul 2>>&1'
		'@xcopy 'dest_dir'\seamonkey\*             'dest_dir'\mozilla\. /H/O/T/S/E/R/V >> 'product_log' 2>>&1'
		'@copy  'dest_dir'\seamonkey\seamonkey.exe 'dest_dir'\mozilla\mozilla.exe      >> 'product_log' 2>>&1'
		'@del   'dest_dir'\mozilla\seamonkey.exe                                       >> 'product_log' 2>>&1'
		/* delete seamonkey */
		call SysFileTree dest_dir'\seamonkey\*', 'tmp.', 'DO'
		do i=1 to tmp.0
			call SysFileTree tmp.i'\*profiles*', 'temp.', 'DSO'
			if temp.0 = 0 then call deldir tmp.i
		end
		call SysFileTree dest_dir'\seamonkey\*', 'tmp.', 'FO', '*****', '-*---'
		do i=1 to tmp.0
			'@call 'source'\updcd\bin\unlock.exe "'tmp.i'" >nul 2>>&1'
			call SysFileDelete tmp.i
		end
		'@rmdir 'dest_dir'\seamonkey >>'product_log' 2>>&1'
	end

	/* unzip thunderbird */
	if stream(inst_dir'\thunderb.zip', 'c', 'query exists') <> '' then do
		install_thunderbird = 1
		'@unzip -o 'inst_dir'\thunderb.zip -d 'dest_dir' >> 'product_log' 2>>&1'
	end

	/* create objects */
	if seamonkey = 1 then browsername = 'Seamonkey'
	else browsername = browser
	Say 
	Say 'Creating objects...'
	call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
	call SysCreateObject 'WPFolder', 'Mozilla.org','<WP_DESKTOP>','OBJECTID=<MOZILLAFLDR>;'||'ALWAYSSORT=YES;','R'
	call SysCreateObject 'WPProgram',browsername,'<MOZILLAFLDR>','ASSOCFILTER=*.htm,*.html;ASSOCTYPE=HTML,text/html;EXENAME='||dir||'\'browser'.EXE;'||'STARTUPDIR='||dir||';'||'OBJECTID=<MOZILLAEXE>','R'
	call SysCreateObject 'WPProgram',browsername'^JavaScript^Console','<MOZILLAFLDR>','EXENAME='||dir||'\'browser'.EXE;'||'PARAMETERS=-jsconsole;'||'STARTUPDIR='||dir||';'||'OBJECTID=<MOZILLAJAVASCRIPTCONSOLE>','R'
	call SysCreateObject 'WPProgram',browsername'^Profile Manager','<MOZILLAFLDR>','EXENAME='||dir||'\'browser'.EXE;'||'PARAMETERS=-ProfileManager;'||'STARTUPDIR='||dir||';'||'OBJECTID=<MOZILLAPROFMANAGER>','R'
	call RxFuncAdd 'SysCreateShadow', 'RexxUtil', 'SysCreateShadow'
	call SysCreateShadow dir'\README.TXT','<MOZILLAFLDR>'
	call SysCreateShadow dir'\LICENSE',   '<MOZILLAFLDR>'

	if browser = 'Mozilla' then do
		call SysCreateObject 'WPProgram',browsername'^Mail and News','<MOZILLAFLDR>','EXENAME='||dir||'\'browser'.EXE;'||'PARAMETERS=-mail;'||'STARTUPDIR='||dir||';'||'OBJECTID=<MOZILLAMAIL>','R'
		call SysCreateObject 'WPProgram',browsername'^Chat','<MOZILLAFLDR>','EXENAME='||dir||'\'browser'.EXE;'||'PARAMETERS=-chat;'||'STARTUPDIR='||dir||';'||'OBJECTID=<MOZILLACHAT>','R'
		call SysCreateObject 'WPProgram',browsername'^Composer','<MOZILLAFLDR>','EXENAME='||dir||'\'browser'.EXE;'||'PARAMETERS=-edit;'||'STARTUPDIR='||dir||';'||'OBJECTID=<MOZILLACOMPOSER>','R'
		call SysCreateObject 'WPProgram',browsername'^Address Book','<MOZILLAFLDR>','EXENAME='||dir||'\'browser'.EXE;'||'PARAMETERS=-addressbook;'||'STARTUPDIR='||dir||';'||'OBJECTID=<MOZILLAADDRESSBOOK>','R'
	end

	if install_thunderbird = 1 then do
		call SysCreateObject 'WPProgram','Thunderbird','<MOZILLAFLDR>','EXENAME='||dest_dir||'\thunderbird\thunderbird.EXE;OBJECTID=<MOZILLAMAIL>','R'
		call SysCreateShadow dest_dir'\thunderbird\README.TXT','<MOZILLAFLDR>'
	end

	/* store things in ini */
	Say
	Say 'Updating INI files...'
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	call SysIni 'USER', 'Mozilla 'product_version' (en)', 'Install Directory',    dest_dir'\'browser
	call SysIni 'USER', 'Mozilla 'product_version' (en)', 'Uninstall Log Folder', dest_dir'\'browser'\Uninstall'
	call SysIni 'USER', 'Mozilla 'product_version' (en)', 'Plugins',              dest_dir'\'browser'\Plugins'
	call SysIni 'USER', 'Mozilla 'product_version' (en)', 'Components',           dest_dir'\'browser'\Components'
	call SysIni 'USER', 'Mozilla 'product_version' (en)', 'PathToExe',            dest_dir'\'browser'\'browser'.exe'

	/* make it the default browser and associate HTML files with it */
	call SysIni 'USER', 'WPURLDEFAULTSETTINGS', 'DefaultBrowserExe', dest_dir'\'browser'\'browser'.exe'	
	call SysIni 'USER', 'WPURLDEFAULTSETTINGS', 'DefaultWorkingDir', dest_dir'\'browser	
	call reorder('PMWP_ASSOC_TYPE HTML')
	call reorder('PMWP_ASSOC_TYPE text/html')
	call reorder('PMWP_ASSOC_FILTER *.HTML')
	call reorder('PMWP_ASSOC_FILTER *.HTM')
	call SysCreateObject 'WPUrl','Temporary URL','<WP_NOWHERE>','OBJECTID=<MOZTEMPCONVERSIONURL>;DEFAULTBROWSER='dest_dir'\'browser'\'browser'.exe;DEFAULTWORKINGDIR='dest_dir'\'browser,'R'
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject 'OBJECTID=<MOZTEMPCONVERSIONURL>'

end
else do /* manual install */

	/* start installer */
	'@'inst_dir'\mozilla.exe'
	dir = find_key('USER Mozilla Install Directory')

end

/* install font engine */
if stream(inst_dir'\ft2lib.exe', 'c', 'query exists') <> '' then do
	Say
	Say 'Installing font engine...'
	'@'inst_dir'\ft2lib.exe /unattended >> 'product_log' 2>>&1'
	if seamonkey = 1 then do
		cfg = target'\config.sys'
		found_ftlib = 0
		do while lines(cfg)
			if pos('SET MOZILLA_USE_EXTENDED_FT2LIB=T', translate(linein(cfg))) > 0 then found_ftlib = 1
		end
		call lineout cfg
		if found_ftlib = 0 then '@echo SET MOZILLA_USE_EXTENDED_FT2LIB=T >> 'cfg
	end
end

/* install java plug-in */
cur_dir = directory()
plugins  = find_key('USER Mozilla Plugins')
plugins2 = strip(value("MOZ_PLUGIN_PATH",,"OS2ENVIRONMENT"),'T','\')
if plugins2 <> '' then plugins = plugins2 /* override */
call RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
call SysFileTree target'\mzplugin.exe', 'tmp.', 'FSO'
if tmp.0 > 0 then do
	Say 
	Say 'Installing Java plug-in from 'tmp.1
	'@echo Found Java 1.3 plug-in in directory: 'tmp.1' >> 'product_log
	mozdir = substr(tmp.1, 1, lastpos('\', tmp.1)-1)
	cdir = directory(mozdir)
	'@'tmp.1' -o >> 'product_log' 2>>&1'
	'@echo JAVA131MZFiles.Selection=1 > mzuser.rsp'
	'@echo JAVA131MZFiles.MZDRV='dir' >> mzuser.rsp'
	cmd_file = 'insmzplg.cmd'
	l = linein(cmd_file)
	call lineout cmd_file
	parse var l w1 w2 w3 w4 rest
	w4 = '/s:'mozdir
	w3 = '/b:'target
	'@echo 'w1 w2 w3 w4 rest' > 'cmd_file
	'@call 'cmd_file ' >> 'product_log' 2>>&1'
	if stream('npoji6.dll','c','querty exists') <> '' then '@copy npoji6.dll 'plugins'\. >> 'product_log' 2>>&1'
	call directory cur_dir
end

/* install plug-in wrapper */
if stream(inst_dir'\ipluginw.xpi', 'c', 'query exists') <> '' then do
	Say
	Say 'Installing plug-in wrapper...'
	'@unzip -oj 'inst_dir'\ipluginw.xpi components/ipluginw.dll -d 'dir'\components\. >> 'product_log' 2>>&1'
	if stream(dir'\components\compreg.dat', 'c', 'query exists') <> '' then do
		Say 'Deleting compreg.dat...'
		'@del 'dir'\components\compreg.dat >> 'product_log' 2>>&1'
	end
end

/* install flash plug-in */
if stream(inst_dir'\..\42_flos2\flashos2.exe', 'c', 'query exists') <> '' | stream(inst_dir'\..\42_flos2\flashinst.exe', 'c', 'query exists') <> '' then do
	Say
	Say 'Installing Flash...'
	if stream(inst_dir'\..\42_flos2\flashos2.exe', 'c', 'query exists') <> '' then do
		'@'inst_dir'\..\42_flos2\flashos2.exe /e /d='target'\temp >> 'product_log' 2>>&1'
		'@copy 'target'\temp\npswf2.dll   'plugins'\.             >> 'product_log' 2>>&1'
		'@copy 'target'\temp\nsiflash.xpt 'dir'\components\. >> 'product_log' 2>>&1'
		'@del 'target'\temp\flash5.exe 	 >nul 2>>&1'
		'@del 'target'\temp\flashdel.cmd >nul 2>>&1'
		'@del 'target'\temp\license.txt  >nul 2>>&1'
		'@del 'target'\temp\npswf2.dll 	 >nul 2>>&1'
		'@del 'target'\temp\nsiflash.xpt >nul 2>>&1'
		'@del 'target'\temp\readme.txt 	 >nul 2>>&1'
	end
	if stream(inst_dir'\..\42_flos2\flashinst.exe', 'c', 'query exists') <> '' then do
		'@copy 'inst_dir'\..\42_flos2\*.exe 'plugins'\. >> 'product_log' 2>>&1' 
		'@copy 'inst_dir'\..\42_flos2\*.dll 'plugins'\. >> 'product_log' 2>>&1' 
		cdir = directory()
		call directory plugins
		'@flashinst.exe >> 'product_log' 2>>&1' 
		call deldir 'Common Files'
		call deldir 'Win'
		'@del flashinst.exe >> 'product_log' 2>>&1'
		call directory cdir
	end
end

/* ready */
Say
Say 'Completed.'

exit 0

/* uninstall mode */
uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<MOZILLAFLDR>"

	/* delete files */
	dest_dir = find_key('USER Mozilla Install Directory')
	if dest_dir <> '' then do
		call deldir dest_dir 
		'@rmdir 'dest_dir' >> 'product_log' 2>>&1'
	end

	/* clean ini */
	call SysIni 'USER', 'Mozilla 'product_version' (en)', 'DELETE:'

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

/* del directory */
DelDir: procedure expose source

	parse upper arg Directory
	DirSpec = Directory'\*'

	/* delete subdirectories */
	call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
	rc = SysFileTree(DirSpec, Subdirs, 'DO', '*****', '-*---')
	do i = 1 to Subdirs.0
   		call DelDir Subdirs.i
	end

	/* delete files */
	rc = SysFileTree(DirSpec, Files, 'FO', '*****', '-*---')
	do i = 1 to Files.0
		'@call 'source'\updcd\bin\unlock.exe "'Files.i'" >nul 2>>&1'
		'@del "'Files.i'"'
	end

	/* delete directory */
	'@rmdir "'Directory'"'

return

/* function to reorder association list */
reorder: procedure expose product_log

	parse arg appl key
	'@echo Manipulating: 'appl' 'key' >> 'product_log 

	/* read assoc list */
	val = sysini('USER', appl, key)

	/* parse list */
	i=1
	do while length(val) > 0
		w.i = substr(val, 1, 7)
		val = substr(val, 8)
		i=i+1
	end
	w.0 = i-1

	/* reorder list */
	if w.0 > 1 then do
		val = w.0
		val = w.val
		do i=1 to w.0-1
			val = val||w.i
		end
	end

	/* write assoc list */
	rc = sysini('USER', appl, key, val)
	if rc = '' then rc = 'OK'
	'@echo Result: 'rc' >> 'product_log 

return
