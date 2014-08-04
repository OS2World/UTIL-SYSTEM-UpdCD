/* Install script for the DANI FLT driver                              */
/* Place the following files in this directory from the DANI package:  */
/* DaniATAPI.DOC -> DaniATAP.DOC                                       */
/* DaniATAPI.FLT -> DaniATAP.FLT                                       */
/* Rename the files as shown above                                     */
/* Last changed on 02.25.2001                                          */
/* 05.19.2002: added support for uninstallation                        */
/* 0926.2005: aligned with os2mt                                       */
/* 10.20.2005: added overwrite mode                                    */

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
if stream(inst_dir'\DaniATAP.FLT', 'c', 'query exists') = '' & stream(inst_dir'\DaniATAPI.FLT', 'c', 'query exists') = '' then exit 9

/* copy files but do not overwrite them if they are already there */
Say
Say 'Updating files...'
if stream(target'\os2\boot\DaniATAP.FLT', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	if stream(inst_dir'\DaniATAPI.FLT', 'c', 'query exists') = '' then
		'@copy 'inst_dir'\DaniATAP.FLT 'target'\os2\boot\. >> 'product_log
	else
		'@copy 'inst_dir'\DaniATAPI.FLT 'target'\os2\boot\DaniATAP.FLT >> 'product_log
end
if stream(target'\os2\help\DaniATAP.DOC', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	if stream(inst_dir'\DaniATAPI.DOC', 'c', 'query exists') = '' then
		'@copy 'inst_dir'\DaniATAP.DOC 'target'\os2\help\. >> 'product_log
	else
		'@copy 'inst_dir'\DaniATAPI.DOC 'target'\os2\help\DaniATAP.DOC >> 'product_log
end

/* change config.sys if needed */
Say
Say 'Updating Config.Sys...'
cfgfile = target'\config.sys'
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('DANIATAP.FLT', translate(l.q)) > 0 
		then exit /* the driver is already added, leave the config.sys alone */
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* backup config.sys */
'@copy 'cfgfile target'\os2\install\config.dnf' 
'@del 'cfgfile
gevonden = 0
do q=1 to l.0
	if (pos('IBMIDECD.FLT', translate(l.q)) > 0 | pos('IBMATAPI.FLT', translate(l.q)) > 0) & gevonden = 0 then do
		/* add DANI driver */
		rc = lineout(cfgfile, ' ')
		rc = lineout(cfgfile, 'REM UpdCD')
		rc = lineout(cfgfile, 'BASEDEV=DaniATAP.FLT')
		/* rem IBM driver out */
		l.q = 'REM UpdCD '||l.q 
		rc = lineout(cfgfile, l.q)
		gevonden = 1
		iterate
	end
	if (pos('IBMIDECD.FLT', translate(l.q)) > 0 | pos('IBMATAPI.FLT', translate(l.q)) > 0) & gevonden = 1 then do
		rc = lineout(cfgfile, ' ')
		rc = lineout(cfgfile, 'REM UpdCD')
		l.q = 'REM UpdCD '||l.q 
		gevonden = 2
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
		if pos('REM UPDCD BASEDEV=IBMIDECD.FLT', translate(l.q)) > 0 then found.idecd = 1
		if pos('REM UPDCD BASEDEV=IBMATAPI.FLT', translate(l.q)) > 0 then found.atapi = 1
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.dnf >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('DANIATAP.FLT', translate(l.q)) > 0 then iterate
		if pos('REM UPDCD BASEDEV=IBMIDECD.FLT', translate(l.q)) > 0 then l.q = 'BASEDEV=IBMIDECD.FLT'
		if pos('REM UPDCD BASEDEV=IBMATAPI.FLT', translate(l.q)) > 0 then l.q = 'BASEDEV=IBMATAPI.FLT'
		call lineout cfgfile, l.q
	end
	if found.idecd = 0 & found.atapi = 0 then do
		if stream(target'\os2\boot\IBMIDECD.FLT', 'c', 'query exists') <> '' then call lineout cfgfile, 'BASEDEV=IBMIDECD.FLT'
		else if stream(target'\os2\boot\IBMATAPI.FLT', 'c', 'query exists') <> '' then call lineout cfgfile, 'BASEDEV=IBMATAPI.FLT'
	end
	call lineout cfgfile

	/* del file */
	'del 'target'\os2\boot\daniatap.flt >> 'product_log
	'del 'target'\os2\help\daniatap.doc >> 'product_log

return
