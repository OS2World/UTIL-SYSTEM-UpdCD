/* updated MKRSP.CMD for use with updcd                     */
/* created 11/23/2003 updated 04/14/2005 with clifi install */

/* This file will take the main configuration file and create the appropriate
    response files */

/* Arguments are the Distribution client name and fully qualifed path
   to configuration file. */

parse arg client cfgfile rsp_indicator

/* Add REXX functions */
Call RxFuncAdd 'SysGetMessage', 'RexxUtil', 'SysGetMessage'
Call RxFuncAdd 'sysfiledelete', 'RexxUtil', 'sysfiledelete'
Call RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
Call RxFuncAdd 'SysMkDir', 'RexxUtil', 'SysMkDir'
call RxFuncAdd 'QuerySingleSyslevel', 'RLANUTIL', 'QuerySingleSyslevel'

/* Message file name */
msgfile = 'npinst.msg'

/* If the cfgfile wasn't passed, give a usage error */
if cfgfile = '' then do
   err1.1 = SysGetMessage(12, msgfile)
   err1.2 = SysGetMessage(13, msgfile)
   call errout 12
end  /* Do */

/* IBMINST drive */
ibminstdrive = filespec(Drive,cfgfile)

/* IBMINST directory name */
 ibminstdir = ibminstdrive'\IBMINST'       /*  Merlin directory structure */
/*  ibminstdir = ibminstdrive'\WARPSRV'  */ /* Server directory structure */

/* Respose File directory */
rspdir = ibminstdir'\RSP'

/* Check to see if we're just generating response files */
if strip(translate(rsp_indicator)) = '/RSP' then do
   cltdir = rspdir'\REMOTE'
   call SysMkDir cltdir
end  /* Do */

else do
   rsp_indicator = ''
   /* Directory for clients */
   cltdir = rspdir'\'client
   call SysMkDir cltdir                    /* defect 45638  */
end /* do */

/* Table Directory */
tabledir = ibminstdir'\TABLES'

/* Logging file */
logname = ibminstdir'\LOGS\IBMINST\MKRSP.LOG'
logfile = ibminstdir'\LOGS'

/* CD Drive */
CD_Drive = ''

/* Integrated_Install Envionment -  Are we in the Integrated_Install desktop?  If
    so, we need to point to another config.sys */
Integrated_Install = 0

/* OS2 Drive */
OS2_Drive = ''

/* If no config file, then exit */
if stream(cfgfile, 'C', 'QUERY EXISTS') = ''  then do
   err1.1 = SysGetMessage(10, msgfile, cfgfile)
   err1.2 = SysGetMessage(11, msgfile)
   call errout 10
end  /* Do */

/* Initialize the variables that are to be read from the config file */
call initialize_variables

/* Read the config file.  If it's not a comment line, interpret the line. */
/* This will read in the list of variables in the config file and assign
    the values. */

do while lines(cfgfile) > 0
   line1 = linein(cfgfile)
   line1 = strip(line1)
   if left(line1,4) = 'MPTS' & right(line1,1) = '{' then
      call load_mpts_struct
   else if left(line1,1) \= ';' & line1 \= '' then do
      parse var line1 kw'='kwval
      kw = strip(kw)
      kwval = strip(kwval)
      /* If a line contains single quotes, delimit the line with double quotes */
      if pos("'", kwval) > 0 then line1 = kw'="'kwval'"'
      else line1 = kw"='"kwval"'"
      interpret line1
   end  /* Do */
end /* do */
call stream cfgfile, 'C', 'CLOSE'

/* Always add MPTS to the product list */
if pos('MPTS', products) = 0 then products = ' MPTS 'products

/* add RIPL and UPS to the products list if they were selected. */
if  LS_InstallDosRemoteIPL | LS_InstallOS2RemoteIPL then
   products = products' RIPL '

if LS_InstallUPS  then
   products = products' UPS '

/* Assign the values in variable products to the products stem */
productlist = products

/* Uppercase string */
productlist = translate(products)

/* Read the product list into a stem called product. */
i = 0
do while length(productlist) > 0
   i = i + 1
   parse upper var productlist product.i productlist
end /* do */
product.0 = i

/* If no products were listed, then exit */
if product.0 = 0 then do
  err1.1 = SysGetMessage(15, msgfile)
  err1.2 = SysGetMessage(11, msgfile)
  call errout 15
end  /* Do */

/* Preserve startup.cmd, config.sys, protocol.ini */
backupdir = OS2_Drive'\OS2\INSTALL\IBMINST.BAK'
call SysMkDir backupdir

/* Find the config.sys in the Integrated_Install desktop */
if integrated_install then do
   configsys = OS2_Drive'\OS2\INSTALL\CONFIG.__$'
   if stream(configsys, 'C', 'QUERY EXISTS') = '' then do
      configsys = OS2_Drive'\OS2\INSTALL\CONFIG._$$'
      if stream(configsys, 'C', 'QUERY EXISTS') = '' then
         configsys = OS2_Drive'\CONFIG.SYS'
   end  /* Do */
end
else configsys = OS2_Drive'\config.sys'

'@copy 'configsys' 'backupdir' 1>nul 2>nul'
'@copy 'MPTS_Drive'\IBMCOM\PROTOCOL.INI 'backupdir' 1>nul 2>nul'
'@copy 'OS2_Drive'\STARTUP.CMD 'backupdir' 1>nul 2>nul'

/* Set flag if we are installing ls */
install_os2peer = 0

/* Set flag if we are installing NSC */
install_NSC = 0

/* Set flag if we are installing LAN Server */
install_ls = 0
if pos('LANSRV', products) > 0 then install_ls = 1

/* Build MPTS to insure the adapter dependencies are setup properly */
if pos('HPFS386', products) > 0 then
   HPFS386only = 1
else
   call BuildMPTS

/* Built LAN Server Response file stem to insure it's done first */
if install_ls then
    call BuildLS

/* Process the list of products.  Valid values are:
   LANSRV, BOOKS PPPSRV, TCPIP,  FFST, NSC,  LCFAGENT
   NETFIN, OS2PEER, RIPL, UPS, PSNS, LDAP, NETSCAPE, HPFS386  */

/* Set list of products to pass to LCU driver file */
products_to_install = ''

/* Build/Modify the response files based on the products that are passed */
do ii = 1 to product.0
   select

      when product.ii = 'LANSRV' then do
           install_ls = 1
           products_to_install = products_to_install || ' LANSRV '
      end /* do */

      when product.ii = 'RIPL' then do
         install_ls = 1
         call BuildRIPL
      end  /* Do */

      when product.ii = 'OS2PEER' then do
        if (install_NSC = 0) then
          do
            install_NSC = 1
            products_to_install = products_to_install || ' OS2PEER  NSC '
            call BuildNSC
          end/*do*/
        else products_to_install = products_to_install || ' OS2PEER '
         install_os2peer = 1
         call BuildOS2Peer
      end  /* Do */

      when product.ii = 'MPTS' then do
         products_to_install = products_to_install || ' MPTS '
      end  /* Do */

      when product.ii = 'TCPIP' then do
        products_to_install = products_to_install || ' TCPIP '
        /* call BuildTCPIP */
				if stream(cd_drive'\ibminst\tables\tcpinst.rsp','c','query exists') <> '' then do
					'copy 'cd_drive'\ibminst\tables\tcpinst.rsp 'tabledir'\.'
					call make_tcpip32_rsp
				end
      end  /* Do */

      when product.ii = 'BOOKS' then do
         products_to_install = products_to_install || ' BOOKS '
         call BuildBOOKS
      end

      when product.ii = 'NETSCAPE' then do
				if stream(CD_Drive'\CID\SERVER\netscape\INSTALL.EXE', 'c', 'query exists') <> '' then do
					products_to_install = products_to_install || ' NETSCAPE '
					call BuildNetscape
				end
      end

      when product.ii = 'LDR' then do
         products_to_install = products_to_install || ' LDR '
         call BuildLDR
      end  /* Do */

      when product.ii = 'PPPSRV' then do
         products_to_install = products_to_install || ' PPPSRV '
         call BuildPPP
      end  /* Do */

      when product.ii = 'FFST' then do
         products_to_install = products_to_install || ' FFST '
         call BuildFFST
      end  /* Do */

      when product.ii = 'UPS' then do
         install_ls = 1
         call BuildUPS
      end  /* Do */

      when product.ii = 'MFS' then do
         products_to_install = products_to_install || ' MFS '
         call BuildMFS
      end  /* Do */

      when product.ii = 'SVAGENT' then do
         products_to_install = products_to_install || ' SVAGENT '
         call BuildSVAgent
      end  /* Do */

      when product.ii = 'NETFIN' then do
         products_to_install = products_to_install || ' NETFIN '
         call BuildNetFin
      end  /* Do */

      when product.ii = 'HPFS386' then do
         products_to_install = products_to_install || ' HPFS386 '
         call BuildFS386
      end  /* Do */

      when product.ii = 'NW' then do
         products_to_install = products_to_install || ' NW  '
         call BuildNetWareMPTS
      end  /* Do */

      when product.ii = 'PSNS' then do
         call BuildPSNS
         products_to_install = products_to_install || ' PSNS '
      end  /* Do */

      when product.ii = 'LDAP' then do
         call BuildLDAP
         products_to_install = products_to_install || ' LDAP '
      end  /* Do */

      when product.ii = 'LCFAGENT' then do
         call BuildLCFAGENT
         products_to_install = products_to_install || ' LCFAGENT '
      end  /* Do */

      when product.ii = 'PSF' then do
        call BuildPSF
        products_to_install = products_to_install || ' PSF '
       end  /* Do */

      when product.ii = 'WARP' then
         nop

   otherwise
      /* Encountered a product I don't know about */
      err1.1 = SysGetMessage(14, msgfile, product.ii)
      err1.2 = SysGetMessage(11, msgfile)
      call errout 14
   end  /* select */

end /* do */

/* !CHECK! - Need to see if BOOKS should be added to install list */
if BOOKS \= '' & pos('BOOKS', products_to_install) = 0 then call BuildBooks

/* If we're installing Peer, write the response file */
if install_os2peer then do
   do i = 1 to peerrsp.0
      rspstem.i = peerrsp.i
   end /* do */
   rspstem.0 = peerrsp.0
   call write_rspfile Peerrspfile
end

/* If we're installing LAN Server, write the response file */
if install_ls then do
   do i = 1 to lsrsp.0
      rspstem.i = lsrsp.i
   end /* do */
   rspstem.0 = lsrsp.0
   call write_rspfile LSrspfile
end

/* If we're not just creating response files */
if rsp_indicator = '' then do


   /* Call to create the LCU driver file */
   call process_LCU_file

   shinc_done = 0

   /* Add RESTARTOBJECTS to config.sys */
   i = 0
   do while lines(configsys) > 0
      i = i + 1
      csys.i = linein(configsys)
   end /* do */

   /* Add restartobjects=no to config.sys to prevent wsconfig from coming backup */
   i = i + 1
   csys.i =  'REM IBMINST: REMOVE NEXT LINE'
   i = i + 1
   csys.i =  'SET RESTARTOBJECTS=NO'

   call stream configsys, 'C', 'CLOSE'

   /* Delete the old config.sys */
   call SysFileDelete configsys
   /* Rewrite config.sys */
   do j = 1 to i
      call lineout configsys, csys.j
   end /* do */

end /* do */

/* zsolt begin */
/* copy scripts for installing add-ons */
'@copy 'tabledir'\ADDON.FIL 'cltdir'\ADDON.CMD'
'@copy 'ibminstdir'\StTimeV.Cmd 'OS2_Drive'\OS2\.'
/* zsolt end */
 
/* We completed successfully */
err1.1 = SysGetMessage(20, msgfile, 'MKRSP.CMD')
err1.2 = ''
Call Errout 0

RETURN 0

/* BUILDLS */
/*
    Called by: Main
    Calls: None
    Dependencies: tabledir cltdir LS_Drive LS_Drive LS_Name
                    LS_Domain
*/
/* Portion to build LanServer Response File */
BuildLS:

   LSrspsrc = tabledir'\LANSRV.RSP'
   LSrspfile = cltdir'\LANSRV.RSP'

   install_ls = 1

   /* If we can't read the response file source, exit */
   if stream(LSrspsrc, 'C', 'QUERY EXISTS') = ''  then do
      err1.1 = SysGetMessage(10, msgfile, LSrspsrc)
      err1.2 = SysGetMessage(11, msgfile)
      call errout 10
   end  /* Do */

   /* Read the file into a stem */
   i = 0
   do while lines(LSrspsrc) > 0
      i = i + 1
      lsrsp.i = linein(LSrspsrc)
      parse var lsrsp.i kw '=' kwval
      select
         when translate(kw) = 'CONFIGTARGETDRIVE' then
            lsrsp.i = '  ConfigTargetDrive = 'left(LS_Drive,1)
         when translate(kw) = 'CONFIGSOURCEDRIVE' then
            lsrsp.i = '  ConfigSourceDrive = 'left(LS_Drive,1)
         when translate(kw) = 'COMPUTERNAME' then
            lsrsp.i = '  Computername = 'LS_Name
         when translate(kw) = 'DOMAIN' then
            lsrsp.i = '  Domain = 'LS_Domain
         when translate(kw) = 'CONFIGSERVERTYPE' then
            lsrsp.i = '  ConfigServerType = 'LS_ServerType

         when translate(kw) = 'INSTALLGUI' then do
            if LS_InstallGUI then
                lsrsp.i = '  InstallGUI = INSTALL'
            else
                lsrsp.i = '  InstallGUI = REMOVE'
         end  /* Do */

         when translate(kw) = 'CONFIGINITIALIZEDCDB' then do
            if LS_ConfigInitializeDCDB then
               lsrsp.i = '  ConfigInitializeDCDB = YES'
         end  /* Do */

         when translate(kw) = 'INSTALLAPI' then do
            if LS_InstallAPI  then
              lsrsp.i = '  InstallAPI = INSTALL'
            else
              lsrsp.i = '  InstallAPI = REMOVE'
         end  /* Do */

         when translate(kw) = 'INSTALLSERVER' then do
              lsrsp.i = '  InstallServer = INSTALL '
         end  /* Do */

         when translate(kw) = 'INSTALLDOSLANAPI' then do
            if LS_InstallDosLanAPI  then
               lsrsp.i = '  InstallDosLanAPI = INSTALL'
            else
               lsrps.i = '  InstallDosLanAPI = REMOVE'
         end  /* Do */

         when translate(kw) = 'INSTALLGENERICALERTER' then do
            if LS_InstallGenericAlerter  then
              lsrsp.i = '  InstallGenericAlerter = INSTALL'
            else
              lsrsp.i = '  InstallGenericAlerter = REMOVE'
         end  /* Do */

         when translate(kw) = 'INSTALLINSTALLPROGRAM' then do
            if LS_InstallInstallProgram then
              lsrsp.i = '  InstallInstallProgram = INSTALL'
            else
              lsrsp.i = '  InstallInstallProgram = REMOVE'
         end  /* Do */

         when translate(kw) = 'INSTALLLOOPBACKDRIVER' then do
            if LS_InstallLoopBackDriver then
              lsrsp.i = '  InstallLoopBackDriver = INSTALL'
            else
              lsrsp.i = '  InstallLoopBackDriver = REMOVE'
         end  /* Do */

         when translate(kw) = 'INSTALLCLIPBOARD' then do
            if LS_InstallClipboard then
              lsrsp.i = '  InstallClipBoard = INSTALL'
            else
              lsrsp.i = '  InstallClipBoard = REMOVE'

         end  /* Do */

         when translate(kw) = 'INSTALLMSGPOPUP' then do
            if LS_InstallMsgPopup  then
              lsrsp.i = '  InstallMSGPopup = INSTALL'
            else
              lsrsp.i = '  InstallMSGPopup = REMOVE'
         end  /* Do */

         when translate(kw) = 'INSTALLUPM' then do
            if LS_InstallUPM  then
              lsrsp.i = '  InstallUPM = INSTALL'
            else
              lsrsp.i = '  InstallUPM = INSTALLIFREQUIRED'
         end  /* Do */

         when translate(kw) = 'INSTALLMIGRATIONIMPORTUTIL' then do
            if LS_InstallMigration & translate(LS_ServerType) = 'DOMAINCONTROLLER'  then
               lsrsp.i = '  InstallMigrationImportUtil = INSTALL'
            else
               lsrsp.i = '  InstallMigrationImportUtil = REMOVE'
          end  /* Do */


         when translate(lsrsp.i) = 'UPDATEIBMLAN = NETWORKS<' then netwkindex = i

         when translate(lsrsp.i) = 'DELETEIBMLAN = NETWORKS<' then delnetwkindex = i

      otherwise nop
      end  /* select */
   end /* do */
   lsrsp.0 = i
   call stream LSrspsrc, 'C', 'CLOSE'

   /* Do LS specific configuration */

   if LS_Adapters \= '' then do
      /* Assign the first part of the response file to a temp stem */
      do i = 1 to delnetwkindex
         tmpstem.i = lsrsp.i
      end /* do */

      /* Null out the delete lines for the adapters that are to be added */
      i = i -1
      endofsection = 0
      do while endofsection = 0
         i = i + 1
         parse var lsrsp.i kw '=' .
         if strip(lsrsp.i) = '>' then do
            endofsection = 1
            tmpstem.i = lsrsp.i
         end  /* Do */
         else if pos(right(strip(kw),1), LS_Adapters) > 0 then lsrsp.i = ''
         tmpstem.i = lsrsp.i
      end /* do */

      /* Assign the couple of lines until the beginning of the add network
          lines section */
      do j = i to netwkindex
         i = i + 1
         tmpstem.j = lsrsp.j
      end /* do */
      tmpstem.j = lsrsp.j

      /* For each adapter being added, search the protocols for the netbios stack
          containing the proper binding.  Then, create a netx line in the response
          file for it */
      numnets = words(LS_Adapters)
      do j = 1 to numnets
         i = i + 1
         netadapnum = right(strip(word(LS_Adapters, j)),1)
         do k = 1 to protocol.0
            if protocol.k.netbios = 1 then do
               do m = 1 to protocol.k.0
                  parse var protocol.k.m kw'='kwval
                  if strip(translate(kw)) = 'BINDINGS' then do
                     this_bind = ''; imdone = 0; commacount = 0
                     if left(kwval,1) \= ',' then this_bind = this_bind || ' 0 '
                     if pos(',',kwval) = 0 then imdone = 1
                     do while imdone = 0
                        parse var kwval first ',' kwval
                        if left(kwval,1) = ',' then commacount = commacount + 1
                        else do
                           this_bind = this_bind || commacount + 1 || ' '
                           commacount = commacount + 1
                        end
                        if pos(',',kwval) = 0 then imdone = 1
                     end /* do */
                     if pos(netadapnum - 1, this_bind) > 0 then do
                        netbios_drivername = strip(protocol.k.drivername)
                        m = protocol.k.0;  k = protocol.0
                     end /* if pos */
                  end  /* Do */
               end /* do */
            end  /* Do */
         end /* do */
         tmpstem.i = 'net'netadapnum' = 'netbios_drivername',*,LM10,*,100,*'
         if pos('IPXNB', translate(tmpstem.i)) > 0 then do
            tmpstem.i = 'net'netadapnum' = 'netbios_drivername',*,LM10,75,120,14'
         end  /* Do */
      end /* do */

      /* Assign the rest of the file to the tmpstem */
      do j = netwkindex + 1 to lsrsp.0
         i = i + 1
         tmpstem.i = lsrsp.j
      end /* do */

      /* Create net string */
      tmpstring = ''
      do k = 1 to words(LS_Adapters)
         tmpstring = tmpstring || word(LS_Adapters,k)||', '
      end /* do */
      tmpstring = left(tmpstring, length(tmpstring)-2)

      /* Create the delete net string */
      tmp1string = ''
      /* There are 4 possible net lines, delete the ones that aren't in the
         tmpstring */
      do k = 1 to 4
         knetname = 'net'||k
         if pos(knetname, tmpstring) = 0 then tmp1string = tmp1string || knetname ||', '
      end /* do */
      if tmp1string \= '' then
         tmp1string = left(tmp1string, length(tmp1string)-2)

      /* Assign the tmpstem back to the original variable */
      do j = 1 to i
         if strip(translate(tmpstem.j)) = 'WRKNETS = NET1' then tmpstem.j = '  wrknets = ' || tmpstring
         else if strip(translate(tmpstem.j)) = 'WRKNETS = NET1,NET2,NET3,NET4' then tmpstem.j = '  wrknets = ' || tmp1string
    /*   defect 46269   */
          if strip(translate(tmpstem.j)) = 'SRVNETS = NET1' then tmpstem.j = '  srvnets = ' || tmpstring
         else if strip(translate(tmpstem.j)) = 'SRVNETS = NET1,NET2,NET3,NET4' then tmpstem.j = '  srvnets = ' || tmp1string
         lsrsp.j = tmpstem.j
    end /* do */
      lsrsp.0 = j - 1

      drop tmpstem.

      call BuildAutoStart

   end /* do */

