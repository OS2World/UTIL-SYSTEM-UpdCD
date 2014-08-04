/* Installation script for unattended install of Object Desktop 2.0 */
/* Copy from your installation disk the contents of directory OD20  */ 
/* to this directory.                                               */
/* Be sure to edit addons.cfg to include your registration number!  */
/* Last modified on 03.25.2001              					              */
/* 05.26.2002: added support for uninstallation                     */
/* 05.27.2002: added CID uninstall method + improved rsp file       */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
product_rsp       = value("PRODUCT_RSP"      , ,"OS2ENVIRONMENT")
product_license   = value("PRODUCT_LICENSE"  , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* check product */
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' then exit 9

/* check for registration */
if product_license == 'XXXXXXXXXXXXXXXX' then exit 8

/* installation dir must be in the root */
product_path = '\OD'
'@mkdir 'product_drv||product_path'   >>'product_log' 2>>&1'

/* create response file */
dest_dir = product_drv||product_path
'@echo FILE = 'dest_dir'              > 'product_rsp
'@echo AUX1 = 'dest_dir'\EXTRAS       >>'product_rsp
'@echo AUX2 = 'dest_dir'\EXTRAS\BIN   >>'product_rsp
'@echo AUX3 = 'dest_dir'\EXTRAS\ICONS >>'product_rsp
'@echo AUX4 = 'target'\OS2\BITMAP     >>'product_rsp
'@echo AUX5 = 'dest_dir'\VIEWERS      >>'product_rsp
'@echo AUX6 = 'dest_dir'\PACKAGES     >>'product_rsp
/* I don't know why this line makes install choke, but don't */ 
/* seem to need it anyway, So leave it out!                  */
/* '@echo AUX7 =    >>'product_rsp                           */
'@echo AUX8 = 'dest_dir'\OBJBACK      >>'product_rsp

/* You may comment out components you do not wish to install. */
'@echo COMP = Object Navigator        >>'product_rsp
'@echo COMP = Enhanced Folder         >>'product_rsp
'@echo COMP = Enhanced Data File      >>'product_rsp
'@echo COMP = Task Manager            >>'product_rsp
'@echo COMP = Keyboard LaunchPad      >>'product_rsp
'@echo COMP = Script Objects          >>'product_rsp
'@echo COMP = Tab LaunchPad           >>'product_rsp
'@echo COMP = Control Center          >>'product_rsp

/* This line will not bother the install, but is does not     */
/* install the object archivers either. Perhaps this line     */
/* would work? '@echo COMP = Object Archive >>'product_rsp    */

'@echo COMP = Object Archive (zip/lzh/zoo/arc/tar/rar) >>'product_rsp
'@echo COMP = Documentation                            >>'product_rsp
'@echo COMP = Stardock Extras Archivers                >>'product_rsp
'@echo COMP = Stardock Extras Icons                    >>'product_rsp
'@echo COMP = Stardock Extras Bitmaps                  >>'product_rsp
'@echo COMP = Object Utilities                         >>'product_rsp
'@echo COMP = Object Package                           >>'product_rsp
'@echo COMP = Desktop Backup Advisor                   >>'product_rsp
'@echo COMP = Object Security                          >>'product_rsp
'@echo COMP = Stardock Internet Shell                  >>'product_rsp
'@echo COMP = Object Viewers                           >>'product_rsp

/* Un-commenting this next line is very risky, most users find */
/* this will hang the install.                                 */
/* '@echo COMP = Object Advisor  >>'product_rsp                */

'@echo COMP = Common Folder Packages           >>'product_rsp
'@echo COMP = Object Backup                    >>'product_rsp
'@echo COMP = Object Inspector                 >>'product_rsp
'@echo COMP = Object Backup ATAPI/IDE          >>'product_rsp
'@echo COMP = Package Folder                   >>'product_rsp

'@echo CFGUPDATE = AUTO                        >>'product_rsp
'@echo DELETEBACKUP = NO                       >>'product_rsp
'@echo OVERWRITE = YES                         >>'product_rsp
'@echo SAVEBACKUP = NO                         >>'product_rsp
'@echo OBJD_INSTALL_STARTUPFOLDER = YES        >>'product_rsp
'@echo OBJD_LICENSE = 'product_license'        >>'product_rsp

/* OK, now begin CID install */
inst_dir'\INSTALL.EXE /A:I /X /L1:'product_log' /L2:'product_log' /R:'product_rsp

exit

uninstall:

	dest_dir = product_drv'\OD'
	if stream(dest_dir'\epfinsts.exe', 'c', 'query exists') <> '' then 
		inst_dir'\INSTALL.EXE /A:D /X /L1:'product_log' /L2:'product_log' /R:'product_rsp
	else
		'call 'dest_dir'\OBJDRMOV.CMD'
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
