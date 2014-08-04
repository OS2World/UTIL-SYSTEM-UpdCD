/* Install Xfree86 4.3.0/4.4.0 for OS/2 (use addonins.336 for ver. 3.3.6)   */
/*                                                                          */
/* The EMX run-time should be installed first. The target partition should  */
/* support long file names (HPFS, JFS, FAT32, etc).                         */
/*                                                                          */
/* Version 4.3.0:                                                           */
/* Place the following packages (zips) here: BIN.ZIP, LIB.ZIP, X11.ZIP      */
/* FONTS.ZIP, FONTS100DPI.ZIP, FONTS75DPI.ZIP                               */
/*                                                                          */
/* Version 4.4.0:                                                           */
/* Place the following packages (zips) here: XBIN440.ZIP, X11_440.ZIP       */
/* XLIB440.ZIP, XFONTS440.ZIP, XFONTS75DPI440.ZIP.                          */
/* Other packages (XDOC, FONTS100, PROG) of 4.4.0 are optional.             */
/*                                                                          */
/* Version 4.5.0:                                                           */
/* Place the following packages (zips) here: X450bin.zip, X450X11.zip       */
/* X450sup.zip, X450lib.zip, X450fnts.zip, X450f75dpi.zip.                  */
/* Other packages (like X450doc.zip) of 4.5.0 are optional.                 */
/*                                                                          */
/* 08.09.2001: added known problem description to header                    */
/* 05.26.2002: added support for uninstallation                             */
/* 03.14.2003: updated for version 4.3.0                                    */
/* 10.03.2004: updated for version 4.4.0                                    */
/* 27.03.2005: updated for version 4.5.0                                    */
/* 30.09.2005: aligned with os2mt                                           */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* define strings */
if stream(inst_dir'\XBIN440.ZIP', 'c', 'query exists') <> '' | stream(inst_dir'\X450bin.zip', 'c', 'query exists') <> '' then do
	s_root    = 'USR\X11R6'
	s_path    = 'USR\X11R6\BIN'
	s_libpath = 'USR\X11R6\LIB'
end
else do
	s_root    = 'XFREE86'
	s_path    = 'XFREE86\BIN'
	s_libpath = 'XFREE86\LIB'
end

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\BIN.ZIP', 'c', 'query exists') = '' & stream(inst_dir'\XBIN440.ZIP', 'c', 'query exists') = '' & stream(inst_dir'\X450bin.zip', 'c', 'query exists') = '' then exit 9

/* define X server */
xserver.exe = 'XFREE86.EXE' 

/* unpack zips */
Say
Say 'Unpacking files...'
rc = RxFuncAdd('SysFileTree', 'RexxUtil', 'SysFileTree')
rc = SysFileTree(inst_dir'\*.zip', 'zip.', 'FO')
do i = 1 to zip.0 
	'@unzip -o 'zip.i' -d 'product_drv'\. >> 'product_log 
end

