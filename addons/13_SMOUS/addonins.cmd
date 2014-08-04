/* IBM Scrollmouse or Singlemouse installation script               */
/* Run scrollms.exe or sMouse??.exe in this directory to get the    */
/* installation files                                               */
/* 07.02.2001: fixed bug in Japanase language detection             */
/* 04.22.2002: objectid changed from <SCROLL_MOUSE> to <WP_MOUSE>   */
/* 05.19.2002: added support for uninstallation                     */
/* 06.09.2002: uninstallation did not recreate mouse object         */
/* 06.22.2002: unlock wpstkmri.dll seems to be needed               */
/* 08.25.2002: added singlemouse support                            */
/* 04.11.2004: updated singlemouse support                          */
/* 09.30.2005: aligned with os2mt                                   */

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
if stream(inst_dir'\mouse.sys', 'c', 'query exists') = '' then exit 9

Say
Say 'Starting installer...'

/* installation of scrollmouse */
if stream(inst_dir'\mouinst.exe', 'c', 'query exists') <> '' then do
	'@copy 'target'\os2\boot\mouse.sys 'target'\os2\boot\mouse.bak >>  'product_log' 2>>&1'
	'@copy 'inst_dir'\mouse.sys 'target'\os2\boot\. >>  'product_log' 2>>&1'

	lang = translate(value("LANG", ,"OS2ENVIRONMENT"))
		select
			when lang = 'FR_BE' | lang = 'FR_CA' | lang = 'FR_CH' | lang = 'FR_FR' then lang = 'FR'
			when lang = 'EN_US' | lang = 'EN_GB' | lang = 'EN_JP' then lang = 'EN'
			when lang = 'DE_DE' | lang = 'DE_CH' then lang = 'DE'
			when lang = 'NL_BE' | lang = 'NL_NL' then lang = 'NL'
			when lang = 'PT_BR' | lang = 'PT_PT' then lang = 'BR'
			when lang = 'ZH_SC' | lang = 'ZH_CN' then lang = 'SC'
			when lang = 'DA_DK' then lang = 'DK'
			when lang = 'ES_ES' then lang = 'ES'
			when lang = 'FI_FI' then lang = 'FI'
			when lang = 'IT_IT' then lang = 'IT'
			when lang = 'JA_JP' then lang = 'JP'
			when lang = 'NO_NO' then lang = 'NO'
			when lang = 'SV_SE' then lang = 'SV'
			when lang = 'ZH_TW' then lang = 'TW'
			otherwise lang = 'EN'
		end

	'@call 'source'\updcd\bin\unlock.exe 'target'\os2\dll\wpstkmri.dll >> 'product_log' 2>>&1'
	'@copy 'inst_dir'\WPSTKMRI.'lang target'\os2\dll\wpstkmri.dll >>  'product_log' 2>>&1'
	call RxFuncAdd 'SysRegisterObjectClass', 'RexxUtil', 'SysRegisterObjectClass';
	call SysRegisterObjectClass "WPStickMouse", "WPSTKMOU.DLL"
	call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject';
	call SysCreateObject "WPStickMouse", "ScrollPoint Mouse", "<WP_APPSFOLDER>", "OBJECTID=<WP_MOUSE>"
end
/* singlemouse install */
else do
	cdir = directory()
	call directory inst_dir
	'@echo drive = 'target' >  'target'\smouse.rsp'
	'@echo overwrite = YES  >> 'target'\smouse.rsp'
	if stream(inst_dir'\smouse.exe', 'c', 'query exists') <> '' then 
		'@smouse.exe /r:'target'\smouse.rsp /x >> 'product_log' 2>>&1'
	else 
		'@install.exe /r:'target'\smouse.rsp /x >> 'product_log' 2>>&1'
	'@del 'target'\smouse.rsp'
	call directory cdir
end

Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	/* scrollmouse */
	if stream(inst_dir'\mouinst.exe', 'c', 'query exists') <> '' then do
		'copy 'target'\os2\boot\mouse.sav 'target'\os2\boot\mouse.sys'
		call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
		call SysDestroyObject '<WP_MOUSE>'
		call RxFuncAdd 'SysDeRegisterObjectClass', 'RexxUtil', 'SysDeRegisterObjectClass'
		call SysDeRegisterObjectClass 'WPStickMouse'
		call SysCreateObject "WPMouse", "Mouse", "<WP_CONFIG>", "OBJECTID=<WP_MOUSE>", "r"
	end
	/* singlemouse */
	else do
		nop; /* have no idea how to uninstall it */
	end

return