RETURN 0

/* BUILDAUTOSTART */
/*
    Called by: Main
    Calls: none
    Dependencies:
*/
/* Add the sections to AutoStart to the LS response file */
BuildAutoStart:

  srvautostartflag = 0;  addsrvflag = 0
  svrstartindex = ''; servicesindex = ''
  ffstautostartflag = 0; ffststartindex = ''

  /* Pull out LSSERVER and FFST and handle seperately */
  autostartline = translate(LS_AutoStart)
  if pos('LSSERVER', autostartline) > 0 then do
     parse var autostartline first 'LSSERVER' last
     autostartline = first || last
     srvautostartflag = 1
  end  /* Do */

  if pos('FFST', autostartline) > 0 then do
     parse var autostartline first 'FFST' last
     autostartline = first || last
     ffstautostartflag = 1
  end  /* Do */

  /* If messenger is in the autostart line, pull it out. */
  if pos('MESSENGER', autostartline) > 0 then do
     parse var autostartline first 'MESSENGER' last
     autostartline = first || last
  end  /* Do */
  /* If messenger isn't there, delete the wrkservices line */
  else do
       updatflag = 0
       do i = 1 to lsrsp.0
          if strip(translate(lsrsp.i)) = 'ADDIBMLAN = REQUESTER<' then updatflag = 1
          if strip(translate(lsrsp.i)) = 'WRKSERVICES = MESSENGER' & updatflag = 1 then do
             lsrsp.i = ''
             i = lsrsp.0
          end  /* Do */
       end /* do */
  end

  do i = 1 to lsrsp.0
     parse upper var lsrsp.i kw'='kwval
     if kw = 'CONFIGAUTOSTARTFFST' then ffststartindex = i
     else  if kw = 'CONFIGAUTOSTARTLS' then srvstartindex = i
     else if translate(strip(lsrsp.i)) = 'ADDIBMLAN = SERVER<' then addsrvflag = 1
     else if addsrvflag then do
        if kw = 'SRVSERVICES' then servicesindex = i
        else if strip(lsrsp.i) = '>' then addsrvflag = 0
     end  /* Do */
  end /* do */

  if srvautostartflag & srvstartindex \= '' then do
     lsrsp.srvstartindex = '  ConfigAutoStartLS = YES'
  end  /* Do */

  if ffstautostartflag & ffststartindex \= '' then do
     lsrsp.ffststartindex = '  ConfigAutoStartFFST = YES'
  end  /* Do */

  tmpautoline = ''
  do while words(autostartline) > 0
     parse var autostartline word1 autostartline
     tmpautoline = tmpautoline || strip(word1) ||', '
  end /* do */
  autostartline = strip(tmpautoline)
  autostartline = strip(autostartline,,',')

  /* Append the rest of the line to the SrvServices Line */
  if servicesindex \= '' then do
     lsrsp.servicesindex = '  SrvServices = ' || autostartline
     if srvautostartflag = 1 then lsrsp.servicesindex = lsrsp.servicesindex || ', LSSERVER'
  end  /* Do */

RETURN 0

/* BUILDRIPL */
/*
    Called by: Main
    Calls: none
    Dependencies:
*/
/* Build the Remote IPL section of the LS response file */
BuildRIPL:

  /* Find the number of RIPL adapters */
  numrplnets = words(RIPL_Adapters)

  do i = 1 to lsrsp.0
     parse var kw '=' kwval         /* Look for the Remoteboot section */
     if translate(strip(lsrsp.i)) = 'UPDATEIBMLAN = REMOTEBOOT<' then do
        do j = 1 to i+1              /* Assign the first part of the stem to a temp stem */
          tmplsrsp.j = lsrsp.j
        end /* do */
        /* Add the RIPL line for each of the ripl adapters */
        do k = 1 to numrplnets
           rpladapnum = right(strip(word(RIPL_Adapters, k)),1)
           tmplsrsp.j = '  rpl' || rpladapnum || ' = RPLNET1.DLL RPLNET2.DLL RPLOEM.DLL ' || rpladapnum -1
           j = j + 1
        end /* do */
        k = k -1
        /* Assign the rest of the original stem to the temp stem */
        do m = j to lsrsp.0+k
           shiftnum = m-k
           tmplsrsp.m = lsrsp.shiftnum
        end /* do */
        tmplsrsp.0 = m - 1
        /* Assign the temp stem back to the original */
        do j = 1 to tmplsrsp.0
          lsrsp.j = tmplsrsp.j
        end /* do */
        lsrsp.0 = tmplsrsp.0
        drop tmplsrsp.
        /* Changed the size of the stem, need to bail */
        i = lsrsp.0
     end  /* Do */
  end /* do */

  /* Indicator for DELETEIBMLAN = Remoteboot section */
  delrplsec = 0
  /* Convert 'net'x entries to 'rpl'x entries */
  rplsrchline = translate(translate(RIPL_Adapters, 'rpl', 'net'))

  do i = 1 to lsrsp.0
     parse var lsrsp.i kw '=' kwval
     if strip(translate(kw)) = 'RPLDIR' then do
        lsrsp.i = '  rpldir ='RIPL_RIPLDrive'\IBMLAN\RPL'
     end  /* Do */
     else if strip(translate(kw)) = 'RPLUSERDIR' then do
        lsrsp.i = '  rpluserdir ='RIPL_USERDrive'\IBMLAN\RPLUSER'
     end  /* Do */
     else if translate(strip(lsrsp.i)) = 'DELETEIBMLAN = REMOTEBOOT<' then do
        delrplsec = 1
     end  /* Do */
     else if delrplsec then do
        if pos(translate(strip(kw)), rplsrchline) > 0 then lsrsp.i = ''
        else if strip(kw) = '>' then delrplsec = 0
     end  /* Do */
     else if strip(translate(kw)) = 'CONFIGCOPYDLR' then do
        if RIPL_InstDosNet then lsrsp.i = '  ConfigCopyDLR = Copy'
     end  /* Do */
     else if strip(translate(kw)) = 'CONFIGCOPYOS2REQUESTER' then do
        if RIPL_InstOS2Net then lsrsp.i = '  ConfigCopyOS2Requester = Copy'
     end  /* Do */
     else if strip(translate(kw)) = 'CONFIGCOPYLSP' then do
        lsrsp.i = '  ConfigCopyLSP = Copy'
     end  /* Do */
     else if strip(translate(kw)) = 'INSTALLDOSREMOTEIPL' & LS_InstallDosRemoteIPL  then do
        lsrsp.i = '  InstallDosRemoteIPL = INSTALL'
     end  /* Do */
     else if strip(translate(kw)) = 'INSTALLOS2REMOTEIPL' & LS_InstallOS2RemoteIPL  then do
        lsrsp.i = '  InstallOS2RemoteIPL = INSTALL'
     end  /* Do */
  end /* do */

RETURN 0

/* BUILDUPS */
/*
    Called by: Main
    Calls: None
    Dependencies: UPSComPort lsrsp.
*/
/* Build the UPS portion of the LS response file */
BUILDUPS:

   do i = 1 to lsrsp.0
     parse var lsrsp.i kw '=' kwval
     if translate(kw) = 'CONFIGUPSPORT' & UPS_ComPort \= '' then do
        lsrsp.i = '  ConfigUPSPort = 'UPS_ComPort
     end  /* Do */
     else if translate(kw) = 'INSTALLUPS'  then do
        lsrsp.i = '  InstallUps = INSTALL'
     end  /* Do */
   end /* Do */

RETURN 0

/* BUILDOS2Peer */
/*
    Called by: Main
    Calls: None
    Dependencies: tabledir cltdir OS2Peer_Drive OS2_Drive OS2Peer_Name
                    OS2Peer_Domain
*/
/* Portion to build Peer Response File */
BuildOS2Peer:

   Peerrspsrc = tabledir'\PEER.RSP'
   Peerrspfile = cltdir'\OS2PEER.RSP'

   install_OS2Peer = 1

   /* If we can't read the response file source, exit */
   if stream(Peerrspsrc, 'C', 'QUERY EXISTS') = ''  then do
      err1.1 = SysGetMessage(10, msgfile, Peerrspsrc)
      err1.2 = SysGetMessage(11, msgfile)
      call errout 10
   end  /* Do */

   /* Read the file into a stem */
   i = 0
   do while lines(Peerrspsrc) > 0
      i = i + 1
      peerrsp.i = linein(Peerrspsrc)
      parse var peerrsp.i kw '=' kwval
      select
         when translate(kw) = 'CONFIGTARGETDRIVE' then
            peerrsp.i = '  ConfigTargetDrive = 'left(OS2Peer_Drive,1)
         when translate(kw) = 'CONFIGSOURCEDRIVE' then
            peerrsp.i = '  ConfigSourceDrive = 'left(OS2Peer_Drive,1)
         when translate(kw) = 'COMPUTERNAME' then
            peerrsp.i = '  Computername = 'OS2Peer_Name
         when translate(kw) = 'DOMAIN' then
            peerrsp.i = '  Domain = 'OS2Peer_Domain

         when translate(kw) = 'SRVCOMMENT' then
            peerrsp.i = '  srvcomment = 'OS2Peer_Comment

         when translate(kw) = 'REPLACENETACC' then do

            if OS2Peer_ReplaceNetAcc then
               OS2Peer_ReplaceNetAcc = 'YES'
            else
               OS2Peer_ReplaceNetAcc = 'NO'
            peerrsp.i = '  ReplaceNetAcc = 'OS2Peer_ReplaceNetAcc
         end  /* Do */

         when translate(kw) = 'INSTALLADMINGUI' then do
            if OS2Peer_InstallAdminGUI then
               last = 'INSTALL'
            else
               last = 'REMOVE'
            peerrsp.i = '  InstallAdminGUI = ' || last
         end  /* Do */

         when translate(kw) = 'INSTALLPEERSERVICE' then do
            if OS2Peer_InstallPeerService then
               last = 'INSTALL'
            else
               last = 'REMOVE'
            peerrsp.i = '  InstallPeerService = ' || last
         end  /* Do */

         when translate(kw) = 'INSTALLGUI' then do
            if OS2Peer_InstallPeerService then
               last = 'INSTALL'
            else
               last = 'REMOVE'
            peerrsp.i = '  InstallGUI = ' || last
         end  /* Do */

         when translate(peerrsp.i) = 'UPDATEIBMLAN = NETWORKS<' then netwkindex = i

         when translate(peerrsp.i) = 'DELETEIBMLAN = NETWORKS<' then delnetwkindex = i

      otherwise nop
      end  /* select */
   end /* do */
   peerrsp.0 = i
   call stream Peerrspsrc, 'C', 'CLOSE'

   /* Do Peer specific configuration */

   if OS2Peer_Adapters \= '' then do
      /* Assign the first part of the response file to a temp stem */
      do i = 1 to delnetwkindex
         tmpstem.i = peerrsp.i
      end /* do */

      /* Null out the delete lines for the adapters that are to be added */
      i = i -1
      endofsection = 0
      do while endofsection = 0
         i = i + 1
         parse var peerrsp.i kw '=' .
         if strip(peerrsp.i) = '>' then do
            endofsection = 1
            tmpstem.i = peerrsp.i
         end  /* Do */
         else if pos(right(strip(kw),1), OS2Peer_Adapters) > 0 then peerrsp.i = ''
         tmpstem.i = peerrsp.i
      end /* do */

      /* Assign the couple of lines until the beginning of the add network
          lines section */
      do j = i to netwkindex
         i = i + 1
         tmpstem.j = peerrsp.j
      end /* do */
      tmpstem.j = peerrsp.j

      /* For each adapter being added, search the protocols for the netbios stack
          containing the proper binding.  Then, create a netx line in the response
          file for it */
      numnets = words(OS2Peer_Adapters)
      do j = 1 to numnets
         i = i + 1
         netadapnum = right(strip(word(OS2Peer_Adapters, j)),1)
         do k = 1 to protocol.0
            if protocol.k.netbios = 1 then do
               do m = 1 to protocol.k.0
                  parse var protocol.k.m kw'='kwval
                  if strip(translate(kw)) = 'BINDINGS' then do
                     this_bind = ''; imdone = 0; commacount = 0
                     if left(kwval,1) \= ',' then this_bind = this_bind || ' 0 '
                     if pos(',',kwval) = 0 then imdone = 1
                     do while imdone = 0
                        parse var kwval first ',' kwval
                        if left(kwval,1) = ',' then commacount = commacount + 1
                        else do
                           this_bind = this_bind || commacount + 1 || ' '
                           commacount = commacount + 1
                        end
                        if pos(',',kwval) = 0 then imdone = 1
                     end /* do */
                     if pos(netadapnum - 1, this_bind) > 0 then do
                        netbios_drivername = strip(protocol.k.drivername)
                        m = protocol.k.0;  k = protocol.0
                     end /* if pos */
                  end  /* Do */
               end /* do */
            end  /* Do */
         end /* do */
         tmpstem.i = 'net'netadapnum' = 'netbios_drivername',*,LM10,*,100,*'
         if pos('IPXNB', translate(tmpstem.i)) > 0 then do
            tmpstem.i = 'net'netadapnum' = 'netbios_drivername',*,LM10,75,120,14'
         end  /* Do */
      end /* do */

      /* Assign the rest of the file to the tmpstem */
      do j = netwkindex + 1 to peerrsp.0
         i = i + 1
         tmpstem.i = peerrsp.j
      end /* do */

      /* Create net string */
      tmpstring = ''
      do k = 1 to words(OS2Peer_Adapters)
         tmpstring = tmpstring || word(OS2Peer_Adapters,k)||', '
      end /* do */
      tmpstring = left(tmpstring, length(tmpstring)-2)

      /* Create the delete net string */
      tmp1string = ''
      /* There are 4 possible net lines, delete the ones that aren't in the
         tmpstring */
      do k = 1 to 4
         knetname = 'net'||k
         if pos(knetname, tmpstring) = 0 then tmp1string = tmp1string || knetname ||', '
      end /* do */
      if tmp1string \= '' then
         tmp1string = left(tmp1string, length(tmp1string)-2)

      /* Assign the tmpstem back to the original variable */
      do j = 1 to i
         if strip(translate(tmpstem.j)) = 'WRKNETS = NET1' then tmpstem.j = '  wrknets = ' || tmpstring
         else if strip(translate(tmpstem.j)) = 'WRKNETS = NET1,NET2,NET3,NET4' then tmpstem.j = '  wrknets = ' || tmp1string
    /*   defect 46269   */
          if strip(translate(tmpstem.j)) = 'SRVNETS = NET1' then tmpstem.j = '  srvnets = ' || tmpstring
         else if strip(translate(tmpstem.j)) = 'SRVNETS = NET1,NET2,NET3,NET4' then tmpstem.j = '  srvnets = ' || tmp1string
         peerrsp.j = tmpstem.j
    end /* do */
      peerrsp.0 = j - 1

      drop tmpstem.

   end /* do */

