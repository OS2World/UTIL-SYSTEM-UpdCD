/* Installation of ASPI Router                  */
/* Place aspirout.sys in this directory         */
/* 08.12.2001: created                          */
/* 05.19.2002: added support for uninstallation */
/* 09.30.2005: aligned with os2mt               */
/* 04.03.2006: config.sys update did not work   */

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

if stream(inst_dir'\aspirout.sys', 'c', 'query exists') = '' then exit 9

/* copy file */
Say
Say 'Copying file...'
dest_dir = product_drv'\os2\boot'
'@copy 'inst_dir'\aspirout.sys 'dest_dir'\. >> 'product_log

/* remove RO attributes */
call RxFuncAdd SysFileTree, RexxUtil, SysFileTree
call SysFileTree dest_dir'\*', 'tmp.', 'SO',,'**---'

/* read config.sys */
Say
Say 'Reading Config.Sys...'
cfgfile = target'\config.sys'
q = 1
found = 0
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('OS2ASPI.DMD',  translate(l.q)) > 0 then found = q
	if pos('ASPIROUT.SYS', translate(l.q)) > 0 then exit 0
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* write config.sys */
Say
Say 'Writing Config.Sys...'
if found > 0 then do
	'@copy 'cfgfile target'\os2\install\config.asp >> 'product_log 
	'@del 'cfgfile' >> 'product_log 
	do i = 1 to l.0
		if i = found+1 then	call lineout cfgfile, 'DEVICE='target'\OS2\BOOT\ASPIROUT.SYS'
		call lineout cfgfile, l.i
	end
	call lineout cfgfile
end
else do
	'@echo BASEDEV=OS2ASPI.DMD /ALL >> 'cfgfile
	'@echo DEVICE='target'\OS2\BOOT\ASPIROUT.SYS >> 'cfgfile
end

Say
Say 'Completed.'

exit 

uninstall:

	/* update config.sys */
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'@copy 'cfgfile target'\os2\install\config.asp >> 'product_log 
	'@del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('ASPIROUT.SYS', translate(l.q)) > 0 then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

	/* del file */
	dest_dir = product_drv'\os2\boot'
	'@del 'dest_dir'\aspirout.sys >> 'product_log

return
