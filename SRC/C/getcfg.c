#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(argc,argv)

int argc;
char *argv[];

{

int i;
FILE *fopen(),*fq;
char parameters[5000]="getcfg2.exe ";
char cmd_header[5000]="copy \\UPDCD\\BOOTIMG\\config.sys ";
char cmd_trailer[500]="\\d1config.ins";

/* get parameters */
for(i=1;i<argc;i++)
	{
	strcat(parameters, argv[i]);
	strcat(parameters, " ");
	}

/* call original getcfg.exe */
i = system(parameters);

/* copying config.sys did not work */
if (i!=0) {
	/* prepare copy command */
	strcat(cmd_header, argv[1]);
	strcat(cmd_header, cmd_trailer);
	strcat(cmd_header, ">>nul 2>>&1");
	/* copy config.sys from CD-ROM to installation drive */
	i = system(cmd_header);
	}

return i;

}

