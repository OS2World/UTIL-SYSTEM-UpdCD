/* VFAT/EXT2/NTFS IFS installation script                           */
/*                                                                  */
/* VFAT driver support                                              */
/* Unzip vfat_005.zip to this directory                             */
/* Add ext2flt.flt from ext2_240.zip if you want Linux FS support   */
/* Warning: This driver does not work with LVM installed            */
/* Installing LVM will automatically disable this driver to avoid   */
/* the hang during boot. If you want this limitation removed please */
/* email the author of the driver: daniel.steiner@cch.cerberus.ch   */
/*                                                                  */
/* eCS NTFS driver support                                          */
/* Place the following files in this directory:                     */
/* NTFS.IFS, NTFSCHK.EXE, UNTFS.DLL, UNTFSD.DLL                     */
/*                                                                  */
/* Last modified on 04.22.2001                                      */
/* 05.20.2002: added support for uninstallation                     */
/* 02.28.2003: drivers were added dubble to config.sys after reinst */
/* 09.26.2003: added support for eCS 1.1 NTFS driver                */

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
if stream(inst_dir'\VFAT-OS2.EXE', 'c', 'query exists') = '' & stream(inst_dir'\NTFS.IFS', 'c', 'query exists') = '' then exit 9

/* config.sys */
cfgfile = target'\config.sys'

/* eCS NTFS support */
if stream(inst_dir'\NTFS.IFS', 'c', 'query exists') <> '' then do

	/* copy files */
	'copy 'inst_dir'\NTFS.IFS    'target'\os2\.     >> 'product_log' 2>>&1'
	'copy 'inst_dir'\NTFSCHK.EXE 'target'\os2\.     >> 'product_log' 2>>&1'
	'copy 'inst_dir'\UNTFS.DLL   'target'\os2\dll\. >> 'product_log' 2>>&1'
	'copy 'inst_dir'\UNTFSD.DLL  'target'\os2\dll\. >> 'product_log' 2>>&1'

	/* update config.sys */
	'echo IFS='target'\OS2\NTFS.IFS /Q /V >> 'cfgfile

end