RETURN 0

/* BUILDNSC */
/* Called by: Main
   Calls:
   Dependencies:
*/

BuildNSC:

  nscsrcfile = tabledir'\NSC.RSP'
  nscrspfile = cltdir'\NSC.RSP'

  if (product.ii = "OS2PEER") then
     NSC_Drive = OS2Peer_Drive
  else NSC_Drive = NW_Drive

  if stream(nscrspfile, 'C', 'QUERY EXISTS') \= '' then
     call SysFileDelete nscsrcfile

  do while lines(nscsrcfile) > 0
     line1 = linein(nscsrcfile)

     parse var line1 kw'='kwval

     if strip(translate(kw)) = 'FILE' then
        line1 = 'FILE = 'NSC_Drive'\NSC'

     else if strip(translate(kw)) = 'AUX1' then
        line1 = 'AUX1 = 'NSC_Drive'\NSC\DLL'

     call lineout nscrspfile, line1
  end /* do */

  call stream nscsrcfile, 'C', 'CLOSE'
  call stream nscrspfile, 'C', 'CLOSE'

RETURN 0

/* BUILDNETFIN */
/*
    Called by: Main
    Calls: write_rspfile
    Dependencies:
*/
/* Builds the NetFinity Response file */
BuildNetFin:

  NetFSrcfile = tabledir'\netfbase.rsp'
  NetFTgtFile = cltdir'\netfin.rsp'

  NetF_Drive = left(NetF_Drive,1)

  if NetF_SystemName = '' then do
     if OS2Peer_Name \= '' then
        NetF_SystemName = OS2Peer_Name
     else
        NetF_SystemName = 'NetClient'
  end  /* Do */

  i = 0
  do while lines(NetFSrcfile) > 0

     i = i + 1
     netfrsp.i = linein(NetFSrcfile)

     parse upper var netfrsp.i kw'='kwval

     if kw = ';SYSTEMNAME' then do
        netfrsp.i = 'SystemName = 'NetF_SystemName
     end  /* Do */

     /* Insert entries for Keywords */
     else if strip(kw) = ';KEYWORD.1' & NetF_Keyword1 \= '' then
        netfrsp.i = 'Keyword.1 = 'NetF_Keyword1

     else if strip(kw) = ';KEYWORD.2' & NetF_Keyword2 \= '' then
        netfrsp.i = 'Keyword.2 = 'NetF_Keyword2

     /* Modify Driver lines */
     else if strip(kw) = 'DRIVER.TCPIP' then
        netfrsp.i = 'Driver.TCPIP = 'NetF_TCPIPDriver

     /* If it's the primary driver line, use is */
     else if strip(kw) = 'DRIVER.NETBIOS' then
        netfrsp.i = 'Driver.NETBIOS = 'NetF_NETBIOSDriver

     /* If not, use the alternate NetBIOS line */
     else if strip(kw) = 'DRIVER.NETBIOS2' then
        netfrsp.i = 'Driver.NETBIOS2 = 'NetF_NETBIOSDriver2

     else if strip(kw) = 'DRIVER.SERIPC' then
        netfrsp.i = 'Driver.SERIPC = 'NetF_SerialDriver

     else if strip(kw) = 'DRIVER.IPX' then
        netfrsp.i = 'Driver.IPX = 'NetF_IPXDriver

     /* Insert Parm1 lines for  NETBIOS */
     else if strip(kw) = ';PARM1.NETBIOS' & NetF_NetBIOSParm \= '' then
        netfrsp.i = 'Parm1.NETBIOS = 'NetF_NetBIOSParm

     else if strip(kw) = ';PARM1.NETBIOS' & NetF_NetBIOS2Parm \= '' then
        netfrsp.i = 'Parm1.NETBIOS = 'NetF_NetBIOS2Parm

     /* Set Parm1 line for SeriPC */
     else if strip(kw) = ';PARM1.SERIPC' & NetF_SeriPCParm \= '' then
        netfrsp.i = 'Parm1.SERIPC = 'NetF_SeriPCParm

  end /* do */
  netfrsp.0 = i

  call stream NetFSrcfile, 'C', 'CLOSE'

  /* Write respose file */
  do i = 1 to netfrsp.0
     rspstem.i = netfrsp.i
  end /* do */
  rspstem.0 = netfrsp.0

  call write_rspfile NetFTgtFile


RETURN 0

/* BUILDMFS */

BuildMFS:

  mfssrcfile = tabledir'\mfs.rsp'
  mfsrspfile = cltdir'\mfs.rsp'

   if stream(mfsrspfile, 'C', 'QUERY EXISTS') \= '' then
     call SysFileDelete mfsrspfile


  do while lines(mfssrcfile) > 0

     line1 = linein(mfssrcfile)
     parse var line1 kw '=' kwval

     if strip(translate(kw)) = 'FILE' then do
        line1 = kw' = ' || MFS_Drive || '\mfs'
     end  /* Do */

     call lineout mfsrspfile, line1
  end /* do */

  call stream mfssrcfile, 'C', 'CLOSE'
  call stream mfsrspfile, 'C', 'CLOSE'

RETURN 0

/* BUILDSVAGENT */

BuildSVAgent:

   svasrcfile = tabledir'\svagent.rsp'
   svarspfile = cltdir'\svagent.rsp'

   if stream(svarspfile, 'C', 'QUERY EXISTS') \= '' then
     call SysFileDelete svarspfile

   sva_ipx = 'NO'; sva_ip = 'NO'; sva_nb = 'NO'

   /* Find which protocols are present */
   do i =1 to protocol.0
      if pos('ODI2NDI', translate(protocol.i)) > 0 then
         sva_ipx = 'YES'
      else if pos('BEUI', translate(protocol.i)) > 0 | pos('IPXNB', translate(protocol.i)) > 0 then
         sva_nb = 'YES'
      if pos('TCPIP', translate(protocol.i)) > 0 then
         sva_ip = 'YES'
   end /* do */

   /* If no protocols are selected, then don't install SVAGENT */
   if sva_ipx = 'NO' & sva_ip = 'NO' & sva_nb = 'NO' then do
      parse var products_to_install first 'SVAGENT' last
      products_to_install = first || last
      RETURN 0
   end  /* Do */

   /* Set the protocols to be used */
   do while lines(svasrcfile) > 0

      line1 = linein(svasrcfile)
      parse var line1 kw'='kwval

      if strip(translate(kw)) = 'FILE' then
         line1 = kw' = 'sva_drive'\SVCA'
      else if strip(translate(kw)) = 'NETVIEW_AGENT_IP_TRANSPORT' then
         line1 = kw' = 'sva_ip
      else if strip(translate(kw)) = 'NETVIEW_AGENT_NETBIOS_TRANSPORT' then
         line1 = kw' = 'sva_nb
      else if strip(translate(kw)) = 'NETVIEW_AGENT_IPX_TRANSPORT' then
         line1 = kw' = 'sva_ipx

      call lineout svarspfile, line1

   end /* do */

  call stream svasrcfile, 'C', 'CLOSE'
  call stream svarspfile, 'C', 'CLOSE'

RETURN 0

/* BuildBooks */
/*
   Called by: Main
   Calls: None
   Dependencies:
   File Dependencies: None
*/

BuildBooks:

  booksrcfile=tabledir'\BOOKS.SRC'
  booksrspfile=cltdir'\BOOKS.RSP'

  if stream(booksrspfile, 'C', 'QUERY EXISTS') \= '' then call SysFileDelete booksrspfile

  i = 0
  do while lines(booksrcfile) > 0
     i = i + 1
     booksrc.i = linein(booksrcfile)
  end /* do */
  call stream booksrcfile, 'C', 'CLOSE'
  booksrc.0 = i

  do i =1 to words(BOOKS)
     thisprod = word(BOOKS,i)
     do j = 1 to booksrc.0
        parse var booksrc.j kw';'last
        if translate(kw) = translate(thisprod) then call lineout booksrspfile, booksrc.j
     end /* do */
  end /* do */
  call stream booksrspfile, 'C', 'CLOSE'

RETURN 0

BuildNetscape:

/*   Netscape is installed with Software installer, and it requires that the   */
/*   component name in the response file exactly match the component name used */
/*   when Netscape was packaged.  Unfortunately, this component name is        */
/*   translated for each country, so we need to find extract it from the       */
/*   the NS40COMM.PKG file shipped with Netscape Communicator.  The component  */
/*   id for the communicator is 'NS40', and we need to extract the 'NAME' for  */
/*   that component. This name is then placed in the response file             */
/*   If the component name isn't found, we use the (english) version that was  */
/*   in the default response file, and log a message                           */

  netscapesrcfile = tabledir'\NETSCAPE.RSP'
  netscaperspfile = cltdir'\NETSCAPE.RSP'
  netscapepkgfile = CD_Drive'\cid\server\netscape\ns46comm.pkg'

   /* If we can't read the response file source, exit */
   if stream(netscapesrcfile, 'C', 'QUERY EXISTS') = ''  then do
      err1.1 = SysGetMessage(10, msgfile, netscapesrcfile)
      err1.2 = SysGetMessage(11, msgfile)
      call errout 10
   end  /* Do */

  /* If no NETSCAPE pkg file, then write a message to the log */

   if stream(netscapepkgfile, 'C', 'QUERY EXISTS') = ''  then do
      err1.1 = SysGetMessage(10, msgfile, netscapepkgfile)
      err1.2 = SysGetMessage(11, msgfile)
      call errout 10
   end  /* Do */

   netscapeid = ''
   netscapename = ''
   foundpkgname = 0

   do while lines(netscapepkgfile) > 0  & foundpkgname = 0
      nspkg = linein(netscapepkgfile)
      parse var nspkg kw '=' kwval
      select
         when strip(translate(kw)) = 'COMPONENT' then do
            netscapeid = ''
            netscapename = ''
         end
         when strip(translate(kw)) = 'NAME'  then
            parse var kwval "'" netscapename "'"
         when strip(translate(kw)) = 'ID'  then
            parse var kwval netscapeid ","

         otherwise nop
      end
      if netscapeid = 'NS46' & netscapename \= '' then
         foundpkgname = 1

      end  /* while lines(netscapepkgfile) > 0 */

   call stream netscapepkgfile, 'C', 'CLOSE'

   if foundpkgname = 0 then
     do
         err1.1 = SysGetMessage(27, msgfile)
         err1.2 = SysGetMessage(28, msgfile)
         call errout 15
     end

  if stream(netscaperspfile, 'C', 'QUERY EXISTS') \= '' then
     call SysFileDelete netscaperspfile

  do while lines(netscapesrcfile) > 0
     line1 = linein(netscapesrcfile)

     parse var line1 kw'='kwval

     if strip(translate(kw)) = 'COMP' then
        if foundpkgname = 1  then
           line1 = 'COMP = 'netscapename

     if strip(translate(kw)) = 'FILE' then
        line1 = 'FILE = 'Netscape_Drive'\NETSCAPE'

     else if strip(translate(kw)) = 'NSCONVERTBROWSER' then do
        if Netscape_NSCONVERTBROWSER = 1 then
           line1 = 'NSCONVERTBROWSER = YES'
        else
          line1 = 'NSCONVERTBROWSER = NO'
        end

     else if strip(translate(kw)) = 'NSCONVERTQL' then do
        if Netscape_NSCONVERTQL = 1 then
           line1 = 'NSCONVERTQL = YES'
        else
           line1 = 'NSCONVERTQL = NO'
        end /* do */


     else if strip(translate(kw)) = 'NSASSOCIATEHTML' then do
         if Netscape_NSASSOCIATEHTML = 1  then
            line1 = 'NSASSOCIATEHTML= YES'
         else
            line1 = 'NSASSOCIATEHTML= NO'
     end /* do */

     call lineout netscaperspfile, line1
  end /* do */


  call stream netscapesrcfile, 'C', 'CLOSE'
  call stream netscaperspfile, 'C', 'CLOSE'

RETURN 0

/* generate tcp/ip 32 clifi response file */
make_tcpip32_rsp:

	/* get tcp/ip parameters */
  TCPIP_Drive = ibminstdrive
  npcfgfile = tabledir'\npconfig.cfg'
	if stream(npcfgfile, 'c', 'query exists') <> '' then do
		do while lines(npcfgfile)
			l=linein(npcfgfile)
			parse value l with 'TCPIP_Drive=' tcpipdrive
			if length(tcpipdrive) = 2 then TCPIP_Drive = tcpipdrive
		end
		call lineout npcfgfile
	end

	/* needed files */
	tcp32rspsrc = tabledir'\TCPINST.RSP'
	tcp32rspfile = cltdir'\TCPINST.RSP'
	'@del 'tcp32rspfile' >nul 2>>&1'

	found  = 0
	found2 = 0
	found3 = 0

	do while lines(tcp32rspsrc)
		l = linein(tcp32rspsrc)

		if found = 1 then do
			l = '		Value='cd_drive'\cid\server\tcpapps\install'
			found = 0
		end

		if found2 = 1 then do
			call lineout tcp32rspfile, '		FilePath='cd_drive'\cid\server\tcpapps\install\makecmd.exe'
			found2 = 0
		end

		if found3 = 1 then do
			l = '		Value='TCPIP_Drive
			found3 = 0
		end

		if pos('Description=Where Package is put', l) > 0 then found = 1
		if pos('FilePath={Current_path}\install\makecmd.exe', l) > 0 then found2 = 1
		if pos('Description=The drive letter of InstallDir', l) > 0 then found3 = 1

		if found2 <> 1 then call lineout tcp32rspfile, l
	end

	call lineout tcp32rspfile

RETURN

/* BUILDTCPIP */
/*
    Called by: Main
    Calls: write_rspfile
    Dependencies: cltdir CD_Drive TCPIP_Hostname TCPIP_Router TCPIP_IPAddress
                    TCPIP_SubNetMask TCPIP_NameServer TCPIP_Drive TCPIP_DomName
                    TCP_DDNS_DHCP_Server TCP_VPN TCP_NFS  TCPIP_Migrate
    File Dependencies: TCPIP.RSP
*/
/* Build the TCPAPPS response file */
BuildTCPIP:

  tcpsrcfile = tabledir'\TCPIP.RSP'
   tcprspfile = cltdir'\TCPAPPS.RSP'

   /* If we can't read the response file source, exit */
   if stream(tcpsrcfile, 'C', 'QUERY EXISTS') = ''  then do
      err1.1 = SysGetMessage(10, msgfile, tcpsrcfile)
      err1.2 = SysGetMessage(11, msgfile)
      call errout 10
   end  /* Do */

   /* if the customer just wants to migrate his existing configuration */

   if TCPIP_Migrate = 1 then
      first_tcp = 0
   else
      first_tcp = 1

   /* Read the response file, add in configuration info */
   i = 0
   do while lines(tcpsrcfile) > 0
      i = i + 1
      tcprsp.i = linein(tcpsrcfile)
      parse var tcprsp.i kw'='kwval

      if (translate(kw) = 'TARGET_DRIVE') then
       tcprsp.i = kw'='TCPIP_Drive

      if((translate(kw)='LOG_PATH1') | (translate(kw)='LOG_PATH2')) then
        tcprsp.i=kw'='logfile kwval

      if(translate(kw)='BOOT_DRIVE') then do
          parse var OS2_Drive Boot_Drive':'
         tcprsp.i=kw'='Boot_Drive
      end  /* do */

       if(translate(kw)='DHCP_DDNS_SERVER' & TCP_DHCP_DDNS_Server=1) then
             tcprsp.i=kw'=Y'

      if(translate(kw)='VPN' & TCP_VPN=1) then
             tcprsp.i=kw'=Y'

      if(translate(kw)='NFS' & TCP_NFS=1) then
             tcprsp.i=kw'=Y'

