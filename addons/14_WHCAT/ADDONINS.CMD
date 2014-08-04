/* WatchCat 2.1 installation script                          */
/* Unzip wcat21.zip to this directory                        */
/* You may als place addon dll's, like wkill9.dll here       */
/* 08.12.2001: added removal of RO attributes                */
/* 05.25.2002: added support for uninstallation              */
/* 05.18.2004: reinstallation adds double entries to cfg.sys */
/* 09.30.2005: aligned with os2mt                            */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' then exit 9

/* copy files */
Say
Say 'Copying files... '
dest_dir = translate(product_drv'\'product_path)
'@copy 'inst_dir'\CLEANWPS.EXE 'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\INSTALL.EXE  'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\PMCENTER.ZIP 'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\README.TXT   'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\SERIAL.CNF   'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\STARTPGM.DL_ 'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\WATCHCAT.EXE 'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\WATCHCAT.INF 'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\WATCHCAT.SYS 'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\WCAPI.ZIP    'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\WCATDEB.DL_  'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\WCCAD.EXE    'dest_dir'\. >> 'product_log' 2>>&1'
'@copy 'inst_dir'\WCINFO.EXE   'dest_dir'\. >> 'product_log' 2>>&1'
'@xcopy 'inst_dir'\*.DLL       'dest_dir'\. >> 'product_log' 2>>&1'

/* remove RO attributes */
call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
call SysFileTree dest_dir'\*', 'tmp.', 'SO',,'**---'

/* update config.sys */
Say
Say 'Updating Config.sys...'
cfgfile = target'\config.sys'
q = 1
found. = 0
do while lines(cfgfile)

	l.q = linein(cfgfile)

	/* libpath */
	if pos('LIBPATH=', translate(l.q)) > 0 & pos(dest_dir, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || dest_dir';'
		else l.q = l.q || ';' || dest_dir';'
	end

	/* path */
	if pos('SET PATH=', translate(l.q)) > 0 & pos(dest_dir, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || dest_dir';'
		else l.q = l.q || ';' || dest_dir';'
	end

	/* bookshelf */
	if pos('SET BOOKSHELF=', translate(l.q)) > 0 & pos(dest_dir, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || dest_dir';'
		else l.q = l.q || ';' || dest_dir';'
	end

	/* check */
	l = translate(l.q)
	if pos('WATCHCAT.SYS', l) > 0 & substr(l, 1, 3) <> 'REM' then found.sys = 1
	if pos('WATCHCAT.EXE', l) > 0 & substr(l, 1, 3) <> 'REM' then found.exe = 1

	q=q+1

end
rc = lineout(cfgfile)
l.0 = q-1

'@copy 'cfgfile target'\os2\install\config.wct >> 'product_log 
'@del 'cfgfile' >> 'product_log 
gevonden = 0
do q=1 to l.0
	rc = lineout(cfgfile, l.q)
end

if found.sys = 0 | found.exe = 0 then do
	call lineout cfgfile, ' '
	call lineout cfgfile, 'REM UpdCD'
end
if found.sys = 0 then do
	call lineout cfgfile, 'REM *** WatchCat 2.1 device driver - REQUIRED'
	call lineout cfgfile, 'DEVICE='dest_dir'\WATCHCAT.SYS KEYB:CA-W '
end
if found.exe = 0 then do
	call lineout cfgfile, 'REM *** WatchCat 2.1 main program - REQUIRED'
	call lineout cfgfile, 'RUN='dest_dir'\WATCHCAT.EXE'
end
if found.sys = 0 | found.exe = 0 then do
	call lineout cfgfile, 'REM *** WatchCat 2.1 Process Manipluation Center Driver'
	call lineout cfgfile, 'REM DEVICE='dest_dir'\KILLER.SYS'
	call lineout cfgfile, 'REM *** WatchCat 2.1 CAD Package Virtual Device Driver'
	call lineout cfgfile, 'REM DEVICE='dest_dir'\VWCAT.SYS'
	call lineout cfgfile, 'REM *** WatchCat 2.1 CAD Package Control Program'
	call lineout cfgfile, 'REM RUN='dest_dir'\WCCAD.EXE'
	call lineout cfgfile
end

/* register class and create object */
call RxFuncAdd 'SysRegisterObjectClass', 'RexxUtil', 'SysRegisterObjectClass';
call SysRegisterObjectClass "WPCat", "WPCAT"
call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject';
call SysCreateObject "WPCat", "WatchCat", "<WP_APPSFOLDER>", "OBJECTID=<WP_CAT>"

Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<WP_CAT>"
	call RxFuncAdd 'SysDeRegisterObjectClass', 'RexxUtil', 'SysDeRegisterObjectClass'
	call SysDeRegisterObjectClass "WPCat"

	/* update config.sys */
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.wct >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('WATCHCAT.SYS', translate(l.q)) > 0 | pos('WATCHCAT.EXE', translate(l.q)) > 0 | pos('KILLER.SYS', translate(l.q)) > 0 then iterate
		if pos('VWCAT.SYS', translate(l.q)) > 0 | pos('WCCAD.EXE', translate(l.q)) > 0 | pos('REM *** WATCHCAT', translate(l.q)) > 0 then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile
	dest_dir = translate(product_drv'\'product_path)
	call remove_from_path cfgfile dest_dir' LIBPATH='
	call remove_from_path cfgfile dest_dir' SET PATH='
	call remove_from_path cfgfile dest_dir' SET BOOKSHELF='

	/* delete files */
	call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
	call SysFileTree dest_dir'\*', 'tmp.', 'FO',,'**---'
	do q=1 to tmp.0
		'call 'source'\updcd\bin\unlock.exe 'tmp.q
		'del 'tmp.q
	end
	'rmdir 'dest_dir

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
