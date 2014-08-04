/* Install script for JJSCDROM.DMD               */
/* Place the file jjscdrom.dmd in this directory */
/* Created on 09.07.2001                         */
/* 05.25.2002: added support for uninstallation  */
/* 09.30.2005: aligned with os2mt                */
/* 10.20.2005: added overwrite mode              */

/* get command line parameters */
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
if stream(inst_dir'\jjscdrom.dmd', 'c', 'query exists') = '' then exit 9

Say 
Say 'Updating files...'

/* copy file but do not overwrite it if it is already there */
if stream(target'\os2\boot\jjscdrom.dmd', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\jjscdrom.dmd 'target'\os2\boot\. >> 'product_log
end

/* change config.sys if needed */
Say 
Say 'Updating Config.Sys...'
cfgfile = target'\config.sys'
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('JJSCDROM.DMD', translate(l.q)) > 0 
		then exit /* the driver is already added, leave the config.sys alone */
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* backup config.sys */
'@copy 'cfgfile target'\os2\install\config.jjc' 
'@del 'cfgfile
gevonden = 0
do q=1 to l.0
	if pos('OS2CDROM.DMD', translate(l.q)) > 0 & gevonden = 0 then do
		/* add the driver */
		rc = lineout(cfgfile, ' ')
		rc = lineout(cfgfile, 'REM UpdCD')
		rc = lineout(cfgfile, 'DEVICE='target'\OS2\BOOT\JJSCDROM.DMD')
		/* rem IBM driver out */
		l.q = 'REM UpdCD '||l.q 
		rc = lineout(cfgfile, l.q)
		gevonden = 1
		iterate
	end
	rc = lineout(cfgfile, l.q)
end
rc = lineout(cfgfile)

Say 
Say 'Completed.'

exit

uninstall:

	/* update config.sys */
	found. = 0
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		if pos('REM UPDCD', translate(l.q)) > 0 & pos('OS2CDROM.DMD', translate(l.q)) > 0 then found.ibmdrv = 1
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.jjc >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('JJSCDROM.DMD', translate(l.q)) > 0 then iterate
		if pos('REM UPDCD', translate(l.q)) > 0 & pos('OS2CDROM.DMD', translate(l.q)) > 0 then l.q = substr(l.q, 11)
		call lineout cfgfile, l.q
	end
	if found.ibmdrv = 0 then call lineout cfgfile, 'BASEDEV=OS2CDROM.DMD'
	call lineout cfgfile

	/* delete files */
	'del 'target'\os2\boot\jjscdrom.dmd >> 'product_log

return
