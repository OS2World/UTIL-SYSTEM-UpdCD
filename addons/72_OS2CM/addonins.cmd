/* Installation of OS/2 Commander               */
/* Add the os2commander files to this directory */
/* 08.12.2001: added removal of RO attribs      */
/* 05.25.2002: added support for uninstallation */

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

if stream(inst_dir'\os2com.exe', 'c', 'query exists') = '' then exit 9

/* copy files */
dest_dir = product_drv'\'product_path
'xcopy 'inst_dir'\* 'dest_dir'\. >> 'product_log
'del 'dest_dir'\addonins.cmd >> 'product_log

/* remove RO attributes */
call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
call SysFileTree dest_dir'\*', 'tmp.', 'SO',,'**---'

/* create object */
Folder = '<WP_DESKTOP>'
Type = 'WPProgram'
Title = 'OS/2 Commander'
Parms = 'MINWIN=SYMBOL;PROGTYPE=WP;EXENAME='dest_dir'\OS2Com.EXE;STARTUPDIR='dest_dir';OBJECTID=<OS/2-Commander>;NOPRINT=YES;'
Result = SysCreateObject( Type, Title, Folder, Parms, 'ReplaceIfExists' )

exit

/* uninstall mode */
uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<OS/2-Commander>"

	/* delete files */
	dest_dir = translate(product_drv'\'product_path)
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