/* VFAT/NTFS support */
else do

	/* check if LVM active */
	q = 1
	partfilt_active = 0
	mwdd32_active   = 0
	vfatos2_active  = 0
	vfatlw_active   = 0
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		if translate(l.q) = 'BASEDEV=OS2LVM.DMD' then do
			'echo LVM is active, exiting... >> 'product_log
			exit 8
		end
		if translate(l.q) = 'BASEDEV=PARTFILT.FLT /P 0B,0C /W' then do
			l.q = 'BASEDEV=PARTFILT.FLT /P 0B,0C,83 /W'
			partfilt_active = 1
		end
		if translate(l.q) = 'BASEDEV=PARTFILT.FLT /P 0B,0C'    then do
			l.q = 'BASEDEV=PARTFILT.FLT /P 0B,0C,83'
			partfilt_active = 1
		end
		if pos('BASEDEV=MWDD32.SYS', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then
			mwdd2_active = 1
		if pos('VFAT-OS2.IFS', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then
			vfatos2_active = 1
		if pos('VFAT_LW.EXE', translate(l.q)) > 0 & substr(translate(l.q), 1, 3) <> 'REM' then
			vfatlw_active = 1
		q=q+1
	end
	l.0 = q-1
	call lineout cfgfile
	
	/* copy files */
	'copy 'inst_dir'\MWDD32.SYS   'target'\os2\boot\. >> 'product_log' 2>>&1'
	'copy 'inst_dir'\VFAT-OS2.IFS 'target'\os2\.      >> 'product_log' 2>>&1'
	'copy 'inst_dir'\remount.exe  'target'\os2\.      >> 'product_log' 2>>&1'
	'copy 'inst_dir'\umount.exe   'target'\os2\.      >> 'product_log' 2>>&1'
	'copy 'inst_dir'\VFAT_LW.EXE  'target'\os2\.      >> 'product_log' 2>>&1'
	'copy 'inst_dir'\VFAT-OS2.EXE 'target'\os2\.      >> 'product_log' 2>>&1'
	if stream(inst_dir'\ext2flt.flt', 'c', 'query exists') <> '' then 
		'copy 'inst_dir'\ext2flt.flt  'target'\os2\.    >> 'product_log' 2>>&1'
	
	/* update config.sys */
	'copy 'cfgfile target'\os2\install\config.vft >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		rc = lineout(cfgfile, l.q)
	end
	call lineout cfgfile, ' '
	call lineout cfgfile, 'REM UpdCD'
	if mwdd32_active   = 0 then call lineout cfgfile, 'BASEDEV=MWDD32.SYS -q'
	if partfilt_active = 0 then call lineout cfgfile, 'BASEDEV=EXT2FLT.FLT'
	if vfatos2_active  = 0 then call lineout cfgfile, 'REM IFS='target'\os2\vfat-os2.ifs -q -cache:256 -errors=continue -VFAT:*'
	if vfatos2_active  = 0 then call lineout cfgfile, 'IFS='target'\os2\vfat-os2.ifs -q -cache:256 -errors=continue -NTFS'
	if vfatlw_active   = 0 then call lineout cfgfile, 'RUN='target'\os2\vfat_lw.exe'
	call lineout cfgfile

end
	
exit

uninstall:

	/* update config.sys */
	cfgfile = target'\config.sys'
	q = 1
	do while lines(cfgfile)
		l.q = linein(cfgfile)
		q=q+1
	end
	call lineout cfgfile
	l.0=q-1
	'copy 'cfgfile target'\os2\install\config.vft >> 'product_log 
	'del 'cfgfile' >> 'product_log 
	do q=1 to l.0
		if pos('MWDD32.SYS',   translate(l.q)) > 0 then iterate
		if pos('VFAT-OS2.IFS', translate(l.q)) > 0 then iterate
		if pos('VFAT_LW.EXE',  translate(l.q)) > 0 then iterate
		if pos('NTFS.IFS',     translate(l.q)) > 0 then iterate
		call lineout cfgfile, l.q
	end
	call lineout cfgfile

	/* delete files */
	if stream(inst_dir'\NTFS.IFS', 'c', 'query exists') = '' then do
		'call 'source'\updcd\bin\unlock.exe 'target'\os2\remount.exe'
		'call 'source'\updcd\bin\unlock.exe 'target'\os2\umount.exe'
		'call 'source'\updcd\bin\unlock.exe 'target'\os2\VFAT-OS2.EXE'
		'call 'source'\updcd\bin\unlock.exe 'target'\os2\VFAT_LW.EXE'
		'del 'target'\os2\boot\MWDD32.SYS >> 'product_log
		'del 'target'\os2\VFAT-OS2.IFS    >> 'product_log
		'del 'target'\os2\remount.exe     >> 'product_log
		'del 'target'\os2\umount.exe      >> 'product_log
		'del 'target'\os2\VFAT_LW.EXE     >> 'product_log
		'del 'target'\os2\VFAT-OS2.EXE    >> 'product_log
	end
	else do
		'call 'source'\updcd\bin\unlock.exe 'target'\os2\NTFSCHK.EXE'
		'call 'source'\updcd\bin\unlock.exe 'target'\os2\dll\UNTFS.DLL'
		'call 'source'\updcd\bin\unlock.exe 'target'\os2\dll\UNTFSD.DLL'
		'del 'target'\os2\NTFS.IFS        >> 'product_log
		'del 'target'\os2\NTFSCHK.EXE     >> 'product_log
		'del 'target'\os2\dll\UNTFS.DLL   >> 'product_log
		'del 'target'\os2\dll\UNTFSD.DLL  >> 'product_log
	end

return
