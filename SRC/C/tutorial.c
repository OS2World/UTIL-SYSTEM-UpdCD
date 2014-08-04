#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(argc,argv)

int argc;
char *argv[];

{

int i,j,p;
char cmd1[500]="tutoria2.exe";
char cmd2[500]="strinstl.cmd";
char cmd3[500]="start /F \0";
char cmd4[500]="start /C \0";
char temp[500]="\0";

/* get path */
p = strlen(argv[0])-strlen(strrchr(argv[0], '\\')+1);
strncpy(temp, argv[0], p);

/* append path */
strcat(cmd3, temp);
strcat(cmd4, temp);

/* append file */
strcat(cmd3, cmd1);
strcat(cmd4, cmd2);

/* start install */
j = system(cmd4);

/* start tutorial */
i = system(cmd3);

return j;

}
