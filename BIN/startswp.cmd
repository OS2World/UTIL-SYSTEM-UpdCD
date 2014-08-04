/* start swapping */

parse arg cdpath

swapdrive = filespec("drive", directory())
swapexe = cdpath'\os2image\disk_3\strtswap.exe'
if stream(swapexe, 'c', 'query exists') = '' then swapexe = cdpath'\os2image\disk_2\strtswap.exe'
'@'swapexe swapdrive' >> ..\wininst.log 2>>&1' 
'@copy 'swapexe' . >> ..\wininst.log 2>>&1' 

exit
