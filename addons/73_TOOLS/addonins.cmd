/* Installation of tools (zip, arj, etc.)                             */
/* Prepare a zip called tools.zip and place it in this directory.     */
/* It will be unzipped on your boot drive. Directory names containing */
/* BIN will be added to the PATH. DLL names to the LIBPATH and HLP    */
/* names to the HELP PATH. Installation scripts called INSTALL.CMD in */
/* tools.zip will be run.                                             */
/* Created: 11.15.2002                                                */
/* 08.20.2005: made zip oriented                                      */
/* 08.28.2005: added uninstall, fixed problems with manipulating path */
/* 09.17.2005: (un)install scripts were not running from install dir  */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* check */
Say 'Checking install files...'
if stream(inst_dir'\tools.zip', 'c', 'query exists') = '' then exit 9

/* unzip files */
Say 'Unpacking files...'
'@unzip -o 'inst_dir'\tools.zip -d 'target'\. >> 'product_log 

/* run scripts */
Say 'Running scripts...'
cdir = directory()
ziptmp = target'\ziptmp.lst'
'@unzip -l 'inst_dir'\tools.zip > 'ziptmp
do while lines(ziptmp)
	l = linein(ziptmp)
	parse upper var l w1 w2 w3 w4 w5 w6
	if pos('/INSTALL.CMD', w6) > 0 then do
		file = target'\'translate(space(w6),'\','/')
		fpath = strip(filespec('drive', file) || filespec('path', file), 'T', '\')
		call directory fpath
		'@call 'file' >> 'product_log' 2>>&1'
	end
end
call lineout ziptmp
'@del 'ziptmp
call directory cdir

/* update cfg.sys */
Say 'Reading Config.Sys...'
binpath = ''
dllpath = ''
hlppath = ''
ziptmp = target'\ziptmp.lst'
'@unzip -l 'inst_dir'\tools.zip > 'ziptmp
do while lines(ziptmp)
	l = linein(ziptmp)
	parse upper var l w1 w2 w3 w4 w5 w6
	if pos('/BIN/', w6) > 0 | substr(space(w6),1,4) = 'BIN/' then
		if substr(w6, length(w6)) = '/' then binpath = binpath||translate(target)'\'translate(space(substr(w6,1,length(w6)-1)),'\','/')';'
	if pos('/DLL/', w6) > 0 | substr(space(w6),1,4) = 'DLL/' then
		if substr(w6, length(w6)) = '/' then dllpath = dllpath||translate(target)'\'translate(space(substr(w6,1,length(w6)-1)),'\','/')';'
	if pos('/HLP/', w6) > 0 | substr(space(w6),1,4) = 'HLP/' then
		if substr(w6, length(w6)) = '/' then hlppath = hlppath||translate(target)'\'translate(space(substr(w6,1,length(w6)-1)),'\','/')';'
end
call lineout ziptmp
'@del 'ziptmp
cfgfile = target'\config.sys'
'@copy 'cfgfile target'\os2\install\config.tls' 
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	/* libpath */
	if pos('LIBPATH=', translate(l.q)) > 0 & pos(dllpath, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || dllpath
		else l.q = l.q || ';' || dllpath
	end
	/* path */
	if pos('SET PATH=', translate(l.q)) > 0 & pos(binpath, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || binpath
		else l.q = l.q || ';' || binpath
	end
	/* hlppath */
	if pos('SET HELP=', translate(l.q)) > 0 & pos(hlppath, translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || hlppath
		else l.q = l.q || ';' || hlppath
	end
	q = q+1
end
call lineout cfgfile
l.0 = q-1
'@del 'cfgfile
Say 'Writing Config.Sys...'
do q=1 to l.0
	call lineout cfgfile, l.q
end
call lineout cfgfile

exit

/* uninstall mode */
uninstall:

	/* check */
	Say 'Checking files...'
	if stream(inst_dir'\tools.zip', 'c', 'query exists') = '' then do
		Say inst_dir'\tools.zip is missing. Cannot install without it. Exiting...'
		'@echo 'inst_dir'\tools.zip is missing. Cannot install without it. Exiting... >> 'product_log
		exit 9
	end

	/* run scripts */
	Say 'Running scripts...'
	cdir = directory()
	ziptmp = target'\ziptmp.lst'
	'@unzip -l 'inst_dir'\tools.zip > 'ziptmp
	i=1
	do while lines(ziptmp)
		l.i = linein(ziptmp)
		parse upper var l.i w1 w2 w3 w4 w5 w6
		if pos('/UNINSTALL.CMD', w6) > 0 then do
			file = target'\'translate(space(w6),'\','/')
 			fpath = strip(filespec('drive', file) || filespec('path', file), 'T', '\')
			call directory fpath
			'@call 'file' >> 'product_log' 2>>&1'
		end
		i=i+1
	end
	call lineout ziptmp
	'@del 'ziptmp
	call directory cdir
	l.0 = i-1

	/* remove files */
	Say 'Removing files...'
	call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
	do i=1 to l.0
		parse upper var l.i w1 w2 w3 w4 w5 w6
		if datatype(w1) = 'NUM' & w6 <> '' then 
			if substr(w6, length(w6)) <> '/' then do
				file = target'\'translate(space(w6),'\','/')
				/* remove RO attributes */
				call SysFileTree file, 'tmp.', 'FO',,'**---'
				/* unlock file */
				'@call 'source'\updcd\bin\unlock.exe 'file' >> 'product_log' 2>>&1'
				/* remove */
				'@del 'file' >> 'product_log' 2>>&1'
			end
	end

	/* remove dirs */
	Say 'Removing directories...'
	do i=l.0 to 1 by -1
		parse upper var l.i w1 w2 w3 w4 w5 w6
		if datatype(w1) = 'NUM' & w6 <> '' then
			if substr(w6, length(w6)) = '/' then do
				file = target'\'translate(space(w6),'\','/') 
				file = substr(file, 1, length(file)-1)
				/* remove RO attributes */
				call SysFileTree file, 'tmp.', 'DO',,'**---'
				/* remove */
				'@rmdir 'file' >> 'product_log' 2>>&1'
			end
	end

	/* update cfg.sys */
	Say 'Reading Config.Sys...'
	pstring. = ''
	q = 1
	do i=1 to l.0
		parse upper var l.i w1 w2 w3 w4 w5 w6
		if pos('/BIN/', w6) > 0 | substr(space(w6),1,4) = 'BIN/' then 
			if substr(w6, length(w6)) = '/' then do
				pstring.q = translate(target)'\'translate(space(substr(w6,1,length(w6)-1)),'\','/')
				q = q+1
			end
		if pos('/DLL/', w6) > 0 | substr(space(w6),1,4) = 'DLL/' then 
			if substr(w6, length(w6)) = '/' then do
				pstring.q = translate(target)'\'translate(space(substr(w6,1,length(w6)-1)),'\','/')
				q = q+1
			end
		if pos('/HLP/', w6) > 0 | substr(space(w6),1,4) = 'HLP/' then 
			if substr(w6, length(w6)) = '/' then do
				pstring.q = translate(target)'\'translate(space(substr(w6,1,length(w6)-1)),'\','/')
				q = q+1
			end
	end
	pstring.0 = q-1
	cfgfile = target'\config.sys'
	'@copy 'cfgfile target'\os2\install\config.tls' 
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		do i=1 to pstring.0
			if pos(pstring.i, translate(l.q)) > 0 then do
				/* remove string */
				l.q = substr(l.q, 1, pos(pstring.i, translate(l.q))-1) || substr(l.q, pos(pstring.i, translate(l.q))+length(pstring.i))
				/* remove ;; */
				if pos(';;', translate(l.q)) > 0 then 
					l.q = substr(l.q, 1, pos(';;', translate(l.q))-1) || ';' || substr(l.q, pos(';;', translate(l.q))+length(';;'))
			end
		end
		q = q+1
	end
	call lineout cfgfile
	l.0 = q-1
	'@del 'cfgfile
	Say 'Writing Config.Sys...'
	do q=1 to l.0
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

return
