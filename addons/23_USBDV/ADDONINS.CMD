/* Installation script for USB support                                       */
/*                                                                           */
/* Unpack the distribution files in this directory. You need to unpack at    */
/* least usbbasic.exe. Other USB files are optional.                         */
/*                                                                           */
/* If there are conflicting files, use the most recent version. Exception is */
/* usbmon.exe which is available in the printer and in the MSD package.      */
/* Rename the PRT file to usbmonp.exe. Rename the MSD file to usbmonm.exe.   */
/*                                                                           */
/* An other optional package is usbcfg. Unzip the distribution zip here.     */
/*                                                                           */
/* 08.12.2001: fixed problem with copying usbmon.exe                         */
/* 05.26.2002: added support for uninstallation                              */
/* 04.11.2004: added support for USB MSD/CDROM                               */
/* 02.13.2006: added support for USBCFG, aligned with latest USB drv version */
/* 02.18.2006: added support for USBKBD, aligned with latest USB drv version */
/*             added support for USBMSD, aligned with latest USB drv version */
/* 02.25.2005: added support for USBAUDIO, USBETH, USBMODEM with latest ver. */
/* 04.18.2005: added support for USBSER package                              */
/* 06.03.2005: added support for USBQSER package                             */

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
if stream(inst_dir'\usbd.sys',    'c', 'query exists') = '' &,
   stream(inst_dir'\usbkbd.sys',  'c', 'query exists') = '' &,
   stream(inst_dir'\usbaudio.sys','c', 'query exists') = '' &,
   stream(inst_dir'\usbcom.sys',  'c', 'query exists') = '' &,
   stream(inst_dir'\usbmouse.sys','c', 'query exists') = '' &,
   stream(inst_dir'\usbprt.sys',  'c', 'query exists') = '' &,
   stream(inst_dir'\usbethr.os2', 'c', 'query exists') = '' &,
   stream(inst_dir'\usbmsd.add',  'c', 'query exists') = '' then exit 9

/* start */
Say
Say 'Starting installation...'
Call RxFuncAdd 'SysFileTree',     'RexxUtil', 'SysFileTree'
Call RxFuncAdd 'SysIni',          'RexxUtil', 'SysIni'
Call RxFuncAdd 'Syscreateobject', 'RexxUtil', 'Syscreateobject'

/* detect usb hw */
if stream(inst_dir'\hcimonit.exe', 'c', 'query exists') <> '' then do
	Say 
	Say 'Detecting USB hardware...'
	file.0 = target'\os2\$usb$.txt'
	usb. = ''; i=1;
	'@'inst_dir'\hcimonit.exe > 'file.0
	do while lines(file.0)
		l=linein(file.0)
		parse var l with 'You have 'usb.i.num' PCI USB 'usb.i.type' host controller(s)'
		if datatype(usb.i.num) = 'NUM' then i = i+1
	end
	call lineout file.0
	'@del 'file.0' >nul 2>>&1'
	usb.0 = i-1
	if usb.0 > 0 then
		do i=1 to usb.0
			say 'Detected: 'usb.i.type usb.i.num
		end
	else
		do
			say 'Detected no USB hardware. Exiting. '
			exit
		end
end
else do /* we cannot detect: fake UHCI HW */
	usb.0 = 1
	usb.1.type = 'UHCI'
	usb.1.num  = 1
end

/* add new USB .sys files */
Say 
Say 'Copying SYS files...'
call SysFileTree inst_dir'\usb*.sys', 'file.', 'FO'
do i = 1 to file.0
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\OS2\BOOT\. 	>> 'product_log
end
if stream(inst_dir'\ibmkbd.sys', 'c', 'query exists') <> '' then
	'@copy 'inst_dir'\ibmkbd.sys' target'\OS2\BOOT\. >> 'product_log

/* add new USB .add files */
Say 
Say 'Copying ADD files...'
call SysFileTree inst_dir'\usb*.add', 'file.', 'FO'
do i = 1 to file.0
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\OS2\BOOT\. 	>> 'product_log
end

