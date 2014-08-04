/* CMDRun V1.2 installation. Files available at:                           */
/* http://hobbes.nmsu.edu/pub/os2/util/wps/cmdrun12.zip                    */
/* Unpack the cmdrun installation files to this directory                  */
/* The cmdrun readme instructs that cmdrun.dll must be installed           */
/* from a directory included in the LIBPATH. If your LIBPATH               */
/* statement includes a dot (.) entry, then any directory will do.         */
/* The default install directory is ?:\OS2\DLL                             */

/* This handy dandy FREE utility is the first add-on to be installed       */
/* on my system, bar none. Without it I feel crippled.                     */
/* From a folder popup menu you can open a command prompt with the prompt  */
/* already set to the directory where you right-clicked.  It also adds a   */
/* RUN item to the folder popup menu.  This gives access to a dialogue     */
/* similar to the Windows RUN dialogue.  From this dialogue, you can       */
/* easily browse for a program to run, plus the run history is saved for   */
/* quick recall.                                                           */

/* This script will also create a program object named PMRun on the        */
/* desktop which gives another way to start up the same RUN dialogue       */
/* window.  If you include an icon file in this installation directory     */
/* (cmdrun does not actually come with one, you have to supply one         */
/* yourself), this script will set the icon of the PMRun program object    */
/* to the icon you have included.                                          */
/* 05.19.2002: added support for uninstallation                            */

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

/* exit if package does not exist */
if stream(inst_dir'\cmdrun.dll', 'c', 'query exists') = '' then exit 9

/* install */
DO
   /* copy files */
   '@copy 'inst_dir'\cmdrun.cmd 'product_drv'\OS2\.      >> 'product_log
   '@copy 'inst_dir'\pmrun.exe  'product_drv'\OS2\.      >> 'product_log
   '@copy 'inst_dir'\cmdrun.dll 'product_drv'\OS2\DLL\.  >> 'product_log
   '@copy 'inst_dir'\cmdrun.doc 'product_drv'\OS2\HELP\. >> 'product_log

   /* register classes */
	 cdir = directory()
	 call directory product_drv'\OS2\DLL'
   "@call ..\cmdrun.cmd i                                >> "product_log
	 call directory cdir

   /* Create a program object for pmrun.exe */
   call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
   call SysCreateObject "WPProgram", "PMRun", "<WP_DESKTOP>", "OBJECTID=<PMRUN>;EXENAME="||product_drv||"\OS2\pmrun.exe", "U"

   /* find out if user included an icon file in the installation directory */
   call RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
   call SysFileTree inst_dir||'\*.ico', "junk.", "FO"
   If junk.0 = 1 Then Do
			/* copy */
	    '@copy 'inst_dir'\*.ico      'product_drv'\OS2\.   >> 'product_log
      /* register the rexx function */
      call RxFuncAdd 'SysSetObjectData', 'RexxUtil', 'SysSetObjectData'
      call SysSetObjectData "<PMRUN>", "ICONFILE="||product_drv||"\OS2\"||filespec( "N", junk.1 )
      call RxFuncDrop 'SysSetObjectData'
   End /* Do */

End /* Do */

exit

uninstall:

   /* delet object pmrun.exe */
   call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
   call SysDestroyObject '<PMRUN>'

   /* unregister classes */
	 cdir = directory()
	 call directory product_drv'\OS2\DLL'
   "@call ..\cmdrun.cmd u >> "product_log
	 call directory cdir

	/* del files */
	'del 'target'\os2\cmdrun.cmd      >> 'product_log
	'del 'target'\os2\pmrun.exe       >> 'product_log
	'del 'target'\os2\dll\cmdrun.dll  >> 'product_log
	'del 'target'\os2\help\cmdrun.doc >> 'product_log

return