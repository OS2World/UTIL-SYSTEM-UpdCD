/* Install script for Scitech SNAP and IBM GRADD drivers    */
/* Unpack the IBM distribution file in this directory or    */
/* place the Scitech file here under the name snap.exe.     */
/* Use version 2.9.0 (beta) or higher, older versions are   */
/* not supported.                                           */
/*                                                          */
/* 02.14.2002: added support for Scitech distribution       */
/* 05.19.2002: added support for uninstallation             */
/* 06.12.2004: added support Scitech SNAP                   */
/* 09.30.2005: aligned with os2mt                           */

parse upper arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

Say
Say 'Starting installer...'

/* exit if package does not exist */
if stream(inst_dir'\setup.cmd', 'c', 'query exists') <> '' then do
	/* start CID install */
	if stream(inst_dir'\sddgradd', 'c', 'query exists') <> '' then key = 'SDD'
	else key = 'DYN'
	'@call 'inst_dir'\setup.cmd 'key' 'inst_dir' 'target' /u >> 'product_log
end

else if stream(inst_dir'\snap.exe', 'c', 'query exists') <> '' then do
	/* start exe */
	'@'inst_dir'\snap.exe /u'
end

Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	if stream(target'\SNAP\UNINSTAL.EXE', 'c', 'query exists') <> '' then do
		'call 'target'\SNAP\UNINSTAL.EXE'
	end
	else do
		'call 'target'\os2\setvga.cmd'
	end

return