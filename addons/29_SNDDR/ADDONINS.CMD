/* General install script for sound driver                                  */
/*                                                                          */
/* Unpack/Unzip the distribution package here                               */ 
/* If you add the SBLive driver do not forget to rename sblive32w4.sys or   */
/* sblive32kee.sys (Warp 4+FP13 or higher) to sblive32.sys                  */
/*                                                                          */
/* If you work with uniaud please be sure that you use a full distribution  */
/* of the package available on ftp://ftp.os2.kiev.ua/uniaud. You may update */
/* update it with newer files from the zip found on                         */
/* ftp://ftp.netlabs.org/pub/uniaud. If you use this update you have to     */
/* manually add the line 0 17 2 0 "uniaud.dll" to audfiles.scr. Be sure     */
/* ftp://ftp.netlabs.org/pub/wvgui/libc06r1.zip is installed somewehere in  */
/* your LIBPATH or place it in this directory as well.                      */
/*                                                                          */
/* Optionally you can place the the files of unimixerpm here.               */
/*                                                                          */
/* 10.11.2002: created                                                      */
/* 12.14.2002: minstall is not always in path                               */
/* 11.20.2005: aligned with os2mt                                           */
/* 11.22.2005: added support for unimixerpm                                 */

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
if stream(inst_dir'\cardinfo.dll', 'c', 'query exists') = '' then exit 9

Say
Say 'Installing Sound Driver...'

/* preserve dir */
cdir = directory()
call directory inst_dir

/* run minstall */
if stream(target'\mmos2\minstall.exe','C','query exists') <> '' then do
	'@'target'\mmos2\minstall >> 'product_log
	if stream(inst_dir'\libc06r1.dll', 'C', 'query exists') <> '' then do
		'@copy 'inst_dir'\libc06r1.dll 'target'\os2\dll\. >> 'product_log
	end
	if stream(inst_dir'\UniMix.exe', 'C', 'query exists') <> '' then do
		call SysCreateObject 'WPFolder',  'UniMixer',   '<WP_DESKTOP>', 'OBJECTID=<UNIMIXER_FOLDER>;','R'
		call SysCreateObject 'WPProgram', 'UniMixer',   '<UNIMIXER_FOLDER>', 'EXENAME='target'\mmos2\unimix.exe;','R'
		call SysCreateShadow target'\mmos2\unimix.txt', '<UNIMIXER_FOLDER>'
	end
	if stream(inst_dir'\UniMixPM.exe', 'C', 'query exists') <> '' then do
		'@copy 'inst_dir'\UniMixPM.exe 'target'\mmos2\. >> 'product_log
		'@copy 'inst_dir'\example.cmd  'target'\mmos2\. >> 'product_log
		'@copy 'inst_dir'\unimixpm.txt 'target'\mmos2\. >> 'product_log
		call SysCreateObject 'WPProgram', 'UniMixerPM',   '<UNIMIXER_FOLDER>', 'EXENAME='target'\mmos2\unimixpm.exe;','R'
		call SysCreateShadow target'\mmos2\example.cmd',  '<UNIMIXER_FOLDER>'
		call SysCreateShadow target'\mmos2\unimixpm.txt', '<UNIMIXER_FOLDER>'
	end
end
else do
	Say
	Say 'Error: No 'target'\mmos2\minstall.exe has been found on your system.'
	'@echo Error: No 'target'\mmos2\minstall.exe has been found on your system. >> 'product_log
end

/* restore dir */
call directory cdir

/* done */
Say
Say 'Completed.'

exit

uninstall:

	/* run minstall */
	if stream(target'\mmos2\minstall.exe','C','query exists') <> '' then do
		Say
		Say 'This program will start thr Multimedia Installation program.'
		Say 'Select 0 for the number of adapters. It will desinstall the driver.'
		'@pause'
		'@'target'\mmos2\minstall >> 'product_log
		call SysDestroyObject '<UNIMIXER_FOLDER>'
		'@del 'target'\mmos2\UniMixPM.exe >nul 2>>&1'
		'@del 'target'\mmos2\example.cmd  >nul 2>>&1'
		'@del 'target'\mmos2\unimixpm.txt >nul 2>>&1'
	end
	else do
		Say
		Say 'No 'target'\mmos2\minstall.exe has been found on your system.'
		Say 'Remove the lines containing the sound driver manually from your Config.Sys.'
		'@pause'
	end

return
