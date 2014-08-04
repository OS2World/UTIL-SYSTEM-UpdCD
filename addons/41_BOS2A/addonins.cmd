/* Install.cmd - Installation Utility for Bamba for OS/2 */
/* place all files of BOS2a in this directory,           */
/* Last modified on 01.16.2001                           */
/* 05.25.2002: added support for uninstallation          */
/* 11.30.2003: removed echo off                          */

parse arg target source mode

/* get additional parameters from environment */
product_log       = value("PRODUCT_LOG"      , ,"OS2ENVIRONMENT")
inst_dir          = value("INST_DIR"         , ,"OS2ENVIRONMENT")
NS_DIR            = value("NS_DIR"           , ,"OS2ENVIRONMENT")

/* check if we are in uninstall mode */
if mode = 'UNINSTALL' then do
	call uninstall
	exit
end

/* check product */
if stream(inst_dir'\NPBAMBA.DLL', 'c', 'query exists') = '' then exit 9

/* init */
backup = 0 /* Flag to tell us if we need to back up. */
NS_DIR = NS_DIR'\Program'
netscapeplugindir = NS_DIR'\PlugIns'
osdir = value('OS2_SHELL', ,'OS2ENVIRONMENT')
osdrive = left(osdir,3)
if backup = 1 then do
	call backupnpb
	call backupbmb /* Check if there are any bmb*.dll's */
end

/* Everything is backed up, now we can copy our stuff */
call copystuff /* copies the dll's into their destination and deletes them in the current temporary directory */

exit

/* Backupnpb: backs up old plug-in */
backupnpb: procedure expose netscapeplugindir

	say ''
	say 'Found previous Bamba version.'
	bdir=netscapeplugindir'\bbbackup'
	call SysFileTree bdir, 'dir', 'D'
	if dir.0=0 then do              /* backup directory doesn't exist, so create it */
        say 'Creating backup directory 'bdir
        rc=SysMkDir(bdir)
        if rc=5 then do
                say 'Error. Access denied while trying to create backup directory.'
                say 'Ending program. Bamba was NOT installed.'
                exit
        end
        else if rc\=0 then do
                say 'An unknown error has occured while trying to create backup directory.'
                say 'Program is ending. Bamba was NOT installed.'
                say 'Return code is ' rc
                exit
        end
	end
	backnpbdll=bdir'\npbamba.'
	i=0
	ext='000'
	call SysFileTree backnpbdll'000', 'npb', 'F'
	do while npb.0\=0
        i=i+1
        ext=addzeros(i)
        file=backnpbdll||ext
        call SysFileTree file, 'npb', 'F'
	end /* do while */
	/* now we have an 'i' which is the extention of the backup file */
	'@copy ' netscapeplugindir'\npbamba.dll' bdir'\npbamba.'ext '>nul'
	'@del 'netscapeplugindir'\npbamba.dll'
	say 'Backup directory: 'bdir
	say 'NPBAMBA.DLL backed up as NPBAMBA.'ext

return

/* AddZeros: turns a 1 or 2 digit number into a 3 digit number */
addzeros: procedure

	parse arg getal
	zeros='000'
	ret=left(zeros,3-length(getal))||getal

return ret

/* backupbmb: looks for bmb*.dll files and backs them up if necessary */
backupbmb: procedure expose osdrive netscapeplugindir

	bmb1='bmblbra.dll'
	bmb2='bmblbrv.dll'
	bmb3='bmbom30.dll'

	bmbdir=osdrive'MMOS2\DLL'
	orbmb.1=bmbdir'\'bmb1
	orbmb.2=bmbdir'\'bmb2
	orbmb.3=bmbdir'\'bmb3
	do i=1 to 3
        temp=orbmb.i
        call SysFileTree temp, 'file', 'F'
        if file.0=1 then call backbmb(orbmb.i)
	end /* do */
	/* Check for c:\os2\dll as well */
	orbmb.1=osdrive'OS2\DLL\'bmb1
	orbmb.2=osdrive'OS2\DLL\'bmb2
	orbmb.3=osdrive'OS2\DLL\'bmb3
	do i=1 to 3
        temp=orbmb.i
        call SysFileTree temp, 'file', 'F'
        if file.0=1 then call backbmb(temp)
	end /* do */
	/* This install program assumes that the dll's haven't been put into another directory */

return

/* backbmb: moves the bmb* files to bbbackup */
backbmb: procedure expose orbmb. netscapeplugindir backup

	parse arg bestand

	best=left(bestand,length(bestand)-3)
	best=right(best,8)
	bdir=netscapeplugindir'\bbbackup'
	bfile=bdir'\'best
	i=0
	ext='000'
	bkfile=bfile||ext
	call SysFileTree bkfile, 'file', 'F'
	do while file.0\=0
        i=i+1
        ext=addzeros(i)
        bkfile=bfile||ext
        call SysFileTree bkfile, 'file', 'F'
	end
	fbest=best||ext
	'@copy' bestand bdir'\'fbest ' > nul'
	'@del' bestand
	say bestand 'backed up as' fbest

return

/* CopyStuff: copies all the files into their destination */
copystuff:

	'@copy 'inst_dir'\npbamba.dll 'netscapeplugindir'\npbamba.dll > nul'
	'@copy 'inst_dir'\bmblbra.dll' osdrive'os2\dll\bmblbra.dll > nul'
	'@copy 'inst_dir'\bmblbrv.dll' osdrive'os2\dll\bmblbrv.dll > nul'
	'@copy 'inst_dir'\bmbom30.dll' osdrive'os2\dll\bmbom30.dll > nul'

return

uninstall:

	netscapeplugindir = NS_DIR'\program\PlugIns'
	'del 'netscapeplugindir'\npbamba.dll'
	'del 'target'\os2\dll\bmblbra.dll'
	'del 'target'\os2\dll\bmblbrv.dll'
	'del 'target'\os2\dll\bmbom30.dll'

return
