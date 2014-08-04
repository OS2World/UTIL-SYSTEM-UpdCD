/* UpdCD add-on installation script for EMX 0.9d                            */
/* Implements all the actions described in the install.doc file of EMX      */
/* up to section "Creating desktop objects".                                */
/*                                                                          */
/* Place the emx zip's here which should be installed in the emx dir        */
/* The zip's should contain the emx subdirectory. The content of this       */
/* directory will be unzipped to the drive which contains OS/2 installed.   */
/*                                                                          */
/* Obligatory component:                                                    */
/*                      EMX run-time (emxrt.zip)                            */
/*                                                                          */
/* To use the GNU C compiler you will need to add:                          */
/*                      emxdev1.zip, emxdev2.zip, gnudev1.zip, gnudev2.zip  */ 
/*                      gppdev1.zip, gobjcdev.zip                           */
/*                                                                          */
/* Optional components:                                                     */
/*                      emxview.zip, emxsrcd1.zip, emxsrcd2.zip             */
/*                      emxsrcr.zip, emxample.zip, emxtest.zip, gnuview.zip */
/*                      gnudoc.zip, gnuinfo.zip, gnupat.zip, gnusrc.zip     */
/*                      gbinusrc.zip, gccsrc1.zip, gccsrc2.zip, gccsrc3.zip */
/*                      gdbsrc1.zip, gdbsrc2.zip, gppdev2.zip, gppsrc1.zip  */
/*                      gppsrc2.zip, bsddev.zip, bsddoc.zip, bsdsrc.zip     */
/*                                                                          */
/* EMX fix (optional):                                                      */
/*                      emxfix??.zip                                        */
/*                                                                          */
/* Created on 04.01.2002                                                    */
/* 04.06.2002: made unzip action conditional                                */
/* 05.26.2002: added support for uninstallation                             */
/* 09.29.2005: aligned with os2mt                                           */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* define EMX components */
emx.       = ''
emx.comp.1 = 'emxrt.zip'
emx.comp.2 = 'emxdev1.zip'
emx.comp.3 = 'emxdev2.zip'
emx.comp.4 = 'gnudev1.zip'
emx.comp.5 = 'gnudev2.zip'
emx.comp.6 = 'gppdev1.zip'
emx.comp.7 = 'gobjcdev.zip'
emx.comp.8 = 'emxview.zip'
emx.comp.9 = 'emxsrcd1.zip'
emx.comp.10 = 'emxsrcd2.zip'
emx.comp.11 = 'emxsrcr.zip'
emx.comp.12 = 'emxample.zip'
emx.comp.13 = 'emxtest.zip'
emx.comp.14 = 'gnuview.zip'
emx.comp.15 = 'gnudoc.zip'
emx.comp.16 = 'gnuinfo.zip'
emx.comp.17 = 'gnupat.zip'
emx.comp.18 = 'gnusrc.zip'
emx.comp.19 = 'gbinusrc.zip'
emx.comp.20 = 'gccsrc1.zip'
emx.comp.21 = 'gccsrc2.zip'
emx.comp.22 = 'gccsrc3.zip'
emx.comp.23 = 'gdbsrc1.zip'
emx.comp.24 = 'gdbsrc2.zip'
emx.comp.25 = 'gppdev2.zip'
emx.comp.26 = 'gppsrc1.zip'
emx.comp.27 = 'gppsrc2.zip'
emx.comp.28 = 'bsddev.zip'
emx.comp.29 = 'bsddoc.zip'
emx.comp.30 = 'bsdsrc.zip'
emx.comp.31 = 'emxfix??.zip'

/* count them */
i = 1
do while emx.comp.i <> ''
	emx.comp.0 = i
	i = i + 1
end

/* exit if obligatory component does not exist */
if stream(inst_dir'\emxrt.zip', 'c', 'query exists') = '' then exit 9

