/*****************************/
/* Update installation disks */
/* Created: 12.18.2001       */
/*****************************/

parse arg parameter_string

/* create tmp.cmd */
temp_cmd = 'tmpupdf2.cmd'
rootdir = strip(directory(), 'T', '\')
'@call startup.cmd  . 'rootdir temp_cmd' updif2.rlb general.rlb'

/* start program */
'@call 'temp_cmd parameter_string

/* clean up */
'@del 'temp_cmd

exit

