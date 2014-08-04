/* Samba/2 installation script                                       */
/*                                                                   */
/* Place the following files in this directory:                      */
/* 1. Samba/2 distribution file, rename it to samba.zip              */
/*                                                                   */
/* 15.10.2005: created                                               */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* things we need to know */
cfgsys  = target'\CONFIG.SYS'
etc     = value('ETC',,'os2environment')
mptnbin = translate(value('PATH',,'os2environment'))
mptnbin = substr(mptnbin, pos(':\MPTN\BIN',mptnbin)-1, 11)
mptndll = substr(mptnbin, 1, 8)'DLL'
mptndoc = substr(mptnbin, 1, 8)'DOC'
mptnlog = substr(mptnbin, 1, 8)'LOG'
'@mkdir 'mptndoc' >nul 2>>&1'
'@mkdir 'mptndoc'\samba >nul 2>>&1'
'@mkdir 'mptnlog' >nul 2>>&1'
'@mkdir 'mptnlog'\samba >nul 2>>&1'
'@mkdir 'etc' >nul 2>>&1'
'@mkdir 'target'\tmp >nul 2>>&1'

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\samba.zip', 'c', 'query exists') = '' then exit 9

/* create config */
Say
Say ' Creating Samba configuration in 'etc'\SAMBA...'
'@mkdir 'etc'\SAMBA >nul 2>>&1'
'@unzip -oC 'inst_dir'\samba.zip *etc* -d 'inst_dir'\. >> 'product_log
'@xcopy 'inst_dir'\etc\* 'etc'\. /S/E >> 'product_log
call RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
call SysFileTree etc'\smb.conf', 'Files.', 'FSO'
if Files.0 > 0 then 
	sambacfg = Files.1
else 
	sambacfg = etc'\samba\smb.conf' 

/* unzip/copy binaries */
Say
Say ' Copying Samba/2 files...'
'@unzip -ojC 'inst_dir'\samba.zip *.exe      -d 'mptnbin'\. >> 'product_log
'@unzip -ojC 'inst_dir'\samba.zip *.dll      -d 'mptndll'\. >> 'product_log
'@unzip -ojC 'inst_dir'\samba.zip readme.os2 -d 'mptndoc'\samba\. >> 'product_log

usr_cmd = mptnbin'\AddSMBUr.Cmd'
'@del 'usr_cmd' >nul 2>>&1'
call lineout usr_cmd, "/* add Samba/2 use */"
call lineout usr_cmd, "Say"
call lineout usr_cmd, "'@whoami'"
call lineout usr_cmd, "Say"
call lineout usr_cmd, "Say 'Add Security/2 user above to Samba user database'"
call lineout usr_cmd, "'@pause'"
call lineout usr_cmd, "'@smbpasswd.exe -La'"
call lineout usr_cmd, "'@pause'"
call lineout usr_cmd, "exit"
call lineout usr_cmd

/* inform */
Say
Say ' Creating objects...'

/* create objects */
call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
call SysCreateObject 'WPFolder', 'SAMBA/2', '<WP_DESKTOP>','OBJECTID=<SAMBA2>;'||'ALWAYSSORT=YES','R'
call SysCreateObject 'WPProgram','SAMBA/2^Configuration','<SAMBA2>','EXENAME=epm.exe;PARAMETERS='sambacfg,'R'
call SysCreateObject 'WPProgram','SAMBA/2^Readme','<SAMBA2>','EXENAME=epm.exe;PARAMETERS='mptndoc'\samba\readme.os2;OPEN=DEFAULT;','R'
call SysCreateObject 'WPProgram','SAMBA/2 Server','<SAMBA2>','EXENAME='mptnbin'\SMBD.EXE;STARTUPDIR='mptnlog'\samba','R'
call SysCreateObject 'WPProgram','SAMBA/2 Server^Debug Mode','<SAMBA2>','EXENAME='mptnbin'\SMBD.EXE;PARAMETERS=-d 2;STARTUPDIR='mptnlog'\samba','R'
call SysCreateObject 'WPProgram','Add SAMBA/2^User','<SAMBA2>','EXENAME='usr_cmd,'R'
call RxFuncAdd 'SysCreateShadow', 'RexxUtil', 'SysCreateShadow'
call SysCreateShadow mptnlog,'<SAMBA2>'
call RxFuncAdd 'SysSetObjectData', 'RexxUtil', 'SysSetObjectData'
call SysSetObjectData mptnlog, 'DEFAULTVIEW=DETAILS'

/* ready */
Say
Say ' Finished installation.'

exit

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<SAMBA2>"

	/* delete files */
	call deldir etc'\samba'
	call deldir mptndoc'\samba'
	'@del 'mptnbin'\smb*.exe      >> 'product_log
	'@del 'mptndll'\libc*.dll     >> 'product_log
	'@del 'mptnbin'\profiles.exe  >> 'product_log
	'@del 'mptnbin'\rpcclient.exe >> 'product_log
	'@del 'mptnbin'\pdbedit.exe   >> 'product_log
	'@del 'mptnbin'\tdbdump.exe   >> 'product_log
	'@del 'mptnbin'\nmblookup.exe >> 'product_log
	'@del 'mptnbin'\tdbbackup.exe >> 'product_log
	'@del 'mptnbin'\testparm.exe  >> 'product_log
	'@del 'mptnbin'\net.exe       >> 'product_log
	'@del 'mptnbin'\nmbd.exe      >> 'product_log

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
