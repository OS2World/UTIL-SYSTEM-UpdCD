/* updcd tuning and network product installation on warp 3 */
/* 12.04.2006: redirected output copy to nul               */

bdrive = BootDrive()':'
CD_Drive = CD_Drive()

Say
Say 'Tuning System, do not close!!!'
'@call 'bdrive'\grpware\tunecfg.cmd 'bdrive' grpware tunecfg.cfg'
if stream(bdrive'\grpware\tunecfg.cfu', 'c', 'query exists') <> '' then '@call 'bdrive'\grpware\tunecfg.cmd 'bdrive' grpware tunecfg.cfu'
'@call 'bdrive'\grpware\tuneini.cmd 'bdrive' grpware tuneini.cfg'
if stream(bdrive'\grpware\tuneini.cfu', 'c', 'query exists') <> '' then '@call 'bdrive'\grpware\tuneini.cmd 'bdrive' grpware tuneini.cfu'
'@call 'bdrive'\grpware\tunefls.cmd 'bdrive' grpware tunefls.cfg'
if stream(bdrive'\grpware\tunefls.cfu', 'c', 'query exists') <> '' then '@call 'bdrive'\grpware\tunefls.cmd 'bdrive' grpware tunefls.cfu'

Say
Say 'Creating object for Network install...'
call RxFuncAdd 'SysCreateObject', 'RexxUtil', 'SysCreateObject'
call SysCreateObject 'WPProgram', 'Install Network Products', '<WP_DESKTOP>', 'EXENAME='bdrive'\grpware\grpinst.cmd', 'R'

Say
Say 'Creating object for Addons install...'
'@echo dummy, do not delete > 'bdrive'\grpware\npconfig.wp3'
'@echo dummy, do not delete > 'bdrive'\grpware\coninst.exe'
'@echo dummy, do not delete > 'bdrive'\grpware\noprog.flg'
'@mkdir 'bdrive'\grpware\clients\logs >nul 2>>&1'
'@mkdir 'bdrive'\grpware\clients\logs\addon >nul 2>>&1'
call SysCreateObject 'WPProgram', 'Selective Install^for AddOn Products', '<WP_DESKTOP>', 'EXENAME='bdrive'\grpware\npconfig.exe;PARAMETERS=/REINSTALL;', 'R'
call SysCreateObject 'WPProgram', 'Selective UnInstall^for AddOn Products', '<WP_DESKTOP>', 'EXENAME='bdrive'\grpware\npconfig.exe;PARAMETERS=/UNINSTALL;', 'R'

