/* SysBar installation script                      */
/* Create a zip file called sysbar.zip containing  */
/* the Sysbar files and copy it to this directory. */
/*                                                 */
/* 05.07.2002: created                             */
/* 05.19.2002: added support for uninstallation    */
/* 01.12.2004: made installation source a zip file */

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
if stream(inst_dir'\sysbar.zip', 'c', 'query exists') = '' then exit 9

/* copy files */
dest_dir = product_drv'\'product_path
'unzip -o 'inst_dir'\sysbar.zip -d 'dest_dir'\. >> 'product_log' 2>>&1'

/* remove RO attributes */
call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
call SysFileTree dest_dir'\*', 'tmp.', 'SO',,'**---'

/* create objects */
cdir = directory()
rc   = directory(dest_dir)
'call 'dest_dir'\SB2_FLDR.CMD >> 'product_log
rc   = directory(cdir)

exit

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<SYSBAR2FOLDER>"

	/* del files */
	call deldir product_drv'\'product_path

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
