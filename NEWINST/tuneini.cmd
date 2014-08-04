/* rexx program to tune the os2.ini and os2sys.ini during phase2 */
/* created: 06.18.2002                                           */
/* 10.25.2003: macrofile -> cmd line parameter                   */
/* 03.06.2005: added more logging                                */

parse arg target instdir macroFile

/* log file */
logFile = target||"\"instdir"\tune.log"
'@echo TuneIni: Starting tuneini.cmd 'date() time()' >> 'logFile

/* ini files */
os2file = target'\os2\os2.ini'
sysfile = target'\os2\os2sys.ini'

/* macro file */
macroFile = target'\'instdir'\'macroFile

call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
do while lines(macroFile)
	l = linein(macroFile)
	if substr(l, 1, 1) = ';' then iterate
	parse var l ini apps key value
	if ini <> 'USER' & ini <> 'SYSTEM' then do
		'@echo TuneIni: Skipping line 'l' >> 'logFile
		iterate
	end
	if ini = 'USER'   then do
		call sysini os2file, apps, key, value
		'@echo TuneIni: Added line "'l'" with result "'result'" >> 'logFile
	end
	if ini = 'SYSTEM' then do
		call sysini sysfile, apps, key, value
		'@echo TuneIni: Added line "'l'" with result "'result'" >> 'logFile
	end
end
call lineout macroFile

'@echo TuneIni: Ending tuneini.cmd 'date() time()' >> 'logFile

exit


