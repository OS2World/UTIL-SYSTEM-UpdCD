/* PMVIEW installation file                          */
/* PMView 2.32: unrar/run the distribution exe here  */
/* PMView 3.02: place the pmvos2e.exe here           */
/* Do not forget to register!                        */
/* 05.08.2002: created                               */
/* 05.25.2002: added support for uninstallation      */
/* 07.18.2002: changed header information            */
/* 09.04.2002: changed header information            */
/* 08.27.2003: registration program did not work     */
/* 08.28.2003: added support for pmview pro (3.02)   */
/* 09.30.2005: aligned with os2mt                    */

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
if stream(inst_dir'\install.exe', 'c', 'query exists') = '' & stream(inst_dir'\pmvos2e.exe', 'c', 'query exists') = '' then exit 9

Say
Say 'Starting installer...'

if stream(inst_dir'\install.exe', 'c', 'query exists') <> '' then do

	/* create install dir */
	PMViewDIR = product_drv'\'product_path
	SOMObjDIR = PMViewDIR

	/* Create sub-directories */
	'@mkdir '||PMViewDIR||'\filters  >> 'product_log
	'@mkdir '||PMViewDIR||'\dragdrop >> 'product_log

	/* Create the PMView folder on the desktop */
	Call SysCreateObject 'WPFolder','PMView 2000','<WP_DESKTOP>','OBJECTID=<PMVIEW20FOLDER>','U'

	/* Delete and deregister the PMVDDrop object (just in case it is installed already) */
	Call SysDestroyObject '<PMVDDrop>'
	call SysDeregisterObjectClass 'PMVDDrop'

	/* Unpack the files in PMVIEW1 */
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:pmv20uic.msg >> 'product_log
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:pmv4.msg     >> 'product_log
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:pmv4c01e.msg >> 'product_log
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:pmv20htk.dll >> 'product_log 
	'@unpack 'inst_dir'\pmview1.PA_ '||SOMObjDIR||' /N:pmvddrop.dll >> 'product_log
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:makedefv.exe >> 'product_log
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:register.exe >> 'product_log
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:register.dat >> 'product_log

	/* Unpack unlock.exe and run it with 'pmview.exe' as parameter. This  */
	/* will unlock a running copy of PMView and lets us update pmview.exe */
	/* without requiring a reboot                                         */
	'@unpack 'inst_dir'\pmview1.PA_ '||PMViewDIR||' /N:unlock.exe   >> 'product_log
	'if exist '||PMViewDIR||'\pmview.exe '@||PMViewDIR||'\unlock.exe '||PMViewDIR||'\pmview.exe >> 'product_log

	/* Unpack pmview.exe in PMVIEW2 */
	'@unpack 'inst_dir'\pmview2.PA_ '||PMViewDIR||' /N:pmview.exe   >> 'product_log

	/* Unpack the files in PMVIEW3 */
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||' /N:pmview.hlp   >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||' /N:readme.txt   >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||' /N:trouble.txt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||' /N:twain.txt    >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||' /N:order.txt    >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||' /N:ordform.txt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\dragdrop /N:instdd.cmd   >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\dragdrop /N:uninstdd.cmd >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour2.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour3.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour4.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour5.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour6.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour7.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:contour_.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:diagonal.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossi1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossi2.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossi3.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossi4.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossi5.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossi6.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossi7.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:embossin.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradien1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradien2.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradien3.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradien4.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradien5.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradien6.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradien7.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:gradient.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:high_pa1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:high_pa2.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:high_pa3.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:high_pas.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:horizon1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:horizont.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:laplaci1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:laplaci2.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:laplacia.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:low_pas1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:low_pas2.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:low_pas3.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:low_pas4.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:low_pass.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:prewitt1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:prewitt_.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:sobel_ho.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:sobel_ve.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:vertica1.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:vertica2.flt  >> 'product_log
	'@unpack 'inst_dir'\pmview3.PA_ '||PMViewDIR||'\filters /N:vertical.flt  >> 'product_log

	/* Store the program location in OS2.INI */
	call Sysini 'USER', 'PMView 2.0', 'Installer\ProgramPath', PMViewDIR

	/* Create a PMView program object in the PMView folder */
	Call SysCreateObject 'WPProgram','PMView 2000','<PMVIEW20FOLDER>','EXENAME='||PMViewDIR||'\pmview.exe;STARTUPDIR='||PMViewDIR||';OBJECTID=<PMVIEW20>;CCVIEW=YES','U'

	/* Create an object for the readme.txt file */
	Call SysCreateObject 'WPShadow','readme.txt','<PMVIEW20FOLDER>','SHADOWID='||PMViewDIR||'\readme.txt;OBJECTID=<PMVIEW20README>','U'

	/* Create an object for the trouble.txt file */
	Call SysCreateObject 'WPShadow','trouble.txt','<PMVIEW20FOLDER>','SHADOWID='||PMViewDIR||'\trouble.txt;OBJECTID=<PMVIEW20TROUBLESHOOTING>','U'

	/* Create an object for the twain.txt file */
	Call SysCreateObject 'WPShadow','twain.txt','<PMVIEW20FOLDER>','SHADOWID='||PMViewDIR||'\twain.txt;OBJECTID=<PMVIEW20TWAININFO>','U'

	/* Create a program object for the makedefv utility in the PMView folder */
	Call SysCreateObject 'WPProgram','Set File Associations','<PMVIEW20FOLDER>','EXENAME='||PMViewDIR||'\makedefv.exe;STARTUPDIR='||PMViewDIR||';OBJECTID=<PMVIEW20MAKEDEFV>;CCVIEW=NO','U'

	/* Create a program object for the registration utility in the PMView folder */
	Call SysCreateObject 'WPProgram','Registration','<PMVIEW20FOLDER>','EXENAME='||PMViewDIR||'\register.exe;STARTUPDIR='||PMViewDIR||';OBJECTID=<PMVIEW20REGISTER>;CCVIEW=NO','U'

	/* Register and create the PMVDDrop object with WPS */
	call SysRegisterObjectClass 'PMVDDrop', SOMObjDir||'\pmvddrop.dll'
	Call SysCreateObject 'PMVDDrop','PMVDDrop','<WP_DESKTOP>','NOTVISIBLE=YES;OBJECTID=<PMVDDrop>','U'

	/* Delete files no longer needed */
	'@del '||PMViewDIR||'\unlock.exe'

