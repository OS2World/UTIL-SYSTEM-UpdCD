�MKMSGF CB2�     �         ��(�h��$j���
9[��$���	�	q
�
O���������������������������"�$��I�.147:=@CFIL��/��6���&\�*c� � 3!^!�!�!""" "#"&"E"p"�"�"#^#�#�#�#*$Y$�$�$(%n%�%�%I&L&O&R&U&X&[&^&a&d&g&j&m&p&s&v&y&|&&�&�&�&�&�&�&�&�&�&�&�&�&�&�&�&�&�&'E'w'�'�'�'�'0(>(Y(g(�(�(�($).)8)A)K)T)\)h)r)|)�)�)�)�)�)�)�)�)�)�)  	   �                              CB2Us.msg                                                                                                                                                                                                                                                            II CB2Us.msg
EE Can't load message %1 from messagefile %2. Please report this problem to the author.
II Can't load message from NLS (National Language Support) message file, trying US English version.
EE Can't load message from NLS (National Language Support) and from US English message files. CD Boot/2 can't continue, press "Close" to exit.
EE Error SYS%1 writing to logfile %2. CD Boot/2 will not write a logfile.
II DLL execution failed! CD Boot/2 can't continue, press the "%1" pushbutton to exit.
II Press the "%1" pushbutton to exit CD Boot/2.
IX                                 CD Boot/2 V2.00
IX              (C) Roman Stangl (Roman_Stangl@at.ibm.com)  05, 2002
IX               http://www.geocities.com/SiliconValley/Pines/7885/
IX Close
II Initializing CD Boot/2 environment ...
II Loading CD Boot/2 messagefile ...
II CD Boot/2 runs under the %1 evironment ...
II Loading CD Boot/2 modules ...
II Loading CD Boot/2 resource DLL ...
II Error loading messagefile "%1". Messages might be displayed in English instead!
II Error SYS%1 loading CD Boot/2 resource DLL "%2", module "%3" contributed to the failure. CD Boot/2 terminates.
Please try to specify a supported language (e.g. English with "/Language Us") on the commandline when launching CD Boot/2. 
Resource will therefore be loaded in English! CD Boot/2 terminates if that doesn't work too.
EE Wrong version of resource DLL "%1", OS/2's BLDLEVEL command can be used to display the version of a module. CD Boot/2 terminates.
II Loading CD Boot/2 compiler runtime DLLs %1 ... 
EE Error SYS%1 loading CD Boot/2 compiler runtime DLL "%2", module "%3" contributed to the failure.
Please check your environment if that DLL is installed correctly! CD Boot/2 terminates.
II Loading CD Boot/2 code DLL ...
EE Error SYS%1 loading CD Boot/2 code DLL "%2", module "%3" contributed to the failure.
Please check your environment if that DLL is installed correctly! CD Boot/2 terminates.
EE Wrong version of code DLL "%1", OS/2's BLDLEVEL command can be used to display the version of a module. CD Boot/2 terminates.
EE Error SYS%1 loading code entrypoint from CD Boot/2 code DLL "%2". CD Boot/2 terminates.
EE Can't startup thread to execute CD Boot/2 code DLL "%1". CD Boot/2 terminates.
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
II Syntax: CDBOOT/CDBOOTPM [/?] [/LANGUAGE ll] [/LOG [logfile]] 
          [/CID cidfile] [/DRIVE d /TIMEOUT tt] [/CPYCOLOR c]
          [/MSG1 message] [/MSG2 message] [/MSG3 message] [/MSGCOLOR m] 
          [/HARDDISK | /REMOVEABLE] [/CLEAR] [/BM] [/PASSWORD password]
          Where:  
                  ?  ........ Shows this help
                  ll ........ Language to use (CB2ll.msg is required, 
                              otherwise English is used as the default)
                  logfile ... Optional logfile (default: CB2.LOG)
                  cidfile ... File to read commandline parameters from
                  d  ........ Bootable removeable media to install CD Boot/2
                              onto (A, B, ..., Z)
                  tt ........ Timeout for CD Boot/2 to continue booting from 
                              first harddisk (1...60) 
                  c ......... Copyright message color (0...15)
                  message ... Custom message to be displayed by CD Boot/2
                              (max. 79 characters)
                  m ......... Custom message color (0...15)
                  password .. Password to boot from removeable media (max. 7 
                              characters, 0...9, A...Z, a...z)
          Return code:
                  0  ........ Successful completion
                  1  ........ Warning, invalid parameter
                  2  ........ Fatal, internal processing error
II Syntax: CDBOOT/CDBOOTPM [/?] [/LANGUAGE ll] [/LOG [logfile]] [/CID cidfile] [/DRIVE d /TIMEOUT tt] [/CPYCOLOR c] [/MSG1 message] [/MSG2 message] [/MSG3 message] [/MSGCOLOR m] [/PASSWORD password]
          Where:  
                  ?  ........ Shows this help
                  ll ........ Language to use (CB2ll.msg is required, otherwise English is used as the default)
                  logfile ... Optional logfile (default: CB2.LOG)
                  cidfile ... File to read commandline parameters from
                  d  ........ Bootable removeable media to install CD Boot/2 onto (A, B, ..., Z)
                  tt ........ Timeout for CD Boot/2 to continue booting from first harddisk (1...60) 
                  c ......... Copyright message color (0...15)
                  message ... Custom message to be displayed by CD Boot/2 (max. 79 characters)
                  m ......... Custom message color (0...15)
                  password .. Password to boot from removeable media (max. 7 characters, 0...9, A...Z, a...z)
          Return code:
                  0  ........ No error, successful completion
                  1  ........ Warning, invalid parameter specified
                  2  ........ Fatal internal process error
EE Optional parameter "/DRIVE d" (where "d" is a removeable media e.g. A) incomplete or invalid. CD Boot/2 terminates.
EE Optional parameter "/TIMEOUT tt" (where "tt" is the timeout period in the range of 1 to 60 seconds) incomplete or invalid. CD Boot/2 terminates.
EE Optional parameters "/DRIVE d" und "/TIMEOUT tt" must be specified simultaneously! CD Boot/2 terminates.
EE Optional parameters "/HARDDISK" und "/REMOVEABLE" must not be specified simultaneously! CD Boot/2 terminates.
II Supported commandline parameters are valid and will be used.
EE Optional parameter "/MSG? message" has excessive length (>79 characters) for "message". CD Boot/2 terminates.
EE Optional parameter "/PASSWORD password" has excessive length (>7 characters) or invalid characters (that is not 0...9, A...Z, a...z). CD Boot/2 terminates.
II Supplied parameters are sufficient, CD Boot/2 runs unattendedly.
I
I
I
I
I
I
I
I
I
I
EE Creation of anchor block failed with error 0x%1. CD Boot/2 terminates.
EE Creation of message queue failed with error 0x%1. CD Boot/2 terminates.
EE Creation of dialog window failed with error 0x%1. CD Boot/2 terminates.
EE Opening the requested removeable media failed with error SYS%1. CD Boot/2 terminates.
EE Locking the requested removeable media failed with error SYS%1. CD Boot/2 terminates.
EE Reading/Writing the Boot Sector failed with error SYS%1. CD Boot/2 terminates.
EE Closing the requested removeable media failed with error SYS%1. CD Boot/2 terminates.
EE Reading/Writing CD2BOOT failed. CD Boot/2 terminates.
EE Invalid contents in CD2BOOT, please try to reinstall. CD Boot/2 terminates.
EE Invalid Boot Sector, reference to "OS2BOOT" is missing. Please ensure that you select an OS/2 Boot Sector from a removeable media. CD Boot/2 terminates.
II The drive(s) %1 seem to support removeable media on which the CD Boot/2 Boot Loader can be installed onto.
IQ On which drive to you want to install CD Boot/2? 
II CD Boot/2 allows to define a period from %1 to %2 seconds in which pressing the keys 1 or 2 allows you to boot from another media than the default selection.
IQ How many seconds should CD Boot/2 wait?
II Reading the bootsector from the removeable media %1.
II Reading the CD2BOOT code from file %1.
WW The bootsector of the removeable media %1 was already modified by running CD Boot/2! CD Boot/2 will act accordingly.
II The bootsector of the removeable media looks like a FAT based non-OS/2 bootsector (e.g. from DOS). Likely it is compatible with CD Boot/2.
WW The bootsector of the removeable media does not look like an OS/2 or compatible FAT based non-OS/2 bootsector. Likely it is incompatible with CD Boot/2!
II Writing the CD2BOOT code into file %1.
II Modifying the bootsector of the removeable media to load CD2BOOT instead of OS2BOOT.
II Writing the modified bootsector onto the removeable media %1.
IX CD2BOOT - CD Boot/2 V2.00
I
I
I
I
I
II Initializing CD Boot/2 ...
II Waiting for CD Boot/2 to terminate ...
IX CD2BOOT - CD Boot/2 V2.00
IX Copyright (C) Roman Stangl (Roman_Stangl@at.ibm.com) 05, 2002
IX           http://www.geocities.com/SiliconValley/Pines/7885/
IX Please press the key for the media ( is default) you want to boot from:
IX   1 ... From the first harddisk
IX   2 ... From the removeable media
IX Please select within %d seconds, or boot continues from the default media!
IX Continuing booting from removeable media ...
IX Continuing booting from first harddisk ...
IX CD2Boot SYS02025: Disk read error loading partition table from first harddisk!
IX CD2Boot SYS02027: Insert a system diskette and restart the system!
IX Please enter Password to boot removeable media: 
IX Invalid Password, please retry or press ALT+CTRL+DEL to reboot:  
IX No active OS/2 Bootmanager Partition found in partition table.
IX Active OS/2 Bootmanager Partition found in partition table.
IX CD2BOOT is corrupt or fragmented - System stopped! Press ALT+CTRL+DEL to reboot!   
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
IX CD Boot/2 Boot Loader "CD2BOOT" Settings:    
IX Installation:                                
IX Install on Drive:                            
IX Path of CD2BOOT code:                        
IX Delay [seconds]:                             
IX Default is ~Harddisk Boot
IX Default is ~Removeable Boot
IX Clear ~BIOS Screen
IX Optional Password Protection:                
IX ~Activate
IX Advanced Harddisk Boot
IX Acti~vate
IX Copyright Messages:               
IX Optional Userdefined Messages:               
IX ~Install                                     
IX ~Cancel                                      
IX Color
IX Black
IX Blue
IX Green
IX Cyan
IX Red
IX Magenta
IX Brown
IX White
IX Gray
IX Light Blue
IX Light Green
IX Light Cyan
IX Light Red
IX Light Magenta
IX Yellow
IX Intensive White
I
I
I
