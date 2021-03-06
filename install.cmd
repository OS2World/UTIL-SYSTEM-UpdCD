/*************************/
/* Install UpdateCD      */
/* Created: 26.01.2002   */
/*************************/

parse arg parameter_string

/* change to updcd directory */
hdir = value('UPDCD_HDIR', , 'OS2ENVIRONMENT')
if hdir <> '' then call directory hdir

/* create tmp.cmd */
temp_cmd = 'tmpinst.cmd'
rootdir = strip(directory(), 'T', '\')
if stream(rootdir'\startup.cmd', 'c', 'query exists') = '' then 
	'@copy 'rootdir'\lib\startup.rlb 'rootdir'\startup.cmd >nul'
'@call startup.cmd  . 'rootdir temp_cmd' install.rlb general.rlb'

/* start program */
'@call 'temp_cmd parameter_string

/* clean up */
'@del 'temp_cmd' >nul 2>>&1'
'@del 'rootdir'\startup.cmd >nul 2>>&1'

exit
