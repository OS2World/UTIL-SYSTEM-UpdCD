/* Innotek RunTime installation                                              */
/*                                                                           */
/* Place Innotek Runtime here under the name runtime.exe                     */
/*                                                                           */
/* 18.09.2004: created                                                       */
/* 30.09.2005: aligned with os2mt                                            */

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
if stream(inst_dir'\runtime.exe', 'c', 'query exists') = '' then exit 9

/* install Innotek RunTime */
Say
Say 'Installing files...'
'@'inst_dir'\runtime.exe /directory='product_drv'\'product_path' /update=force /unattended >> 'product_log' 2>>&1'

Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	inst_dir'\runtime.exe /uninstall /complete >> 'product_log' 2>>&1'

return
