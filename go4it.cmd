/***************************/
/* Start update procedure  */
/* Created: 12.17.2001     */
/* Modified: 11.09.2003    */
/***************************/

/* get minimal configuration */
parse source . . cmdfile
rootdir = substr(cmdfile, 1, lastpos('\', cmdfile)-1)
cmdfile = substr(cmdfile, lastpos('\', cmdfile)+1)
call directory rootdir

/* get os type */
call rxfuncadd sysini, rexxutil, sysini
os2_version = SysIni(, 'UPDCD', 'OS2VER')
if os2_version = "ERROR:" then do
	os2_version = "Warp 4"
	call SysIni , 'UPDCD', 'OS2VER', os2_version
end

/* determine library file list */
select 
	when os2_version = 'Warp 4'    then liblist = 'warp4.rlb'
	when os2_version = 'Warp 3'    then liblist = 'warp3.rlb'
	when os2_version = 'WSeB'      then liblist = 'wseb.rlb '
	when os2_version = 'MCP/ACP'   then liblist = 'cp.rlb   '
	when os2_version = 'MCP1/ACP1' then liblist = 'cp.rlb   '
	when os2_version = 'eCS'       then liblist = 'ecs.rlb  '
	when os2_version = 'eCS 1.0'   then liblist = 'ecs.rlb  '
	when os2_version = 'eCS 1.1'   then liblist = 'ecs11.rlb'
	otherwise                           liblist = 'warp4.rlb'
end
/* always add general */
liblist = liblist' general.rlb'

/* start basic startup procedure with libs */
tmp = rootdir'\tmp'substr(cmdfile, 1, 5, '_')'.cmd'
'@copy lib\startup.rlb startup.cmd >nul'
'@call startup.cmd updcd.cfg 'rootdir tmp liblist

/* start program */
'@call 'tmp

/* clean up */
'@del 'tmp' >nul 2>>&1'
'@del startup.cmd >nul 2>>&1'

exit
