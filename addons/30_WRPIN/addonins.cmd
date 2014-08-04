/* WarpIN installation, registration and create icons    */
/*                                                       */
/* Unpack the WarpIn distribution file in this directory */
/* or install WarpIn and copy the installed files here   */
/* including the test subdirectory                       */
/*                                                       */
/* 08.11.2001: added removal of RO attributes            */
/* 05.19.2002: added support for uninstallation          */
/* 07.04.2002: added history icon creation               */
/* 09.30.2005: aligned with os2mt                        */

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
if stream(inst_dir'\warpin.exe', 'c', 'query exists') = '' & stream(inst_dir'\iwarpin.exe', 'c', 'query exists') = '' then exit 9

/* os2mt install */
if stream(inst_dir'\iwarpin.exe', 'c', 'query exists') <> '' then do
	Say
	Say 'Starting installer...'
	'@'inst_dir'\iwarpin.exe'
	Say
	Say 'Completed.'
	exit
end

/* Register with REXX API extensions. */
Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

/* WarpIN kopieren und registrieren */
Say
Say 'Copying files...'
dest_dir = product_drv'\'product_path
'@xcopy 'inst_dir' 'dest_dir'\. /s/e >> 'product_log
'@del 'dest_dir'\addonins.cmd >> 'product_log

/* remove RO attributes */
call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
call SysFileTree dest_dir'\*', 'tmp.', 'SO',,'**---'

/* creating objects */
Say
Say 'Creating objects...'
CreateCollision = 'Replace' 
CreateObjects:
rc = CreateObject( 'WPFolder',,
    'WarpIN',,
    '<WP_DESKTOP>',,
    'NOPRINT=YES;'||,
        'DEFAULTVIEW=CONTENTS;'||,
        'SELFCLOSE=1;'||,
        'ICONFONT=9.WarpSans;'||,
        'DETAILSFONT=9.WarpSans;'||,
        'TREEFONT=9.WarpSans;'||,
        'ICONVIEW=NONGRID,NORMAL;'||,
        'DETAILSVIEW=MINI;'||,
        'TREEVIEW=LINES,MINI;'||,
        'OBJECTID=<WARPIN_FOLDER>',,
    CreateCollision )
rc = CreateObject( 'WPProgram',,
    'WarpIN',,
    '<WARPIN_FOLDER>',,
    'NOPRINT=YES;'||,
        'DEFAULTVIEW=RUNNING;'||,
        'ASSOCFILTER=*.WPI;'||,
        'ASSOCTYPE=WarpIN Archive;'||,
        'EXENAME='dest_dir'\WARPIN.EXE;'||,
        'STARTUPDIR='dest_dir';'||,
        'PROGTYPE=PM;'||,
        'OBJECTID=<WARPIN_EXE>',,
    CreateCollision )
rc = CreateObject( 'WPProgram',,
    'WarpIN User''s Guide',,
    '<WARPIN_FOLDER>',,
    'NOPRINT=YES;'||,
        'DEFAULTVIEW=RUNNING;'||,
        'EXENAME=VIEW.EXE;'||,
        'STARTUPDIR='dest_dir';'||,
        'PARAMETERS=WPI_USER.INF;'||,
        'PROGTYPE=PM;'||,
        'OBJECTID=<WARPIN_PROGGUIDE>',,
    CreateCollision )
rc = CreateObject( 'WPProgram',,
    'WarpIN Programmer''s Guide and Reference',,
    '<WARPIN_FOLDER>',,
    'NOPRINT=YES;'||,
        'DEFAULTVIEW=RUNNING;'||,
        'EXENAME=VIEW.EXE;'||,
        'STARTUPDIR='dest_dir';'||,
        'PARAMETERS=WPI_PROG.INF;'||,
        'PROGTYPE=PM;'||,
        'OBJECTID=<WARPIN_USERGUIDE>',,
    CreateCollision )
rc = CreateObject( 'WPShadow',,
    'readme.txt',,
    '<WARPIN_FOLDER>',,
    'SHADOWID='dest_dir'\readme.txt',,
    CreateCollision )
rc = CreateObject( 'WPShadow',,
    'history.txt',,
    '<WARPIN_FOLDER>',,
    'SHADOWID='dest_dir'\history.txt',,
    CreateCollision )

/* WarpIN in OS2.Ini eintragen */
Say
Say 'Registering WarpIn...'
rc = SysIni( 'USER', 'WarpIN', 'Path', dest_dir''d2c(0) )
if rc ='' then
  '@echo WarpIN has been added to the OS2.INI. >> 'product_log
else
  '@echo WarpIN was not added to the OS2.INI. >> 'product_log

Say
Say 'Completed.'

exit

CreateObject: procedure expose product_log
    Parse Arg Class, Title, Location, Setup, Collision
    'echo Object ['Title'] erzeugt >> 'product_log
    rc = SysCreateObject( Class, Title, Location, Setup, Collision )
    If rc <> 1 Then
        'echo Object ['Title' | 'Class'] in ['Location'] nicht erstellt >> 'product_log
return rc

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<WARPIN_FOLDER>"

	/* delete from ini */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	rc = SysIni('USER', 'Warpin', 'DELETE:')

	/* del files */
	dest_dir = product_drv'\'product_path
	call deldir dest_dir

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
