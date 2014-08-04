/* Netdrive installation                                                     */
/*                                                                           */
/* Place the following file here: ndfs.zip (netdrive)                        */
/*                                                                           */
/* The following plugins are optional:                                       */
/* ndppsion.zip: psion                                                       */
/* ndphpc.zip:   hp c200                                                     */
/* ndpnfs.zip:   nfs                                                         */
/* ndpfat.zip:   vfat                                                        */
/* ndpiso.zip:   isofs                                                       */
/* ndpcrypt.zip: cipher                                                      */
/* ndpsmb.zip:   samba                                                       */
/*                                                                           */
/* 11.11.2005: created                                                       */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\ndfs.zip', 'c', 'query exists') = '' then exit 9

/* install */
Say
Say 'Installing NetDrive..'
'@unzip -o 'inst_dir'\ndfs.zip -d 'product_drv'\'product_path'\. >> 'product_log' 2>>&1'
cdir = directory()
'@copy 'source'\updcd\bin\unpack2.exe 'product_drv'\'product_path'\. >> 'product_log' 2>>&1'
call directory product_drv'\'product_path
'@unpack2.exe ndfs.@ /C                 >> 'product_log' 2>>&1'
'@del ndfs.@                            >> 'product_log' 2>>&1'
'@del ndinst.exe                        >> 'product_log' 2>>&1'
'@del unpack2.exe                       >> 'product_log' 2>>&1'

/* change config.sys if needed */
Say
Say 'Updating Config.Sys...'
found.    = ''
found.dir = 0
found.ifs = 0
found.ctl = 0
cfgfile = target'\config.sys'
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('SET NDFSDIR', translate(l.q)) > 0 then found.dir = 1
	if pos('NDFS32.IFS',  translate(l.q)) > 0 then found.ifs = 1
	if pos('NDFS.IFS',    translate(l.q)) > 0 then found.ifs = 1
	if pos('NDCTL.EXE',   translate(l.q)) > 0 then found.ctl = 1
	q = q+1
end
rc = lineout(cfgfile)
if found.dir = 0 then do
	l.q = 'SET NDFSDIR='product_drv'\'product_path
	q = q+1