end /* do */

      /* Have to start adding stuff someplace, 4 seems like a good number */
      if first_tcp then do

         first_tcp = 0

         /* If we're using DHCP, there isn't any configuration */
            i = i + 1
            tcprsp.i = 'LAN_INTERFACE = ('
            i = i + 1
            tcprsp.i = '    INTERFACE_NUM=0'
            i = i + 1
            tcprsp.i = '    ENABLE_INTERFACE=Y'
         if TCPIP_DHCP \= 1 then do
            i = i + 1
            tcprsp.i = '    AUTO_DHCP=N'
            i = i + 1
            tcprsp.i = '    IP_ADDR='TCPIP_IPAddress
            i = i + 1
            tcprsp.i = '  NETMASK = 'TCPIP_SubNetMask
          end   /*  Do */
          else do
           i = i + 1
            tcprsp.i = '    AUTO_DHCP=Y'
            i = i + 1
            if TCPIP_DDNS then
               tcprsp.i = '    USE_DDNS=Y'
            else
               tcprsp.i = '    USE_DDNS=N'
            i = i + 1
            tcprsp.i = ' DHCP_MOBILE=Y'
          end /* do */
            i = i + 1
            tcprsp.i = ')'

          if (TCPIP_Router \='') then do
              i = i + 1
              tcprsp.i = 'DEFAULT_ROUTE = ('
              i = i + 1
              tcprsp.i = '  ROUTER = 'TCPIP_Router
              i = i + 1
              tcprsp.i = '  METRIC_COUNT=1'
              i = i + 1
              tcprsp.i = ')'
          end
         i = i + 1
         tcprsp.i = 'HOSTNAME = 'TCPIP_Hostname
         i = i + 1
         tcprsp.i = 'DOMAIN =  'TCPIP_DomName
         i = i + 1
         tcprsp.i = 'NAMESERVERS = ('
         i = i + 1
         tcprsp.i = '    NAMESERVER1='TCPIP_NameServer
         i = i + 1
         tcprsp.i = ')'
      end  /* Do */


   tcprsp.0 = i

   call stream tcpsrcfile, 'C', 'CLOSE'

   /* Assign the file to the response file stem for writing */
   do i = 1 to tcprsp.0
      rspstem.i = tcprsp.i
   end /* do */

   rspstem.0 = tcprsp.0

   /* Write the response file */
   call write_rspfile tcprspfile

RETURN 0

/* BUILDNWMPTS */
/*
    Called by: Main
    Calls: write_rspfile
    Dependencies: tabledir cltdir landd_index original_landd protocol.
                  odi2ndi_mappings_commentline landd_bindings_index
                  original_landd_netaddress landd_netaddress_index
*/

/* Creates the MPTS response file for NetWare.  Needs to be seperate
    from the first MPTS response file because of netapi.dll and other
    considerations.  We will always install all of the ODI2NDI logical
    adapters even if they existed before hand. */

BuildNetWareMPTS:

  nwmptsrspfile = cltdir'\NWMPTS.RSP'

  /* Search the protocol list for ODI2NDI */
  do j = 1 to protocol.0
     if strip(translate(protocol.j)) = 'ODI2NDI_NIF' then do
        i = 0
        do k = 1 to protocol.j.0
           parse var protocol.j.k kw'='kwval
           /* Add the settings to the stem */
           i = i + 1
           nwsettings.i = protocol.j.k
           /* Save the location of the bindings line */
           if strip(translate(kw)) = 'BINDINGS' then bindingindex = i
        end /* do */
        nwsettings.0 = i
     end  /* Do */
  end /* do */

  /* Find the number of adapters the protocol is bound to */
  numbindings = countem(translate(nwsettings.bindingindex), '_NIF')

  /* Get the list of adapters */
  parse upper var nwsettings.bindingindex kw '='nwadaplist

  currdir = directory()
  call directory ibminstdir

  /* Inititialize templates for ODI2NDI settings */
  ethermaster = ''; tokenmaster = ''

  /* For each physical adapter the protocol is bound to, we need to
      determine if it's TR or Ethernet.  Then append to the templates
      so the settings can be determined properly */
  do i = 1 to numbindings
     parse var nwadaplist first '_NIF' nwadaplist
     /* If we have a _NIFx extension, this will drop off the extension */
     if left(nwadaplist,1) \= ',' then nwadaplist = substr(nwadaplist,2)
     numcommas = copies(',',countem(first, ','))
     /* Take the bound section and convert it to a file name */
     nifname = strip(translate(first,' ',','))||'.NIF'

     /* Set the flag to True */
     adapter_is_ethernet = 1

     /* See if the adapter type has already been determined */
     do j = 1 to adapter.0
        if pos(strip(translate(first'_NIF')), translate(adapter.j)) > 0 then do
           if adapter.j.ethernet = 0 then adapter_is_ethernet = 0
        end  /* Do */
     end /* do */

     /* Set up the master template for Ethernet settings */
     ethermaster = ethermaster||numcommas
     if adapter_is_ethernet then ethermaster = ethermaster || '"YES"'
     else ethermaster = ethermaster || '"NO"'

     /* Set up the master template for Token Ring setting */
     tokenmaster = tokenmaster||numcommas
     if adapter_is_ethernet then tokenmaster = tokenmaster || '"NO"'
     else tokenmaster = tokenmaster || '"YES"'

  end /* do */
  call directory currdir

  /* Walk the settings, to insure the user hasn't already set them */
  defaults_changed = 0

  do i = 1 to nwsettings.0
     parse var nwsettings.i kw '=' kwval
     if pos('TOKEN', translate(kw)) > 0 | pos('ETHER', translate(kw)) then do
        if strip(translate(kw)) = 'TOKEN-RING'  & strip(translate(kwval)) = '"YES"' then nop
          else if strip(translate(kw)) = 'TOKEN-RING'  & strip(translate(kwval)) = '"NO"' then defaults_changed = 1
            else if strip(translate(kwval)) = '"YES"' then defaults_changed = 1
     end  /* Do */
  end /* do */

  /* Walk through the settings, assigning the proper values to the
      token ring and ethernet sections */
  if defaults_changed = 0 then do
     do i = 1 to nwsettings.0
        parse var nwsettings.i kw '=' kwval
        if pos('ETHERNET', translate(kw)) > 0  then do
           kwval = ethermaster
           nwsettings.i = kw ' = 'kwval
        end  /* Do */
        else if strip(translate(kw)) = 'TOKEN-RING' then do
           kwval = tokenmaster
           nwsettings.i = kw ' = 'kwval
        end  /* Do */
     end /* do */
  end /* do */

  /* Build the response file */
  nwmptsrsp.1= 'PROT_SECTION = ('
  nwcount = 2
  do i = 1 to nwsettings.0
     nwmptsrsp.nwcount = '  '||nwsettings.i
     nwcount = nwcount + 1
  end /* do */
  nwmptsrsp.nwcount = ')'
  nwcount = nwcount + 1
  nwmptsrsp.nwcount = ''
  nwcount = nwcount + 1
  nwmptsrsp.nwcount = odi2ndi_mappings_commentline

  if nbipx_exists then do
     nwmptsrsp.nwcount = 'PROT_NETBIOS = ('
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = "  SECTION_NAME = NETBIOS"
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = "  DRIVERNAME = NETBIOS$"
     nwcount = nwcount + 1
     do i = 1 to protocol.0
        if protocol.i.netbios then do
           do j = 1 to protocol.i.0
              parse upper var protocol.i.j kw'='kwval
              kwval = strip(kwval)
              if strip(kw) = 'BINDINGS' then do
                commacount = 0
                do while length(kwval) > 0
                   nextcomma = pos(',',kwval)
                   if nextcomma = 0 then do
                      kwval = ''
                      nwmptsrsp.nwcount = '  ADAPTER'commacount' = 'protocol.i.drivername','commacount
                      nwcount = nwcount + 1
                   end  /* Do */
                   else do
                      first = left(kwval, nextcomma)
                      kwval = substr(kwval, nextcomma+1)
                      if length(first) > 1 then do
                         nwmptsrsp.nwcount = '  ADAPTER'commacount' = 'protocol.i.drivername','commacount
                         nwcount = nwcount + 1
                      end  /* Do */
                   end /* do */
                   commacount = commacount + 1
                end /* do */
              end /* do */
           end /* do */
        end  /* Do */
     end /* do */
     nwmptsrsp.nwcount = ')'
     nwcount = nwcount + 1
     nwmptsrsp.nwcount  = ''
     nwcount = nwcount + 1
     do i = 1 to protocol.0
        if translate(protocol.i) = 'IPXNB_NIF' then do
           nwmptsrsp.nwcount = 'PROT_SECTION = ('
           do j = 1 to protocol.i.0
              nwcount = nwcount + 1
              nwmptsrsp.nwcount = '  'protocol.i.j
           end /* do */
           nwcount = nwcount + 1
           nwmptsrsp.nwcount = ')'
           nwcount = nwcount + 1
           nwmptsrsp.nwcount = ''
        end  /* Do */
     end /* do */
  end /* do */

  if original_landd = '' then do
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = 'PROT_SECTION = ('
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = '   delete_sect'
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = '   section_name = LANDD_NIF'
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = ')'
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = ''
  end  /* Do */
  else do
     protocol.landd_index.landd_bindings_index = 'BINDINGS = 'original_landd
     if original_landd_netaddress \= '' then
        protocol.landd_index.landd_netaddress_index = original_landd_netaddress
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = 'PROT_SECTION = ('
     do i = 1 to protocol.landd_index.0
        nwcount = nwcount + 1
        nwmptsrsp.nwcount = '  'protocol.landd_index.i
     end /* do */
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = ')'
     nwcount = nwcount + 1
     nwmptsrsp.nwcount = ''
  end  /* Do */

  nwmptsrsp.0 = nwcount

  /* Assign the file to the response file stem for writing */
  do i = 1 to nwmptsrsp.0
     rspstem.i = nwmptsrsp.i
  end /* do */
  rspstem.0 = nwmptsrsp.0

  call write_rspfile nwmptsrspfile

  call buildnetware

RETURN 0

/* BuildNetware */
/*
    Called by: BuildNetwareMPTS
    Calls: none
*/
BuildNetware:

   /* Determine if TR is out there */
   do i = 1 to adapter.0
      if nifname = adapter.i.nif_name then
        if adapter.i.ethernet = 0 then
         NW_TokenRing = 'TRUE'
        else NW_TokenRing = 'FALSE'
   end /* do */

   nw_rspfile = cltdir'\NPNWINST.RSP'

   nwrsp.1 = 'netbios_indicator = ' nbipx_exists
   nwrsp.2 = 'preferred_server = ' NW_PrefSrv
   nwrsp.3 = 'context_name = ' NW_Context
   nwrsp.4 = 'token_ring = ' NW_TokenRing
   nwrsp.0 = 4

  /* Assign the file to the response file stem for writing */
  do i = 1 to nwrsp.0
     rspstem.i = nwrsp.i
  end /* do */
  rspstem.0 = nwrsp.0

  call write_rspfile nw_rspfile

RETURN 0

/* BUILDLDR */
/*
    Called by: Main
    Calls: write_rspfile
    Dependencies: tabledir cltdir
*/
/* Section to create response file for LDR. */
BuildLDR:

  ldrrspfile = cltdir'\LDR.RSP'

  /* Initialize address */
  ldr_address = ''
  do ldra = 1 to 11
     ldr_address = ldr_address || d2x(random(15))
  end /* do */

  ldr_address = '4' || ldr_address

  if LDR_Ethernet then LDR_Lantype = 'Ethernet'
  else LDR_Lantype = 'TokenRing'

  ldrrsp.1 = 'Target = 'LDR_Drive'\'
  ldrrsp.2 = 'Phone = 'LDR_Phonenum
  ldrrsp.3 = 'LANType = 'LDR_Lantype
  ldrrsp.4 = 'Port = 'LDR_ComPort
  ldrrsp.5 = 'Modem = 'LDR_Modem
  ldrrsp.6 = 'Address = 'LDR_Address
  ldrrsp.0 = 6

  /* Assign the file to the response file stem for writing */
   do i = 1 to ldrrsp.0
      rspstem.i = ldrrsp.i
   end /* do */
   rspstem.0 = ldrrsp.0

   /* Write the response file */
   call write_rspfile ldrrspfile

RETURN 0

/* BUILDPPP */
/*
    Called by: Main
    Calls: write_rspfile
    Dependencies: tabledir cltdir
*/
/* Section to create response file for PPPSERVER. */
BuildPPP:

  pppsrvrspfile = cltdir'\PPPSRV.RSP'

  pppsrvrsp.1 = 'Target='PPP_Drive'\'
  pppsrvrsp.2 = 'WorkStationType=SERVER'
  pppsrvrsp.0 = 2

  /* Assign the file to the response file stem for writing */
   do i = 1 to pppsrvrsp.0
      rspstem.i = pppsrvrsp.i
   end /* do */
   rspstem.0 = pppsrvrsp.0

   /* Write the response file */
   call write_rspfile pppsrvrspfile

  call BuildPPPConfig

RETURN 0

/* BUILDPPPCONFIG */
/*
    Called by: BuildPPPSRV
    Calls: write_rspfile
    Dependencies: tabledir cltdir ls_name tcpip_hostname
    File Dependencies: clbsniff.exe
*/
BuildPPPConfig:

  PPPconfigfile = cltdir'\PPPCFG.RSP'
  default_PPP_name = 'PPPSRVR'

  /* Find/create the ldcs server name */
  if Ldcsservername = '' then do
     if LS_Name \= '' then ldcsservername = LS_Name
     else if TCPIP_Hostname \= '' then ldcsservername = TCPIP_Hostname
     else ldcsservername = default_PPP_name
  end

  /* See if there is a current PDFH_NIF.  If there is, use it */
  do i = 1 to adapter.0
        do j = 1 to adapter.i.0
            if pos('PDFH_NIF', translate(adapter.i.j)) > 0 then do
                do k = 1 to adapter.i.0
                    parse var adapter.i.k kw'='kwval
                    if pos('NETADDRESS', translate(kw)) > 0 then do
                       parse var kwval '"'kwval1'"'
                         PPP_Address = strip(kwval1)
                         if pos('T', translate(PPP_Address)) > 0 then   PPP_Address = strip(PPP_Address, 'L', T)
                         else if pos('I', translate(PPP_Address)) > 0 then   PPP_Address = strip(PPP_Address, 'L', I)
                    end
                end
           end /* do */
     end  /* Do */
  end /* do */

  /* Set the value of if it's an initial install */
  if pos('PPPSRV', translate(Previous_Products)) = 0 then ldcsinitial = 1
  else ldcsinitial = 0

  /* Check to see if a comport has been passed, if not, assign it to COM1 */
  if strip(PPP_ComPort) = '' then PPP_ComPort = 'COM1'

  pppcfgrsp.1 = 'Target='PPP_Drive
  pppcfgrsp.2 = 'Comport='PPP_ComPort
  pppcfgrsp.3 = 'Modem='PPP_Modem
  pppcfgrsp.4 = 'Ethernet='PPP_Ethernet
  pppcfgrsp.5 = 'Servername='ldcsservername
  pppcfgrsp.6 = 'Initial='ldcsinitial
  pppcfgrsp.7 = 'Address='PPP_Address
  pppcfgrsp.0 = 7

  if ( (PPP_Modem = '') | (ldcsinitial = 0) ) then configure_lan_distance = 0

  /* Assign the file to the response file stem for writing */
   do i = 1 to pppcfgrsp.0
      rspstem.i = pppcfgrsp.i
   end /* do */
   rspstem.0 = pppcfgrsp.0

   /* Write the response file */
   call write_rspfile   PPPconfigfile

RETURN 0


/* BUILDFFST */
/*
    Called by: Main
    Calls: None
    Dependencies: FFSTRA FFSTDispmsg FFSTId
*/

/* Build the standalone install file, then build the
   FFST portion of the OS/2 ls response file */
