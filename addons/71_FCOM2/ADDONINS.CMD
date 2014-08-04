/* Installation script for FC/2                    */
/* Create a zip file called fc2.zip containing     */
/* the FC/2 files and copy it to this directory.   */
/*                                                 */
/* 08.12.2001: added removal of RO attribs         */
/* 05.19.2002: added support for uninstallation    */
/* 01.12.2004: made installation source a zip file */
/* 09.30.2005: aligned with os2mt                  */
/* 12.07.2005: os2mt did no handle fc2 updates     */

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

if stream(inst_dir'\fc2.zip', 'c', 'query exists') = '' then exit 9

Say
Say 'Unzipping files...'

/* unzip files */
dest_dir = product_drv'\'product_path
if stream(inst_dir'\fc2f.zip', 'c', 'query exists') <> '' then '@unzip -o 'inst_dir'\fc2f.zip -d 'dest_dir'\. >> 'product_log
'@unzip -o 'inst_dir'\fc2.zip -d 'dest_dir'\. >> 'product_log

/* remove RO attributes */
call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
call SysFileTree dest_dir'\*', 'tmp.', 'SO',,'**---'

/* create objects */
Say
Say 'Creating objects...'
cdir = directory()
rc   = directory(dest_dir)
'@'dest_dir'\setup.exe >> 'product_log
rc   = directory(cdir)

Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<FC2_FOLDER>"

	/* delete files */
	dest_dir = translate(product_drv'\'product_path)
	call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
	call SysFileTree dest_dir'\*', 'tmp.', 'FO',,'**---'
	do q=1 to tmp.0
		'call 'source'\updcd\bin\unlock.exe 'tmp.q
		'del 'tmp.q
	end
	'rmdir 'dest_dir

return
