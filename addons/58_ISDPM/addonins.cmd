/*                                                                          */
/* ISDNPM installation script                                               */
/*                                                                          */
/* Rename the distribution zip to isdnpm.zip and place it in this directory */
/* There might be updated files (like isdnt.dll) for ISDNPM out there.      */
/* If you want to use them you have to manually add them to isdnpm.zip.     */
/*                                                                          */
/* It is a shareware product, do not forget to register                     */
/* You may also place your registration key (reg.key) in this directory     */
/*                                                                          */
/* 12.12.2004: created                                                      */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* combine */
dest_dir = product_drv'\'product_path

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\isdnpm.zip', 'c', 'query exists') = '' then exit 9

/* unzip */
'@unzip -o 'inst_dir'\isdnpm.zip -d 'dest_dir' >> 'product_log' 2>>&1'

/* copy registration */
if stream(inst_dir'\reg.key', 'c', 'query exists') <> '' then
	'@copy 'inst_dir'\reg.key 'dest_dir'\. >> 'product_log' 2>>&1'

/* create objects */
cdir = directory()
call directory dest_dir
'@call install.cmd >> 'product_log' 2>>&1'
'@echo on'
call directory cdir

exit

uninstall:

	/* get objectid */
	objectid = ''
	i_script = dest_dir'\install.cmd'
	do while lines(i_script)
		l = linein(i_script)
		parse value l with keyword '=' value
		if keyword = 'IniAppName' then objectid = value
	end
	call lineout i_script
	objectid = strip(space(objectid),"B","'")||"_FOLDER"
	if objectid = '' then objectid = 'ISDNPM30_FOLDER'
	objectid = '<'objectid'>'

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject objectid

	/* delete files */
	call deldir dest_dir

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