BUILDFFST:

   if install_ls = 1 then
      do i = 1 to lsrsp.0
         parse var lsrsp.i kw '=' kwval
         select
            when translate(kw) = 'CONFIGROUTEALERTSTO' then do
               if FFST_RouteAlerts \= '' then lsrsp.i = '  ConfigRouteAlertsTo = 'FFST_RouteAlerts
            end  /* Do */
            when translate(kw) = 'CONFIGDISPLAYMSG' then do
               if FFST_DisplayMsg \= '' then lsrsp.i = '  ConfigDisplayMsg = 'FFST_DisplayMsg
            end  /* Do */
            when translate(kw) = 'CONFIGWSID' then do
               if FFST_WorkstationID \= '' then lsrsp.i = '  ConfigWsId = 'FFST_WorkstationID
            end  /* Do */
         otherwise nop
         end  /* select */
      end /* do */

   /* Define the source and target */
   ffstsrcfile = tabledir'\instffst.src'
   ffsttgtfile = cltdir'\instffst.cmd'

   /* Delete the file if it exists */
   if stream(ffsttgtfile, 'C', 'QUERY EXISTS') \= '' then
      call SysFileDelete ffsttgtfile

   /* Read the source file and modify the lines, then write them out */
   do while lines(ffstsrcfile) > 0

      line1 = linein(ffstsrcfile)

      if strip(translate(line1)) = "FFSTWORKSTATIONID = ''" then
         line1 = "FFSTWorkStationID = '"FFST_WorkstationID"'"

      else if strip(translate(line1)) = "WSDIR = ''" then
         line1 = "WSDir = '"ibminstdir"'"

      else if strip(translate(line1)) = "CIDSRVPATH = ''" then
         line1 = "CIDSrvPath = '"CD_Drive"\CID\SERVER'"

      else if strip(translate(line1)) = "CLIENT = ''" then
         line1 = "Client = '"client"'"

      /* Rout is not straightforward */
      else if strip(translate(line1)) = "ROUTNUM = ''" then do
         if translate(FFSTRouteAlerts) = 'IBMLANMANAGER' then
            routnum = 20
         else
            routnum = 1
         line1 = "RoutNum = '"routnum"'"
      end  /* Do */

      call lineout ffsttgtfile, line1

   end /* do */
   call stream ffsttgtfile, 'C', 'CLOSE'
   call stream ffstsrcfile, 'C', 'CLOSE'

RETURN 0


/* BUILDPSNS */
/*
   Called by: Main
   Calls: write_rspfile
   Dependencies: tabledir cltdir psns_adsm psns_optical psns_lan
                   psns_tape psns_prm psns_remdrv
   File Dependencies: psnsdef.rsp
*/
/* This section will build the PSNS product response file */
BuildPSNS:

   psns_rsp_source = tabledir'\PSNSDEF.RSP'
   psns_rsp_target = cltdir'\PSNSCID.RSP'

/*   psns_target_path = PSNS_Drive'\PSNS'  */
   /* Read the file into the stem */
   i = 0
   do while lines(psns_rsp_source) > 0
      i = i + 1
      psnsrsp.i = linein(psns_rsp_source)
   end /* do */
   psnsrsp.0 = i
   call stream psns_rsp_source, 'C', 'CLOSE'

   /* Substitute the variables into the stem */
   do i = 1 to psnsrsp.0
      parse var psnsrsp.i kw '=' kwval
      select
         when translate(kw) = 'PSNS.INSTDRIVE' then do
            psnsrsp.i = kw' = 'PSNS_Drive
         end  /* Do */
         when translate(kw) = 'PSNS_OPTICAL.SELECTION' then do
            psnsrsp.i = kw' = 'PSNS_OPTICAL
         end  /* Do */
         when translate(kw) = 'PSNS_LAN.SELECTION' then do
            psnsrsp.i = kw' = 'PSNS_LAN
         end  /* Do */
        when translate(kw) = 'PSNS_TAPE.SELECTION' then do
           psnsrsp.i = kw' = 'PSNS_TAPE
        end  /* Do */
         when translate(kw) = 'PSNS_ADSM.SELECTION' then do
            psnsrsp.i = kw' = 'PSNS_ADSM
         end  /* Do */
        when translate(kw) = 'PSNS_PRM.SELECTION' then do
           psnsrsp.i = kw' = 'PSNS_PRM
        end  /* Do */
         when translate(kw) = 'PSNS_REMDRV.SELECTION' then do
            psnsrsp.i = kw' = 'PSNS_REMDRV
         end  /* Do */
       otherwise nop
      end  /* select */
   end /* do */

   /* Assign value to response file stem */
   do i = 1 to psnsrsp.0
      rspstem.i = psnsrsp.i
   end /* do */
   rspstem.0 = psnsrsp.0

  /* Write response file */
  call write_rspfile psns_rsp_target

RETURN 0


/* BUILDLDAP */
/*
   Called by: Main
   Calls: write_rspfile
   Dependencies: tabledir cltdir ldaptkfeature ldaptlkt ldapexamples
                   ldapdoc ldapjsupport ldapjdoc
   File Dependencies: ldapdef.rsp
*/
/* This section will build the LDAP product response file */
BuildLDAP:

   ldap_rsp_source = tabledir'\LDAPDEF.RSP'
   ldap_rsp_target = cltdir'\LDAPCID.RSP'

   /* Read the file into the stem */
   i = 0
   do while lines(ldap_rsp_source) > 0
      i = i + 1
      ldaprsp.i = linein(ldap_rsp_source)
   end /* do */
   ldaprsp.0 = i
   call stream ldap_rsp_source, 'C', 'CLOSE'

   /* Substitute the variables into the stem */
   do i = 1 to ldaprsp.0
      parse var ldaprsp.i kw '=' kwval
      select
         when translate(kw) = 'LDAP.INSTDRIVE' then do
            ldaprsp.i = kw' = 'LDAP_Drive
         end  /* Do */
         when translate(kw) = 'LDAP_TOOLKIT.SELECTION' then do
            ldaprsp.i = kw' = 'LDAPTlkt
         end  /* Do */
        when translate(kw) = 'LDAP_EXAMPLES.SELECTION' then do
           ldaprsp.i = kw' = 'LDAPExamples
        end  /* Do */
         when translate(kw) = 'LDAP_DOC.SELECTION' then do
            ldaprsp.i = kw' = 'LDAPDoc
        end  /* Do */
        when translate(kw) = 'JAVA_SUPPORT.SELECTION' then do
           ldaprsp.i = kw' = 'LDAPJSupport
        end  /* Do */
         when translate(kw) = 'JAVA_DOC.SELECTION' then do
            ldaprsp.i = kw' = 'LDAPJDoc
         end  /* Do */
       otherwise nop
      end  /* select */
   end /* do */

   /* Assign value to response file stem */
   do i = 1 to ldaprsp.0
      rspstem.i = ldaprsp.i
   end /* do */
   rspstem.0 = ldaprsp.0

  /* Write response file */
  call write_rspfile ldap_rsp_target

RETURN 0

/* BUILDPSF */
/*
  Called by: Main
  Calls: write_rspfile
  Dependencies: cltdir tabledir PSFdrive PSF_BaseFiles PSF_Resourcelib
                  PSF_ParallelAttachedDevices PSF_Transforms PSF_CoreFonts
                  PSF_CodedFonts PSF_240dpiFonts PSF_300dpiFonts
                  PSF_PSAAttachedDevices PSF_TCPIPAttachedDevices PSF_PostScript
  File Dependencies: psf.rsp
*/
BuildPSF:

   psf_rsp_source = tabledir'\PSF.RSP'
   psf_rsp_target = cltdir'\PSF.RSP'

   /* If it's already installed, we gotta go break it up... */
   if PSF_Installed then do
      call SysFileDelete PSF_Drive'\BASEPSF.PKG'
      call SysFileDelete PSF_Drive'\BASERES.PKG'
      call SysFileDelete PSF_Drive'\IBMCORE.PKG'
      call SysFileDelete PSF_Drive'\PARALLEL.PKG'
      call SysFileDelete PSF_Drive'\POSTSCRT.PKG'
      call SysFileDelete PSF_Drive'\PSF2SRV.PKG'
      call SysFileDelete PSF_Drive'\PSFISINC.PKG'
      call SysFileDelete PSF_Drive'\SAMPLES.PKG'
      call SysFileDelete PSF_Drive'\TCPIP.PKG'

      if maintenance then configsys = OS2_os2drive'\OS2\INSTALL\CONFIG._$$'
      else configsys = OS2_drive'\config.sys'
      ccnt = 0

      do while lines(configsys) > 0
         ccnt = ccnt + 1
         changepsf = 0
         line1 = linein(configsys)
         parse var line1 first'='last
         if translate(first) = 'SET DPATH' | translate(first) = 'SET PATH' | translate(first) = 'LIBPATH' | translate(first) = 'SET HELP' | translate(first) = 'SET BOOKSHELF' then changepsf = 1
         if changepsf then do
            do until pos('\PSF', last) = 0
               parse var last before'\PSF'.';'after
               last = left(before, length(before)-2)||after
            end /* do */
            line1 = first'='last
         end  /* Do */
         else if pos('\PSF2', translate(last)) > 0 | translate(first) = 'SET AINLANGUAGE' | translate(first) = 'SET AINUPTIMER' then line1 = 'REM 'line1
         csys.ccnt = line1
      end /* do */
      call stream configsys, 'C', 'CLOSE'
      call SysFileDelete configsys
      do i = 1 to ccnt
         call lineout configsys, csys.i
      end /* do */
      call stream configsys, 'C', 'CLOSE'
   end  /* Do */

   /* Read the file into the stem */
   i = 0
   do while lines(psf_rsp_source) > 0
      i = i + 1
      psfrsp.i = linein(psf_rsp_source)
   end /* do */
   psfrsp.0 = i
   call stream psf_rsp_source, 'C', 'CLOSE'

   /* Substitute the variables into the stem */
   do i = 1 to psfrsp.0
      parse upper var psfrsp.i kw'='kwval
      if pos('TGTDRIVE', kwval) > 0 then do
         psfrsp.i = kw'='PSF_Drive
      end  /* Do */
      else if pos('CDDRIVE', kwval) > 0 then do
         psfrsp.i = kw'='CD_Drive'\CID\SERVER\PSF2'
      end  /* Do */
      else if pos('PSF/2 SERVER - BASE FILES', kwval) >0 then do
         if \ PSF_BaseFiles then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
      else if pos('RESOURCE LIBRARY' ,kwval) > 0 then do
         if \ PSF_ResourceLib then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
      else if pos('PARALLEL ATTACHED DEVICES' ,kwval) > 0 then do
         if \ PSF_ParallelAttachedDevices then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
      else if pos('TRANSFORMS' ,kwval) > 0 then do
         if \ PSF_Transforms then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
      else if pos('CODEDFONTS' ,kwval) > 0 then do
         if \ PSF_CodedFonts then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
      else if pos('300 DPI COMPATABILITY FONTS' ,kwval) > 0 then do
         if \ PSF_300dpiFonts then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
      else if pos('POSTSCRIPT' ,kwval) > 0 then do
         if \ PSF_PostScript then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
      else if pos('TCP/IP ATTACHED DEVICES' ,kwval) > 0 then do
         if \ PSF_TCPIPAttachedDevices then psfrsp.i = '* ' || psfrsp.i
      end  /* Do */
   end /* do */

   /* Assign value to response file stem */
   do i = 1 to psfrsp.0
      rspstem.i = psfrsp.i
   end /* do */
   rspstem.0 = psfrsp.0

  /* Write response file */
  call write_rspfile psf_rsp_target

RETURN 0

/* BUILDLCFAGENT */
/*
   Called by: Main
   Calls: write_rspfile
   Dependencies: tabledir cltdir l   File Dependencies: lcfagent.rsp */
/* This section will build the LCF Agent product response file       */
/* The poduct is developed by Tivoli, and it is know by many         */
/* names:  LCF, TME 10, TMA 10, Common Agent and more.               */
/* I have used LCF for consistancy.                                  */
BuildLCFAGENT:

   lcf_rsp_source = tabledir'\LCFAGENT.RSP'
   lcf_rsp_target = cltdir'\LCFAGENT.RSP'

   /* Read the file into the stem */
   i = 0
   do while lines(lcf_rsp_source) > 0
      i = i + 1
      lcfrsp.i = linein(lcf_rsp_source)
   end /* do */
   lcfrsp.0 = i
   call stream lcf_rsp_source, 'C', 'CLOSE'

   /* Substitute the variables into the stem */
   do i = 1 to lcfrsp.0
      parse var lcfrsp.i kw '=' kwval
      select
         when translate(kw) = 'FILE' then do
            lcfrsp.i = kw' = 'LCF_Drive'\TIVOLI\LCF'
         end  /* Do */
         when translate(kw) = 'GPORT' then do
            lcfrsp.i = kw' = 'LCF_GPort
         end  /* Do */
         when translate(kw) = 'LPORT' then do
            lcfrsp.i = kw' = 'LCF_LPort
         end  /* Do */
        when translate(kw) = 'OPTIONS' then do
           lcfrsp.i = kw' = 'LCF_Options
        end  /* Do */
       otherwise nop
      end  /* select */
   end /* do */

   /* Assign value to response file stem */
   do i = 1 to lcfrsp.0
      rspstem.i = lcfrsp.i
   end /* do */
   rspstem.0 = lcfrsp.0

  /* Write response file */
  call write_rspfile lcf_rsp_target

RETURN 0

/* BUILDHPFS386 */
/*
    Called by: Main
    Calls: none
    Dependencies:
*/
/* Build HPFS386 response file */

BuildFS386:

   FS386rspsrc = tabledir'\FS386DEF.RSP'
   FS386rspfile = cltdir'\FS386CID.RSP'

   /* error in FI which causes problems in removing HPFS386 if the base */
   /* apps has been installed more than once.  This is a workaround     */
   /* to try to avoid that problem.  The customer must uninstall HPFS386 */
   /* before they can reinstall the base applications through Topinstall.*/

   if pos('HPFS386', Previous_Products) > 0 then
           Install386HPFS=0

   /* Read the file into a stem */
   i = 0
   do while lines(FS386rspsrc) > 0
      i = i + 1
      fs386rsp.i = linein(FS386rspsrc)
     parse var fs386rsp.i kw '=' kwval
     select
        when translate(kw) = 'WKSTADETERMINESCACHESIZE.SELECTION' then do
           fs386rsp.i = 'WkStaDeterminesCacheSize.Selection = 'HPFS386_WSDetermineCacheSize
        end  /* Do */
        when translate(kw) = 'WKSTADETERMINESHEAPSIZE.SELECTION' then do
           fs386rsp.i = 'WkStaDeterminesHeapSize.Selection = 'HPFS386_WSDetermineHeapSize
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.CONFIG386CACHE' then do
           fs386rsp.i = 'HPFS386_TOP.Config386Cache = 'HPFS386_Cache
        end  /* Do */
        when translate(kw) = 'CONFIGLAZYWRITE.SELECTION' then do
           if HPFS386_LazyWrite \='' then fs386rsp.i = 'ConfigLazyWrite.Selection = 'HPFS386_LazyWrite
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.CONFIGHEAP' then do
           fs386rsp.i = 'HPFS386_TOP.ConfigHeap = 'HPFS386_Heap
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.CONFIGMINBUFFERIDLE' then do
           if HPFS386_MinBufferIdle \='' then fs386rsp.i = 'HPFS386_TOP.ConfigMinBufferIdle = 'HPFS386_MinBufferIdle
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.CONFIGMAXCACHEAGE' then do
           if HPFS386_MaxCacheAge \='' then fs386rsp.i = 'HPFS386_TOP.ConfigMaxCacheAge = 'HPFS386_MaxCacheAge
        end  /* Do */
        when translate(kw) = 'INSTALL386HPFS.SELECTION' then do
           fs386rsp.i = 'Install386HPFS.Selection = ' Install386HPFS
        end  /* Do */
        when translate(kw) = 'INSTALLFAULTTOLERANCE.SELECTION' then do
           fs386rsp.i = 'InstallFaultTolerance.Selection = ' InstallFaultTolerance
        end  /* Do */
        when translate(kw) = 'INSTALLLOCALSECURITY.SELECTION' then do
            fs386rsp.i = 'InstallLocalSecurity.Selection = ' InstallLocalSecurity
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.ISINTEGRATEDINSTALL' then do
            if Integrated_Install = 1 then
                  fs386rsp.i = 'HPFS386_TOP.isIntegratedInstall = ' YES
            else if Integrated_Install = 0 then
                  fs386rsp.i = 'HPFS386_TOP.isIntegratedInstall = ' NO
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.CONFIGUSEALLMEM' then do
           if HPFS386_UseAllMem \='' then fs386rsp.i = 'HPFS386_TOP.ConfigUseAllMem = ' HPFS386_UseAllMem
        end  /*  Do */
        when translate(kw) = 'HPFS386_TOP.MEDIADRIVE' then do
            parse var CD_DRIVE CD_DRIVE0 ':'
            fs386rsp.i = 'HPFS386_TOP.MediaDrive = 'CD_DRIVE0
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.INSTALLDRIVE' then do
           fs386rsp.i = 'HPFS386_TOP.InstallDrive = ' HPFS386_DRIVE
        end  /* Do */
        when translate(kw) = 'HPFS386_TOP.LANDRV' then do
           fs386rsp.i = 'HPFS386_TOP.Landrv = ' LAN_Drive
        end  /* Do */
    otherwise nop
     end  /* select */
  end /* do */
   fs386rsp.0 = i
   call stream FS386rspsrc, 'C', 'CLOSE'

   do i = 1 to FS386rsp.0
      rspstem.i =FS386rsp.i
   end /* do */
   rspstem.0 = FS386rsp.0
   call write_rspfile FS386rspfile

RETURN 0

/* BUILDMPTS */
/*
    Called by: Main
    Calls: write_rspfile
    Dependencies: cltdir adapter.x lastadapter CD_Drive
    File Dependencies: \CID\NIFS\*
*/
/* This section will build the MPTS Response file */

