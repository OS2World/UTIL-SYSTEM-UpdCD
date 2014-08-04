/* Install script for the FAT32 driver                                    */
/*                                                                        */
/* Place the following files in this directory from the FAT32 package:    */
/* FAT32.IFS, CACHEF32.EXE, F32STAT.EXE, UFAT32.DLL, FAT32.TXT, FAT32.INF */
/*                                                                        */
/* Depending on the version you are using you also need to place the      */
/* following files here: F32PARTS.EXE or DISKINFO.EXE, F32MON.EXE or      */
/* MONITOR.EXE.                                                           */
/*                                                                        */
/* If you use MONITOR.EXE and DISKINFO.EXE they will be ranemed to        */
/* F32MON.EXE and F32PARTS.EXE during installation to comply with newer   */
/* versions of the FAT32 driver package.                                  */
/*                                                                        */
/* You may extract the files from the Netlab WPI distribution file        */
/* using WIC.EXE distributed with the WarpIn installer. The extract       */
/* commands are: wic fat32_netlab_dani.wpi -x 1                           */
/*               wic fat32_netlab_dani.wpi -x 2                           */
/*                                                                        */
/* Or just simply use the zip distribution file. :-)                      */
/*                                                                        */
/* On non-LVM systems you als need to add PARTFILT.FLT or DANIDASD.DMD.   */
/* PARTFILT.FLT can be found in older versions of the FAT32 driver.       */
/*                                                                        */
/* 05.05.2001: FAT32.IFS will be added before the PROTSHELL line, and not */
/*             after HPFS.IFS. HPFS.IFS is not always in the config.sys.  */ 
/* 23.01.2002: added option 0B,0C,1B,1C to partfilt.flt                   */
/* 05.24.2002: added support for uninstallation                           */
/* 05.26.2002: copy diskinfo.exe to diskif32.exe (dani has the same tool) */
/* 01.09.2003: fixed danidasd.dmd uninstallation problem                  */
/* 12.08.2003: added info to header to support Netlabs' FAT32 driver      */
/* 10.26.2003: added support for version 0.97                             */
/* 11.23.2003: do not try to copy monitor/diskinfo if they are not here   */
/* 08.22.2004: added /F option to fat32cache                              */
/* 09.30.2005: aligned with os2mt                                         */
/* 10.20.2005: added overwrite mode                                       */
/* 11.09.2005: added unlocking cachef32.exe during install                */
/* 04.01.2006: TXT and INF file should go to \os2\book                    */

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
if stream(inst_dir'\fat32.ifs', 'c', 'query exists') = '' then exit 9

Say
Say 'Updating files...'