/* unpack zip's */
Say
Say 'Unzipping files...'
do i = 1 to emx.comp.0
	if stream(inst_dir'\'emx.comp.i, 'c', 'query exists') <> '' then 
		'@unzip -o 'inst_dir'\'emx.comp.i' -d 'target'\ >> 'product_log' 2>>&1'
end

/* copy termcap to etc, some stupid programs need it here */
Say
Say 'Copying termcap.dat to ETC...'
'@copy 'target'\emx\etc\termcap.dat  'VALUE('ETC', ,'OS2ENVIRONMENT')'\.  >> 'product_log

/* read config */
Say
Say 'Updating Config.sys...'
cfgfile = target'\config.sys'
q = 1
found. = ''
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('C_INCLUDE_PATH=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.c_include_path = 1
	if pos('LIBRARY_PATH=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.library_path = 1
	if pos('CPLUS_INCLUDE_PATH=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.cplus_include_path = 1
	if pos('PROTODIR=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.protodir = 1
	if pos('OBJC_INCLUDE_PATH=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.objc_include_path = 1
	if pos('GCCLOAD=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.gccload = 1
	if pos('GCCOPT=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.gccopt = 1
	if pos('TERM=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.term = 1
	if pos('TERMCAP=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.termcap = 1
	if pos('INFOPATH=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.infopath = 1
	if pos('EMXBOOK=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.emxbook = 1
	if pos('HELPNDX=', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then found.helpndx = 1
	q = q+1
end
call lineout cfgfile
l.0 = q-1

/* backup and del config */
'@copy 'cfgfile target'\os2\install\config.emx' 
'@del 'cfgfile

/* change lines config */
do q=1 to l.0
	if substr(translate(l.q), 1, 13) = 'SET BOOKSHELF' & pos('EMX\BOOK', translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || target'\EMX\BOOK;'
		else l.q = l.q || ';' || target'\EMX\BOOK;'
		call lineout cfgfile, l.q
	end
	else if substr(translate(l.q), 1, 9) = 'SET DPATH' & pos('EMX\BOOK', translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || target'\EMX\BOOK;'
		else l.q = l.q || ';' || target'\EMX\BOOK;'
		call lineout cfgfile, l.q
	end
	else if substr(translate(l.q), 1, 8) = 'SET HELP' & pos('EMX\HELP', translate(l.q)) = 0 & stream(target'\emx\help\pmgdb.hlp', 'c', 'query exists') <> '' then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || target'\EMX\HELP;'
		else l.q = l.q || ';' || target'\EMX\HELP;'
		call lineout cfgfile, l.q
	end
	else if substr(translate(l.q), 1, 8) = 'SET PATH' & pos('EMX\BIN', translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || target'\EMX\BIN;'
		else l.q = l.q || ';' || target'\EMX\BIN;'
		call lineout cfgfile, l.q
	end
	else if substr(translate(l.q), 1, 7) = 'LIBPATH' & pos('EMX\DLL', translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || target'\EMX\DLL;'
		else l.q = l.q || ';' || target'\EMX\DLL;'
		call lineout cfgfile, l.q
	end
	else if substr(translate(l.q), 1, 11) = 'SET HELPNDX' then do
		call SysFileTree target'\emx\book\*.ndx', 'file.', 'FO'
		if file.0 > 0 then do
			string = filespec('name', file.1)
			do i=2 to file.0
				string = string'+'filespec('name', file.i)
			end
			call lineout cfgfile, 'SET HELPNDX='string
		end
		else call lineout cfgfile, l.q
	end
	else
		call lineout cfgfile, l.q
end

/* append to config config */
if found.c_include_path = '' then	call lineout cfgfile, 'SET C_INCLUDE_PATH='target'/EMX/INCLUDE'
if found.library_path = '' then	call lineout cfgfile, 'SET LIBRARY_PATH='target'/EMX/LIB'
if found.cplus_include_path = '' then	call lineout cfgfile, 'SET CPLUS_INCLUDE_PATH='target'/EMX/INCLUDE/CPP;'target'/EMX/INCLUDE'
if found.protodir = '' then	call lineout cfgfile, 'SET PROTODIR='target'/EMX/INCLUDE/CPP/GEN'
if found.objc_include_path = '' then	call lineout cfgfile, 'SET OBJC_INCLUDE_PATH='target'/EMX/LIB'
if found.gccload = '' then	call lineout cfgfile, 'SET GCCLOAD=5'
if found.gccopt = '' then	call lineout cfgfile, 'SET GCCOPT=-pipe'
if found.term = '' then	call lineout cfgfile, 'SET TERM=mono'
if found.termcap = '' then	call lineout cfgfile, 'SET TERMCAP='target'/emx/etc/termcap.dat'
if found.infopath = '' then	call lineout cfgfile, 'SET INFOPATH='target'/emx/info'

/* append EMX books */
if found.emxbook = '' then do
	call SysFileTree target'\emx\book\*.inf', 'file.', 'FO'
	if file.0 > 0 then do
		string = filespec('name', file.1)
		do i=2 to file.0
			string = string'+'filespec('name', file.i)
		end
		call lineout cfgfile, 'SET EMXBOOK='string
	end
end

/* append EMX indexes */
if found.helpndx = '' then do
	call SysFileTree target'\emx\book\*.ndx', 'file.', 'FO'
	if file.0 > 0 then do
		string = filespec('name', file.1)
		do i=2 to file.0
			string = string'+'filespec('name', file.i)
		end
		call lineout cfgfile, 'SET HELPNDX='string
	end
end

/* close config */
call lineout cfgfile

/* create wps objects */
if stream(target'\emx\bin\emxinst.cmd', 'c', 'query exists') <> '' then do
	Say 'Creating objects...'
	cdir = directory()
	call directory target'\emx\bin'
	'@call emxinst'
	call directory cdir
end

/* ready */
Say
Say 'Completed.'

exit

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<EM_emx_0.9d_FOLDER>"

	/* delete files */
	call deldir product_drv'\emx'

	/* change config */
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.emx >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('SET C_INCLUDE_PATH=', translate(l.q)) > 0 then iterate
		if pos('SET LIBRARY_PATH=', translate(l.q)) > 0 then iterate
		if pos('SET CPLUS_INCLUDE_PATH=', translate(l.q)) > 0 then iterate
		if pos('SET PROTODIR=', translate(l.q)) > 0 then iterate
		if pos('SET OBJC_INCLUDE_PATH=', translate(l.q)) > 0 then iterate
		if pos('SET GCCLOAD=', translate(l.q)) > 0 then iterate
		if pos('SET GCCOPT=', translate(l.q)) > 0 then iterate
		if pos('SET INFOPATH=', translate(l.q)) > 0 then iterate
		if pos('SET EMXBOOK=', translate(l.q)) > 0 then iterate
		if pos('SET HELPNDX=', translate(l.q)) > 0 then iterate
		if pos('EMX/ETC/TERMCAP.DAT', translate(l.q)) > 0 then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile
	call remove_from_path cfgfile product_drv'\EMX\DLL LIBPATH='
	call remove_from_path cfgfile product_drv'\EMX\BIN SET PATH='
	call remove_from_path cfgfile product_drv'\EMX\BOOK SET DPATH='
	call remove_from_path cfgfile product_drv'\EMX\HELP SET HELP='
	call remove_from_path cfgfile product_drv'\EMX\BOOK SET BOOKSHELF='

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
