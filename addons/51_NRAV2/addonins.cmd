/* Installation of Norton Antivirus for OS/2 5.x                          */
/* Place all files of NAV and the actual virusdef ????o32.ZIP in this dir */
/* Last modified 01.21.2001                                               */
/* 05.25.2002: added support for uninstallation                           */
/* 06.08.2002: made warp 3 compatible                                     */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
product_rsp       = value("PRODUCT_RSP"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* check */
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' then exit 9

/* set nav package file */
NAV_PKG           = inst_dir'\NAVOS2.PKG'

/* find out component name */
component = ''
do while lines(NAV_PKG)
	l = linein(NAV_PKG)
	if pos('NAME', translate(l)) > 0 & pos('NORTON ANTIVIRUS', translate(l)) > 0 then do
		parse value l with name	'=' component
		leave
	end
end
call lineout NAV_PKG
if component = '' then component = 'Norton AntiVirus for OS/2'
else component = strip(space(strip(space(component), "T", ",")), "B", "'")

/* create response file */
dest_dir = product_drv'\'product_path
'echo COMP = 'component'                        >'product_rsp
'echo CFGUPDATE = AUTO                         >>'product_rsp
'echo DELETEBACKUP = NO                        >>'product_rsp
'echo OVERWRITE = YES                          >>'product_rsp
'echo SAVEBACKUP = NO                          >>'product_rsp
'echo FILE = 'dest_dir'                        >>'product_rsp
'echo AUX1 = 'dest_dir'\COMMON\SHARED\VIRUSDEF >>'product_rsp
'echo AUX2 = 'dest_dir'\VDEFTEMP               >>'product_rsp

/* the newest version of this shit product should be installed from HDU */
'mkdir 'target'\temp'
'mkdir 'target'\temp\navtemp'
'xcopy 'inst_dir'\* 'target'\temp\navtemp\.'

/* install */
target'\temp\navtemp\INSTALL.EXE /A:I /L1:'product_log' /L2:'product_log' /NMSG /O:DRIVE /R:'product_rsp' /X'

/* delete this shit */
'del 'target'\temp\navtemp\*.*_'
'del 'target'\temp\navtemp\nav*'
'del 'target'\temp\navtemp\epf*'
'del 'target'\temp\navtemp\ins*'
'del 'target'\temp\navtemp\*.zip'
'del 'target'\temp\navtemp\*.txt'
'del 'target'\temp\navtemp\*.cmd'
'rmdir 'target'\temp\navtemp'

/* Older NAV seems to install virus definitions on C: :-( */
'dir c:\SYMANTEC\COMMON\SHARED\VIRUSDEF'
instpath = 'warpsrv'
if stream(source'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'grpware'
if stream(source'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'ibminst'
if rc = 0 then do
	target'\'instpath'\unzip -o 'inst_dir'\????o32.ZIP -d C:\SYMANTEC\COMMON\SHARED\VIRUSDEF\INCOMING\. >> 'product_log' 2>>&1'
end
else do
	target'\'instpath'\unzip -o 'inst_dir'\????o32.ZIP -d 'dest_dir'\COMMON\SHARED\VIRUSDEF\INCOMING\. >> 'product_log' 2>>&1'
end

exit

/* uninstall mode */
uninstall:

	dest_dir = product_drv'\'product_path
	dest_dir'\VDEFINST.EXE /U'
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
