/* Security/2 installation script                                    */
/*                                                                   */
/* Place the following file in this directory:                       */
/* 1. Install.exe from Security/2                                    */
/* Default uid/pwd = root                                            */
/*                                                                   */
/* 22.10.2005: created                                               */

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

/* copy/create/install sec/2 files */
Say
Say ' Installing Security/2 files...'
'@'inst_dir'\install.exe -i >> 'product_log

/* tune Config.Sys */
cfgsys = target'\CONFIG.SYS'
i = 1
do while lines(cfgsys)
	l.i = linein(cfgsys)
	if translate(substr(l.i,1,16)) = 'BASEDEV=SSES.SYS' & pos('/SUANYUSER', translate(l.i)) = 0 then 
		l.i = 'BASEDEV=SSES.SYS /suanyuser'
	i=i+1
end
call lineout cfgsys
l.0=i-1
'@copy 'cfgsys' 'target'\Config.SEC >> 'product_log' 2>>&1'
'@del 'cfgsys' >> 'product_log' 2>>&1'
do i=1 to l.0
	call lineout cfgsys, l.i
end
call lineout cfgsys

/* inform */
Say
Say ' Creating objects...'

/* create folders */
call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
call SysCreateObject 'WPFolder', 'Security/2', '<WP_DESKTOP>','OBJECTID=<SECURITY2>;'||'ALWAYSSORT=YES','R'

/* create config objects */
aclcfg = target'\security\etc\acls' 
pwdcfg = target'\security\etc\passwd'
call SysCreateObject 'WPProgram','Security/2^ACL file','<SECURITY2>','EXENAME=epm.exe;PARAMETERS='aclcfg,'R'
call SysCreateObject 'WPProgram','Security/2^PWD file','<SECURITY2>','EXENAME=epm.exe;PARAMETERS='pwdcfg,'R'
call SysCreateObject 'WPProgram','Security/2^Config.Sys','<SECURITY2>','EXENAME=epm.exe;PARAMETERS='target'\config.sys','R'

/* create documentation objects */
docfile1 = target'\security\doc\readme'
docfile2 = target'\security\doc\acls.example.en'
sseslog  = target'\security\log\ssesctl.log'
if stream(docfile1, 'c', 'query exists') <> '' then call SysCreateObject 'WPProgram','Security/2^Readme','<SECURITY2>','EXENAME=epm.exe;PARAMETERS='docfile1,'R'
if stream(docfile2, 'c', 'query exists') <> '' then call SysCreateObject 'WPProgram','Security/2^ACL examples','<SECURITY2>','EXENAME=epm.exe;PARAMETERS='docfile2,'R'
call SysCreateObject 'WPProgram','Security/2^Log file','<SECURITY2>','EXENAME=epm.exe;PARAMETERS='sseslog,'R'

/* ready */
Say
Say ' Finished installation. Please reboot your system now.'

exit

uninstall:

	/* update config */
	q = 1
	do while lines(cfgsys)
		l.q = linein(cfgsys)
		if pos('SSES.SYS',        translate(l.q)) > 0 then iterate
		if pos('SSESCTL.EXE',     translate(l.q)) > 0 then iterate
		if pos('REM *USE IT FOR', translate(l.q)) > 0 then iterate
		q=q+1
	end
	call lineout cfgsys
	l.0=q-1
	'@copy 'cfgsys target'\os2\install\config.sec >> 'product_log 
	'del 'cfgsys' >> 'product_log 
	do q=1 to l.0
		call lineout cfgsys, l.q
	end
	call lineout cfgsys

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<SECURITY2>"

	/* unlock files */
	'@call 'source'\updcd\bin\unlock.exe 'target'\security\bin\ssesctl.exe >> 'product_log
	'@call 'source'\updcd\bin\unlock.exe 'target'\security\dll\passwd.dll  >> 'product_log
	'@call 'source'\updcd\bin\unlock.exe 'target'\security\dll\sesmgr.dll  >> 'product_log

	/* delete files */
	call deldir target'\security'

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
