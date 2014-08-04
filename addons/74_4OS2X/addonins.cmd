/* Install script for 4OS2 (tested with version 4.02->Netlabs version) */
/* Place the distribution zip under the name 4os2.zip here.            */
/* 03.22.2004: created                                                 */

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
if stream(inst_dir'\4os2.zip', 'c', 'query exists') = '' then exit 9

/* unzip files */
dest_dir = target'\os2'
'unzip -o 'inst_dir'\4os2.zip *.exe     -d 'dest_dir'\.        >> 'product_log
'unzip -o 'inst_dir'\4os2.zip *.dll     -d 'dest_dir'\dll\.    >> 'product_log
'unzip -o 'inst_dir'\4os2.zip *.inf     -d 'dest_dir'\help\.   >> 'product_log
'unzip -o 'inst_dir'\4os2.zip 4os2h.txt -d 'dest_dir'\system\. >> 'product_log

/* change config.sys if needed */
cfgfile = target'\config.sys'
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	q=q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* backup config.sys */
'copy 'cfgfile target'\os2\install\config.4os' 

/* update config.sys */
'del 'cfgfile
do q=1 to l.0
	if substr(translate(l.q), 1, 14) = 'SET OS2_SHELL=' then 
		rc = lineout(cfgfile, 'SET OS2_SHELL='target'\OS2\4OS2.EXE')
	else if substr(translate(l.q), 1, 12) = 'SET COMSPEC=' then 
		rc = lineout(cfgfile, 'SET COMSPEC='target'\OS2\4OS2.EXE')
	else 
		rc = lineout(cfgfile, l.q)
end
rc = lineout(cfgfile)

exit

uninstall:

	/* update config.sys */
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	rc = lineout(cfgfile)
	l.0 = q-1

	/* backup config.sys */
	'copy 'cfgfile target'\os2\install\config.4os' 

	/* update config.sys */
	'del 'cfgfile
	do q=1 to l.0
		if substr(translate(l.q), 1, 14) = 'SET OS2_SHELL=' then 
			rc = lineout(cfgfile, 'SET OS2_SHELL='target'\OS2\CMD.EXE')
		else if substr(translate(l.q), 1, 12) = 'SET COMSPEC=' then 
			rc = lineout(cfgfile, 'SET COMSPEC='target'\OS2\CMD.EXE')
		else 
			rc = lineout(cfgfile, l.q)
	end
	rc = lineout(cfgfile)

	/* del files */
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\4os2.exe'
	'del 'target'\os2\4os2.exe         >> 'product_log
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\keystack.exe'
	'del 'target'\os2\keystack.exe     >> 'product_log
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\option2.exe'
	'del 'target'\os2\option2.exe      >> 'product_log
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\shralias.exe'
	'del 'target'\os2\shralias.exe     >> 'product_log
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\4os2.inf'
	'del 'target'\os2\help\4os2.inf    >> 'product_log
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\jpos2dll.exe'
	'del 'target'\os2\dll\JPOS2DLL.dll >> 'product_log
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\4os2h.txt'
	'del 'target'\os2\system\4os2h.txt >> 'product_log

return