end
else do

	/* start warpin installer */
	cdir = directory()
	rc   = directory(get_ini_key(warpin path))
	'@WarpIN.Exe 'inst_dir'\pmvos2e.exe'
	rc = directory(cdir)

end

Say
Say 'Completed.'

exit

uninstall:

	if stream(inst_dir'\install.exe', 'c', 'query exists') <> '' then do

		/* unlock files */
		'call 'source'\updcd\bin\unlock.exe 'product_drv'\'product_path'\pmview.exe'
		'call 'source'\updcd\bin\unlock.exe 'product_drv'\'product_path'\pmvddrop.dll'

		/* destroy objects */
		call RxFuncAdd 'SysDestroyObject', 'RexxUtil', 'SysDestroyObject'
		call SysDestroyObject "<PMVIEW20FOLDER>"

		/* dereg */
		call RxFuncAdd 'SysDeRegisterObjectClass', 'RexxUtil', 'SysDeRegisterObjectClass'
		call SysDeRegisterObjectClass 'PMVDDrop'

	end
	else do

		/* run warpin to uninstall */
		cdir = directory()
		rc   = directory(get_ini_key(warpin path))
		'WarpIN.Exe'
		rc = directory(cdir)	

	end

	/* del files */
	call deldir product_drv'\'product_path

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

/* get apps key value from OS2.INI */
get_ini_key: procedure

	parse upper arg apps key

	call rxfuncadd sysini, rexxutil, sysini
	call SysIni 'USER', 'All:', 'Apps.'
	do i = 1 to Apps.0	
		if translate(apps.i) = apps then do
			call SysIni 'USER', Apps.i, 'All:', 'Keys'
 	   	do j=1 to Keys.0
 	   		if translate(Keys.j) = key then do
					val = SysIni('USER', Apps.i, Keys.j)
					return val
				end
    	end
  	end
	end

return ''