/* read the config.sys */
Say
Say 'Updating Config.Sys...'
cfgfile = target'\config.sys'
q = 1
found. = 0
do while lines(cfgfile)
	l.q = linein(cfgfile)

	/* libpath */
	if pos('LIBPATH=', translate(l.q)) > 0 & pos(s_libpath, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || product_drv'\'s_libpath';'
		else l.q = l.q || ';' || product_drv'\'s_libpath';'
	end

	/* path */
	if pos('SET PATH=', translate(l.q)) > 0 & pos(s_path, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || product_drv'\'s_path';'
		else l.q = l.q || ';' || product_drv'\'s_path';'
	end

	/* environment settings */
	if pos('SET HOSTNAME=', translate(l.q)) > 0 then found.hostname = 1
	if pos('SET X11ROOT=',  translate(l.q)) > 0 then found.x11root  = 1
	if pos('SET HOME=',     translate(l.q)) > 0 then found.home     = 1
	if pos('SET USER=',     translate(l.q)) > 0 then found.user     = 1
	if pos('SET LOGNAME=',  translate(l.q)) > 0 then found.logname  = 1
	if pos('SET TERMCAP=',  translate(l.q)) > 0 then found.termcap  = 1
	if pos('SET TERM=',     translate(l.q)) > 0 then found.term     = 1
	if pos('SET DISPLAY=',  translate(l.q)) > 0 then found.display  = 1
	if pos('SET XSERVER=',  translate(l.q)) > 0 then found.xserver  = 1
	if pos('SET MANPATH=',  translate(l.q)) > 0 then found.manpath  = 1
	if pos('SET TMP=',      translate(l.q)) > 0 then found.tmp      = 1

	/* support driver */
	if pos('XF86SUP.SYS',   translate(l.q)) > 0 then found.sup      = 1
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* add some extra stuff */
if found.home = 0 then do
	'@mkdir 'product_drv'\'s_root'\X11User >> 'product_log 
end
etc_dir = value("ETC", ,"OS2ENVIRONMENT")
if stream(etc_dir'\hosts', 'c', 'query exists') = '' then '@echo 127.0.0.1 localhost > 'etc_dir'\hosts'

/* backup and write new config.sys */
'@copy 'cfgfile target'\os2\install\config.xfr >> 'product_log 
'@del 'cfgfile' >> 'product_log 
gevonden = 0
do q=1 to l.0
	rc = lineout(cfgfile, l.q)
end

/* add Xfree stuff to config.sys */
rc = lineout(cfgfile, ' ')
rc = lineout(cfgfile, 'REM UpdCD')
if found.sup      = 0 then rc = lineout(cfgfile, 'DEVICE='product_drv'\'s_libpath'\xf86sup.sys')
if found.x11root  = 0 then rc = lineout(cfgfile, 'SET X11ROOT='product_drv)
if found.user     = 0 then rc = lineout(cfgfile, 'SET USER=ROOT')
if found.logname  = 0 then rc = lineout(cfgfile, 'SET LOGNAME=ROOT')
if found.home     = 0 then rc = lineout(cfgfile, 'SET HOME='product_drv'\home\root')	
if found.home     = 0 then do
	'@mkdir 'product_drv'\home >nul 2>&1'
	'@mkdir 'product_drv'\home\root >nul 2>&1'
end
if found.hostname = 0 then rc = lineout(cfgfile, 'SET HOSTNAME=127.0.0.1')
if found.termcap  = 0 then rc = lineout(cfgfile, 'SET TERMCAP='product_drv'/'s_libpath'/X11/etc/emx.termcap.x11')
if found.term     = 0 then rc = lineout(cfgfile, 'SET TERM=ANSI')
if found.xserver  = 0 then rc = lineout(cfgfile, 'SET XSERVER='product_drv'/'s_path'/'xserver.exe)
if found.display  = 0 then rc = lineout(cfgfile, 'SET DISPLAY=127.0.0.1:0.0')
if found.manpath  = 0 then rc = lineout(cfgfile, 'SET MANPATH='product_drv'/'s_root'/man')
if found.tmp      = 0 then rc = lineout(cfgfile, 'SET TMP='target'\TEMP')
rc = lineout(cfgfile)

/* customize startx.cmd */
startx = product_drv'\'s_path'\startx.cmd'
q=1
found.x = 1
do while lines(startx)
	l.q = linein(startx)
	q = q+1
end
l.0=q-1
call lineout startx
'@del 'startx
call lineout startx, '/* updcd customized startx */'
call lineout startx, '"ifconfig lo 127.0.0.1"'
call lineout startx, ' '
do i=1 to l.0
	call lineout startx, l.i
end
call lineout startx

/* create icons */
Say
Say 'Creating objects...'
rc = RxFuncAdd('SysCreateObject', 'RexxUtil', 'SysCreateObject')
option = 'R'

/* Xfree folder */
classname = 'WPFolder'
title     = 'XFree86 for OS/2'
location  = '<WP_DESKTOP>'
setup     = 'NOTDEFAULTICON=YES;'||,
            'NOPRINT=YES;'||,
            'DEFAULTVIEW=CONTENTS;'||,
            'SELFCLOSE=1;'||,
            'ICONFONT=9.WarpSans;'||,
            'DETAILSFONT=9.WarpSans;'||,
            'TREEFONT=9.WarpSans;'||,
            'ICONVIEW=FLOWED,NORMAL;'||,
            'DETAILSVIEW=MINI;'||,
            'TREEVIEW=LINES,MINI;'||,
            'ALWAYSSORT=YES;'||,
            'OBJECTID=<XFREE86OS2>'
call SysCreateObject classname, title, location, setup, option

/* config */
classname = 'WPProgram'
title     = 'X-Server Configuration'
location  = '<XFREE86OS2>'
setup     = 'PROGTYPE=FULLSCREEN;' ||,
            'EXENAME='product_drv'\'s_path'\xf86config.cmd;' ||,
            'STARTUPDIR='product_drv'\'s_path';'
call SysCreateObject classname, title, location, setup, option
if stream(product_drv'\'s_path'\xf86config.cmd', 'c', 'query exists') = '' then do
	'@echo ifconfig lo 127.0.0.1 > 'product_drv'\'s_path'\xf86config.cmd'
	'@echo 'product_drv'\'s_path'\xfree86.exe -configure >> 'product_drv'\'s_path'\xf86config.cmd'
	'@echo pause >> 'product_drv'\'s_path'\xf86config.cmd'
end

/* StartX icon */
classname = 'WPProgram'
title     = 'Start X'
location  = '<XFREE86OS2>'
setup     = 'PROGTYPE=FULLSCREEN;' ||,
            'EXENAME='product_drv'\'s_path'\startx.cmd;' ||,
            'STARTUPDIR='product_drv'\'s_path';'
call SysCreateObject classname, title, location, setup, option

/* readme 1st */
classname = 'WPProgram'
title     = 'XFree86 Readme 1st'
location  = '<XFREE86OS2>'
setup     = 'PROGTYPE=PM;' ||,
            'EXENAME='target'\os2\e.exe;' ||,
            'PARAMETERS='product_drv'\'s_root'\README.1ST;'
call SysCreateObject classname, title, location, setup, option
'@echo+ > 'product_drv'\'s_root'\README.1ST'
'@echo Things you have to do after installation >> 'product_drv'\'s_root'\README.1ST'
'@echo+ >> 'product_drv'\'s_root'\README.1ST'
'@echo 1. Reboot your system >> 'product_drv'\'s_root'\README.1ST'
'@echo 2. Check if TCP/IP is functioning (ping 127.0.0.1) >> 'product_drv'\'s_root'\README.1ST'
'@echo 3. Run X-Server Configuration >> 'product_drv'\'s_root'\README.1ST'
'@echo 4. Only for version 4.3.0: Select option 5 to copy it to the X-Server directory >> 'product_drv'\'s_root'\README.1ST'
'@echo 5. Only for version 4.3.0: Exit X-Server Configuration by selecting option 7 >> 'product_drv'\'s_root'\README.1ST'
'@echo 6. Run Start X to start XFree86 >> 'product_drv'\'s_root'\README.1ST'

/* readme howto */
if stream(product_drv'\'s_root'\HowTo.txt', 'c', 'query exists') <> '' then do
	classname = 'WPProgram'
	title     = 'XFree86 HowTo'
	location  = '<XFREE86OS2>'
	setup     = 'PROGTYPE=PM;' ||,
	            'EXENAME='target'\os2\e.exe;' ||,
	            'PARAMETERS='product_drv'\'s_root'\HowTo.txt;'
	call SysCreateObject classname, title, location, setup, option
end

Say
Say 'Done.'

exit

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<XFREE86OS2>"

	/* delete files */
	call deldir product_drv'\'s_root

	/* change config */
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.xfr >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos(':\'s_libpath'\XF86SUP.SYS', translate(l.q)) > 0 then iterate
		if pos('SET X11ROOT=', translate(l.q)) > 0 then iterate
		if pos(':\'s_root'\X11USER', translate(l.q)) > 0 then iterate
		if pos(':/'s_root'/LIB/X11/ETC/EMX.TERMCAP.X11', translate(l.q)) > 0 then iterate
		if pos('SET XSERVER=', translate(l.q)) > 0 then iterate
		if pos(':/'s_root'/MAN', translate(l.q)) > 0 then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile
	call remove_from_path cfgfile product_drv'\'s_libpath' LIBPATH='
	call remove_from_path cfgfile product_drv'\'s_path' SET PATH='

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

/* remove string from path */
remove_from_path: procedure

	parse upper arg cfgfile rpstr ststr 

	i=1
	do while lines(cfgfile)
		l.i=linein(cfgfile)
		i=i+1
	end
	call lineout cfgfile
	l.0=i-1
	'@del 'cfgfile

	do i=1 to l.0
		/* remove rpstr */
		if substr(translate(l.i), 1, length(ststr)) = ststr & pos(rpstr, translate(l.i)) > 0 then do
			l.i = substr(l.i, 1, pos(rpstr, translate(l.i))-1) || substr(l.i, pos(rpstr, translate(l.i))+length(rpstr))
			/* remove ;; */
			if pos(';;', translate(l.i)) > 0 then 
				l.i = substr(l.i, 1, pos(';;', translate(l.i))-1) || ';' || substr(l.i, pos(';;', translate(l.i))+length(';;'))
		end
		call lineout cfgfile, l.i
	end
	call lineout cfgfile

return