/* copy files but do not overwrite them if they are already there */
if stream(target'\os2\FAT32.IFS', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\FAT32.IFS 'target'\os2\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\CACHEF32.EXE', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@'source'\updcd\bin\unlock.exe 'target'\os2\cachef32.exe >nul 2>>&1'
	'@copy 'inst_dir'\CACHEF32.EXE 'target'\os2\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\F32STAT.EXE', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\F32STAT.EXE 'target'\os2\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\F32MON.EXE', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\F32MON.EXE 'target'\os2\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\MONITOR.EXE', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	if stream(inst_dir'\MONITOR.EXE', 'c', 'query exists') <> '' then 
		'@copy 'inst_dir'\MONITOR.EXE 'target'\os2\F32MON.EXE >> 'product_log' 2>>&1'
end
if stream(target'\os2\F32PARTS.EXE', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\F32PARTS.EXE 'target'\os2\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\DISKINFO.EXE', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	if stream(inst_dir'\DISKINFO.EXE', 'c', 'query exists') <> '' then
		'@copy 'inst_dir'\DISKINFO.EXE 'target'\os2\F32PARTS.EXE >> 'product_log' 2>>&1'
end
if stream(target'\os2\DLL\UFAT32.DLL', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\UFAT32.DLL 'target'\os2\dll\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\boot\PARTFILT.FLT', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
  if stream(inst_dir'\PARTFILT.FLT', 'c', 'query exists') <> '' then 
		'@copy 'inst_dir'\PARTFILT.FLT 'target'\os2\boot\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\boot\DANIDASD.DMD', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	if stream(inst_dir'\DANIDASD.DMD', 'c', 'query exists') <> '' then 
		'@copy 'inst_dir'\DANIDASD.DMD 'target'\os2\boot\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\book\fat32.txt', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\fat32.txt 'target'\os2\book\. >> 'product_log' 2>>&1'
end
if stream(target'\os2\book\fat32.inf', 'c', 'query exists') = '' | mode = 'OVERWRITE' then do
	'@copy 'inst_dir'\fat32.inf 'target'\os2\book\. >> 'product_log' 2>>&1'
end

/* change config.sys if needed */
Say
Say 'Updating Config.Sys...'
cfgfile = target'\config.sys'
q = 1
lvm_active = 0
do while lines(cfgfile)
	l.q = linein(cfgfile)
	if pos('FAT32.IFS',  translate(l.q)) > 0 then exit /* the driver is already added, leave the config.sys alone */
	if pos('OS2LVM.DMD', translate(l.q)) > 0 then lvm_active = 1
	q = q+1
end
rc = lineout(cfgfile)
l.0 = q-1

/* backup config.sys */
'@copy 'cfgfile target'\os2\install\config.f32 >nul' 
'@del 'cfgfile
gevonden = 0
do q=1 to l.0
	if pos('PROTSHELL=', translate(l.q)) > 0 then do
		/* add FAT32 driver after PROTSHELL= */
		gevonden = 1
	end
	if (pos('OS2DASD.DMD', translate(l.q)) = 0 | stream(inst_dir'\DANIDASD.DMD', 'c', 'query exists') = '') then rc = lineout(cfgfile, l.q)
	if gevonden = 1 then do
		rc = lineout(cfgfile, ' ')
		rc = lineout(cfgfile, 'REM UpdCD')
		rc = lineout(cfgfile, 'IFS='target'\OS2\FAT32.IFS /CACHE:2048')
		rc = lineout(cfgfile, 'CALL='target'\OS2\CACHEF32.EXE /F')
		if lvm_active = 0 then do
			if stream(inst_dir'\DANIDASD.DMD', 'c', 'query exists') <> '' then rc = lineout(cfgfile, 'BASEDEV=DANIDASD.DMD') 
			else rc = lineout(cfgfile, 'BASEDEV=PARTFILT.FLT /P 0B,0C,1B,1C /W') 
		end
		else do
			if stream(inst_dir'\DANIDASD.DMD', 'c', 'query exists') <> '' then rc = lineout(cfgfile, 'BASEDEV=OS2DASD.DMD') 
		end
		gevonden = 0
	end
end
rc = lineout(cfgfile)

Say
Say 'Completed.'

exit

uninstall:

	/* update config.sys */
	found. = 0
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.f32 >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('\OS2\FAT32.IFS', translate(l.q)) > 0 then iterate
		if pos('\OS2\CACHEF32.EXE', translate(l.q)) > 0 then iterate
		if pos('DANIDASD.DMD', translate(l.q)) > 0 then do
			call lineout cfgfile, 'BASEDEV=OS2DASD.DMD'
			iterate
		end
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

	/* delete files */
	'call 'source'\updcd\bin\unlock.exe 'target'\os2\cachef32.exe'
	'del 'target'\os2\fat32.ifs    >> 'product_log
	'del 'target'\os2\cachef32.exe >> 'product_log
	'del 'target'\os2\F32MON.EXE  >> 'product_log
	'del 'target'\os2\F32PARTS.EXE >> 'product_log
	'del 'target'\os2\DLL\UFAT32.DLL >> 'product_log
	'del 'target'\os2\book\fat32.txt >> 'product_log
	'del 'target'\os2\book\fat32.inf >> 'product_log
	if stream(target'\os2\boot\danidasd.dmd', 'c', 'query exists') <> '' then 'del 'target'\os2\boot\danidasd.dmd >> 'product_log

return