BuildMPTS:

  mptsrspfile = cltdir'\MPTS.RSP'

  nifdir = CD_Drive'\CID\NIFS'
  /* See if the CD is in the drive */
  if stream(nifdir'\*', 'C', 'QUERY EXISTS') \= CD_Drive'\CID\NIFS\*' then do
     err1.1=sysgetmessage(16, msgfile, nifdir)
     err1.2=sysgetmessage(11, msgfile)
     call errout 16
  end  /* Do */

  otherdir = tabledir'\IBMCOM\MACS'

  do i = 1 to adapter.0

     parse var adapter.i . niffile

     /* Ensure that the driver exists for each of the adapters */
     /* if no nif then skip looking for it */
     if niffile = '' then iterate  /* c programming in Rexx */

     /* 1st check: "Other adapter" */
     nifpath = otherdir'\'niffile
     if stream(nifpath, 'C', 'QUERY EXISTS') = '' then do

        /* 2nd check: CD's \CID\NIFS directory */
        nifpath = nifdir'\'niffile
        if stream(nifpath, 'C', 'QUERY EXISTS') = '' then do

           /* 3rd: IBMCOM\MACS (e.g., LAN Distance NIF) */
           nifpath = MPTS_Drive'\IBMCOM\MACS\'niffile
           if stream(nifpath, 'C', 'QUERY EXISTS') = '' then do

              /* Error, we can't find the NIF File */
              err1.1=sysgetmessage(17, msgfile, niffile)
              err1.2=sysgetmessage(11, msgfile)
              call errout 17

           end /* Do */
        end /* Do */
     end  /* Do */

     /* Find the Driver name from the nif file */
     adapter.i.drivername = ''
     do while lines(nifpath) > 0 & adapter.i.drivername = ''
        line1 = linein(nifpath)
        parse upper var line1 kw'='kwval
        if strip(kw) = 'DRIVERNAME' then adapter.i.drivername = strip(kwval)
     end  /* Do */
     call stream nifpath, 'C', 'CLOSE'
  end /* do */

  otherdir = tabledir'\IBMCOM\PROTOCOL'

  do i = 1 to protocol.0
     niffile = strip(translate(protocol.i,'.','_'))

     /* If it isn't a valid nif section, ignore it */
     if pos('.NIF', translate(niffile)) = 0 then protocol.i.netbios = 0

     else do
        nifpath = otherdir'\'niffile
        if stream(nifpath, 'C', 'QUERY EXISTS') = '' then do

           /* Determine if the protocol file exists in the default nif directory. */
           nifpath = nifdir'\'niffile
           if stream(nifpath, 'C', 'QUERY EXISTS') = '' then do

              nifpath = MPTS_Drive'\IBMCOM\PROTOCOL\'niffile
              if stream(nifpath, 'C', 'QUERY EXISTS') = '' then do
                 /* Error, we can't find the NIF File */
                 err1.1=sysgetmessage(17, msgfile, niffile)
                 err1.2=sysgetmessage(11, msgfile)
                 call errout 17
              end /* Do */
           end /* Do */
        end  /* Do */
        /* Find the Driver name from the nif file and determine if it's a
            NetBIOS protocol */
        protocol.i.drivername = ''; protocol.i.netbios = ''
        do while lines(nifpath) > 0
           line1 = linein(nifpath)
           parse upper var line1 kw'='kwval
           if strip(kw) = 'DRIVERNAME' then protocol.i.drivername = strip(kwval)
           else if strip(kw) = 'NAME' then do
              if pos('NETBIOS.OS2', kwval) > 0 then protocol.i.netbios = 1
              else protocol.i.netbios = 0
           end  /* Do */
        end  /* Do */
        call stream nifpath, 'C', 'CLOSE'
     end /* do */
  end /* do */

  mptslevel = 0

  /* Check for the current level of MPTS on the system */
  syslevelfile = stream(MPTS_Drive'\IBMCOM\SYSLEVEL.TRP', 'C', 'query exists')
  if syslevelfile \= '' then do
     call QuerySingleSyslevel syslevelfile, "syslevelstem"
     mptslevel = syslevelstem.1.MajorVersion||'.'||syslevelstem.1.MinorVersion
  end  /* Do */

  bootfile = cltdir'\REBOOT.FIL'
  call sysfiledelete bootfile

  /* If we're just building response files, force the installation */
  if rsp_indicator \= '' then
     mptslevel = 1.0

  /* If we're not at the current MPTS level, then add the install section */
  currmptslevel = 6.01
  if mptslevel < currmptslevel then do
     /* Header section */
     mptsrsp.1 = "INST_SECTION = ("
     mptsrsp.2 = "  UPGRADE_LEVEL = SAME"
     mptsrsp.3 = "  INSTALL = PRODUCT"
     mptsrsp.4 = ")"
     mptsrsp.5 = ""
     lc = 6
  end
  else do
     lc = 1
     if Integrated_Install = 0 then do
        call lineout bootfile, "DON'T REBOOT!!!!"
        call stream bootfile, 'C', 'CLOSE'
     end /* If \Integrated_Install */
  end  /* Do */

  /* Indeces for 802.2 and ODI2NDI protocols. */
  odi_index = 0; landd_index = 0; tcpip_installed = 0

  /* Determine the protocol indeces */
  do i = 1 to protocol.0
     if translate(protocol.i) = 'ODI2NDI_NIF' then odi_index = i
     else if translate(protocol.i) = 'LANDD_NIF' then landd_index = i
     else if translate(protocol.i) = 'TCPIP_NIF' then tcpip_installed = 1
  end /* do */

  /* If we're installing ODI2NDI, we need to add the appropriate bindings to
      802.2.  Only if we're installing NetWare... */
  if odi_index > 0 & pos('NW', translate(products)) > 0 then do

     /* Set this variable so that the landd stuff that's added can be removed. */
     original_landd = ''; original_landd_netaddress = ''

     /* Setup a comment line to contain a mapping of the bindings for 802.2 to
         the same adapters in ODI2NDI */
     odi2ndi_mappings_commentline = ';ODIMAPPINGS ='

     /* If we're deleting ODI2NDI, don't worry about it */
     if strip(protocol.odi_index.changes) = 'DELETE_PROTOCOL' then nop

     else do

        /* We need to determine what the bindings are for odi2ndi.  We'll then put the
           netaddress lines in 802.2 section.  We need to handle the case of what happens
           when there is no netaddress line in the 802.2 or odi2ndi sections */

        odi_address_line = ''
        do i = 1 to protocol.odi_index.0
           parse upper var protocol.odi_index.i kw'='kwval
           if strip(translate(kw)) = 'BINDINGS' then odibound = strip(kwval)
           else if strip(translate(kw)) = 'NETADDRESS' then odi_address_line = strip(kwval)
        end /* do */

        /* If there is no 802.2, then create a section with the appropriate bindings */
        if landd_index = 0 then do
           mptsrsp.lc = "PROT_SECTION = ("
           lc = lc+1
           mptsrsp.lc = "  NIF = LANDD.NIF"
           lc = lc+1
           mptsrsp.lc = "  SECTION_name = LANDD_NIF"
           lc = lc+1
           mptsrsp.lc = "  BINDINGS = "odibound
           lc = lc + 1

           /* Add the netaddress line from the ODI2NDI section so we don't get boot errors
              with mismatched addressed */
           if odi_address_line \= '' then do
              mptsrsp.lc = "  NETADDRESS = "odi_address_line
              lc = lc + 1
           end  /* Do */

           mptsrsp.lc = ")"
           lc = lc+1
           mptsrsp.lc = ""
           lc = lc + 1
        end  /* Do */

        /* If it there is an 802.2 section, insert or append the settings and then
            create a map to the bindings and netaddress if it exists. */
        else do

           landd_netaddress_index = 0

           /* Find the bindings and netaddress lines for 802.2 */
           do i = 1 to protocol.landd_index.0

              parse upper var protocol.landd_index.i kw'='kwval

              if strip(translate(kw)) = 'BINDINGS' then do
                 original_landd = strip(kwval)
                 landd_bindings_index = i
              end /* do */

              if strip(translate(kw)) = 'NETADDRESS' then do
                 original_landd_netaddress = strip(kwval)
                 landd_netaddress_index = i
              end  /* Do */

           end /* do */

           /* If 802.2 doesn't have a netaddress line, but odi2ndi does, add the one to 802.2 */
           if landd_netaddress_index = 0 & odi_address_line \= '' then do
              tmplastval = protocol.landd_index.0 + 1
              protocol.landd_index.0 = tmplastval
              protocol.landd_index.tmplastval = odi_address_line
              landd_netaddress_index = tmplastval
           end  /* Do */

           /* If they both have netaddress lines, need to merge in the odi_address_line */
           else if landd_netaddress_index > 0 & odi_address_line \= '' then do
              parse var protocol.landd_index.landd_netaddress_index . '=' kwval
              call build_protocol_line_stem kwval tmplanddaddr
              call build_protocol_line_stem odi_address_line tmpodi2ndiaddr
              do i = 1 to tmpodi2ndiaddr.0
                 if tmpodi2ndiaddr.i \= '' then tmplanddaddr.i = tmpodi2ndiaddr.i
              end /* do */
              if tmpodi2ndiaddr.0 > tmplanddaddr.0 then tmplanddaddr.0 = tmpodi2ndiaddr.0
              call build_protocol_line_string tmplanddaddr tmpline
              protocol.landd_index.landd_netaddress_index = 'NETADDRESS=' tmpline
           end  /* Do */


           /* Find the logical adapter number associated with each adapter */
           numcommas = 0;  numadaps = 0; characters = ''
           do i = 1 to length(odibound)
              tmpchar = substr(odibound, i, 1)
              if tmpchar = ',' then do
                 numcommas = numcommas + 1
                 if characters \= '' then do
                    numadaps = numadaps + 1
                    odilist.numadaps = characters||':'||numcommas -1
                    characters = ''
                 end  /* Do */
              end
              else characters = characters||tmpchar
           end /* do */

           numadaps = numadaps + 1
           odilist.numadaps = characters||':'||numcommas
           odilist.0 = numadaps

           /* Create stem to contain all possible logical adapter numbers */
           do j = 0 to 63
              landd.j = ''
           end /* do */

           /* Find the logical adapter number associated with each adapter for 802.2 */
           numcommas = 0;  numadaps = 0; characters = ''
           do i = 1 to length(original_landd)
              tmpchar = substr(original_landd, i, 1)
              if tmpchar = ',' then do
                 numcommas = numcommas + 1
                 if characters \= '' then do
                    numadaps = numadaps + 1
                    commacount = numcommas -1
                    landdlist.numadaps = characters||':'||commacount
                    landd.commacount = characters
                    characters = ''
                 end  /* Do */
              end
              else characters = characters||tmpchar
           end /* do */
           numadaps = numadaps + 1
           landdlist.numadaps = characters||':'||numcommas
           landdlist.0 = numadaps
           landd.numcommas = characters

           do i = 1 to odilist.0
              parse var odilist.i odidriver':'odibindnumber
              foundit = 0
              do j = 1 to landdlist.0
                 parse var landdlist.j landddriver':'landdbindnumber
                 if translate(odidriver) = translate(landddriver) then do
                    foundit = j
                    j = landdlist.0
                 end  /* Do */
              end /* do */
              if foundit > 0 then odi2ndi_mappings_commentline = odi2ndi_mappings_commentline || odibindnumber':'landdbindnumber' '
              else do
                 if landd.odibindnumber = '' then do
                    landd.odibindnumber = odilist.i
                    odi2ndi_mappings_commentline = odi2ndi_mappings_commentline || odibindnumber':'odibindnumber' '
                    landdbindnumber = odibindnumber
                 end
                 else do j = 0 to 63
                    if landd.j = '' then do
                       landd.j = odilist.i
                       odi2ndi_mappings_commentline = odi2ndi_mappings_commentline || odibindnumber':'j' '
                       landdbindnumber = j
                       j = 64
                    end /* do */
                 end /* do */
                 commacount = countem(protocol.landd_index.landd_bindings_index, ',')
                 /* Add the driver to the bindings line */
                 /* If necessary, add commas to the bindings line, then the driver */
                 if commacount < landdbindnumber then do
                    commas = copies(',', landdbindnumber-commacount)
                    protocol.landd_index.landd_bindings_index = protocol.landd_index.landd_bindings_index || commas || odidriver
                 end  /* Do */
                 /* Otherwise, insert the driver into the middle of the bindings stem */
                 else do
                    commapos = 0
                    do j = 1 to landdbindnumber
                       commapos = pos(',', protocol.landd_index.landd_bindings_index, commapos+1)
                    end /* Do */
                    if commapos = 0 then do
                       parse var protocol.landd_index.landd_bindings_index kw'='kwval
                       kwval = odidriver||kwval
                       protocol.landd_index.landd_bindings_index = kw ' = ' kwval
                    end
                    else
                       protocol.landd_index.landd_bindings_index = insert(odidriver, protocol.landd_index.landd_bindings_index, commapos)
                 end  /* Do */
              end  /* Do */
           end /* do */
        end  /* Do */

        /* We'll need a re-boot now to go read the addresses from the lantran.log */
        call SysFileDelete bootfile

     end  /* Do */
  end  /* Do */


  /* Protocol prot sections */
  do i = 1 to protocol.0
     if pos('_NIF', translate(protocol.i)) = 0 then iterate
     /* If the protocol is to be deleted, add the delete_sect keyword */
     if pos('DELETE_PROTOCOL', protocol.i.changes) > 0 then do
        mptsrsp.lc = 'PROT_SECTION = ('
        lc = lc + 1
        mptsrsp.lc = '  delete_sect'
        lc = lc + 1
        mptsrsp.lc = '  section_name = 'protocol.i
        lc = lc + 1
        mptsrsp.lc = ')'
        lc = lc + 1
        mptsrsp.lc = ''
        lc = lc + 1
     end  /* Do */
     else if strip(translate(protocol.i)) = 'ODI2NDI_NIF' then nop
     else if strip(translate(protocol.i)) = 'IPXNB_NIF' then nbipx_exists = 1
     else do
        /* If not, create the prot section header, then add the settings */
        mptsrsp.lc = "PROT_SECTION = ("
        lc = lc+1
        /* Now add the settings */
        do j = 1 to protocol.i.0
            mptsrsp.lc = "  "||protocol.i.j
            lc = lc + 1
        end /* do */
        mptsrsp.lc = ")"
        lc = lc+1
        mptsrsp.lc = ""
        lc = lc + 1
     end  /* Do */
  end /* do */

  firstnb = 1

  do i = 1 to protocol.0
     if pos('DELETE_PROTOCOL', protocol.i.changes) > 0 then iterate
     if translate(protocol.i) = 'IPXNB_NIF' then iterate
     if protocol.i.netbios then do
        if firstnb then do
           firstnb = 0
           mptsrsp.lc = "PROT_NETBIOS = ("
           lc = lc+1
           mptsrsp.lc = "  SECTION_NAME = NETBIOS"
           lc = lc+1
           mptsrsp.lc = "  DRIVERNAME = NETBIOS$"
           lc = lc + 1
        end  /* Do */
        do j = 1 to protocol.i.0
           parse upper var protocol.i.j kw'='kwval
           kwval = strip(kwval)
           if strip(kw) = 'BINDINGS' then do
             commacount = 0
             do while length(kwval) > 0
                nextcomma = pos(',',kwval)
                if nextcomma = 0 then do
                   kwval = ''
                   mptsrsp.lc = '  ADAPTER'commacount' = 'protocol.i.drivername','commacount
                   lc = lc + 1
                end  /* Do */
                else do
                   first = left(kwval, nextcomma)
                   kwval = substr(kwval, nextcomma+1)
                   if length(first) > 1 then do
                      mptsrsp.lc = '  ADAPTER'commacount' = 'protocol.i.drivername','commacount
                      lc = lc + 1
                   end  /* Do */
                end /* do */
                commacount = commacount + 1
             end /* do */
           end /* do */
        end /* do */
     end  /* Do */
  end /* do */

  if firstnb = 0 then do
     mptsrsp.lc = ')'
     lc = lc + 1
     mptsrsp.lc = ''
     lc = lc + 1
  end  /* Do */

  /* Write the adapter prot sections */
  do i = 1 to adapter.0
     if pos('DELETE_ADAPTER', translate(adapter.i.changes)) > 0 then do
        mptsrsp.lc = 'PROT_SECTION = ('
        lc = lc + 1
        mptsrsp.lc = '  delete_sect'
        lc = lc + 1
        parse var adapter.i section_name .
        mptsrsp.lc = '  section_name = 'section_name
        lc = lc + 1
        mptsrsp.lc = ')'
        lc = lc + 1
        mptsrsp.lc = ''
        lc = lc + 1
     end  /* Do */
     else do
        parse var adapter.i adapsec_name nifname
        if strip(nifname) \= '' then do
           mptsrsp.lc ="PROT_SECTION = ("
           lc = lc+1
           /* Add the adapter settings */
           do j = 1 to adapter.i.0
              parse var adapter.i.j kw'='kwval
              mptsrsp.lc = "  "||adapter.i.j
              lc = lc + 1
           end /* do */
           mptsrsp.lc =")"
           lc = lc+1
           mptsrsp.lc =""
           lc = lc + 1
        end /* do */
     end /* write prot_section */
  end /* do */

  confginifile = MPTS_Drive'\mptn\bin\mptconfg.ini'
  mptnsetupfile = MPTS_Drive'\mptn\bin\setup.cmd'

  ipcvar = "YES"; inetvar = "YES"; nbaccvar = "NO"

  /* If the setup.cmd file doesn't exist, then we'll create it.  If it does
     exist, don' write over it, because we'll use the TCP/IP response file
     to do what we need to do */

  if stream(mptnsetupfile, 'C', 'QUERY EXISTS') \= '' then
     inetvar = 'NO'

  /* If there is no TCP/IP address and DHCP is not configured then don't
     write the setup.cmd file */
  if TCPIP_IPAddress = '' & TCPIP_DHCP = 0 then
     inetvar = 'NO'


  /* If the mptconfg.ini file doesn't exist and TCP/IP is being installed,
      create the file via the MPTS section */

  if stream(confginifile, 'C', 'QUERY EXISTS') = '' & tcpip_installed then do
     mptsrsp.lc = "MPTS = ("
     lc = lc + 1
     mptsrsp.lc = "   [CONTROL]"
     lc = lc + 1
     mptsrsp.lc = "       Local_IPC = "ipcvar
     lc = lc + 1
     mptsrsp.lc = "       INET_Access = "inetvar
     lc = lc + 1
     mptsrsp.lc = "       NETBIOS_Access = "nbaccvar
     lc = lc + 1
     mptsrsp.lc = ""
     lc = lc + 1

     /* If there is a TCP/IP address, or we need to configure DHCP, then write this section */
     if TCPIP_IPAddress \= '' | TCPIP_DHCP then do
        mptsrsp.lc = "   [IFCONFIG] "
        lc = lc + 1
        mptsrsp.lc = "       Interface      = 0"
        lc = lc + 1
        mptsrsp.lc = "       Address        = "TCPIP_IPAddress
        lc = lc + 1
        mptsrsp.lc = "       Brdcast        = "
        lc = lc + 1
        mptsrsp.lc = "       Dest           = "
        lc = lc + 1
        mptsrsp.lc = "       Enable         = UP "
        lc = lc + 1
        mptsrsp.lc = "       Netmask        =  "TCPIP_SubNetMask
        lc = lc + 1
        mptsrsp.lc = "       Metric         = 0"
        lc = lc + 1
        mptsrsp.lc = "       Mtu            = 1500"
        lc = lc + 1
        mptsrsp.lc = "       Trailers       = NO "
        lc = lc + 1
        mptsrsp.lc = "       Arp            = NO "
        lc = lc + 1
        mptsrsp.lc = "       Bridge         = NO "
        lc = lc + 1
        mptsrsp.lc = "       Snap           = NO "
        lc = lc + 1
        mptsrsp.lc = "       Allrs          = NO "
        lc = lc + 1
        mptsrsp.lc = "       802.3          = NO "
        lc = lc + 1
        mptsrsp.lc = "       Icmpred        = NO "
        lc = lc + 1
        mptsrsp.lc = "       Canonical      = NO "
        lc = lc + 1
        if TCPIP_DHCP then last = 'YES'
        else  last = 'NO'
        mptsrsp.lc = "       EnableDhcp     = "last
        lc = lc + 1
        mptsrsp.lc = ""
        lc = lc + 1
     end /* If ipaddress */

     /* If we're using DHCP, then add this section */
     if TCPIP_DHCP then do
        mptsrsp.lc = "   [DHCP]"
        lc = lc + 1
        mptsrsp.lc = "       Adapter = 0"
        lc = lc + 1
        mptsrsp.lc = "       ClientID       = MAC"
        lc = lc + 1
        if TCPIP_DDNS then last = 'YES'
        else  last = 'NO'
        mptsrsp.lc = "       DDNS = "last
        lc = lc + 1
        mptsrsp.lc = "       NumLogFiles    = 0"
        lc = lc + 1
        mptsrsp.lc = "       LogFileSize    = 0"
        lc = lc + 1
        mptsrsp.lc = "       LogFileName    = "
        lc = lc + 1
        mptsrsp.lc = "       SYSERR         = NO "
        lc = lc + 1
        mptsrsp.lc = "       OBJERR         = NO "
        lc = lc + 1
        mptsrsp.lc = "       PROTERR        = NO "
        lc = lc + 1
        mptsrsp.lc = "       WARNING        = NO "
        lc = lc + 1
        mptsrsp.lc = "       EVENT          = NO "
        lc = lc + 1
        mptsrsp.lc = "       ACTION         = NO "
        lc = lc + 1
        mptsrsp.lc = "       INFO           = NO "
        lc = lc + 1
        mptsrsp.lc = "       ACNTING        = NO "
        lc = lc + 1
        mptsrsp.lc = "       TRACE          = NO "
        lc = lc + 1
        mptsrsp.lc = ""
        lc = lc + 1
     end

     if TCPIP_Router \= '' then do
        mptsrsp.lc = "   [ROUTE]"
        lc = lc + 1
        mptsrsp.lc = "       Type           = default"
        lc = lc + 1
        mptsrsp.lc = "       Action         = add"
        lc = lc + 1
        mptsrsp.lc = "       Dest           = "
        lc = lc + 1
        mptsrsp.lc = "       Router         = "TCPIP_Router
        lc = lc + 1
        mptsrsp.lc = "       Metric         = 1"
        lc = lc + 1
     end /* If router */

  end /* If mptconfg.ini does not exist */

  /* If the mptconfg.ini file does exist, we need to read it and incorporate our settings into it */
  else do

     /* Read the mptconfg.ini into a stem */
     i = 0
     do while lines(confginifile)
         i = i + 1
         mptcfg.i = linein(confginifile)
     end /* do */
     mptcfg.0 = i

     /* Put the header on */
     mptsrsp.lc = "MPTS = ("
     lc = lc + 1

     /* Read the config file, putting all the entries in their correct position */
     found_dhcp = 0; found_route = 0; found_ifconfig = 0; found_control = 0

     do i = 1 to mptcfg.0
        parse var mptcfg.i kw'='kwal','last

        /* We're only concered with the first adapter... */
        if last \= '' then last = ','last

        /* Only overwrite the address, netmask or router if we're installing TCP/IP, otherwise we
            might overwrite a valid address with blanks... */
        if strip(translate(kw)) = 'ADDRESS' & (pos('TCPIP', products_to_install) > 0) then mptcfg.i = kw'= 'TCPIP_IPAddress || last
        else if strip(translate(kw)) = 'NETMASK' & (pos('TCPIP', products_to_install) > 0) then mptcfg.i = kw'= 'TCPIP_SubNetMask || last
        else if strip(translate(kw)) = 'ROUTER' & (pos('TCPIP', products_to_install) > 0) then mptcfg.i = kw'= 'TCPIP_Router || last

        /* Update entries for DHCP  & DDNS */
        else if strip(translate(kw)) = 'ENABLEDHCP' & TCPIP_DHCP then mptcfg.i = kw'= YES' || last
        else if strip(translate(kw)) = 'DDNS' & TCPIP_DDNS then mptcfg.i = kw'= YES' || last

        /* See if there are sections we need to add */
        else if strip(translate(kw)) = '[CONTROL]' then found_control = 1
        else if strip(translate(kw)) = '[IFCONFIG]' then found_ifconfig = 1
        else if strip(translate(kw)) = '[DHCP]' then found_dhcp = 1
        else if strip(translate(kw)) = '[ROUTE]' then found_route = 1

        mptsrsp.lc = mptcfg.i
        lc = lc + 1

     end /* do */

     if \ found_control then do
        mptsrsp.lc = "   [CONTROL]"
        lc = lc + 1
        mptsrsp.lc = "       Local_IPC = "ipcvar
        lc = lc + 1
        mptsrsp.lc = "       INET_Access = "inetvar
        lc = lc + 1
        mptsrsp.lc = "       NETBIOS_Access = "nbaccvar
        lc = lc + 1
        mptsrsp.lc = ""
        lc = lc + 1
     end  /* Do */

     if \ found_ifconfig & (TCPIP_IPAddress \= '' | TCPIP_DHCP) then do
        mptsrsp.lc = "   [IFCONFIG] "
        lc = lc + 1
        mptsrsp.lc = "       Interface      = 0"
        lc = lc + 1
        mptsrsp.lc = "       Address        = "TCPIP_IPAddress
        lc = lc + 1
        mptsrsp.lc = "       Brdcast        = "
        lc = lc + 1
        mptsrsp.lc = "       Dest           = "
        lc = lc + 1
        mptsrsp.lc = "       Enable         = UP "
        lc = lc + 1
        mptsrsp.lc = "       Netmask        =  "TCPIP_SubNetMask
        lc = lc + 1
        mptsrsp.lc = "       Metric         = 0"
        lc = lc + 1
        mptsrsp.lc = "       Mtu            = 1500"
        lc = lc + 1
        mptsrsp.lc = "       Trailers       = NO "
        lc = lc + 1
        mptsrsp.lc = "       Arp            = NO "
        lc = lc + 1
        mptsrsp.lc = "       Bridge         = NO "
        lc = lc + 1
        mptsrsp.lc = "       Snap           = NO "
        lc = lc + 1
        mptsrsp.lc = "       Allrs          = NO "
        lc = lc + 1
        mptsrsp.lc = "       802.3          = NO "
        lc = lc + 1
        mptsrsp.lc = "       Icmpred        = NO "
        lc = lc + 1
        mptsrsp.lc = "       Canonical      = NO "
        lc = lc + 1
        if TCPIP_DHCP then last = 'YES'
        else  last = 'NO'
        mptsrsp.lc = "       EnableDhcp     = "last
        lc = lc + 1
        mptsrsp.lc = ""
        lc = lc + 1
     end  /* Do */

     if \ found_dhcp & TCPIP_DHCP then do
        mptsrsp.lc = "   [DHCP]"
        lc = lc + 1
        mptsrsp.lc = "       Adapter = 0"
        lc = lc + 1
        mptsrsp.lc = "       ClientID       = MAC"
        lc = lc + 1
        if TCPIP_DDNS then last = 'YES'
        else  last = 'NO'
        mptsrsp.lc = "       DDNS = "last
        lc = lc + 1
        mptsrsp.lc = "       NumLogFiles    = 0"
        lc = lc + 1
        mptsrsp.lc = "       LogFileSize    = 0"
        lc = lc + 1
        mptsrsp.lc = "       LogFileName    = "
        lc = lc + 1
        mptsrsp.lc = "       SYSERR         = NO "
        lc = lc + 1
        mptsrsp.lc = "       OBJERR         = NO "
        lc = lc + 1
        mptsrsp.lc = "       PROTERR        = NO "
        lc = lc + 1
        mptsrsp.lc = "       WARNING        = NO "
        lc = lc + 1
        mptsrsp.lc = "       EVENT          = NO "
        lc = lc + 1
        mptsrsp.lc = "       ACTION         = NO "
        lc = lc + 1
        mptsrsp.lc = "       INFO           = NO "
        lc = lc + 1
        mptsrsp.lc = "       ACNTING        = NO "
        lc = lc + 1
        mptsrsp.lc = "       TRACE          = NO "
        lc = lc + 1
        mptsrsp.lc = ""
        lc = lc + 1
     end  /* Do */

     if \ found_route & TCPIP_Router \= '' then do
        mptsrsp.lc = "   [ROUTE]"
        lc = lc + 1
        mptsrsp.lc = "       Type           = default"
        lc = lc + 1
        mptsrsp.lc = "       Action         = add"
        lc = lc + 1
        mptsrsp.lc = "       Dest           = "
        lc = lc + 1
        mptsrsp.lc = "       Router         = "TCPIP_Router
        lc = lc + 1
        mptsrsp.lc = "       Metric         = 1"
        lc = lc + 1
     end  /* Do */

  end  /* Do */

  mptsrsp.lc = ')'

  mptsrsp.0 = lc

  if strip(translate(CD_Drive)) = 'Z:' then do

     /* If we're in the remote case, verify that we have a NetBIOS protocol */
     found_nb = 0
     do i = 1 to protocol.0
        if protocol.i.netbios then do
          if pos(remote_protocol, translate(protocol.i)) then
             found_nb = 1
        end  /* Do */
     end /* do */

     /* If there is no NetBEUI or TCPBEUI section, add one */
     if \ found_nb then do

        parse var adapter.1 adapname .

        lc = lc + 1
        mptsrsp.lc = ''
        lc = lc + 1
        mptsrsp.lc = 'PROT_SECTION = ('
        lc = lc + 1
        mptsrsp.lc = '  SECTION_NAME = 'remote_protocol || '_NIF'
        lc = lc + 1
        mptsrsp.lc = '  NIF = 'remote_protocol || '.NIF'
        lc = lc + 1
        mptsrsp.lc = '  BINDINGS = 'adapname
        lc = lc + 1
        mptsrsp.lc = ')'

        mptsrsp.0 = lc

        rmvnbrsp = cltdir'\RMVNB.RSP'

        if stream(rmvnbrsp, 'C', 'QUERY EXISTS') \= '' then
           call SysFileDelete rmvnbrsp

        call lineout rmvnbrsp, 'PROT_SECTION = ('
        call lineout rmvnbrsp, '  delete_sect'
        call lineout rmvnbrsp, '  SECTION_NAME = 'remote_protocol || '_NIF'
        call lineout rmvnbrsp, ')'
        call lineout rmvnbrsp

        /* Remove NetBEUI */
        rmv_nb = 1

     end /* do */

  end /* do */

  /* Copy unsupported adapter stuff to it's proper place */
  call SysFileTree tabledir'\IBMCOM\*.*', 'nifs', 'FOS'

  if nifs.0 > 0 then
     '@xcopy ' tabledir'\IBMCOM\* 'MPTS_Drive'\IBMCOM\ /S /E >nul 2>nul'

  /* Write stem to response file stem */
   do i = 1 to mptsrsp.0
      rspstem.i = mptsrsp.i
   end /* do */
   rspstem.0 = mptsrsp.0

  /* Write the response file */
   call write_rspfile mptsrspfile

