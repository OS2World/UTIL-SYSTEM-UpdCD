/* PMMAIL installation file                                     */
/* Place the pmmail install file here under the name pmmail.exe */
/* 02.15.2002: created                                          */
/* 05.25.2002: added support for uninstallation                 */

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
if stream(inst_dir'\pmmail.exe', 'c', 'query exists') = '' then exit 9

/* run exe */
inst_dir'\pmmail.exe'

exit

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<PMM2FOLDER>"
	call SysDestroyObject "<PMM2DESKEXE>"

	/* delete from ini */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	prod_dir = SysIni('USER', 'PMMail/2', 'InstallRoot')
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	rc = SysIni('USER', 'PMMail/2', 'DELETE:')

	/* delete files */
	p = pos('PMMAIL', translate(prod_dir))-2
	if p > 1 then prod_dir = substr(prod_dir, 1, p)
	else prod_dir = substr(prod_dir, 1, length(prod_dir)-1)
	call deldir prod_dir

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
