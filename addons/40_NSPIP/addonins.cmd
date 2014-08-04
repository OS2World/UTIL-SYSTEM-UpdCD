/* Installation of Netscape Plugin Pack 3.0     */
/* Place all files of NSPIP30 in this dir       */
/* Last modified on 01.30.2001                  */
/* 05.25.2002: added support for uninstallation */
/* 08.23.2002: added syslevel check             */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_rsp       = value("PRODUCT_RSP"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
NS_DIR            = value("NS_DIR"           , ,"OS2ENVIRONMENT")
MM_DIR            = value("MM_DIR"           , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* check product */
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' then exit 9
syslevel = inst_dir'\syslevel.pp2'
c = charin(syslevel, 1, stream(syslevel, 'c', 'query size'))
if pos('Communicator', c) = 0 then exit 8

/* read products */
readme = inst_dir'\os2pip30.pkg'
i=1
do while lines(readme)
	l=linein(readme)
	if l = 'COMPONENT' then do
		l = linein(readme)
		if pos('PROXY SHADOW', l) = 0 & pos('INSFIRST', l) = 0 & pos('DELLAST', l) = 0 then do
			parse value l with . '=' l.i
			l.i = strip(strip(space(l.i),,","),,"'")
			i=i+1
		end
	end
end
rc=lineout(readme)

/* create response file */
'echo COMP = 'l.1'        > 'product_rsp
do j=2 to i-1
	'echo COMP = 'l.j'     >> 'product_rsp
end
'echo CFGUPDATE = AUTO   >> 'product_rsp
'echo DELETEBACKUP = NO  >> 'product_rsp
'echo OVERWRITE = YES    >> 'product_rsp
'echo SAVEBACKUP = NO    >> 'product_rsp
'echo FILE = 'NS_DIR'    >> 'product_rsp
'echo AUX1 = 'MM_DIR'    >> 'product_rsp
'echo NAV_PRESENT = TRUE >> 'product_rsp

/* install */
inst_dir'\INSTALL.EXE /A:I /L1:'product_log' /L2:'product_log' /NMSG /O:DRIVE /R:'product_rsp' /X'

exit

uninstall:

	prod_dir = NS_DIR'\SIUTIL'
	prod_dir'\EPFINSTS.EXE /C:'prod_dir'\OS2PIP3.ICF /O:DRIVE /P:"OS/2 Plug-In Pack v3.0" /A:D /NMSG'

return