RETURN 0

/* WRITE_RSPFILE */
/*
    Called by: BuildMPTS, BuildTCPIP, BuildLDR, BuildKarat, Main
    Calls: None
    Dependencies: rspstem.
*/
/* Write the Response File with the response file that is passed, using
    the stem that is created before the response file is called. */

write_rspfile:
  parse arg rspfilename
  if stream(rspfilename, 'C', 'QUERY EXISTS') \= '' then call sysfiledelete(rspfilename)
  do i = 1 to rspstem.0
     rc = lineout(rspfilename, rspstem.i)
     if rc \= 0 then do
        err1.1 = sysgetmessage(18, msgfile, rspfilename)
        err1.2 = SysGetMessage(11, msgfile)
        call errout 18
     end  /* Do */
  end /* do */
  call stream rspfilename, 'C', 'CLOSE'

RETURN 0

/* COUNTEM */
/*
    Called by:
    Calls: None
    Dependencies: None
*/
/* Count the number of objects in the target */
countem:

  parse arg target, object

  index1 = 1; countit = 0; foundit = ''
  do while foundit \= 0
    foundit = POS(object, target, index1)
    if foundit \= 0 then do
       countit = countit + 1
       index1 = foundit + 1
    end  /* Do */
  end /* do */

RETURN countit

/* PROCESS_LCU_FILE */
/*
    Called by: Main
    Calls: None
    Dependencies: tabledir cltdir CD_Drive OS2_Drive MPTS_Drive ibminstdrive
                    products_to_install Integrated_Install
*/
/* Modify the LCU_file */
process_LCU_file:

  LCU_src_file = tabledir'\LCUDRVR.FIL'
  LCU_file = cltdir'\'client'.cmd'

  if stream(LCU_file, 'C', 'QUERY EXISTS') \= '' then call SysFileDelete(LCU_file)

  /* Write out the LCU file, adding in the install specific info. */
  do while lines(LCU_src_file) > 0
     line1 = linein(LCU_src_file)
     if strip(line1) = '/* Start Drive Variables section */' then do
        call lineout LCU_file, line1
        call lineout LCU_file, 'CD_Drive = "'CD_Drive'"'
        call lineout LCU_file, 'bootdrive = "'OS2_Drive'"'
        call lineout LCU_file, 'MPTS_Drive = "'MPTS_Drive'"'
        call lineout LCU_file, 'LAN_Drive = "'LAN_Drive'"'
        call lineout LCU_file, 'ibminstdrive = "'ibminstdrive'"'
        call lineout LCU_file, 'products_to_install = "'products_to_install'"'
        call lineout LCU_file, 'integrate = "'Integrated_Install'"'
        call lineout LCU_file, 'Deltasize = "'Deltasize'"'
        call lineout LCU_file, 'rmv_nb = 'rmv_nb