/* copy .hlp, .pdr, .txt, usbmon.exe and hcimonit.exe */
Say 
Say 'Copying HLP, TXT, PDR and some EXE files...'
call SysFileTree inst_dir'\usb*.hlp', 'file.', 'FO'
do i = 1 to file.0
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\OS2\HELP\. 	>> 'product_log
end
call SysFileTree inst_dir'\usb*.txt', 'file.', 'FO'
do i = 1 to file.0
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\OS2\HELP\. 	>> 'product_log
end

/* usbprt */
call SysFileTree inst_dir'\usb*.pdr', 'file.', 'FO'
do i = 1 to file.0
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\OS2\DLL\.	>> 'product_log
end
if file.0 > 0 & stream(target'\OS2\DLL\usbprt.pdr', 'c', 'query exists') <> '' then do
	rc = SysIni('SYSTEM', 'PM_PORT_DRIVER', 'USBPRT', target'\OS2\DLL\USBPRT.PDR')
	'@echo Added PM_PORT_DRIVER for usbprt.pdr (rc='rc') >> 'product_log
	'@copy 'inst_dir'\usbmon.exe 'inst_dir'\usbmonp.exe >nul 2>>&1'
	file.i = inst_dir'\usbmonp.exe'
	if stream(file.i, 'c', 'query exists') <> '' then do
		'@echo Updating with 'file.i'	>> 'product_log
		'@copy 'file.i target'\OS2\usbmon.exe >> 'product_log
		rc = SysCreateObject('WPProgram', 'USBMON_Printer', '<WP_START>', 'PROGTYPE=WINDOWABLEVIO;MINIMIZED=YES;EXENAME='target'\os2\usbmon.exe;OBJECTID=<USB_MON_P>', 'R')
		'@echo created object usbmon.exe (rc='rc') >> 'product_log
	end
end

/* usbmsd */
file.i = inst_dir'\usbwarn.exe'
if stream(file.i, 'c', 'query exists') <> '' then do
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\OS2\boot\.	>> 'product_log
	'@copy 'inst_dir'\usbmon.exe 'inst_dir'\usbmonm.exe >nul 2>>&1'
	file.i = inst_dir'\usbmonm.exe'
	if stream(file.i, 'c', 'query exists') <> '' then do
		'@echo Updating with 'file.i' 	  >> 'product_log
		'@copy 'file.i target'\OS2\boot\usbmon.exe >> 'product_log
	end
	file.i = inst_dir'\usbicon.exe'
	if stream(file.i, 'c', 'query exists') <> '' then do
		'@echo Updating with 'file.i' 	  >> 'product_log
		'@copy 'file.i target'\OS2\boot\. >> 'product_log	
	end
	file.i = inst_dir'\usbwarn.msg'
	if stream(file.i, 'c', 'query exists') <> '' then do
		'@echo Updating with 'file.i'	  >> 'product_log
		'@copy 'file.i target'\OS2\boot\. >> 'product_log
	end
	file.i = inst_dir'\usbmon.ini'
	if stream(file.i, 'c', 'query exists') <> '' then do
		'@echo Updating with 'file.i' 	  >> 'product_log
		'@copy 'file.i target'\OS2\boot\. >> 'product_log
	end
	file.i = inst_dir'\usbmon.ico'
	if stream(file.i, 'c', 'query exists') <> '' then do
		'@echo Updating with 'file.i' 	  >> 'product_log
		'@copy 'file.i target'\OS2\boot\. >> 'product_log
	end
	file.i = inst_dir'\usbicon.cmd'
	if stream(file.i, 'c', 'query exists') <> '' then do
		'@echo Updating with 'file.i' 	  >> 'product_log
		'@copy 'file.i target'\OS2\boot\. >> 'product_log
		/* run msd cmd */
		cdir = directory()
		call directory target'\os2\boot'
		'@call usbicon.cmd >> 'product_log' 2>>&1'
		call directory cdir
	end
end

/* usb eth */
file.i = inst_dir'\usbethr.os2'
if stream(file.i, 'c', 'query exists') <> '' then do
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\ibmcom\macs\.	>> 'product_log
end
file.i = inst_dir'\usbethr.nif'
if stream(file.i, 'c', 'query exists') <> '' then do
	'@echo Updating with 'file.i' 		>> 'product_log
	'@copy 'file.i target'\ibmcom\macs\.	>> 'product_log
	Say 'Please run MPTS to configure the USB Ethernet driver.'
