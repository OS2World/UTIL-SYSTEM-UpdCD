@echo off
cls
echo+
echo+
REM check
if not exist .\newinst\config.sys goto msg1
if "%1" == "" goto msg2
if exist %1\DISKIMGS\LOADDSKF.EXE goto start
echo %1 does not seem to contain the OS/2 installation files.
goto end

REM start floppy creation
:start

	echo+
	echo This program will create 3 boot diskettes which can be used to boot
	echo to OS/2 and to setup and run UpdCD on a FAT32 or a HPFS partition.
	pause

	REM Create disk 0
	echo+
	echo Label a blank diskette "UpdCD Diskette 0" and insert it into Drive A:
	pause
	echo+
	echo Creating UpdCD Diskette 0...
	%1\DISKIMGS\LOADDSKF %1\DISKIMGS\OS2\35\DISK0.DSK A: /Y/Q/F
	if ERRORLEVEL 1 goto bad
	echo+
	del A:\bundle >nul 2>nul
	del A:\readme.cid >nul 2>nul
	del A:\readme.ins >nul 2>nul
	del A:\xdfcopy.exe >nul 2>nul
	del A:\xdf.msg >nul 2>nul
	del A:\xdfh.msg >nul 2>nul
	del A:\config.x >nul 2>nul
	del A:\dmf_ps2.cmd >nul 2>nul

	REM Create disk 2
	echo+
	echo Please remove the diskette from Drive A:
	pause
	echo+
	echo Label another blank diskette "UpdCD Diskette 2" and insert it into Drive A:
	pause
	echo+
	echo Creating UpdCD Diskette 2...
	%1\DISKIMGS\LOADDSKF %1\DISKIMGS\OS2\35\DISK2.DSK A: /Y/Q/F
	if ERRORLEVEL 1 goto bad
	echo+
	del A:\bundle >nul 2>nul
	del A:\cdboot.exe >nul 2>nul
	del A:\sysinst?.exe >nul 2>nul
	del A:\marketng.msg >nul 2>nul
	del A:\del.lst >nul 2>nul
	copy bin\f32stat.exe A:
	copy bin\cachef32.exe A:
	copy bin\f32mon.exe A:
	copy bin\ufat32.dll A:
	copy bin\fat32.ifs A:
	copy bin\vfdisk.sys A:
	copy bin\aspirout.sys A:
	echo @echo off > A:\WELCOME.CMD
	echo cls >> A:\WELCOME.CMD
	echo echo+ >> A:\WELCOME.CMD
	echo echo Switch to the UpdCD directory and run WinInst.Cmd. This program >> A:\WELCOME.CMD
	echo echo will setup the UpdCD maintanace system on your machine which will >> A:\WELCOME.CMD
	echo echo enable you to setup and to run UpdCD. >> A:\WELCOME.CMD

	REM create disk 1
	echo+
	echo Please remove the diskette from Drive A:
	pause
	echo+
	echo Label another blank diskette "UpdCD Diskette 1" and insert it into Drive A:
	pause
	echo+
	echo Creating UpdCD Diskette 1...
	%1\DISKIMGS\LOADDSKF %1\DISKIMGS\OS2\35\DISK1_CD.DSK A: /Y/Q/F
	if ERRORLEVEL 1 goto bad
	echo+
	del A:\cdinst.exe >nul 2>nul
	del A:\xdfloppy.flt >nul 2>nul
	del A:\ibm2*.add >nul 2>nul
	del A:\readme.ins >nul 2>nul
	del A:\config.x >nul 2>nul
	del A:\ibm1s506.add >nul 2>nul
	del A:\ibmidecd.flt >nul 2>nul
	if exist A:\aha152x.add copy newinst\nulldev.sys A:\aha152x.add
	if exist A:\aha154x.add copy newinst\nulldev.sys A:\aha154x.add
	if exist A:\aha164x.add copy newinst\nulldev.sys A:\aha164x.add
	if exist A:\aha174x.add copy newinst\nulldev.sys A:\aha174x.add
	if exist A:\aic7770.add copy newinst\nulldev.sys A:\aic7770.add
	if exist A:\btscsi.add copy newinst\nulldev.sys A:\btscsi.add
	if exist A:\dac960.add copy newinst\nulldev.sys A:\dac960.add
	if exist A:\dpt20xx.add copy newinst\nulldev.sys A:\dpt20xx.add
	if exist A:\fd16-700.add copy newinst\nulldev.sys A:\fd16-700.add
	if exist A:\fd7000ex.add copy newinst\nulldev.sys A:\fd7000ex.add
	if exist A:\fd8xx.add copy newinst\nulldev.sys A:\fd8xx.add
	if exist A:\flashpt.add copy newinst\nulldev.sys A:\flashpt.add
	if exist A:\ipsraid.add copy newinst\nulldev.sys A:\ipsraid.add
	if exist A:\ql10os2.add copy newinst\nulldev.sys A:\ql10os2.add
	if exist A:\ql40os2.add copy newinst\nulldev.sys A:\ql40os2.add
	if exist A:\ql510.add copy newinst\nulldev.sys A:\ql510.add
	if exist A:\tmv1scsi.add copy newinst\nulldev.sys A:\tmv1scsi.add
	copy bin\partfilt.flt A:
	copy bin\DaniS506.ADD A:
	copy bin\DaniATAP.FLT A:
	copy newinst\config.sys A:
	if exist a:\os2lvm.dmd copy newinst\config.cp A:\config.sys

	REM final message
	echo+
	echo+
	echo UpdCD has replaced IBM1S506.ADD and IBMIDECD.FLT (IDE drivers) with 
	echo a recent version of DaniS506.ADD and DaniATAP.FLT. This will enable
	echo the OS/2 maintanance system to access large IDE disks.
	echo+
	echo UpdCD has also replaced the SCSI drivers (except AIC7870.ADD) with 
	echo a dummy driver to save space. If you still need one of those or an  
	echo other SCSI driver to access your hard disk you need to manually 
	echo copy it to disk 1. If the corresponding BASEDEV statement is not in 
	echo A:\Config.Sys you need to add it before proceeding. You may find
	echo the replaced drivers on your original Warp 4 installation disk 1.
	echo+
	pause
	echo+
	echo Please remove the diskette from Drive A: and reinsert diskette 0.
	echo Restart your system and boot from drive A:. If your system hangs or
	echo traps, reboot. When the white OS/2 blob appears in the upper left
	echo corner of the screen press ALT-F2. The system will now list the drivers
	echo as they are loaded. Write down the last driver before the system hangs
	echo or traps. Try to replace the driver with a newer/older version and try
	echo again.
	echo+
	pause
goto end

REM Usage Message
:msg1
	echo+
	echo Cannot find newinst\config.sys!
	echo Did you run this script from the UpdCD directory?
goto end

REM Usage Message
:msg2
	echo+
	echo Usage: MkDisks.Bat [path to OS/2 installation CD-ROM]
	echo Example: MkDisks.Bat D:, MkDisks.Bat H:\CDROM\WARP4, etc.
goto end

REM Error during disk creation
:bad
	echo+
	echo A problem occured while creating the disk.
	echo You may retry it with another diskette.
goto end

:end