/*        if PSNS_Drive \= '' then
          call lineout LCU_file, 'psnstgtpath = "'psns_target_path'"'

        if TCPIP_Drive \= '' then
          call lineout LCU_file, 'tcpiptgtpath = "'TCPIP_Drive'"'
*/
         if pos('PPPSRV', products_to_install) > 0 then do
           call lineout LCU_file, 'configure_lan_distance = 'configure_lan_distance
        end  /* Do */

       if pos('PEER', products_to_install) > 0 then
           call lineout LCU_file, 'peerdrive = "'OS2Peer_Drive'"'

        if pos('NSC', products_to_install) > 0 then do
          call lineout LCU_file, 'nsctgtpath = "'NSC_Drive'"'

           if pos('NSC', Previous_Products) > 0 then
              nsc_instupdt = 'u'
           else
              nsc_instupdt = 'i'

          call lineout LCU_file, 'nsc_instupdt = "'nsc_instupdt'"'

        end
        else if pos('LANSRV',products_to_install) > 0 then
           call lineout LCU_file, 'nsctgtpath = "'LS_Drive'"'

       if pos('NETSCAPE', products_to_install) > 0 then do

          call lineout LCU_file, 'netscapetgtpath = "'Netscape_Drive'"'
          if pos('NETSCAPE', Previous_Products) > 0 then
              netscape_instupdt = 'u'
           else
              netscape_instupdt = 'i'
           call lineout LCU_file, 'netscape_instupdt = "'netscape_instupdt'"'

         end

         if PSF_Drive \= '' then
            call lineout LCU_file, 'psftgtpath = "'PSF_Drive'"'

        if pos('LCFAGENT', products_to_install) > 0 then do

          if pos('LCFAGENT', Previous_Products) > 0 then
              lcfagent_instupdt = 'u'
           else
              lcfagent_instupdt = 'i'
           call lineout LCU_file, 'lcfagent_instupdt = "'lcfagent_instupdt'"'

        end

        if pos('SVAGENT', products_to_install) > 0 then do

           if pos('SVAGENT', Previous_Products) > 0 then
              svagent_instupdt = 'u'
           else
              svagent_instupdt = 'i'

           call lineout LCU_file, 'svagent_instupdt = "'svagent_instupdt'"'

        end  /* Do */

        if pos('LANSRV', translate(All_Products)) > 0 & WSTune = 1 then
           call lineout LCU_file, 'WSTune = '1
        else
           call lineout LCU_file, 'WSTune = '0

        if LAN_Drive \= 'NONE' & WCTune = 1 then
           call lineout LCU_file, 'WCTune = '1
        else
           call lineout LCU_file, 'WCTune = '0

        /* Write the NetFin install variables */
        if NetF_Drive \= '' then do
          call lineout LCU_file, 'NetFin_Drive = "'NetF_Drive'"'
        end

        /* Write MFS Drive */
        if pos('MFS', products_to_install) > 0 then do
           call lineout LCU_file, 'MFS_Drive = "'MFS_Drive'"'

           if pos('MFS', Previous_Products) > 0 then
              mfs_instupdt = 'u'
           else
              mfs_instupdt = 'i'

          call lineout LCU_file, 'mfs_instupdt = "'mfs_instupdt'"'

        end  /* Do */

        /* Write NetWare Drive & preferred server */
        if pos('NW', products_to_install) > 0 then do
          call lineout LCU_file, 'nwtgtpath = "' || left(NW_Drive,1) || '"'
          call lineout LCU_file, 'nwprefsrv = "' || NW_PrefSrv || '"'
          call lineout LCU_file, 'nwtokenring = "' || NW_TokenRing || '"'
          call lineout LCU_file, "nwcontext = '" || NW_Context || "'"
          call lineout LCU_file, 'nwversion = "' || NW_Version || '"'

          if pos('NW', Previous_Products) >0 then
             last = 1
          else
             last = 0

          call lineout LCU_file, 'nwexists = "' || last || '"'

          /* Check to see if we need to remove ODI2NDI */
          if last = 1 then do

             fnd_odi = 0
             do bb =1 to protocol.0
                if pos('ODI2NDI', translate(protocol.bb)) > 0 then
                   fnd_odi = 1
             end /* do */

             if fnd_odi then do

                rmvnwrsp = cltdir'\RMVNW.RSP'

                if stream(rmvnwrsp, 'C', 'QUERY EXISTS') \= '' then
                   call SysFileDelete rmvnwrsp

                call lineout rmvnwrsp, 'PROT_SECTION = ('
                call lineout rmvnwrsp, '  delete_sect'
                call lineout rmvnwrsp, '  SECTION_NAME = ODI2NDI_NIF'
                call lineout rmvnwrsp, ')'

                call stream rmvnwrsp, 'C', 'CLOSE'

             end /* Do */

          end  /* Do */

        end  /* Do */

        else
          call lineout LCU_file, 'nwexists = 0'

        if books = '' then call lineout LCU_file, 'instbooks = 0'
        else do
           call lineout LCU_file, 'instbooks = 1'
           call lineout LCU_file, 'booksdrive = "'Books_Drive'"'
        end

        /* Add call to create UIDP */
        if pos('OS2PEER', products_to_install) > 0 | translate(LS_ServerType) = 'DOMAINCONTROLLER' then
           call lineout LCU_file, 'addcallcrtuidp = 1'
        else call lineout LCU_file, 'addcallcrtuidp = 0'

        if pos('PPPSRV', products_to_install) > 0 then do
           call lineout LCU_file, 'PPP_Drive = "'PPP_Drive'"'
           call lineout LCU_file, 'PPP_initial = "'ldcsinitial'"'
        end  /* Do */

     end /* Do */

     else call lineout LCU_file, line1

  end /* do */

  call stream LCU_src_file, 'C', 'CLOSE'
  call stream LCU_file, 'C', 'CLOSE'

RETURN 0

/* INITIALIZE_VARIABLES */
/*
    Called by: Main
    Calls None:
    Dependencies: All Declared section variables
*/
/* This section will initialize all the variables from the config file
    before they are read */

initialize_variables:

  /* Drives and Dirs */
  MPTS_Drive=''; OS2_Drive=''; Integrated_Install=''; CD_Drive=''

  /* Products */
  Products=''; Deltasize = ''; All_Products = ''; Previous_Products = ''

  /* MPTS */
  rmv_nb = 0; remote_protocol = 'NETBEUI'

  /* OS2 Peer */
  OS2Peer_Drive=''; OS2Peer_Name=''; OS2Peer_Domain=''; OS2Peer_Comment=''
  OS2Peer_ReplaceNetAcc = 0; WCTune = 0; OS2Peer_Adapters=''

  /* !CHECK! - Change defaults after Joe drops code */
  OS2Peer_InstallPeerService=1; OS2Peer_InstallAdminGUI=1

  /* LanServer */
  LS_Drive='';   LS_Name='';   LS_Domain='';   LS_ServerType='';   LS_ConfigInitializeDCDB=0
  LS_InstallGUI=0;   LS_InstallAPI=0;   LS_InstallClipboard=0;   LS_InstallMsgPopup=0;   LS_InstallUPM=0;
  LS_InstallInstallProgram=0;   LS_AutoStart='';   LS_InstallDosLanAPI=0; LS_InstallGenericAlerter=0
  LS_InstallLoopBackDriver = 0;   LS_InstallMigration = 0;   LS_Adapters=''; WSTune = 0
  /* LDR */
  LDR_Drive=''; LDR_ComPort=''; LDR_Modem=''; LDR_Ethernet=''; LDR_Phonenum=''

    /* RIPL */
  RIPL_RIPLDrive=''; RIPL_UserDrive=''; RIPL_InstOS2Net=0;
  RIPL_InstDosNet=0; RIPL_Adapters=''; LS_InstallDosRemoteIPL=0;
  LS_InstallOS2RemoteIPL=0

  /* UPS */
  UPS_ComPort=''
  LS_InstallUPS = 0

  /* TCP/IP */
  TCPIP_Drive=''; TCPIP_DHCP=0; TCPIP_DDNS=0; TCPIP_IPAddress=''; TCPIP_SubNetMask=''
  TCPIP_Router=''; TCPIP_Hostname=''; TCPIP_DomName=''; TCPIP_NameServer='';  TCPIP_Migrate=0

  /* FFST */
  FFST_DisplayMsg=''; FFST_RouteAlerts=''; FFST_WorkstationID=''

  /* Books */
  BOOKS=''; Books_Drive=''

  /* Karat */
  NetF_Drive=''; NetF_SystemName=''; NetF_TCPIPDriver=0; NetF_NetBIOSDriver2=0
  NetF_NetBIOSDriver=1; NetF_IPXDriver=0; NetF_SeriPCDriver = 0
  NetF_NetBIOSParm = ''; NetF_NetBIOS2Parm = ''; NetF_SeriPCParm = ''
  NetF_Keyword1 = ''; NetF_Keyword2 = ''

  /* PSNS */
  PSNS_OPTICAL = 0; PSNS_LAN = 0
  PSNS_TAPE = 0; PSNS_ADSM = 0; PSNS_PRM = 0; PSNS_REMDRV = 0; PSNS_Drive=''

  /* LDAP */
  LDAPTlkt = 0;
  LDAPExamples = 0; LDAPDoc = 0; LDAPJSupport = 0; LDAPJDoc = 0;  LDAP_Drive=''

  /* PSF/2 */
  PSF_Drive = ''; PSF_BaseFiles=0; PSF_ResourceLib=0; PSF_ParallelAttachedDevices=0
  PSF_Transforms=0; PSF_CodeFonts=0; PSF_CoreFonts=0; PSF_CodedFonts=0
  PSF_240dpiFonts=0; PSF_300dpiFonts=0; PSF_PSAAttachedDevices=0
  PSF_TCPIPAttachedDevices=0; PSF_PostScript=0; PSF_Installed=0

  /* Netware */
  NW_Drive = '';  NW_PrefSrv = ''; nbipx_exists=0; NW_TokenRing='FALSE'
  NW_Context = ''; NW_Version = 4

  /* LCF Common Agent -- Use product defaults for LPORT and GPORT*/
  LCF_Drive = ''; LCF_GPORT=9494; LCF_LPORT=9494; LCF_OPTIONS='';

  /* PPP Server  */
  PPP_Drive = ''; PPP_Comport = ''; PPP_Modem = ''; PPP_Ethernet = 0;  ldcsservername = '';  ldcsinitial = 0;
  PPP_Address = '';  configure_lan_distance = 1

  /* MFS */
  MFS_Drive = ''

  /* SVAgent */
  sva_drive = ''

  /* NSC */
  NSC_Drive = ''

  /* Netscape */
  Netscape_Drive = ''; Netscape_NSCONVERTQL=''; Netscape_NSCONVERTBROWSER='';
  Netscape_NSASSOCIATEHTML=''

  /* HPFS386  */
  Install386HPFS=0; InstallFaultTolerance=0; InstallLocalSecurity=0;
  HPFS386_Cache=1; HPFS386_LazyWrite=''; HPFS386_Heap=1; HPFS386_UseAllMem='';
  HPFS386_MinBufferIdle=0; HPFS386_MaxcacheAge=0; HPFS386_Drive=''

RETURN 0


/* This procedure reads in the MPTS piece of the config file */
load_mpts_struct:

  prot_section = 0; adap_section = 0; netbios_section = 0
  adap_cnt = 0; prot_cnt = 0
  pcnt = 0; acnt = 0; nbcnt = 0

  do while line1 \= '}'

     line1 = linein(cfgfile)
     line1 = strip(line1)

     if left(line1,1) = ';' | line1 = '' then nop

     else if pos('PROTOCOL_SECTION', translate(line1)) \= 0 then do
        prot_cnt = prot_cnt + 1
        prot_section = 1; adap_section = 0; netbios_section = 0
     end  /* Do */

     else if pos('ADAPTER_SECTION', translate(line1)) \= 0 then do
        adap_cnt = adap_cnt + 1
        prot_section = 0; adap_section = 1; netbios_section = 0
     end  /* Do */

     else if pos('NETBIOS_SECTION', translate(line1)) \= 0 then do
        prot_section = 0; adap_section = 0; netbios_section = 1
     end  /* Do */

     else if adap_section then do
        if line1 = ')' then do
           adapter.adap_cnt = secname || ' ' || nifname
           adap_section = 0
           adapter.adap_cnt.0 = acnt
           acnt = 0
        end  /* Do */
        else do
           parse var line1 kw '=' kwval

           if strip(translate(kw)) = 'SECTION_NAME' then do
              secname = strip(kwval)
           end  /* Do */

           else if strip(translate(kw)) = 'NIF' then do
              nifname = strip(kwval)
              adapter.adap_cnt.nif_name = strip(translate(kwval))
           end  /* Do */

           else if strip(translate(kw)) = 'ADAPTERCARDTYPE' then do
              if strip(translate(kwval)) = 'ETHERNET' then
                 adapter.adap_cnt.ethernet = 1
              else
                 adapter.adap_cnt.ethernet = 0
           end

           else if strip(translate(kw)) = 'DELETE_SECTION' then do
              adapter.adap_cnt.changes = 'DELETE_ADAPTER'
           end  /* Do */

           acnt = acnt + 1
           adapter.adap_cnt.acnt = line1
        end
     end  /* Do */

     else if prot_section then do
        if line1 = ')' then do
           prot_section = 0
           protocol.prot_cnt.0 = pcnt
           pcnt = 0
        end  /* Do */
        else do
           if pos('SECTION_NAME', translate(line1)) > 0 then do
              parse var line1 . '=' secname
              protocol.prot_cnt = strip(secname)
           end  /* Do */
           else if pos('DELETE_SECTION', translate(line1)) > 0 then do
              protocol.prot_cnt.changes = 'DELETE_PROTOCOL'
           end  /* Do */
           pcnt = pcnt + 1
           protocol.prot_cnt.pcnt = line1
        end  /* Do */
     end  /* Do */

     else if netbios_section then do
        if line1 = ')' then do
           netbios_section = 0
           netbios.1.0 = nbcnt
           nbcnt = 0
        end  /* Do */
        else do
           nbcnt = nbcnt + 1
           netbios.1.nbcnt = line1
        end  /* Do */
     end  /* Do */

  end /* do */

  netbios.0 = 1
  adapter.0 = adap_cnt
  protocol.0 = prot_cnt

RETURN 0

/* build_protocol_line_stem */
/* This section is passed a string from the protocol.ini and a target stem
   name.  It will pull apart the string, filling in the elements of the
   stem with the value of the string based on their comma position.  The 0
   element of the stem will contain the maximum number of elements.
   e.g. :
    mystring = "I",,"D"
    call build_protocol_line_stem mystring mystem

           mystem.0 = 3
           mystem.1 = "I"
           mystem.2 = ''
           mystem.3 = "D"

   The build_protocol_line_string function does the reverse.  This makes it
   easier to manipulate lines from the protocol.ini.
*/

build_protocol_line_stem:

parse arg bpls_string1 bpls_stemname

/* Initialize temporary string */
bpls_newstring = ''

/* Initialize the stem counter */
bpls_cmmcnt = 0

/* Parse the string */
do bpls_iicnt = 1 to length(bpls_string1)

   /* Pull each character out of the string */
   bpls_cchar = substr(bpls_string1, bpls_iicnt, 1)

   /* If we find a comma, bump up the comma counter, assign the value of
      the temp string to a stem value, and reinitalize the temp string */

   if bpls_cchar = ',' then do
      bpls_cmmcnt = bpls_cmmcnt + 1
      bpls_stem.bpls_cmmcnt = bpls_newstring
      bpls_newstring = ''
   end  /* Do */

   /* If it's not a comma, append it to the string being built */
   else bpls_newstring = bpls_newstring || bpls_cchar

end /* do */

/* Assign the last part of the string to the right stem element */

bpls_cmmcnt = bpls_cmmcnt + 1
bpls_stem.bpls_cmmcnt = bpls_newstring

/* Set the number of elements in the stem */
bpls_stem.0 = bpls_cmmcnt

/* Assign the value of the stem back to the one the user has indicated */
do iicnt = 0 to bpls_stem.0
   interpret bpls_stemname'.'iicnt' = bpls_stem.'iicnt
end /* do */

RETURN 0


/* build_protocol_line_string */

/*  This section will take a stem created by build_protocol_line_section
    and convert it back to a line that can be put in the protocol.ini
    See the section above for a full description.  */

build_protocol_line_string:

parse arg bpls_stemname bpls_stringname

/* Get the ending value for the loop since interpret doesn't like do's */
interpret 'bpls_endval = value('bpls_stemname'.0)'

/* Initialize the string value */
bpls_tmpstring = ''

/* Pull the values from the stem, building the line */
do bpls_iicnt = 1 to bpls_endval
   interpret 'bpls_tmpstring = bpls_tmpstring || '','' ||'bpls_stemname'.'bpls_iicnt
end

/* Remove the extraneous comma from the front of the line */
bpls_tmpstring = substr(bpls_tmpstring, 2, length(bpls_tmpstring) - 1)

/* Assign the string value back to the one that was passed in */
interpret bpls_stringname' = bpls_tmpstring'

RETURN 0


/* ERROUT */
/*
    Called by: Any error or completion
    Calls: None
    Dependencies: err1. logname
*/
/* Function to write log file */

errout:

if logname = '' then logname = 'C:\ERROR.OUT'
parse arg retc

if retc \= 0 then do
   say err1.1
   say err1.2
end  /* Do */

err1.0 = 2
rc =  stream(logname, 'C', 'QUERY EXISTS')
if rc \= '' then call sysfiledelete(logname)

do i = 1 to err1.0
   call lineout logname, err1.i
end /* do */

call lineout logname

EXIT retc

