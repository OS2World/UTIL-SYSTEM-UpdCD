/* network install procedure for plain Warp 3    */
/* created: 04.25.2005                           */
/* 05.02.2005: added copy operation object files */
/* 12.04.2006: redirected output copy to nul     */

Say
Say 'This program will install network products on your system.'
Say 'Press ENTER to continue or CTRL-BREAK to abort.'
'@pause>nul'

Say
Say 'Please sure that you have inserted you updated OS/2 installation'
Say 'CD-ROM in your CD/DVD drive. Type in the drive letter of this drive'
Say 'and press ENTER.'
Say
Say 'Example response: X:'
pull cd_drive

if stream(cd_drive'\cid\img\fi\fisetup.exe', 'c', 'query exists') = '' then do
	Say
	Say 'Cannot find network products in drive 'cd_drive'. Exiting.'
	exit
end
else do

	/* netscape */
	if stream(cd_drive'\cid\img\NETSCAPE\INSTALL.EXE', 'c', 'query exists') <> '' then do
		Say
		Say 'Installing Netscape, please wait.'
		'@'cd_drive'\cid\img\netscape\install.exe'
		Say 'Installation ended with return code rc='rc
	end

	/* FI */
	Say
	Say 'Installing Feature Installer, please wait.'
	if stream(cd_drive'\cid\img\NETSCAPE\INSTALL.EXE', 'c', 'query exists') = '' then 
		'@'cd_drive'\cid\img\fi\fisetup.exe /NORESTARTSHELL /NN'
	else
		'@'cd_drive'\cid\img\fi\fisetup.exe /NORESTARTSHELL'
	Say 'Installation ended with return code rc='rc

	/* MPTS */
	if stream(cd_drive'\cid\img\mpts\mpts.exe', 'c', 'query exists') <> '' then do
		Say
		Say 'Installing MPTS, please wait.'
		'@'cd_drive'\cid\img\mpts\mpts.exe'
		Say 'Installation ended with return code rc='rc
	end

	/* TCP/IP */
	if stream(cd_drive'\cid\img\tcpapps\install.exe', 'c', 'query exists') <> '' then do
		Say
		Say 'Installing TCP/IP, please wait.'
		'@'cd_drive'\cid\img\tcpapps\install.exe'
		Say 'Installation ended with return code rc='rc
	end
	if stream(cd_drive'\cid\img\tcpapps\install.cmd', 'c', 'query exists') <> '' then do
		Say
		Say 'On which drive would you like to install TCP/IP?'
		Say 'Type in the drive letter and press ENTER.'
		Say
		Say 'Example response: D:'
		pull bootdrive
		if length(bootdrive) <> 2 then bootdrive = 'C:' 
		Say
		Say 'Installing TCP/IP, please wait.'
		tabledir = cd_drive'\cid\img\tcpapps\install'
		cltdir = '\grpware'
		instdir = 'grpware'
		call make_tcpip32_rsp
		/* '@clifi /a:i /r:\grpware\tcpinst.rsp' */
		'@clifi /a:c /b:'bootdrive' /s:'cd_drive'\cid\img\tcpapps\install /l1:\grpware\ciderr.log /l2:\grpware\cidhst.log /r:\grpware\tcpinst.rsp'
		Say 'Installation ended with return code rc='rc
		'@copy 'bootdrive'\tcpip\samples\bin\odskbase.tcp 'bootdrive'\tcpip\bin\dskbase.tcp >nul 2>>&1'
		'@copy 'bootdrive'\tcpip\samples\bin\odskdbox.tcp 'bootdrive'\tcpip\bin\dskdbox.tcp >nul 2>>&1'
		'@copy 'bootdrive'\tcpip\samples\bin\odskdocs.tcp 'bootdrive'\tcpip\bin\dskdocs.tcp >nul 2>>&1'
		'@copy 'bootdrive'\tcpip\samples\bin\odskdel.tcp  'bootdrive'\tcpip\bin\dskdel.tcp  >nul 2>>&1'
		'@copy 'bootdrive'\tcpip\samples\bin\odskfeat.tcp 'bootdrive'\tcpip\bin\dskfeat.tcp >nul 2>>&1'
		'@copy 'bootdrive'\tcpip\samples\bin\oiak.txt     'bootdrive'\tcpip\bin\iak.txt     >nul 2>>&1'
	end

end

Say
Say 'Installation has been ended. Please reboot your system!'
'@pause>nul'

exit

/* generate tcp/ip 32 clifi response file */
make_tcpip32_rsp:

	/* get tcp/ip parameters */
  TCP_Drive = bootdrive

	/* needed files */
	tcp32rspsrc = tabledir'\TCPINST.RSP'
	tcp32rspfile = cltdir'\TCPINST.RSP'
	'@del 'tcp32rspfile' >nul 2>>&1'

	found  = 0
	found2 = 0
	found3 = 0
	found4 = 0

	do while lines(tcp32rspsrc)
		l = linein(tcp32rspsrc)

		if found = 1 then do
			if instdir = 'grpware' then 
				l = '		Value='cd_drive'\cid\img\tcpapps\install'
			else 
				l = '		Value='cd_drive'\cid\server\tcpapps\install'
			found = 0
		end

		if found2 = 1 then do
			if instdir = 'grpware' then 
				call lineout tcp32rspfile, '		FilePath='cd_drive'\cid\img\tcpapps\install\makecmd.exe'
			else 
				call lineout tcp32rspfile, '		FilePath='cd_drive'\cid\server\tcpapps\install\makecmd.exe'
			found2 = 0
		end

		if found3 = 1 then do
			call lineout tcp32rspfile, '		EditLine=PATH'
			found3 = 0
		end

		if found4 = 1 then do
			l = '		Value='TCP_Drive
			found4 = 0
		end

		if pos('Description=Where Package is put', l) > 0 then found = 1
		if pos('FilePath={Current_path}\install\makecmd.exe', l) > 0 then found2 = 1
		if pos('EditLine=PATH=', l) > 0 then found3 = 1
		if pos('Description=The drive letter of InstallDir', l) > 0 then found4 = 1

		if found2 <> 1 & found3 <> 1 then call lineout tcp32rspfile, l
	end

	call lineout tcp32rspfile

RETURN
