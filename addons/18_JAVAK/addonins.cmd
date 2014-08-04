/* JAVA 1.4.x installation                                                   */
/*                                                                           */
/* Place Innotek JAVA 1.4.x here under the name java.exe                     */
/* AND/OR                                                                    */
/* Place Golden Code JAVA 1.4.x here under the name java.zip                 */
/* Place the license file (license.jvm) in the same directory                */
/*                                                                           */
/* 29.10.2003: created                                                       */
/* 18.09.2004: updated to work with latest innotek java                      */
/* 30.09.2005: aligned with os2mt                                            */
/* 01.10.2005: fix for find_key                                              */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
NS_DIR            = value("NS_DIR"           , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\java.exe', 'c', 'query exists') = '' & stream(inst_dir'\java.zip', 'c', 'query exists') = '' then exit 9

Say
Say 'Installing files...'

/* install Innotek Java */
if stream(inst_dir'\java.exe', 'c', 'query exists') <> '' then do

	'@'inst_dir'\java.exe /directory='product_drv'\'product_path' /update=force /unattended >> 'product_log' 2>>&1'

end

/* install Golden Code Java */
if stream(inst_dir'\java.zip', 'c', 'query exists') <> '' then do

	/* get java dir from zip */
	newQueue = RxQueue('Create')
	oldQueue = RxQueue('Set', newQueue)
	'@unzip -l 'inst_dir'\java.zip | rxqueue' newQueue
	do i=1 to 4
		parse upper pull tag data
	end
	parse var data w1 w2 w3 w4 w5
	jvmdir = space(substr(w5, 1, pos('/',w5)-1))
	call RxQueue 'Delete', newQueue
	call RxQueue 'Set', oldQueue

	/* unzip */
	'@unzip -o 'inst_dir'\java.zip -d 'product_drv'\'product_path' >> 'product_log' 2>>&1'

	/* license */
	'@copy 'inst_dir'\license.jvm 'product_drv'\'product_path'\'jvmdir'\jre\bin\. >> 'product_log' 2>>&1'

	/* store path in ini */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	call SysIni , 'GCJAVA', 'Path', product_drv'\'product_path

	/* create objects */
	call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
	call SysCreateObject 'WPFolder', 'Golden Code JAVA','<WP_DESKTOP>','OBJECTID=<GCJAVA>;'||'ALWAYSSORT=NO;ICONVIEW=FLOWED,NORMAL;','Replace'
	call SysCreateObject 'WPProgram', 'Test Installation', '<GCJAVA>', 'EXENAME='product_drv'\'product_path'\'jvmdir'\jre\bin\java.exe -Xlicenseverify;', 'R'
	call SysCreateObject 'WPProgram', 'Reduce Memory Usage', '<GCJAVA>', 'EXENAME='product_drv'\'product_path'\'jvmdir'\jre\bin\java.exe -XdisableMMFjars;', 'R'
	call SysCreateObject 'WPProgram', 'Readme', '<GCJAVA>', 'EXENAME=e.exe;PARAMETERS='product_drv'\'product_path'\'jvmdir'\README.TXT;', 'R'
	call SysCreateObject 'WPProgram', 'Copyright', '<GCJAVA>', 'EXENAME=e.exe;PARAMETERS='product_drv'\'product_path'\'jvmdir'\Copyright;', 'R'
	call SysCreateObject 'WPProgram', 'License', '<GCJAVA>', 'EXENAME=e.exe;PARAMETERS='product_drv'\'product_path'\'jvmdir'\License;', 'R'
	call SysCreateObject 'WPProgram', 'Run Java Program', '<GCJAVA>', 'EXENAME=cmd.exe;PARAMETERS=/c 'product_drv'\'product_path'\'jvmdir'\jre\bin\java.exe %**N || pause [Command-line arguments for %**F];', 'R'
	call SysCreateObject 'WPProgram', 'Editor for Java', '<GCJAVA>', 'EXENAME=epm.exe;PARAMETERS=/R;', 'R'
	call SysCreateObject 'WPUrl', 'Golden Code Development', '<GCJAVA>', 'NOTDEFAULTICON=YES;DEFAULTVIEW=CONTENTS;URL=http://www.goldencode.com/;', 'R'

end

Say
Say 'Completed.'

exit

/* uninstall mode */
uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<OS2KITJAVAFOLDER>"
	call SysDestroyObject "<GCJAVA>"

	/* del files */
	dest_dir = find_key('USER,OS2 Kit for Java,Path')
	if dest_dir <> '' then call deldir dest_dir
	dest_dir = find_key('USER,GCJAVA,Path')
	if dest_dir <> '' then call deldir dest_dir

	/* delete from ini */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	rc = SysIni('USER', 'OS2 Kit for Java', 'DELETE:')
	rc = SysIni('USER', 'GCJAVA', 'DELETE:')

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

/* find out value key belonging to app stored in ini */
find_key: procedure

  parse arg ini ',' app ',' key
  call rxfuncadd sysini, rexxutil, sysini
  call SysIni ini, 'All:', 'Apps.'
  if Result \= 'ERROR:' then
    do i = 1 to Apps.0
      If apps.i = app then do
        call SysIni ini, Apps.i, 'All:', 'Keys'
        if Result \= 'ERROR:' then
          do j=1 to Keys.0
            if Keys.j = key then do
              val = SysIni(ini, Apps.i, Keys.j)
              return strip(val, 'T', x2c('00'))
            end
          end
      end
    end

return ''
