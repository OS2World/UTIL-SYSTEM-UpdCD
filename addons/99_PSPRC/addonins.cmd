/* Postprocessing script, runs after the installation of the add-on products */
/* 10.11.2001: added move CDrecord/2 folder                                  */
/* 05.18.2002: added move pmview & sysbar folders                            */
/* 05.25.2002: added support for uninstallation                              */
/* 06.11.2002: removed unused path variable                                  */
/* 07.08.2002: added move Mozilla folder                                     */
/* 08.14.2002: added move Odin folder                                        */
/* 12.01.2002: Destroy get Netscape URL is not needed any more               */
/* 12.14.2002: added move OpenChat folder                                    */
/* 29.08.2003: added move Pmview 3.0 folder                                  */
/* 29.10.2003: added move JAVA 1.4 folder                                    */
/* 18.09.2004: added move Acrobat 4                                          */
/* 29.10.2004: added move OpenSSH                                            */
/* 12.12.2004: added move ISDNPM                                             */
/* 12.11.2005: added move Netdrive, Samba, Security/2                        */
/* 09.04.2006: added move TCPCFG                                             */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* add installer icons */
Call RxFuncAdd 'SysLoadFuncs', 'RexxUtil', 'SysLoadFuncs'
Call SysLoadFuncs

/* Move icons from Desktop to different folders */
instpath = 'warpsrv'
if stream(source'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'grpware'
if stream(source'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'ibminst'
if instpath = 'ibminst' then target_folder = '<WP_APPSFOLDER>'
else target_folder = '<WP_OS2SYS>'

caLL SysMoveObject '<WARPIN_FOLDER>',                                  target_folder 
caLL SysMoveObject '<Sym_NAV>',                                        target_folder 
caLL SysMoveObject '<ACROBAT>',                                        target_folder
caLL SysMoveObject '<WPS_SHELLLINK_DESKTOP_Acrobat Reader 4>',         target_folder
caLL SysMoveObject '<WPS_SHELLLINK_DESKTOP_Uninstall Adobe Acrobat 4>',target_folder
caLL SysMoveObject '<FC2_FOLDER>',                                     target_folder
caLL SysMoveObject '<SCITECH_DESKTOP>',                                target_folder
caLL SysMoveObject '<NS46_FOLDER>',                                    target_folder
caLL SysMoveObject '<FI_JAVA_UNINSTALL>',                              target_folder
caLL SysMoveObject '<INNOTEK_FLASH>',                                  target_folder
caLL SysMoveObject '<WC_WEBEX_FOLD>',                                  target_folder
caLL SysMoveObject '<OS/2-Commander>',                                 target_folder
caLL SysMoveObject '<XFREE86OS2>',                                     target_folder
caLL SysMoveObject '<XWP_MAINFLDR>',                                   target_folder
caLL SysMoveObject '<NBMSFLDR>',                                       target_folder
caLL SysMoveObject '<CDREC2>',                                         target_folder 
caLL SysMoveObject '<PMVIEW20FOLDER>',                                 target_folder
caLL SysMoveObject '<PMVIEW30FOLDER>',                                 target_folder
caLL SysMoveObject '<SYSBAR2FOLDER>',                                  target_folder
caLL SysMoveObject '<PMM2FOLDER>',                                     target_folder
caLL SysMoveObject '<EM_emx_0.9d_FOLDER>',                             target_folder
caLL SysMoveObject '<MOZILLAFLDR>',                                    target_folder
caLL SysMoveObject '<ODINFOLDER>',                                     target_folder
caLL SysMoveObject '<OCHAT_FOLDER>',                                   target_folder
caLL SysMoveObject '<GCJAVA>',                                         target_folder
caLL SysMoveObject '<OS2KITJAVAFOLDER>',                               target_folder
caLL SysMoveObject '<OPENSSH>',                                        target_folder
caLL SysMoveObject '<ISDNPM30_FOLDER>',                                target_folder
caLL SysMoveObject '<SECURITY2>',                                      target_folder
caLL SysMoveObject '<SAMBA2>',                                         target_folder
caLL SysMoveObject '<NDFS_FOLDER>',                                    target_folder
caLL SysMoveObject '<TCPCONFFOLDER>',                                  target_folder

/* remove junk from config.sys */
/* load config.sys */
cfgfile = target'\config.sys'
i = 1
do while lines(cfgfile)
	l.i = linein(cfgfile)
	i = i+1
end
rc = lineout(cfgfile)
l.0 = i-1
/* update config.sys */
'copy 'cfgfile target'\os2\install\config.psp >> 'product_log
'del 'cfgfile' >> 'product_log
do i = 1 to l.0
	if pos('SET ADDONINS_', l.i) = 0 then rc = lineout(cfgfile, l.i)
end
rc = lineout(cfgfile)

exit

/* uninstall mode */
uninstall:

	nop;

return
