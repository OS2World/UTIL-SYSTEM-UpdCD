/* OpenSSH installation script                                       */
/*                                                                   */
/* Place the following files in this directory:                      */
/* 1. OpenSSH distribution file, rename it to openssh.zip            */
/* 2. Vioroute package, rename it to vioroute.zip                    */
/*                                                                   */
/* Default uid/pwd = root                                            */
/*                                                                   */
/* 29.05.2004: created                                               */
/* 03.10.2004: added support for Security/2, made fully unattended   */
/* 26.10.2004: added object creation + small improvements            */
/* 29.10.2004: uninstallation improved                               */
/* 06.11.2004: more (un)installation improvements                    */
/* 29.11.2004: warpstock europe 2004 improvements                    */ 
/* 29.09.2005: aligned with os2mt                                    */
/* 14.10.2005: Security/2 moved to separate addon slot               */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_port      = value("PRODUCT_PORT"     , ,"OS2ENVIRONMENT")
product_string    = value("PRODUCT_STRING"   , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* things we need to know */
parse upper value value('PATH',,'OS2ENVIRONMENT') with ':\OS2\SYSTEM' -1 target +2
cfgsys      = target'\CONFIG.SYS'
etc         = value('ETC',,'os2environment')
unixroot    = value('UNIXROOT',,'os2environment')
mptnbin     = translate(value('PATH',,'os2environment'))
mptnbin     = substr(mptnbin, pos(':\MPTN\BIN',mptnbin)-1, 11)
mptndll     = substr(mptnbin, 1, 8)'DLL'
mptndoc     = substr(mptnbin, 1, 8)'DOC'
if unixroot <> '' then etc = unixroot'\ETC'
'@mkdir 'mptndoc' >nul 2>>&1'
'@mkdir 'mptndoc'\ssh >nul 2>>&1'
'@mkdir 'etc' >nul 2>>&1'
cdir = directory()

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\openssh.zip', 'c', 'query exists') = '' then exit 9
call directory inst_dir

/* check files */
Say
Say ' Checking files...'
call check_file 'openssh.zip'
call check_file 'vioroute.zip'

/* check emx */
Say
Say ' Checking EMX...'
trace off
'@call emxrev >nul 2>>&1'
rcode = rc
trace on
if rcode <> 0 then do
	Say ' -> EmxRev.CMD has returned 'rc
	Say ' -> EMX might not be installed'
end
else do
	Say ' -> EmxRev.Cmd has returned 'rc
	Say ' -> EMX seems to be installed'
end

/* check environment */
user = space(value('USER',,'os2environment'))
if user = '' then do
	user = 'os2user'
	call value 'USER',user,'os2environment'
	Say
	Say ' Adding SET USER='user' to your Config.Sys...'
	'@echo SET USER='user' >> 'cfgsys
end
hostname = space(value('HOSTNAME',,'os2environment'))
if hostname = '' then do
	hostname = 'os2host'
	call value 'HOSTNAME',hostname,'os2environment'
	Say
	Say ' Adding SET HOSTNAME='hostname' to your Config.Sys...'
	'@echo SET HOSTNAME='hostname' >> 'cfgsys
end
home = space(value('HOME',,'os2environment'))
if home = '' then do
	Say
	Say ' Your homedir is unknown.'
	home = target'\home\'user
	'@mkdir 'target'\home >nul 2>>&1'
	'@mkdir 'target'\home\'user' >nul 2>>&1'
	Say
	Say ' 'home' will be used as your home directory.'
	call value 'HOME',home,'os2environment'
	Say ' Adding SET HOME='home' to your Config.Sys...'
	'@echo SET HOME='home' >> 'cfgsys
end

/* create config */
Say
Say ' Creating SSHD configuration in 'etc'\SSH...'
'@mkdir 'etc'\SSH >nul 2>>&1'
'@unzip -ojC 'inst_dir'\openssh.zip etc\ssh\* -d 'etc'\ssh\. >> 'product_log
'@unzip -ojC 'inst_dir'\vioroute.zip term.cfg -d 'etc'\.     >> 'product_log
sshdcfg = etc'\ssh\sshd_config' 
'@copy 'sshdcfg' 'etc'\ssh\sshd_config.org >> 'product_log
'@echo port 'product_port' > 'sshdcfg
'@echo Protocol 2  >> 'sshdcfg
'@echo HostKey 'etc'\ssh\ssh_host_dsa_key >> 'sshdcfg
'@echo LoginGraceTime 300  >> 'sshdcfg
'@echo Banner 'etc'\ssh_banner.txt  >> 'sshdcfg
'@echo IgnoreUserKnownHosts yes  >> 'sshdcfg
'@echo PasswordAuthentication yes  >> 'sshdcfg
'@echo SyslogFacility AUTH >> 'sshdcfg
'@echo LogLevel INFO >> 'sshdcfg
'@echo PermitRootLogin yes >> 'sshdcfg
'@echo StrictModes yes >> 'sshdcfg
'@echo RSAAuthentication no >> 'sshdcfg
'@echo PubkeyAuthentication yes >> 'sshdcfg
'@echo AuthorizedKeysFile .ssh/authorized_keys >> 'sshdcfg
'@echo IgnoreRhosts yes >> 'sshdcfg
'@echo RhostsRSAAuthentication no >> 'sshdcfg
'@echo HostbasedAuthentication no >> 'sshdcfg
'@echo PermitEmptyPasswords no >> 'sshdcfg
'@echo ChallengeResponseAuthentication no >> 'sshdcfg
'@echo MaxStartups 10 >> 'sshdcfg
'@echo ClientAliveInterval 600 >> 'sshdcfg
'@echo ClientAliveCountMax 3 >> 'sshdcfg
'@echo Subsystem sftp 'mptnbin'\sftp-server.exe >> 'sshdcfg

/* create banner */
banner = etc'\ssh_banner.txt'
'@echo+ > 'banner
'@echo                             ****USAGE WARNING**** >> 'banner
'@echo+ >> 'banner
'@echo This is a private computer system. This computer system, including all >> 'banner
'@echo related equipment, networks, and network devices (specifically including >> 'banner
'@echo Internet access) are provided only for authorized use. This computer system >> 'banner
'@echo may be monitored for all lawful purposes, including to ensure that its use >> 'banner
'@echo is authorized, for management of the system, to facilitate protection against >> 'banner
'@echo unauthorized access, and to verify security procedures, survivability, and >> 'banner
'@echo operational security. Monitoring includes active attacks by authorized entities >> 'banner
'@echo to test or verify the security of this system. During monitoring, information >> 'banner
'@echo may be examined, recorded, copied and used for authorized purposes. All >> 'banner
'@echo information, including personal information, placed or sent over this system >> 'banner
'@echo may be monitored. >> 'banner
'@echo+ >> 'banner
'@echo Use of this computer system, authorized or unauthorized, constitutes consent >> 'banner
'@echo to monitoring of this system. Unauthorized use may subject you to criminal >> 'banner
'@echo prosecution. Evidence of unauthorized use collected during monitoring may be >> 'banner
'@echo used for administrative, criminal, or other adverse action. Use of this system >> 'banner
'@echo constitutes consent to monitoring for these purposes. >> 'banner
'@echo+ >> 'banner

/* unzip/copy binaries */
Say
Say ' Copying OpenSSH files...'
'@unzip -ojC 'inst_dir'\vioroute.zip *.exe       -d 'mptnbin'\.         >> 'product_log
'@unzip -ojC 'inst_dir'\vioroute.zip *.dll       -d 'mptndll'\.         >> 'product_log
'@unzip -ojC 'inst_dir'\openssh.zip  *.exe       -d 'mptnbin'\.         >> 'product_log
'@unzip -ojC 'inst_dir'\openssh.zip  *.dll       -d 'mptndll'\.         >> 'product_log
'@unzip -ojC 'inst_dir'\openssh.zip  *.inf       -d 'mptndoc'\ssh\.     >> 'product_log
'@unzip -ojC 'inst_dir'\openssh.zip  readme.eng  -d 'mptndoc'\ssh\.     >> 'product_log
'@unzip -ojC 'inst_dir'\openssh.zip  docs\*      -d 'mptndoc'\ssh\.     >> 'product_log
'@unzip -ojC 'inst_dir'\openssh.zip  OpenSSH.ICO -d 'target'\os2\.      >> 'product_log

/* tune Config.Sys */
i = 1
do while lines(cfgsys)
	l.i = linein(cfgsys)
	if translate(substr(l.i,1,16)) = 'BASEDEV=SSES.SYS' & pos('/SUANYUSER', translate(l.i)) = 0 then 
		l.i = 'BASEDEV=SSES.SYS /suanyuser'
	i=i+1
end
call lineout cfgsys
l.0=i-1
'@copy 'cfgsys' 'target'\Config.SSH >> 'product_log' 2>>&1'
'@del 'cfgsys' >> 'product_log' 2>>&1'
do i=1 to l.0
	call lineout cfgsys, l.i
end
call lineout cfgsys

/* add user to pwd file with pwd of root */
pwdcfg = target'\security\etc\passwd'
i=1
root_pwd = ''
found_user = 0
do while lines(pwdcfg)
	l.i = linein(pwdcfg)
	parse value l.i with usr ':' pwd ':' uid ':' .
	if translate(usr) = 'ROOT' then root_pwd = pwd
	if translate(usr) = translate(user) then found_user = 1
	i=i+1
end
l.0=i-1
call lineout pwdcfg
if found_user = 0 then do
	call lineout pwdcfg, user':'root_pwd':'uid+1':0::$'space(translate(home,'',':'),0)':$'space(translate(target,'',':'),0)'\OS2\CMD.EXE:$'space(translate(mptnbin,'',':'),0)'\VIOSTART.EXE'
	call lineout pwdcfg
end

/* create keys */
Say
Say ' Starting key generation...'
'@mkdir 'home'\.ssh >nul 2>>&1'
'@mkdir 'target'\os2\.ssh >nul 2>>&1'
usr_cmd = mptnbin'\GenUsrK.Cmd'
'@del 'usr_cmd' >nul 2>>&1'
call lineout usr_cmd, "/* key generation */"
call lineout usr_cmd, "Say"
call lineout usr_cmd, "parse arg p1 p2 p3 p4 p5"
call lineout usr_cmd, "user = space(value('USER',,'OS2ENVIRONMENT'))"
call lineout usr_cmd, "home = space(value('HOME',,'OS2ENVIRONMENT'))"
call lineout usr_cmd, "if p1 <> ''& p2 <> '' & p3 <> '' & p4 <> '' then call generate"
call lineout usr_cmd, "Say ' This script will (re)generate your user keys (private/public).'"
call lineout usr_cmd, "Say ' Usage  : GenUsrK.Cmd user [type:rsa/rsa1/dsa] [length:512/1024/2048]'"
call lineout usr_cmd, "Say '          [keyfile] [passphrase (optional)]'"
call lineout usr_cmd, "Say ' Default parameters: 'user' dsa 2048 'home'\.ssh\id_dsa'"
call lineout usr_cmd, "Say"
call lineout usr_cmd, "'@pause'"
call lineout usr_cmd, "call generate"
call lineout usr_cmd, "exit"
call lineout usr_cmd, "generate:"
call lineout usr_cmd, "'@"target"'"
call lineout usr_cmd, "'@cd "mptnbin"'"
call lineout usr_cmd, "if p1 <> '' then do; user = p1; call value 'USER',user,'OS2ENVIRONMENT'; end"
call lineout usr_cmd, "if p2 <> '' then keytype = p2; else keytype = 'dsa'"
call lineout usr_cmd, "if p3 <> '' then keylength = p3; else keylength = 2048"
call lineout usr_cmd, "if p4 <> '' then keyfile = p4; else keyfile = home'\.ssh\id_dsa'"
call lineout usr_cmd, "if p5 <> '' then keyphrase = p5; else keyphrase = ''"
call lineout usr_cmd, "Say"
call lineout usr_cmd, "Say ' Generating user keys for 'user' in 'keyfile'...'"
call lineout usr_cmd, "'@del 'keyfile' >nul 2>>&1'"
call lineout usr_cmd, "trace off"
call lineout usr_cmd, "'@su -p root -c dir>nul root >nul 2>>&1'"
call lineout usr_cmd, "rcode = rc"
call lineout usr_cmd, "trace on"
call lineout usr_cmd, "if rcode = 0 then do"
call lineout usr_cmd, "	temp_cmd = '"mptnbin"\GenKTemp.Cmd'"
call lineout usr_cmd, "	'@echo @"mptnbin"\ssh-keygen.exe -q -b 'keylength' -t 'keytype' -f 'keyfile' -N ""'keyphrase'"" > 'temp_cmd"
call lineout usr_cmd, "	'@su -c 'temp_cmd' 'user"
call lineout usr_cmd, "	'@del 'temp_cmd' >nul'"
call lineout usr_cmd, "end"
call lineout usr_cmd, "else"
call lineout usr_cmd, "	'@"mptnbin"\ssh-keygen.exe -q -b 'keylength' -t 'keytype' -f 'keyfile' -N ""'keyphrase'""'"
call lineout usr_cmd, "if stream(home'\.ssh\authorized_keys','c','query exists') = '' then '@copy 'keyfile'.pub 'home'\.ssh\authorized_keys >nul'"
call lineout usr_cmd, "else '@copy 'home'\.ssh\authorized_keys+'keyfile'.pub 'home'\.ssh\authorized_keys >nul'"
call lineout usr_cmd
'@call 'usr_cmd' 'user' dsa 2048 'home'\.ssh\id_dsa 'product_string
'@call 'usr_cmd' root dsa 2048 'target'\os2\.ssh\id_dsa rootroot'

sys_cmd = mptnbin'\GenSysK.Cmd'
'@del 'sys_cmd' >nul 2>>&1'
call lineout sys_cmd, "/* key generation */"
call lineout sys_cmd, "Say"
call lineout sys_cmd, "parse arg p1 p2 p3 p4"
call lineout sys_cmd, "host = space(value('HOSTNAME',,'OS2ENVIRONMENT'))"
call lineout sys_cmd, "etc  = space(value('ETC',     ,'OS2ENVIRONMENT'))"
call lineout sys_cmd, "uxrt = space(value('UNIXROOT',,'OS2ENVIRONMENT'))"
call lineout sys_cmd, "if uxrt <> '' then etc = uxrt'\etc'"
call lineout sys_cmd, "if p1 <> ''& p2 <> '' & p3 <> '' & p4 <> '' then call generate"
call lineout sys_cmd, "Say ' This script will (re)generate your system keys (private/public).'"
call lineout sys_cmd, "Say ' Usage  : GenSysK.Cmd host [type:rsa/rsa1/dsa] [length:512/1024/2048] [keyfile]'"
call lineout sys_cmd, "Say ' Default parameters: 'host' dsa 2048 'etc'\ssh\ssh_host_dsa_key'"
call lineout sys_cmd, "Say"
call lineout sys_cmd, "'@pause'"
call lineout sys_cmd, "call generate"
call lineout sys_cmd, "exit"
call lineout sys_cmd, "generate:"
call lineout sys_cmd, "'@"target"'"
call lineout sys_cmd, "'@cd "mptnbin"'"
call lineout sys_cmd, "if p1 <> '' then do; host = p1; call value 'HOSTNAME',host,'OS2ENVIRONMENT'; end"
call lineout sys_cmd, "if p2 <> '' then keytype = p2; else keytype = 'dsa'"
call lineout sys_cmd, "if p3 <> '' then keylength = p3; else keylength = 2048"
call lineout sys_cmd, "if p4 <> '' then keyfile = p4; else keyfile = etc'\ssh\ssh_host_dsa_key'"
call lineout sys_cmd, "Say"
call lineout sys_cmd, "Say ' Generating server keys for 'host' in 'etc'\ssh...'"
call lineout sys_cmd, "'@del 'keyfile' >nul 2>>&1'"
call lineout sys_cmd, "'@"mptnbin"\ssh-keygen.exe -q -b 'keylength' -t 'keytype' -f 'keyfile' -N """"'"
call lineout sys_cmd
'@call 'sys_cmd' 'hostname' dsa 2048 'etc'\ssh\ssh_host_dsa_key'

vnc_cmd = mptnbin'\S_VNC_CH.Cmd'
'@del 'vnc_cmd' >nul 2>>&1'
call lineout vnc_cmd, "/* start secure channel for VNC client */"
call lineout vnc_cmd, "parse arg host user"
call lineout vnc_cmd, "if host = '' then do"
call lineout vnc_cmd, "	Say"
call lineout vnc_cmd, "	Say 'Please specify the name of your VNC server'"
call lineout vnc_cmd, "	parse pull host"
call lineout vnc_cmd, "	Say 'Please specify your SSH username'"
call lineout vnc_cmd, "	parse pull user"
call lineout vnc_cmd, "end"
call lineout vnc_cmd, ""
call lineout vnc_cmd, "Say 'Do not close this window when you use your VNC client!'"
call lineout vnc_cmd, "'ssh -l 'user' -2 -N -L 5900:127.0.0.1:5900 'host"
call lineout vnc_cmd, "'pause'"
call lineout vnc_cmd

pop_cmd = mptnbin'\S_POP_CH.Cmd'
'@del 'pop_cmd' >nul 2>>&1'
call lineout pop_cmd, "/* start secure channel for POP client */"
call lineout pop_cmd, "parse arg host user"
call lineout pop_cmd, "if host = '' then do"
call lineout pop_cmd, "	Say"
call lineout pop_cmd, "	Say 'Please specify the name of your POP server'"
call lineout pop_cmd, "	parse pull host"
call lineout pop_cmd, "	Say 'Please specify your SSH username'"
call lineout pop_cmd, "	parse pull user"
call lineout pop_cmd, "end"
call lineout pop_cmd, ""
call lineout pop_cmd, "Say 'Do not close this window when you use your email client!'"
call lineout pop_cmd, "'ssh -l 'user' -2 -N -L 25:127.0.0.1:25 -L 110:127.0.0.1:110 'host"
call lineout pop_cmd, "'pause'"
call lineout pop_cmd

/* inform */
Say
Say ' Creating objects...'
readme1 = home'\readme.1st'
'@del 'readme1' >nul 2>>&1'
call lineout readme1, 'Root user = root, pwd = root, keytype dsa, passphrase = rootroot'
call lineout readme1, 'Test user = test, pwd = test, no key, no passphrase'
call lineout readme1, 'Your user ID = 'user', pwd = root, keytype dsa, passphrase = 'product_string
call lineout readme1, ''
call lineout readme1, 'Start SSH  daemon with the command "start sshd"'
call lineout readme1, 'Start SSH  client with the command "ssh -l 'user' <hostname>"'
call lineout readme1, 'Start SFTP client with the command "sftp 'user'@<hostname>"'
call lineout readme1, ''
call lineout readme1, 'If you have problems, try the debug options (sshd -ddd, ssh -vv)'
call lineout readme1, 'check if you use the right user (whoami) and/or key, etc.'
call lineout readme1

/* create folders */
call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
call SysCreateObject 'WPFolder', 'OpenSSH', '<WP_DESKTOP>','OBJECTID=<OPENSSH>;'||'ALWAYSSORT=YES;ICONFILE='target'\OS2\OpenSSH.ICO','R'
call SysCreateObject 'WPFolder', 'OpenSSH^Configuration', '<OPENSSH>','OBJECTID=<OPENSSH-C>;'||'ALWAYSSORT=YES;','R'
call SysCreateObject 'WPFolder', 'OpenSSH^Documentation', '<OPENSSH>','OBJECTID=<OPENSSH-D>;'||'ALWAYSSORT=YES;','R'
call SysCreateObject 'WPFolder', 'OpenSSH^Executables', '<OPENSSH>','OBJECTID=<OPENSSH-E>;'||'ALWAYSSORT=YES;','R'

/* create config objects */
aclcfg = target'\security\etc\acls' 
call SysCreateObject 'WPProgram','OpenSSH^Configuration','<OPENSSH-C>','EXENAME=epm.exe;PARAMETERS='sshdcfg,'R'
call SysCreateObject 'WPProgram','OpenSSH^Banner','<OPENSSH-C>','EXENAME=epm.exe;PARAMETERS='etc'\ssh_banner.txt','R'

/* create documentation objects */
call SysCreateObject 'WPProgram','OpenSSH^Readme 1st','<OPENSSH-D>','EXENAME=epm.exe;PARAMETERS='readme1';OPEN=DEFAULT;','R'
call SysCreateObject 'WPProgram','OpenSSH^4 OS/2','<OPENSSH-D>','EXENAME=VIEW.EXE;PARAMETERS='mptndoc'\ssh\OPEN-SSH_4OS2.INF','R'
call SysCreateObject 'WPProgram','OpenSSH^Readme','<OPENSSH-D>','EXENAME=epm.exe;PARAMETERS='mptndoc'\ssh\readme.eng','R'
call RxFuncAdd 'SysCreateShadow', 'RexxUtil', SysCreateShadow
call SysCreateShadow mptndoc'\ssh','<OPENSSH-D>'

/* create executable objects */
call SysCreateObject 'WPProgram','Start SSHD','<OPENSSH-E>','EXENAME=CMD.EXE;PARAMETERS=/K SSHD.EXE','R'
call SysCreateObject 'WPProgram','Generate^User Key','<OPENSSH-E>','EXENAME=CMD.EXE;PARAMETERS=/K GenUsrK.cmd','R'
call SysCreateObject 'WPProgram','Generate^System Key','<OPENSSH-E>','EXENAME=CMD.EXE;PARAMETERS=/K GenSysK.cmd','R'
call SysCreateObject 'WPProgram','Who am I?','<OPENSSH-E>','EXENAME=whoami.exe;NOAUTOCLOSE=YES','R'
call SysCreateObject 'WPProgram','Switch User^Session to 'user,'<OPENSSH-E>','EXENAME=Su.Exe;PARAMETERS=-p root -m -s 'target'\os2\cmd.exe -c exit 'user,'R'
call SysCreateObject 'WPProgram','Open Shell for^User 'user,'<OPENSSH-E>','EXENAME=Su.Exe;PARAMETERS=-p root -s 'target'\os2\cmd.exe 'user,'R'
call SysCreateObject 'WPProgram','Secure Channel^for VNC server','<OPENSSH-E>','EXENAME='mptnbin'\S_VNC_CH.Cmd','R'
call SysCreateObject 'WPProgram','Secure Channel^for POP server','<OPENSSH-E>','EXENAME='mptnbin'\S_POP_CH.Cmd','R'

/* ready */
Say
Say ' Finished installation. Please reboot your system now.'
call directory cdir

exit

/* check if file exists */
check_file: procedure

	parse arg file
	if stream(file, 'c', 'query exists') = '' then do
		Say ' -> 'file' is missing, aborting...'
		exit
	end
	Say ' -> Found 'file

return

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<OPENSSH>"

	/* delete files */
	call deldir etc'\ssh'
	call deldir mptndoc'\ssh'
	'@del 'mptnbin'\ssh*.exe          >> 'product_log
	'@del 'mptnbin'\scp*.exe          >> 'product_log
	'@del 'mptnbin'\sftp*.exe         >> 'product_log
	'@del 'mptnbin'\vioroute*.exe     >> 'product_log
	'@del 'mptndll'\vioroute.dll      >> 'product_log
	'@del 'mptndll'\userctl.dll       >> 'product_log
	'@del 'etc'\term.cfg              >> 'product_log
	'@del 'etc'\ssh_banner.txt        >> 'product_log

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
