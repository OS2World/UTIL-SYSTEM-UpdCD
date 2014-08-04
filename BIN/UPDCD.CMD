/*****************************/
/* UpdateCD main routine     */
/* Created: 12.18.2001       */
/*****************************/

parse arg parameter_string

/* create tmp.cmd */
temp_cmd = 'tmpupdcd.cmd'
rootdir = strip(directory(), 'T', '\')
'@call startup.cmd  . 'rootdir temp_cmd' updcd.rlb encode.rlb general.rlb'

/* start program */
'@call 'temp_cmd parameter_string

/* clean up */
'@del 'temp_cmd

exit

