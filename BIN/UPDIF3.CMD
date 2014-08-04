/*****************************/
/* Update installation disks */
/* Created: 05.11.2003       */
/*****************************/

parse arg parameter_string

/* create tmp.cmd */
temp_cmd = 'tmpupdf3.cmd'
rootdir = strip(directory(), 'T', '\')
'@call startup.cmd  . 'rootdir temp_cmd' updif3.rlb general.rlb'

/* start program */
'@call 'temp_cmd parameter_string

/* clean up */
'@del 'temp_cmd

exit

