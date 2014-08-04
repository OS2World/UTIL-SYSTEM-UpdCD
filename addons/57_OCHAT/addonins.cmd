/* OpenChat installation script                                    */
/* Unzip the file ochat107.exe file to this directory              */
/* It is a shareware product, do not forget to register            */
/* You can also use this script to install any other products uses */
/* install.exe to start the installation process                   */
/* 12.14.2002: created                                             */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' then exit 9

/* run exe */
inst_dir'\install.exe'

exit

uninstall:

	'say Sorry, there is no uninstall available for OpenChat at this time.'
	'@echo Sorry, there is no uninstall available for OpenChat at this time. >> 'product_log

return

