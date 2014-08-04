/* Amouse installation script                                  */
/* Unzip amou???.zip this directory                            */
/* Known problem: XFree86 3.3.6 traps or hangs the system in   */
/* combination with Amouse 1.01.                               */
/* 08.09.2001: added known problem description to header       */
/* 09.26.2001: added support for Amouse 2.0                    */
/* 10.06.2001: support for Amouse 2.0 German version           */
/* 05.25.2002: added support for uninstallation                */
/* 09.30.2005: aligned with os2mt                              */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_rsp       = value("PRODUCT_RSP"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
product_sel       = value("PRODUCT_SEL"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' then exit 9

Say
Say 'Starting installer...'

/* find out version */
file = inst_dir'\AMOUSE.ICF'
ver = 2
do while lines(file)
	l=linein(file)
	parse var l w1 w2 w3
	if w1 = "VRM" & w2 = "=" & w3 = "'010100'," then do
		ver = 1
		leave
	end
end
call lineout file

if ver = 2 then do

	/* copy install files to temp dir */
	'@mkdir 'target'\temp > nul 2>>&1'
	'@mkdir 'target'\temp\amouse'
	'@copy 'inst_dir'\* 'target'\temp\amouse\.'
	inst_dir = target'\temp\amouse'

	/* find out name configuration module */
	file = inst_dir'\amouse.pkg'
	i=1
	component1 = 'Driver'
	component2 = 'Configuration program'
	pos_iexit=0
	pos_epfiexts=0
	do while lines(file)
		l.i=linein(file)
		parse var l.i w1 w2 w3
		if w1 = "NAME" & w2 = "=" & w3 = "'Treiber'," then component1 = 'Treiber'
		if w1 = "NAME" & w2 = "=" & w3 = "'Konfigurationsprogramm'," then component2 = 'Konfigurationsprogramm'
		if w1 = "DLL" & w2 = "=" & w3 = "'IEXIT.DLL'" then pos_iexit = i
		if w1 = "DLL" & w2 = "=" & w3 = "'EPFIEXTS.DLL'" then pos_epfiexts = i
		i=i+1
	end
	call lineout file
	l.0=i-1

	/* disable selection interface */
	'@del 'file
	do i=1 to l.0
		if i >= pos_iexit-1 & i <= pos_epfiexts then l.i = '* 'l.i
		call lineout file, l.i
	end
	call lineout file

end

/* create response file */
dest_dir = product_drv'\'product_path
'@echo FILE = 'dest_dir'             	 	>  'product_rsp
if ver = 1 then
	'@echo COMP = Driver and WPS support 	>> 'product_rsp
else do
	'@echo COMP = 'component1'  		>> 'product_rsp
	'@echo COMP = 'component2'		>> 'product_rsp
end
'@echo CFGUPDATE = AUTO                		>> 'product_rsp
'@echo OVERWRITE = YES                 		>> 'product_rsp

/* CID install */
rc = value("SELCOMPONENT", product_sel, "OS2ENVIRONMENT")			
'@'inst_dir'\INSTALL /L1:'product_log' /L2:'product_log' /X /R:'product_rsp

/* repare phase2.cmd, it is buggyyyy in version 010100 */
if ver = 1 then do
	cmdfile = dest_dir'\phase2.cmd'
	i=1
	do while lines(cmdfile)
		l.i = linein(cmdfile)
		if substr(translate(l.i), 1, 24) = "SYSCREATEOBJECT('AMOUSE'" then l.i = 'rc = 'l.i
		i = i + 1
	end
	call lineout cmdfile
	l.0 = i - 1
	'@del 'cmdfile' >nul 2>>&1'
	do i = 1 to l.0
		call lineout cmdfile, l.i
	end
	call lineout cmdfile
end

/* clean up */
if ver = 2 then do
	'@attrib -r 'inst_dir'\*'
	call RxFuncAdd 'Sysfiletree', 'RexxUtil', 'Sysfiletree'
	call sysfiletree inst_dir'\*', 'tmp.', 'FO'
	do i=1 to tmp.0
		'@del 'tmp.i
	end
	'@rmdir 'inst_dir
end
	
Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	dest_dir = product_drv'\'product_path
	dest_dir'\EPFINSTS.EXE /C:'dest_dir'\AMOUSE.ICF /O:DRIVE /P:"Amouse" /A:D /NMSG'

return