end

/* load config.sys */
Say
Say 'Reading Config.Sys...'
cfgfile = target'\config.sys'
i=1; found. = 0
do while lines(cfgfile)
	l.i = linein(cfgfile)
	if pos('BASEDEV=USBD.SYS',     translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbd     = 1
	if pos('BASEDEV=USBHID.SYS',   translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbhid   = 1
	if pos('BASEDEV=USBUHCD.SYS',  translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbuhcd  = 1
	if pos('BASEDEV=USBEHCD.SYS',  translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbehcd  = 1
	if pos('BASEDEV=USBOHCD.SYS',  translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbohcd  = 1
	if pos('BASEDEV=USBMSD.ADD',   translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbmsd   = 1
	if pos('BASEDEV=USBCDROM.ADD', translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbcdrom = 1
	if pos('USBKBD.SYS',           translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbkbd   = 1
	if pos('USBMOUSE.SYS',         translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbmouse = 1
	if pos('USBCOM.SYS',           translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbcom   = 1
	if pos('USBAUDIO.SYS',         translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbaudio = 1
	if pos('USBPRT.SYS',           translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbprt   = 1
	if pos('USBETHR.SYS',          translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbethr  = 1
	if pos('USBSER.SYS',           translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbser   = 1
	if pos('USBQSER.SYS',          translate(l.i)) > 0 & substr(translate(l.i), 1,3) <> 'REM' then found.usbqser  = 1
	i = i+1
end
rc = lineout(cfgfile)
l.0 = i-1

/* add USB base controllers */
do j=1 to usb.0
	select
		when usb.j.type = 'UHCI' & found.usbuhcd = 0 then do
			do k=1 to usb.j.num
				'@echo Adding UHCI base controller >> 'product_log
				l.0 = l.0+1
				i = l.0
				l.i = 'BASEDEV=USBUHCD.SYS'
			end
			l.0 = l.0+1
			i = l.0
		  	l.i = 'REM Add the /FS switch to BASEDEV=USBUHCD.SYS on IBM 365 systems'
		end
		when usb.j.type = 'OHCI' & found.usbohcd = 0 then do
			do k=1 to usb.j.num
				'@echo Adding OHCI base controller >> 'product_log
				l.0 = l.0+1
				i = l.0
				l.i = 'BASEDEV=USBOHCD.SYS'
			end
		end
		when usb.j.type = 'EHCI' & found.usbehcd = 0 then do
			do k=1 to usb.j.num
				'@echo Adding EHCI base controller >> 'product_log
				l.0 = l.0+1
				i = l.0
				l.i = 'BASEDEV=USBEHCD.SYS'
			end 
		end
		otherwise nop;
	end
end

/* add USB base driver */
if found.usbd = 0 then do
	'@echo Adding USB base driver >> 'product_log
	i = l.0+1
  	l.i = 'BASEDEV=USBD.SYS'
end

/* add USB HI driver */
if found.usbhid = 0 then do
	'@echo Adding USB HI driver >> 'product_log
	i = l.0+2
  	l.i = 'BASEDEV=USBHID.SYS'
	l.0 = l.0 + 2
end

/* add USB mouse */
if stream(inst_dir'\USBMOUSE.SYS', 'c', 'query exists') <> '' & found.usbmouse = 0 then do
	'@echo Adding USB mouse >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\OS2\BOOT\USBMOUSE.SYS'
	l.0 = l.0 + 1
end

/* add USB keyboard */
if stream(inst_dir'\USBKBD.SYS', 'c', 'query exists') <> '' & found.usbkbd = 0 then do
	'@echo Adding USB keyboard >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\OS2\BOOT\USBKBD.SYS'
	l.0 = l.0 + 1
end

/* add USB modem */
if stream(inst_dir'\USBCOM.SYS', 'c', 'query exists') <> '' & found.usbcom = 0 then do
	'@echo Adding USB comm >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\OS2\BOOT\USBCOM.SYS'
	l.0 = l.0 + 1
end

/* add USB audio */
if stream(inst_dir'\USBAUDIO.SYS', 'c', 'query exists') <> '' & found.usbaudio = 0 then do
	'@echo Adding USB audio >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\OS2\BOOT\USBAUDIO.SYS'
	l.0 = l.0 + 1
end

/* add USB printer */
if stream(inst_dir'\USBPRT.SYS', 'c', 'query exists') <> '' & found.usbprt = 0 then do
	'@echo Adding USB printer >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\OS2\BOOT\USBPRT.SYS'
	l.0 = l.0 + 1
end

/* add USB MSD */
if stream(inst_dir'\USBMSD.ADD', 'c', 'query exists') <> '' & found.usbmsd = 0 then do
	'@echo Adding USB MSD >> 'product_log
	i = l.0+1
	l.i = 'BASEDEV=USBMSD.ADD'
	l.0 = l.0 + 1
end

/* add USB cdrom */
if stream(inst_dir'\USBCDROM.ADD', 'c', 'query exists') <> '' & found.usbcdrom = 0 then do
	'@echo Adding USB CDROM >> 'product_log
	i = l.0+1
	l.i = 'BASEDEV=USBCDROM.ADD'
	l.0 = l.0 + 1
end

/* add USB ETH driver */
if stream(inst_dir'\USBETHR.OS2', 'c', 'query exists') <> '' & found.usbethr = 0 then do
	'@echo Adding USB Ethernet Driver >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\IBMCOM\MACS\USBETHR.SYS'
	l.0 = l.0 + 1
end

/* add USBSER/USBQSER */
if stream(inst_dir'\USBSER.SYS', 'c', 'query exists') <> '' & found.usbser = 0 then do
	'@echo Adding USBSER  >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\OS2\BOOT\USBSER.SYS'
	l.0 = l.0 + 1
end
if stream(inst_dir'\USBQSER.SYS', 'c', 'query exists') <> '' & found.usbqser = 0 then do
	'@echo Adding USBQSER  >> 'product_log
	i = l.0+1
	l.i = 'DEVICE='target'\OS2\BOOT\USBQSER.SYS'
	l.0 = l.0 + 1
end

/* update config.sys */
Say 'Writing Config.Sys...'
'@copy 'cfgfile' 'target'\os2\install\config.usb >> 'product_log
'@del 'cfgfile' >> 'product_log
do i = 1 to l.0
	call lineout cfgfile, l.i
end
call lineout cfgfile

/* install usbcfg */
if stream(inst_dir'\usbcfg.exe','c','query exists') <> '' then do
	cdir = directory()
	call directory inst_dir
	'@call install.cmd >> 'product_log' 2>>&1'
	call directory cdir
end

exit 

uninstall:

	/* update config.sys */
	found. = 0
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'@copy 'cfgfile target'\os2\install\config.usb >> 'product_log 
	'@del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('BASEDEV=USB', translate(l.q)) > 0 then iterate
		if pos('\OS2\BOOT\USB', translate(l.q)) > 0 then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

	/* destroy object */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<USB_MON>"
	call SysDestroyObject "<USBCFG_EXE>"

	/* delete from ini */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	rc = SysIni('SYSTEM', 'PM_PORT_DRIVER', 'USBPRT', 'DELETE:')

	/* delete files */
	'@del 'target'\os2\usbmon.exe     >> 'product_log
	'@del 'target'\os2\usbcfg.exe     >> 'product_log
	'@del 'target'\os2\usbcfg.hlp     >> 'product_log
	'@del 'target'\ecs\bin\usbcfg.exe >> 'product_log
	'@del 'target'\ecs\bin\usbcfg.hlp >> 'product_log
	'@del 'target'\os2\dll\usb*.pdr   >> 'product_log
	'@del 'target'\os2\boot\usb*.sys  >> 'product_log
	'@del 'target'\os2\boot\usb*.add  >> 'product_log
	'@del 'target'\os2\help\usb*.hlp  >> 'product_log
	'@del 'target'\os2\help\usb*.txt  >> 'product_log

return