end
if found.ifs = 0 then do
	if stream(product_drv'\'product_path'\NDFS32.IFS', 'C', 'query exists') = '' then
		l.q = 'IFS='product_drv'\'product_path'\NDFS.IFS'
	else
		l.q = 'IFS='product_drv'\'product_path'\NDFS32.IFS'
	q = q+1
end
if found.ctl = 0 then do
	l.q = 'RUN='product_drv'\'product_path'\NDCTL.EXE'
	q = q+1
end
l.0 = q-1

/* backup config.sys */
'@copy 'cfgfile target'\os2\install\config.ndr' 
'@del 'cfgfile
do q=1 to l.0
	/* libpath */
	if pos('LIBPATH=', translate(l.q)) > 0 & pos(product_drv'\'product_path, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || product_drv'\'product_path';'
		else l.q = l.q || ';' || product_drv'\'product_path';'
	end
	/* path */
	if pos('SET PATH=', translate(l.q)) > 0 & pos(product_drv'\'product_path, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || product_drv'\'product_path';'
		else l.q = l.q || ';' || product_drv'\'product_path';'
	end
	call lineout cfgfile, l.q
end
call lineout cfgfile

/* plugins */
'@echo @echo+ > 'product_drv'\'product_path'\plgreg.cmd'
'@echo @echo This script will activate the plugins installed. >> 'product_drv'\'product_path'\plgreg.cmd'
'@echo @echo If you have rebooted your machine after installation press ENTER now. >> 'product_drv'\'product_path'\plgreg.cmd'
'@echo @echo If not, please reboot your machine before continuing. >> 'product_drv'\'product_path'\plgreg.cmd'
'@echo @echo+ >> 'product_drv'\'product_path'\plgreg.cmd'
'@echo @pause >> 'product_drv'\'product_path'\plgreg.cmd'
if stream(inst_dir'\ndppsion.zip','c','query exists') <> '' then do
	Say
	Say 'Installing Psion plugin...'
	'@unzip -o 'inst_dir'\ndppsion.zip -d . >> 'product_log' 2>>&1'
	'@echo @nd.exe plugin install ndppsion.ndp >> 'product_drv'\'product_path'\plgreg.cmd'
end
if stream(inst_dir'\ndpsmb.zip','c','query exists') <> '' then do
	Say
	Say 'Installing Samba plugin...'
	'@unzip -o 'inst_dir'\ndpsmb.zip -d . >> 'product_log' 2>>&1'
	'@echo @nd.exe plugin install ndpsmb.ndp >> 'product_drv'\'product_path'\plgreg.cmd'
end
if stream(inst_dir'\ndphpc.zip','c','query exists') <> '' then do
	Say
	Say 'Installing HP C200 plugin...'
	'@unzip -o 'inst_dir'\ndphpc.zip -d . >> 'product_log' 2>>&1'
	'@echo @nd.exe plugin install ndphpc.ndp >> 'product_drv'\'product_path'\plgreg.cmd'
end
if stream(inst_dir'\ndpnfs.zip','c','query exists') <> '' then do
	Say
	Say 'Installing NFS plugin...'
	'@unzip -o 'inst_dir'\ndpnfs.zip -d . >> 'product_log' 2>>&1'
	'@echo @nd.exe plugin install ndpnfs.ndp >> 'product_drv'\'product_path'\plgreg.cmd'
end
if stream(inst_dir'\ndpfat.zip','c','query exists') <> '' then do
	Say
	Say 'Installing VFAT plugin...'
	'@unzip -o 'inst_dir'\ndpfat.zip -d . >> 'product_log' 2>>&1'
	'@echo @nd.exe plugin install ndpfat.ndp >> 'product_drv'\'product_path'\plgreg.cmd'
end
if stream(inst_dir'\ndpiso.zip','c','query exists') <> '' then do
	Say
	Say 'Installing ISO FS plugin...'
	'@unzip -o 'inst_dir'\ndpiso.zip -d . >> 'product_log' 2>>&1'
	'@echo @nd.exe plugin install ndpiso.ndp >> 'product_drv'\'product_path'\plgreg.cmd'
end
if stream(inst_dir'\ndpcrypt.zip','c','query exists') <> '' then do
	Say
	Say 'Installing Cipher plugin...'
	'@unzip -o 'inst_dir'\ndpcrypt.zip -d . >> 'product_log' 2>>&1'
	'@echo @nd.exe plugin install ndpcrypt.ndp >> 'product_drv'\'product_path'\plgreg.cmd'
end
'@echo @echo+ >> 'product_drv'\'product_path'\plgreg.cmd'
'@echo @echo Plugins are activated. You may delete this program. >> 'product_drv'\'product_path'\plgreg.cmd'
'@echo @pause >> 'product_drv'\'product_path'\plgreg.cmd'

/* create objects */
call CreateObject 'WPFolder','NetDrive for OS/2','<WP_DESKTOP>','OBJECTID=<NDFS_FOLDER>','R'
call CreateObject 'WPProgram','Information','<NDFS_FOLDER>','EXENAME=VIEW.EXE;PARAMETERS='product_drv'\'product_path'\NDPM.HLP;ICONFILE='product_drv'\'product_path'\ICO\INFO.ICO;OBJECTID=<NDFS_INFO>','R'
call CreateObject 'WPProgram','Control Panel','<NDFS_FOLDER>','EXENAME='product_drv'\'product_path'\NDPM.EXE;STARTUPDIR='product_drv'\'product_path';OBJECTID=<NDFS_CONTROLPANEL>','R'
call CreateObject 'WPProgram','Configuration File','<NDFS_FOLDER>','EXENAME=E.EXE;PARAMETERS='product_drv'\'product_path'\NDCTL.CFG;OBJECTID=<NDFS_CONFIGFILE>','R'
call CreateObject 'WPProgram','Order Form','<NDFS_FOLDER>','EXENAME=E.EXE;PARAMETERS='product_drv'\'product_path'\DOC\ORDER.FRM;ICONFILE='product_drv'\'product_path'\ICO\ORDER.ICO;OBJECTID=<NDFS_REGFORM>','R'
call CreateObject 'WPProgram','Uninstall','<NDFS_FOLDER>','EXENAME='product_drv'\'product_path'\NDUNINST.EXE;STARTUPDIR='product_drv'\'product_path';OBJECTID=<NDFS_UNINSTALL>','R'
call CreateObject 'WPUrl','Web Site','<NDFS_FOLDER>','URL=http://www.blueprintsoftwareworks.com/netdrive;OBJECTID=<NDFS_WEBSITE>','R'
call CreateObject 'WPProgram','Activate Plug-Ins','<NDFS_FOLDER>','EXENAME='product_drv'\'product_path'\plgreg.cmd','R'
if stream(product_drv'\'product_path'\NDFS32.IFS', 'C', 'query exists') = '' then
	call CreateObject 'WPProgram','Registration','<NDFS_FOLDER>','PROGTYPE=WINDOWABLEVIO;EXENAME='product_drv'\'product_path'\NDREG.CMD;STARTUPDIR='product_drv'\'product_path';ICONFILE='product_drv'\'product_path'\ICO\KEY.ICO;OBJECTID=<NDFS_REGISTRATION>','R'
else
	call CreateObject 'WPProgram','Registration','<NDFS_FOLDER>','PROGTYPE=WINDOWABLEVIO;EXENAME='product_drv'\'product_path'\ND.EXE;PARAMETERS=REGISTER;STARTUPDIR='product_drv'\'product_path';ICONFILE='product_drv'\'product_path'\ICO\KEY.ICO;OBJECTID=<NDFS_REGISTRATION>','R'

/* ready */
Say
Say 'Completed. Please reboot your machine now.'
Say
Say 'After the reboot run "Activate PlugIns" from the NetDrive folder.'
call directory cdir

exit

/* create object */
CreateObject: procedure expose product_log
    Parse Arg Class, Title, Location, Setup, Collision
    '@echo Registering Object ['Title'] >> 'product_log
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
