/* rexx program to reorganize files during phase2 */
/* created: 10.25.2003                            */
/* 03.07.2005: added more logging                 */

parse arg target instdir macroFile

/* log file */
logFile = target||"\"instdir"\tune.log"
'@echo TuneFls: Starting tunefls.cmd 'date() time()' >> 'logFile

/* macro file */
macroFile = target'\'instdir'\'macroFile

bdrv = target
do while lines(macroFile)
	l = linein(macroFile)
	if substr(l, 1, 1) = ';' then iterate
	parse var l co_mand p1 p2
	if co_mand = '' | p1 = '' then do
		'@echo TuneFls: Skipping line 'l' >> 'logFile
		iterate
	end
	interpret l
	'@echo TuneFls: Executed command "'l'" with result "'rc'" >> 'logFile
end
call lineout macroFile

'@echo TuneFls: Ending tunefls.cmd 'date() time()' >> 'logFile

exit