/* create additional TCP/IP install icons */
if stream(CD_Drive'\cid\img\tcpapps\install.cmd', 'c', 'query exists') <> '' then do 
	Say
	Say 'Creating object for TCP/IP install...'
	rc = SysCreateObject('WPFolder',  'Install additional^TCP/IP components','<WP_DESKTOP>', 'OBJECTID=<UPDCD_TCPINST>','R')
	rc = SysCreateObject('WPProgram', 'Install VPN','<UPDCD_TCPINST>','EXENAME='bdrive'\grpware\tcpinst.cmd;PARAMETERS=VPN;', 'R')
	rc = SysCreateObject('WPProgram', 'Install NFS','<UPDCD_TCPINST>','EXENAME='bdrive'\grpware\tcpinst.cmd;PARAMETERS=NFS;', 'R')
	rc = SysCreateObject('WPProgram', 'Install DHCP_DDNS','<UPDCD_TCPINST>','EXENAME='bdrive'\grpware\tcpinst.cmd;PARAMETERS=DHCP_DDNS;', 'R')
	rc = SysCreateObject('WPProgram', '(Re)Create TCP/IP objects','<UPDCD_TCPINST>','EXENAME=ifolder.exe;PARAMETERS=/R', 'R')
	'@del 'bdrive'\grpware\tcpinst.cmd >nul 2>>&1' 
	call lineout bdrive'\grpware\tcpinst.cmd', '/* install additional TCP/IP components */'
	call lineout bdrive'\grpware\tcpinst.cmd', 'parse upper arg comp'
	call lineout bdrive'\grpware\tcpinst.cmd', 'if comp <> "NFS" & comp <> "VPN" & comp <> "DHCP_DDNS" then exit'
	call lineout bdrive'\grpware\tcpinst.cmd', 'selection.=0;if comp = "NFS" then selection.nfs=1;if comp = "VPN" then selection.vpn=1;if comp = "DHCP_DDNS" then selection.dhcp_ddns=1'
	call lineout bdrive'\grpware\tcpinst.cmd', 'say '
	call lineout bdrive'\grpware\tcpinst.cmd', 'say "This program will install "comp" on your system."'
	call lineout bdrive'\grpware\tcpinst.cmd', 'say '
	call lineout bdrive'\grpware\tcpinst.cmd', 'say "Please insert your OS/2 installation CD-ROM in drive 'CD_Drive' and press ENTER."'
	call lineout bdrive'\grpware\tcpinst.cmd', 'say "If 'CD_Drive' does not match the drive letter of your CD-R type it in and press ENTER."'
	call lineout bdrive'\grpware\tcpinst.cmd', 'CD_Drive="'CD_Drive'";response = "";pull response;if response <> "" then CD_Drive=response'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@echo TCPIP.InstallDrive='bdrive'             > 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@echo TCPIP_BASE.Selection=0                      >> 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@echo DHCP_DDNS_Server.Selection="selection.dhcp_ddns" >> 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@echo UINSTAL.Selection=0                         >> 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@echo VPN.Selection="selection.vpn"               >> 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@echo IFOLDER.Selection=1                         >> 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@echo NFS.Selection="selection.nfs"               >> 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@clifi /a:c /r:"CD_Drive"\cid\img\tcpapps\install\tcpinst.rsp /l1:'bdrive'\os2\install\tcperr.log /l2:'bdrive'\os2\install\tcphst.log /s:"CD_Drive"\cid\img\tcpapps\install /b:'bdrive' /r2:'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@del 'bdrive'\grpware\tcpip.rsp"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@copy 'bdrive'\tcpip\samples\bin\ODSKDDNS.TCP 'bdrive'\tcpip\bin\DSKDDNS.TCP >nul 2>>&1"'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@copy 'bdrive'\tcpip\samples\bin\ODSKDHCP.TCP 'bdrive'\tcpip\bin\DSKDHCP.TCP >nul 2>>&1"'
	call lineout bdrive'\grpware\tcpinst.cmd', 'say '
	call lineout bdrive'\grpware\tcpinst.cmd', 'say "Installation has been completed. Please reboot your system."'
	call lineout bdrive'\grpware\tcpinst.cmd', '"@pause"'
	call lineout bdrive'\grpware\tcpinst.cmd'
end

Say
Say 'Cleaning up...'
'@'bdrive'\grpware\unlock 'bdrive'\os2\tutoria2.exe'
'@copy 'bdrive'\os2\tutoria2.exe 'bdrive'\os2\tutorial.exe'

Say
Say 'Installation has been finished. Please reboot your system now!'
'@pause >nul'

exit

/* find bootdrive */
BootDrive: procedure

 /* try path method */
 alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
 record = value('PATH',,'OS2ENVIRONMENT')
 record = translate(record)
 os2_pos = pos(':\OS2;',record)
 if (os2_pos=0) then bootdrive='A'
 else do
           bootdrive_pos = os2_pos - 1
           bootdrive = substr(record,bootdrive_pos,1)
 end
 if  (verify(bootdrive,alphabet) <> 0) then return 'A:' /* presume A */

return bootdrive

/* find OS/2 CD-ROM */
CD_Drive: procedure

	call RxFuncAdd 'SysDriveMap', 'RexxUtil', 'SysDriveMap'
	drives = SysDriveMap('C:', 'LOCAL')
	do while length(drives) > 0
		parse var drives drv drives
		call RxFuncAdd 'SysDriveInfo', 'RexxUtil', 'SysDriveInfo'
		rc = SysDriveInfo(drv)
		if rc <> '' then do
			parse var rc . free total label
			if free = 0 & stream(drv'\os2se20.src', 'c', 'query exists') <> '' then return drv
		end
	end

return 'X:' /* educated guess */