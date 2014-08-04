/* Installation of FreeType DLL                 */
/* Place freetype.dll in this directory         */
/* 08.12.2001: added removal of RO attributes   */
/* 05.21.2002: added support for uninstallation */
/* 09.30.2005: aligned with os2mt               */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

if stream(inst_dir'\freetype.dll', 'c', 'query exists') = '' then exit 9

/* copy files */
Say
Say 'Copying file...'
dest_dir = product_drv'\os2\dll'
'@copy 'inst_dir'\freetype.dll 'dest_dir'\. >> 'product_log

/* remove RO attributes */
call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
call SysFileTree dest_dir'\*', 'tmp.', 'SO',,'**---'

/* register dll */
Say
Say 'Registering DLL...'
app = "PM_Font_Drivers"
key = "TRUETYPE"
val = "\OS2\DLL\FREETYPE.DLL" || d2c(0)
call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
Result = SysIni('BOTH', app, key, val)
if Result <> '' then do
	say 'Error: did not register DLL!'
	'@echo Error: did not register DLL! >> 'product_log
end

Say
Say 'Completed.'

exit 

uninstall:

	/* register IBM dll */
	app = "PM_Font_Drivers"
	key = "TRUETYPE"
	val = "\OS2\DLL\TRUETYPE.DLL" || d2c(0)
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	Result = SysIni('BOTH', app, key, val)
	say 'Register DLL returned the following value: 'result

	/* del dll */
	dest_dir = product_drv'\os2\dll'
	'call 'source'\updcd\bin\unlock.exe 'dest_dir'\freetype.dll'
	call syssleep 5
	'del 'dest_dir'\freetype.dll >> 'product_log

return