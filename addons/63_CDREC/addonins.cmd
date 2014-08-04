/* CDRECORD/2 installation script                                       */
/*                                                                      */
/* Tested with the Chris Wohlgemuth port of CDRecord                    */
/* URL: http://www.os2world.com/cdwriting/cdrecord/cdrecordmain.htm     */
/* Unzip the distribution zip (cdrecord-2_00_os2.zip) in this directory */
/*                                                                      */
/* Created: 10.23.2001                                                  */
/* 05.26.2002: added support for uninstallation                         */
/* 10.31.2003: added more info to header                                */
/* 05.15.2005: aligned with the directory structure of 2.0 distribution */
/* 09.30.2005: aligned with os2mt                                       */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
product_drv       = value("PRODUCT_DRV"      , ,"OS2ENVIRONMENT")
product_path      = value("PRODUCT_PATH"     , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* exit if package does not exist */
if stream(inst_dir'\cdrecord.exe', 'c', 'query exists') = '' & stream(inst_dir'\cdr-2_0\cdrecord.exe', 'c', 'query exists') = '' then exit 9

/* determine ppath */
ppath = 'cdr-2_0'
if stream(inst_dir'\cdrecord.exe', 'c', 'query exists') <> '' then ppath = ''

/* copy files */
Say
Say 'Copying files...'
'@xcopy 'inst_dir'\'ppath'\* 'product_drv'\'product_path'\. /E/V/S/H/O/T/R >> 'product_log' 2>>&1'
if stream(product_drv'\'product_path'\addonins.cmd','c','query exists') <> '' then do
	'@attrib -r 'product_drv'\'product_path'\addonins.cmd >> 'product_log' 2>>&1'
	'@del 'product_drv'\'product_path'\addonins.cmd >> 'product_log' 2>>&1'
end

/* load rexxutil */
call rxfuncadd sysloadfuncs, rexxutil, sysloadfuncs
call sysloadfuncs

/* create objects */
Say
Say 'Creating objects...'
call create_icons "CDRecord/2 <WP_DESKTOP> <CDREC2> "product_drv"\"product_path

/* create test object */
if stream(product_drv'\'product_path'\test.cmd','c','query exists') <> '' then
	'@del 'product_drv'\'product_path'\test.cmd'
call create_test_program product_drv'\'product_path'\test.cmd'
call SysCreateObject 'WPProgram', 'Command Prompt', '<CDREC2>', 'EXENAME=CMD.EXE;PARAMETERS=/K "MODE CO80,102";STARTUPDIR='product_drv'\'product_path';', 'R'
call SysCreateObject 'WPProgram', 'Test Installation ^ (start here)', '<CDREC2>', 'EXENAME='product_drv'\'product_path'\test.cmd', 'R'

/* read the config.sys */
Say
Say 'Update config.sys...'
cfgfile = target'\config.sys'
q = 1
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('SET PATH=', translate(l.q)) > 0 & pos(translate(product_drv'\'product_path), translate(l.q)) = 0 then do
		lpos = length(l.q)
		if substr(l.q, lpos) = ';' then l.q = l.q || product_drv'\'product_path';'
		else l.q = l.q || ';' || product_drv'\'product_path';'
	end
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* backup and write new config.sys */
'@copy 'cfgfile target'\os2\install\config.cdr >> 'product_log 
'@del 'cfgfile' >> 'product_log 
do q=1 to l.0
	rc = lineout(cfgfile, l.q)
end

Say
Say 'Completed.'

exit

create_icons: procedure expose product_log
	parse arg title pid fid path
	call lineout product_log, 'Creating objects: 'title pid fid path
	call lineout product_log
	call SysCreateObject 'WPFolder', title, pid, 'OBJECTID='fid';ICONVIEW=FLOWED,NORMAL;', 'R'
	call sysfiletree path'\*', 'file.'
	do i=1 to file.0
		parse var file.i . . size attrib sdir rest
		/* create folder */
		if size = 0 & substr(attrib, 2, 1) = 'D' then do
			title = filespec('name', sdir)
			subfid = '<CDREC2_'title'>'
			call create_icons title fid subfid sdir
		end
		/* create icon */
		else do
			title = filespec('name', sdir)
			ext = translate(substr(title, lastpos('.', title)+1))
			if ext = 'EXE' then do
				found=0
				do while lines(sdir)
					l=linein(sdir)
					if pos('emx.exe', l) > 0 then do
						found=1
						leave;
					end
				end
				call lineout sdir
				if found=1 then call SysCreateObject 'WPProgram', title, fid, 'EXENAME=CMD.EXE;PARAMETERS=/K "MODE CO80,102 & 'sdir'";STARTUPDIR='filespec('drive', sdir)||filespec('path', sdir)';NOAUTOCLOSE=YES', 'R'
				else call SysCreateObject 'WPProgram', title, fid, 'EXENAME='sdir';STARTUPDIR='filespec('drive', sdir)||filespec('path', sdir), 'R'
			end
			else if ext = 'BAT' | ext = 'CMD' then 
				call SysCreateObject 'WPProgram', title, fid, 'EXENAME=CMD.EXE;PARAMETERS=/K "MODE CO80,102 & 'sdir'";STARTUPDIR='filespec('drive', sdir)||filespec('path', sdir)';NOAUTOCLOSE=YES', 'R'
			else if ext = 'HTM' | ext = 'HTML' then
				call SysCreateObject 'WPUrl', title, fid, 'NOTDEFAULTICON=YES;DEFAULTVIEW=CONTENTS;URL=file:///'translate(translate(sdir,'|',':'), '/', '\')';', 'R'
			else
				call SysCreateObject 'WPProgram', title, fid, 'EXENAME=e.exe;PARAMETERS='sdir';', 'R'
		end
	end
return

create_test_program: procedure expose product_drv product_path
	
	parse arg outfile

	line.1 = "/* Check CDRecord installation */"
	line.2 = " "
	line.3 = "'@cls'"
	line.4 = "f='temp.cdr'"
	line.5 = "say"
	line.6 = "say 'This program will check the installation of CDRecord/2.'"
	line.7 = "say"
	line.8 = "say 'Running command: "product_drv"\"product_path"\cdrecord.exe -scanbus'"
	line.9 = "'@"product_drv"\"product_path"\cdrecord.exe -scanbus > 'f"
	line.10 = "l=linein(f)"
	line.11 = "if length(l) = 0 then do"
	line.12 = "	say 'Cannot run cdrecord.exe, check if EMX installed!'"
	line.13 = "	pause"
	line.14 = "	exit 1"
	line.15 = "end"
	line.16 = "parse var l w1 w2 ."
	line.17 = "say 'Detected CDRecord/2 version: 'w2"
	line.18 = " "
	line.19 = "say"
	line.20 = "say 'Detected SCSI devices:'"
	line.21 = "l=linein(f)"
	line.22 = "do while lines(f)"
	line.23 = "	l=linein(f)"
	line.24 = "	if pos('*', l) = 0 & pos('scsibus', l) = 0 then say l"
	line.25 = "end"
	line.26 = "call lineout f"
	line.27 = "'@del 'f"
	line.28 = " "
	line.29 = "say"
	line.30 = "say 'Please enter the SCSI ID of the device you want to use with CDRecord/2'"
	line.31 = "say 'and press ENTER. If you do not see your device check if you load the'"
	line.32 = "say 'appropriate SCSI driver in your config.sys. Check if ASPI router is'"
	line.33 = "say 'installed. If you use an IDE device check if DANI ATAPI and DANI IDE'"
	line.34 = "say 'are installed. Example SCSI ID response: 0,1,0'"
	line.35 = "response = ''"
	line.36 = "do while length(response) <> 5"
	line.37 = "	pull response"
	line.38 = "	if length(response) <> 5 then say 'Invalide response, try again!'"
	line.39 = "end"
	line.40 = " "
	line.41 = "say"
	line.42 = "say 'Creating sample command files...'"
	line.43 = "call rxfuncadd syscreateobject, rexxutil, syscreateobject"
	line.44 = " "
	line.45 = "f = 'image.cmd'"
	line.46 = "'@del 'f' >nul 2>>&1'"
	line.47 = "call lineout f, '/* create image file */'"
	line.48 = "call lineout f, ' '"
	line.49 = "call lineout f, ""'@cls'"""
	line.50 = "call lineout f, ""say"""
	line.51 = "call lineout f, ""say 'This program will create an ISO image on your hard disk.'"""
	line.52 = "call lineout f, ""say 'Specify a directory which should be imaged.'"""
	line.53 = "call lineout f, ""say 'Example: d:\burn'"""
	line.54 = "call lineout f, ""say"""
	line.55 = "call lineout f, ""pull directory"""
	line.56 = "call lineout f, ' '"
	line.57 = "call lineout f, ""rawfile = filespec('name', directory)'.raw'"""
	line.58 = "call lineout f, ""'@""directory()""\mkisofs -l -L -R -o 'rawfile directory"""
	line.59 = "call lineout f, ""say 'Image file 'rawfile' created with return code 'rc"""
	line.60 = "call lineout f, "" """
	line.61 = "call lineout f, ""exit"""
	line.62 = "call lineout f"
	line.63 = " "
	line.64 = "f = 'burn.cmd'"
	line.65 = "'@del 'f' >nul 2>>&1'"
	line.66 = "call lineout f, '/* burn CD */'"
	line.67 = "call lineout f, ' '"
	line.68 = "call lineout f, ""'@cls'"""
	line.69 = "call lineout f, ""say"""
	line.70 = "call lineout f, ""say 'This program will burn a CD from an ISO image on your hard disk.'"""
	line.71 = "call lineout f, ""say 'Specify the image file which should be used.'"""
	line.72 = "call lineout f, ""say 'Example: d:\burn\cd.raw'"""
	line.73 = "call lineout f, ""say"""
	line.74 = "call lineout f, ""pull rawfile"""
	line.75 = "call lineout f, ' '"
	line.76 = "call lineout f, ""device = '""response""'"""
	line.77 = "call lineout f, ""speed = '2'"""
	line.78 = "call lineout f, ""say """
	line.79 = "call lineout f, ""say 'Burning CD using image file 'rawfile' on device 'device' with 'speed' speed.'"""
	line.80 = "call lineout f, ""'@""directory()""\cdrecord dev='device' speed='speed' -v -eject -pad -data 'rawfile"""
	line.81 = "call lineout f, ""say 'The CD-ROM has been created with return code 'rc"""
	line.82 = "call lineout f, ' '"
	line.83 = "call lineout f, ""exit"""
	line.84 = "call lineout f"
	line.85 = " "
	line.86 = "call SysCreateObject 'WPProgram', 'Burn CD-ROM (step 2)', '<CDREC2>', 'EXENAME='directory()'\burn.cmd;NOAUTOCLOSE=YES', 'R'"
	line.87 = "call SysCreateObject 'WPProgram', 'Create image (step 1)', '<CDREC2>', 'EXENAME='directory()'\image.cmd;NOAUTOCLOSE=YES', 'R'"
	line.88 = "say 'Done! Press ENTER to exit.'"
	line.89 = "pull response"
	line.90 = " "
	line.91 = "exit"
	line.92 = " "

	do i=1 to 92
		call lineout outfile, line.i
	end

return

uninstall:

	/* destroy objects */
	call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
	call SysDestroyObject "<CDREC2>"

	/* delete files */
	call deldir product_drv'\'product_path

	/* change config */
	cfgfile = target'\config.sys'
	call remove_from_path cfgfile product_drv'\'product_path' SET PATH='

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

/* remove string from path */
remove_from_path: procedure

	parse upper arg cfgfile rpstr ststr 

	i=1
	do while lines(cfgfile)
		l.i=linein(cfgfile)
		i=i+1
	end
	call lineout cfgfile
	l.0=i-1
	'@del 'cfgfile

	do i=1 to l.0
		/* remove rpstr */
		if substr(translate(l.i), 1, length(ststr)) = ststr & pos(rpstr, translate(l.i)) > 0 then do
			l.i = substr(l.i, 1, pos(rpstr, translate(l.i))-1) || substr(l.i, pos(rpstr, translate(l.i))+length(rpstr))
			/* remove ;; */
			if pos(';;', translate(l.i)) > 0 then 
				l.i = substr(l.i, 1, pos(';;', translate(l.i))-1) || ';' || substr(l.i, pos(';;', translate(l.i))+length(';;'))
		end
		call lineout cfgfile, l.i
	end
	call lineout cfgfile

return
