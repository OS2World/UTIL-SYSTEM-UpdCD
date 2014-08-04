/* Remove UpdCD icons and INI settings */

parse arg opt

if opt <> 'Q' then do
	'@cls'
	Say
	Say 'This script will uninstall UpdCD. Press ENTER to continue, CTRL-C to abort.'
	'@pause >nul'
end

/* clean OS2.INI */	
say
say 'Cleaning OS/2 INI...'
call RxFuncAdd SysIni, RexxUtil, SysIni
call SysIni , 'UPDCD', 'DELETE:'
if result = '' then Say 'OK'
else Say 'Not OK'
Say

/* ask */
if opt <> 'Q' then do
	Say 'Please delete the UpdCD directory with all the files associated with it.'
	Say 'Press ENTER to continue...'
	'@pause >nul'
	Say
end

/* remove objects */
Say 'Deleting UpdCD folder...'
call RxFuncAdd SysDestroyObject, RexxUtil, SysDestroyObject
call SysDestroyObject('<UpdCD_Folder>')
if result = 1 then Say 'OK'
else Say 'Not OK'
Say

Say 'Completed.'
if opt <> 'Q' then do
	Say 'Press ENTER to continue...'
	'@pause >nul'
end

exit
