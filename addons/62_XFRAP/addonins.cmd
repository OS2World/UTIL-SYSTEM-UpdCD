/* Install Xfree86 applications                                             */
/*                                                                          */
/* Place the applications here which should be installed in the XFree86 dir */
/* The applications should be packed in zip files and should contain the    */
/* Xfree86 or Usr/X11R6 directory. The content of this directory will be    */
/* unzipped to the drive which contains Xfree86 installed.                  */
/*                                                                          */
/* You need to repackage (unzip/zip) your application if it is not packed   */
/* this way.                                                                */
/*                                                                          */
/* Created on 05.02.2001                                                    */
/* 05.24.2002: added support for uninstallation                             */
/* 10.02.2004: added support for xfree 4.4.0 applications                   */

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

/* exit if package does not exist */
rc = RxFuncAdd('SysFileTree', 'RexxUtil', 'SysFileTree')
rc = SysFileTree(inst_dir'\*.zip', 'zip.', 'FO')
if zip.0 = 0 then exit 9

/* update config.sys */
s_libpath = 'XFREE86\LIB'
s_path    = 'XFREE86\BIN'
cfgfile   = target'\config.sys'
q = 1
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
	q = q+1
end
rc  = lineout(cfgfile)
l.0 = q-1
'copy 'cfgfile target'\os2\install\config.xfa >> 'product_log 
'del 'cfgfile' >> 'product_log 
do q=1 to l.0
	rc = lineout(cfgfile, l.q)
end
rc = lineout(cfgfile)

/* install files */
ziptmp = target'\ziptmp.lst'
do i = 1 to zip.0 
	
	'unzip -l 'zip.i' >> 'ziptmp
	do while lines(ziptmp)
		l = linein(ziptmp)
		parse var l w1 w2 w3 w4 w5 w6
		if datatype(w1) = 'NUM' & datatype(w2) = 'NUM' & datatype(w3) = 'NUM' then 
			if pos('XFREE86', translate(l)) > 0 | pos('USR/X11R6', translate(l)) > 0 then /* unzip only to xfree86 or usr/x11r6 */
				if w1 > 0 then
					'unzip -o 'zip.i' 'space(w6)' -d 'target'\ >> 'product_log
				else do
					tdir = target'\'translate(space(w6), '\', '/')
					'mkdir 'substr(tdir, 1, lastpos('\', tdir)-1)' >nul 2>>&1'
				end
	end
	call lineout ziptmp
	'del 'ziptmp

end

exit

uninstall:

	ziptmp = target'\ziptmp.lst'
	q=1
	do while lines(ziptmp)
		l.q = linein(ziptmp)
		q=q+1
	end
	call lineout ziptmp
	l.0=q-1

	do q=l.0 to 1 by -1
		parse var l.q w1 w2 w3 w4 w5 w6
		if datatype(w1) = 'NUM' & datatype(w2) = 'NUM' & datatype(w3) = 'NUM' then do
			if w1 = 0 then 'rmdir "'space(target)'\'space(w6)'"'
			else 'del "'space(target)'\'space(w6)'"'
		end
	end

return
