/* Preprocessing script, runs before the installation of the add-on products */
/* 05.18.2002: added support for uninstallation                              */
/* 06.08.2002: made warp 3 compatible                                        */

parse upper arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* create temp directory */
'mkdir 'target'\temp >> 'product_log

/* add updated vrobj.dll to \OS2\DLL */
instpath = 'warpsrv'
if stream(source'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'grpware'
if stream(source'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'ibminst'
if stream(target'\OS2\DLL\vrobj.dll', 'c', 'query exists') = '' then 
	'copy 'source'\'instpath'\vrobj.dll 'target'\OS2\DLL\. >> 'product_log

/* you would add your personal changes after this line */


/* end personal changes */

exit

/* uninstall mode */
uninstall:

	nop;

return