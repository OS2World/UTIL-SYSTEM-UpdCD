/* update config.sys */

parse arg cdpath

cfgf = 'a:\config.sys'
do while stream(cfgf, 'c', 'query exists') = ''
	say
	say 'Please insert UpdCD disk 1 into drive A: and press any key.'
	'@pause >nul'
end

cdir = translate(directory())
i=1
do while lines(cfgf)
	l.i = translate(linein(cfgf))
	if pos('LIBPATH=', l.i) > 0 & pos(cdir, l.i) = 0 then call add_to_path 'LIBPATH'
	else if pos('DPATH=', l.i)   > 0 & pos(cdir, l.i) = 0 then call add_to_path 'DPATH'
	else if pos('PATH=', l.i)    > 0 & pos(cdir, l.i) = 0 then call add_to_path 'PATH'
	if pos('WELCOME.CMD', l.i) = 0 then i=i+1
end
call lineout cfgf
l.0 = i-1

'@del 'cfgf
do i=1 to l.0
	call lineout cfgf, l.i
end
call lineout cfgf, 'BASEDEV=OS2ASPI.DMD /ALL'
call lineout cfgf, 'DEVICE=\ASPIROUT.SYS'
call lineout cfgf, 'DEVICE=\VFDISK.SYS 4'
call lineout cfgf, 'RUN='cdir'\maint\strtswap.exe 'substr(cdir, 1, 2)
call lineout cfgf, 'RUN='cdir'\maint\srvrexx.exe'
call lineout cfgf, 'SET CDROM_PATH='cdpath
call lineout cfgf, 'SET UPDCD_INST=1'
call lineout cfgf, 'SET UPDCD_HDIR='cdir
call lineout cfgf, 'CALL=CMD.EXE /K 'cdir'\INSTALL.CMD'
call lineout cfgf
'@copy maint\os2aspi.dmd a: >> wininst.log 2>>&1' 
'@copy 'cfgf' maint\. >> wininst.log 2>>&1' 

exit

/* add directory to path */
add_to_path: 

	parse upper arg p

	say 'Adding 'cdir'\maint to 'p'.'
	parse value l.i with first_half '=' second_half
	l.i = first_half'='cdir||'\maint;'second_half
	
return
