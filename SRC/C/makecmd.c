#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(argc,argv)

int argc;
char *argv[];

{

int i,j,p;
char cmd1[500]="makecmd2.exe ";
char cmd2[500]="makecmd.cmd";
char cmd3[500]="\0";
char cmd4[500]="\0";

/* get path */
p = strlen(argv[0])-strlen(strrchr(argv[0], '\\')+1);
strncpy(cmd3, argv[0], p);
strcpy(cmd4, cmd3);

/* append path */
strcat(cmd3, cmd1);
strcat(cmd4, cmd2);

/* append command line parameters */
for(i=1;i<argc;i++)
	{
	strcat(cmd3, argv[i]);
	strcat(cmd3, " ");
	}

/* call original makecmd.exe */
i = system(cmd3);

/* fix cmd files */
strcat(cmd4, " ");
strcat(cmd4, argv[1]);
j = system(cmd4);

return i;

}
