/* List all files contained on a Warp CD in plain, packed or zipped files */

parse arg cddrive
if cddrive = '' then 
	do
		say 
		say 'Warp 4 CD-ROM lister.'
		say 
		say 'Missing required parameter!'
		say
		say 'Usage: cdlist.cmd <drive letter CD-ROM>'
		say 'Example: cdlist h'
		say 'Output: cdlist.txt'
		exit
	end

rc = RxFuncAdd('SysFileTree', 'RexxUtil', 'SysFileTree')
say 'Reading CD-ROM...'
rc = sysfiletree(cddrive':\*', 'file.', 'FSO')
if rc <> 0 | file.0 = 0 then
	do
		say 'Drive 'cddrive': cannot be accessed or contains no CD!'
		exit 9
	end

vanunzip = 0
'@unzip -? >nul 2>>&1' /* do you have unzip.exe? */
if rc <> 10 then
	do
		say 'You do not have unzip.exe in your PATH-ban! Cannot list the contents of zip files.'
		'@pause'
	end
else 
	vanunzip = 1

outfile = 'cdlist.txt'
'@del 'outfile' >nul 2>>&1'
do i=1 to file.0
	sor = file.i

	if length(sor) > 57 then
		say 'Reading: ...'reverse(substr(reverse(sor), 1, 57))
	else
		say 'Reading: 'sor

	if translate(substr(sor, lastpos('.', sor)+1)) = 'ZIP' & vanunzip = 1 then
		do
			'@echo 'sor'		>> 'outfile' 2>nul'
			'@unzip -Z2 'sor' 	>> 'outfile' 2>nul'
		end
	else
		'@unpack 'sor' /show 		>> 'outfile' 2>nul'
end

say
say 'Ready. The file list can be found in 'outfile'.'

exit 
