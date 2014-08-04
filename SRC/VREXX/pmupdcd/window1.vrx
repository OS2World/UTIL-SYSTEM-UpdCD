/*:VRX         Main
*/
/*  Main
*/
Main:
/*  Process the arguments.
    Get the parent window.
*/
    parse source . calledAs .
    parent = ""
    argCount = arg()
    argOff = 0
    if( calledAs \= "COMMAND" )then do
        if argCount >= 1 then do
            parent = arg(1)
            argCount = argCount - 1
            argOff = 1
        end
    end; else do
        call VROptions 'ImplicitNames'
        call VROptions 'NoEchoQuit'
    end
    InitArgs.0 = argCount
    if( argCount > 0 )then do i = 1 to argCount
        InitArgs.i = arg( i + argOff )
    end
    drop calledAs argCount argOff

/*  Load the windows
*/
    call VRInit
    parse source . . spec
    _VREPrimaryWindowPath = ,
        VRParseFileName( spec, "dpn" ) || ".VRW"
    _VREPrimaryWindow = ,
        VRLoad( parent, _VREPrimaryWindowPath )
    drop parent spec
    if( _VREPrimaryWindow == "" )then do
        call VRMessage "", "Cannot load window:" VRError(), ,
            "Error!"
        _VREReturnValue = 32000
        signal _VRELeaveMain
    end

/*  Process events
*/
    call Init
    signal on halt
    do while( \ VRGet( _VREPrimaryWindow, "Shutdown" ) )
        _VREEvent = VREvent()
        interpret _VREEvent
        /* say _VREEvent */
    end
_VREHalt:
    _VREReturnValue = Fini()
    call VRDestroy _VREPrimaryWindow
_VRELeaveMain:
    call VRFini
exit _VREReturnValue

VRLoadSecondary:
    __vrlsWait = abbrev( 'WAIT', translate(arg(2)), 1 )
    if __vrlsWait then do
        call VRFlush
    end
    __vrlsHWnd = VRLoad( VRWindow(), VRWindowPath(), arg(1) )
    if __vrlsHWnd = '' then signal __vrlsDone
    if __vrlsWait \= 1 then signal __vrlsDone
    call VRSet __vrlsHWnd, 'WindowMode', 'Modal' 
    __vrlsTmp = __vrlsWindows.0
    if( DataType(__vrlsTmp) \= 'NUM' ) then do
        __vrlsTmp = 1
    end
    else do
        __vrlsTmp = __vrlsTmp + 1
    end
    __vrlsWindows.__vrlsTmp = VRWindow( __vrlsHWnd )
    __vrlsWindows.0 = __vrlsTmp
    do while( VRIsValidObject( VRWindow() ) = 1 )
        __vrlsEvent = VREvent()
        interpret __vrlsEvent
    end
    __vrlsTmp = __vrlsWindows.0
    __vrlsWindows.0 = __vrlsTmp - 1
    call VRWindow __vrlsWindows.__vrlsTmp 
    __vrlsHWnd = ''
__vrlsDone:
return __vrlsHWnd

/*:VRX         __VXREXX____APPENDS__
*/
__VXREXX____APPENDS__:
/*
*/
return
/*:VRX         CB_10_Click
*/
CB_10_Click: 
    changed = 1
    add.up2tb = VRGet( "CB_10", "Set" )
return

/*:VRX         CB_11_Click
*/
CB_11_Click: 
    changed = 1
    add.fat32 = VRGet( "CB_11", "Set" )
return

/*:VRX         CB_12_Click
*/
CB_12_Click: 
    changed = 1
    add.usb = VRGet( "CB_12", "Set" )
return

/*:VRX         CB_1_Click
*/
CB_1_Click: 
    changed = 1
    use_dvd = VRGet( "CB_1", "Set" )
return

/*:VRX         CB_2_Click
*/
CB_2_Click: 
    changed = 1
    iaddons = VRGet( "CB_2", "Set" )
    if iaddons = 1 then call VRSet  "PB_29", "Enabled", 1 
    else call VRSet  "PB_29", "Enabled", 0
return


/*:VRX         CB_3_Click
*/
CB_3_Click: 
    changed = 1
    compress = VRGet( "CB_3", "Set" )
    if compress = 1 then call VRSet  "PB_13", "Enabled", 1 
    else call VRSet  "PB_13", "Enabled", 0
return

/*:VRX         CB_4_Click
*/
CB_4_Click: 
    changed = 1
    add.dani.ide = VRGet( "CB_4", "Set" )
    call VRSet "CB_7", "Set", 0 
    add.dani.flt = VRGet( "CB_7", "Set" )
return

/*:VRX         CB_5_Click
*/
CB_5_Click: 
    changed = 1
    add.dummy = VRGet( "CB_5", "Set" )
return

/*:VRX         CB_6_Click
*/
CB_6_Click: 
    changed = 1
    emulate = VRGet( "CB_6", "Set" )
    if emulate = 1 then do
        call VRSet "PB_28", "Enabled", 0
        call VRSet "CB_11", "Set", 0 
        call VRSet "CB_11", "Enabled", 0 
        call VRSet "CB_12", "Set", 0 
        call VRSet "CB_12", "Enabled", 0 
    end
    else do
        call VRSet "PB_28", "Enabled", 1
        call VRSet "CB_11", "Enabled", 1 
        call VRSet "CB_12", "Enabled", 1 
    end
return

/*:VRX         CB_7_Click
*/
CB_7_Click: 
    changed = 1
    add.dani.flt = VRGet( "CB_7", "Set" )
    if add.dani.flt = 1 then do
        call VRSet "CB_4", "Set", 1 
        add.dani.ide = VRGet( "CB_4", "Set" )
    end
return

/*:VRX         CB_8_Click
*/
CB_8_Click: 
    changed = 1
    add.dani.boot = VRGet( "CB_8", "Set" )
return

/*:VRX         CB_9_Click
*/
CB_9_Click: 
    changed = 1
    add.dani.dasd = VRGet( "CB_9", "Set" )
return

/*:VRX         DDCB_1_Change
*/
DDCB_1_Change: 
    os2ver=VRGet("DDCB_1","Value")

    call SysIni , 'UPDCD', 'OS2VER', os2ver
    if os2ver = 'eCS 1.1' then do
        call VRSet "CB_2", "Enabled", 1 
        call VRSet "CB_10", "Enabled", 1 
        call VRSet "CB_11", "Enabled", 1 
        call VRSet "CB_5", "Set", 0 
        call CB_5_Click
        call VRSet "CB_5", "Enabled", 0 
        call VRSet "RB_3", "Set", 1 
        call RB_3_Click
        call VRSet "RB_4", "Enabled", 0 
        call VRSet "CB_6", "Set", 0 
        call CB_6_Click
        call VRSet "CB_6", "Enabled", 0 
        call VRSet "CB_8", "Set", 0 
        call CB_8_Click
        call VRSet "CB_8", "Enabled", 0 
        call VRSet "CB_9", "Set", 0 
        call CB_9_Click
        call VRSet "CB_9", "Enabled", 0 
        call VRSet "CB_4", "Enabled", 1 
        call VRSet "CB_7", "Enabled", 1 
        call VRSet "CB_12", "Set", 0
        call CB_12_Click
        call VRSet "CB_12", "Enabled", 0
    end
    else if os2ver = 'eCS 1.0' then do
        call VRSet "CB_2", "Set", 0 
        call CB_2_Click
        call VRSet "CB_2", "Enabled", 0 
        call VRSet "CB_4", "Set", 0 
        call CB_4_Click
        call VRSet "CB_4", "Enabled", 0 
        call VRSet "CB_5", "Set", 0 
        call CB_5_Click
        call VRSet "CB_5", "Enabled", 0 
        call VRSet "CB_6", "Set", 1 
        call CB_6_Click
        call VRSet "CB_6", "Enabled", 0 
        call VRSet "CB_7", "Set", 0 
        call CB_7_Click
        call VRSet "CB_7", "Enabled", 0 
        call VRSet "CB_8", "Set", 0 
        call CB_8_Click
        call VRSet "CB_8", "Enabled", 0 
        call VRSet "CB_9", "Set", 0 
        call CB_9_Click
        call VRSet "CB_9", "Enabled", 0 
        call VRSet "CB_10", "Set", 0
        call CB_10_Click
        call VRSet "CB_10", "Enabled", 0 
        call VRSet "CB_11", "Set", 0
        call CB_11_Click
        call VRSet "CB_11", "Enabled", 0
        call VRSet "CB_12", "Set", 0
        call CB_12_Click
        call VRSet "CB_12", "Enabled", 0
    end
    else if os2ver = 'Warp 3' then do
        call VRSet "CB_6", "Set", 1 
        call CB_6_Click
        call VRSet "CB_6", "Enabled", 0 
        call VRSet "CB_7", "Enabled", 1 
        call VRSet "CB_8", "Enabled", 1 
        call VRSet "CB_9", "Enabled", 1 
        call VRSet "RB_4", "Enabled", 1 
        call VRSet "CB_2", "Enabled", 1 
        call VRSet "CB_4", "Enabled", 1 
        call VRSet "CB_5", "Enabled", 1 
        call VRSet "CB_10", "Enabled", 1 
        call VRSet "CB_11", "Set", 0
        call VRSet "CB_12", "Set", 0
        call CB_11_Click
        call CB_12_Click
        call VRSet "CB_11", "Enabled", 0
        call VRSet "CB_12", "Enabled", 0
        call VRSet "PB_28", "Enabled", 0
    end
    else do
        call VRSet "RB_4",  "Enabled", 1 
        call VRSet "CB_6",  "Enabled", 1 
        call VRSet "CB_2",  "Enabled", 1 
        call VRSet "CB_4",  "Enabled", 1 
        call VRSet "CB_7",  "Enabled", 1 
        call VRSet "CB_8",  "Enabled", 1 
        call VRSet "CB_9",  "Enabled", 1 
        call VRSet "CB_5",  "Enabled", 1 
        call VRSet "CB_10", "Enabled", 1 
        call VRSet "CB_11", "Enabled", 1
        call VRSet "CB_12", "Enabled", 1
        if VRGet( "CB_6", "Set" ) = 0 then call VRSet "PB_28", "Enabled", 1  
        if VRGet( "CB_2", "Set" ) = 1 then call VRSet "PB_29", "Enabled", 1  
        if VRGet( "CB_3", "Set" ) = 1 then call VRSet "PB_13", "Enabled", 1  
        if VRGet( "CB_6", "Set" ) = 1 then do
            call VRSet "CB_11", "Set", 0 
            call VRSet "CB_11", "Enabled", 0 
            call VRSet "CB_12", "Set", 0 
            call VRSet "CB_12", "Enabled", 0 
        end
    end
return

/*:VRX         DDCB_2_Change
*/
DDCB_2_Change: 

    lang = VRGet("DDCB_2","Value")
    Call SysIni , 'UPDCD', 'LANG', lang

    /* load language file */
    call load_language 'ENG NOSAVE'
    call load_language 'DEFAULT'
    call set_text_labels_of_main_window

return

/*:VRX         EF_10_Change
*/
EF_10_Change: 
    changed = 1
    burnlog = VRGet( "EF_10", "Value" )
return

/*:VRX         EF_11_Change
*/
EF_11_Change: 
    changed = 1
    tempraw = VRGet( "EF_11", "Value" )
return

/*:VRX         EF_12_Change
*/
EF_12_Change: 
    changed = 1
    cdrdir = VRGet( "EF_12", "Value" )
    cdrdir = strip(cdrdir, 'T', '\')
    if stream(cdrdir'\mkisofs.exe', 'c', 'query exists') <> '' then do
        call VRSet "RB_3","Enabled",1
        set = VRGet( "RB_3", "Set" )
        if set = 1 then call VRMethod  "RB_3", "PostEvent", "Click" 
    end
    else do
        set = VRGet( "RB_3", "Set" )
        if set = 1 then call VRMethod  "RB_3", "PostEvent", "Click" 
        call VRSet "RB_3","Enabled",0
    end

    set = VRGet( "RB_4", "Set" )
    if set = 1 then call VRMethod  "RB_4", "PostEvent", "Click"         

return

/*:VRX         EF_13_Change
*/
EF_13_Change: 
    /* this object changes only after initialization */
    changed = 0
return

/*:VRX         EF_14_Change
*/
EF_14_Change: 
    changed = 1
    extrap = VRGet( "EF_14", "Value" )
return

/*:VRX         EF_15_Change
*/
EF_15_Change: 
    changed = 1
    addons = VRGet( "EF_15", "Value" )
    addons = strip(addons, 'T', '\')
return

/*:VRX         EF_16_Change
*/
EF_16_Change: 
    prev_speed = speed
    changed = 1
    speed = VRGet( "EF_16", "Value" )
    if datatype(speed) <> 'NUM' | speed < 1 then do
        speed = prev_speed
        call VRSet  "EF_16", "Value", speed 
    end    
return

/*:VRX         EF_1_Change
*/
EF_1_Change: 
    changed = 1
    fixes = VRGet( "EF_1", "Value" )
    fixes = strip(fixes, 'T', '\')
return

/*:VRX         EF_2_Change
*/
EF_2_Change: 
    changed = 1
    updates = VRGet( "EF_2", "Value" )
    updates = strip(updates, 'T', '\')
return

/*:VRX         EF_3_Change
*/
EF_3_Change: 
    changed = 1
    w4cd = VRGet( "EF_3", "Value" )
    w4cd = strip(w4cd, 'T', '\')
return


/*:VRX         EF_4_Change
*/
EF_4_Change: 
    changed = 1
    burn = VRGet( "EF_4", "Value" )
    burn = strip(burn, 'T', '\')
return

/*:VRX         EF_5_Change
*/
EF_5_Change: 
    changed = 1
    flpdrv = translate(VRGet( "EF_5", "Value" ))
    if flpdrv = 'A:' then do
        call VRSet "PB_15", "Enabled", 0 
        call VRSet "PB_24", "Enabled", 0 
    end
    else do
        call VRSet "PB_15", "Enabled", 1 
        call VRSet "PB_24", "Enabled", 1 
    end
return
/*:VRX         EF_6_Change
*/
EF_6_Change: 
    changed = 1
    log = VRGet( "EF_6", "Value" )
return

/*:VRX         EF_7_Change
*/
EF_7_Change: 
    changed = 1
    id.1 = VRGet( "EF_7", "Value" )
return

/*:VRX         EF_8_Change
*/
EF_8_Change: 
    changed = 1
    id.2 = VRGet( "EF_8", "Value" )
return

/*:VRX         EF_9_Change
*/
EF_9_Change: 
    changed = 1
    id.3 = VRGet( "EF_9", "Value" )
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         GB_6_Click
*/
GB_6_Click: 

return

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:

    /* load language file */
    call load_language 'ENG NOSAVE'
    call load_language 'DEFAULT'

    cdrprg = 'record.cmd'

    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1

    call set_text_labels_of_main_window

    /* get os2 version */
    os2ver = SysIni(, 'UPDCD', 'OS2VER')
    if os2ver = "ERROR:" then do
        os2ver = "Warp 4" 
	 call SysIni , 'UPDCD', 'OS2VER', os2ver
    end
    call VRSet "DDCB_1", "Value", os2ver

    /* get language */
    lang = translate(SysIni(, 'UPDCD', 'LANG'))
    if lang = "ERROR:" then lang = "ENG"
    curdir = strip(directory(), , '\')
    Call RxFuncAdd Sysfiletree, RexxUtil, Sysfiletree
    call sysfiletree curdir'\nls\message.*', 'tmp.', 'FO'
    if tmp.0 = 0 then call VRMethod "DDCB_2", "AddString", lang
    else
        do i=1 to tmp.0
		tmp.i = translate(filespec('name',tmp.i))
		tmp.i = substr(tmp.i, lastpos('.', tmp.i)+1)
              call VRMethod "DDCB_2", "AddString", tmp.i
        end
    call VRSet "DDCB_2", "Selected", 1
    do i=1 to tmp.0
        if tmp.i = lang then call VRSet "DDCB_2", "Selected", i
    end

    /* get vdisk */
    vdisk = SysIni(, 'UPDCD', 'VDISK')
    if vdisk = "ERROR:" then do
        vdisk = "VFDISK"
        call SysIni , 'UPDCD', 'VDISK', vdisk
    end
    if vdisk = 'VFDISK' then call VRSet "RB_2", "Set", 1 
    else call VRSet "RB_1", "Set", 1 

    /* set fat32 & USB */
    set = VRGet( "CB_6", "Set" )
    if set = 1 then do
            call VRSet "CB_11", "Set", 0 
            call VRSet "CB_11", "Enabled", 0 
            call VRSet "CB_12", "Set", 0 
            call VRSet "CB_12", "Enabled", 0 
    end

    /* get burn prog */
    bprog = SysIni(, 'UPDCD', 'BPROG')
    if bprog = "ERROR:" then do
        bprog = "CDR"
        call SysIni , 'UPDCD', 'BPROG', bprog
    end
    if bprog = 'CDR' then call VRSet "RB_3", "Set", 1 
    else do
        call VRSet "RB_4", "Set", 1 
    end

    call VRMethod window, "Activate"
    drop window

return

/*:VRX         ListWindow_Close
*/
ListWindow_Close: procedure
call ListWindow_Fini
return

/*:VRX         ListWindow_Create
*/
ListWindow_Create: procedure expose l. listwindow_caption msg.

    call VRSet "ListWindow", "Caption", msg.0467

    id   = VRMethod("CN_1","AddField","String",listwindow_caption)
    type = VRMethod("CN_1","AddField","String",msg.0428)
    dir  = VRMethod("CN_1","AddField","String",msg.0429)

    if l.0 > 3 then do
        do i=4 to l.0
            parse value l.i with tmp1 tmp2 tmp3
            record = VRMethod("CN_1", "AddRecord", "", "Last", space(tmp1))
            call VRMethod "CN_1", "SetFieldData", record, id, space(tmp1), type, space(tmp2), dir, space(tmp3)
        end
    end

    call ListWindow_Init

return

/*:VRX         ListWindow_Fini
*/
ListWindow_Fini:
    window = VRInfo("Window")
    call VRDestroy window
    drop window
return
/*:VRX         ListWindow_Init
*/
ListWindow_Init: 
    window = VRInfo("Object")
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         load_language
*/
load_language: 

	/* get parameters */
	call RxFuncAdd 'SysIni', 'RexxUtil', 'SysIni'
	parse upper arg language opt
	if language  = 'DEFAULT' then do
		language = SysIni(, 'UPDCD', 'LANG')
		if language = 'ERROR:' then language = 'ENG'
	end

	/* check */
	lfile = strip(directory(), 'T', '\')||'\nls\message.'language
	if stream(lfile, 'c', 'query exists') = '' then do
              bt.0=1
              bt.1='OK'
              call vrmessage vrwindow(),'Fatal error: cannot find language file: 'lfile' Did you run this script from the root directory of the CD-ROM? Aborting...','Error','I','bt.',1
		call quit
	end

	/* load */
	do while lines(lfile)
		l = linein(lfile)
		interpret l
	end
	call lineout lfile

	/* set ini */
	if opt <> 'NOSAVE' then call SysIni , 'UPDCD', 'LANG', language

return

/*:VRX         Main_Close
*/
Main_Close:
call Quit
return

/*:VRX         Main_Create
*/
Main_Create: 

    Call RxFuncAdd SysLoadFuncs, RexxUtil, SysLoadFuncs
    Call SysLoadFuncs

    Call VRRedirectSTDIO "off"

    homedir = directory()
    cfgfile = homedir'\updcd.cfg'
    call read_config_file cfgfile   

    /* check if we have the CDWRITER class */
    Call SysQueryClassList 'junk.'
    i = 1
    Do i = 1 to junk.0
   	If translate(word(junk.i, 1)) = "CDWRITER" Then do
            found_class = 1
            LEAVE     /* force exit from loop */
   	End /* Do */
    End /* Do */
    if found_class = 1 then call VRSet "RB_4", "Enabled", 1 

    /* send reset signal */
    ok = VRSet( "EF_13", "Value", "reset" ) 
 
return

/*:VRX         MN_File_Build_Click
*/
MN_File_Build_Click: 
call PB_2_Click
return

/*:VRX         MN_File_Burn_Click
*/
MN_File_Burn_Click: 
call PB_3_Click
return

/*:VRX         MN_File_Exit_Click
*/
MN_File_Exit_Click: 
call PB_5_Click
return

/*:VRX         MN_File_Listaddons_Click
*/
MN_File_Listaddons_Click: 
call PB_26_Click
return

/*:VRX         MN_File_Load_Click
*/
MN_File_Load_Click: 
    cfgfile = vrfiledialog(vrwindow(), msg.0327, "Open", directory()||"\*.cfg")
    if cfgfile = '' then return
    window = VRWindow()
    call VRSet window, "Caption", msg.0325" "cfgfile"]"
    call read_config_file cfgfile    
    changed = 1
return

/*:VRX         MN_File_Save_Click
*/
MN_File_Save_Click: 
call PB_1_Click
return

/*:VRX         MN_File_SaveAs_Click
*/
MN_File_SaveAs_Click: 
    cfgfile = vrfiledialog(vrwindow(), msg.0328, "Save", directory()||"\*.cfg")
    call Save_Config_File cfgfile
return

/*:VRX         MN_Help_About_Click
*/
MN_Help_About_Click: 

    /* find out updcd version */
    general = 'lib\general.rlb'
    found_function = 0
    do while lines(general)
        l=translate(linein(general))
        if pos('GET_UPDCD_VERSION:', l) > 0 then do
            found_function = 1
            iterate
        end
        if found_function = 1 & pos('VERSION', l) > 0 then do
            interpret l
            leave
        end
    end
    call lineout general

    /* check */
    if datatype(version) <> 'NUM' then version = '2.0'

    /* display */
    msg.0 = 4
    msg.1 = msg.0330' 'version' (freeware)'
    msg.2 = 'URL: http://xenia.sote.hu/~kadzsol/rexx/sajat/updcd.htm'
    msg.3 = 'Copyright Zsolt K d r, 2000-'substr(date('S'),1,4)
    msg.4 = "Copyright Dimitris "'sehh'" Michelinakis, 2000-2001"
    rc = VrMessageStem(VrWindow(), 'msg.', msg.0329, 'N')
return

/*:VRX         MN_Help_FAQ_Click
*/
MN_Help_FAQ_Click: 
    if stream('doc\updcdfaq.htm', 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0331
    end
    else do
        address cmd 'start /F 'msg.0332' file:///doc/updcdfaq.htm <con >con 2>con'
    end
return

/*:VRX         MN_Help_Readme_Click
*/
MN_Help_Readme_Click: 

    lang = translate(SysIni(, 'UPDCD', 'LANG'))
    if lang = 'ERROR:' then lang = 'ENG'
    if stream('readme.'lang, 'c', 'query exists') = '' then lang = 'ENG'
    if stream('readme.'lang, 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0333
    end
    else do
        address cmd 'start /F e.exe readme.'lang' <con >con 2>con'
    end

return

/*:VRX         PB_10_Click
*/
PB_10_Click: 
    if stream(log, 'c', 'query exists') = '' then do
        call vrmessage vrwindow(), msg.0335
    end
    else do
        address cmd 'start /F e.exe 'log '<con >con 2>con'
    end
return

/*:VRX         PB_11_Click
*/
PB_11_Click: 
    if stream(burnlog, 'c', 'query exists') = '' then do
        call vrmessage vrwindow(), msg.0335
    end
    else do
        address cmd 'start /F e.exe 'burnlog '<con >con 2>con'
    end
return

/*:VRX         PB_12_Click
*/
PB_12_Click: 
    free = substr(tempraw, 1, 2)
    free = SysDriveInfo(free)
    parse var free . free .
    if free = '' then do
        call vrmessage vrwindow(), msg.0336
    end
    else do
        if datatype(free) = 'NUM' then do
            free = trunc(free/(1024*1024))'MB'
            call vrmessage vrwindow(), msg.0337' 'free
        end
        else call vrmessage vrwindow(), msg.0338
    end
return

/*:VRX         PB_13_Click
*/
PB_13_Click: 
    if stream('bin\lxlite.cfg', 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0541
    end
    else do
        address cmd 'start /F e.exe bin\lxlite.cfg <con >con 2>con'
    end
return

/*:VRX         PB_14_Click
*/
PB_14_Click: 
    if stream(cdrdir'\mkisofs.exe', 'c', 'query exists') = '' then do
        call vrmessage vrwindow(), cdrdir'\MKISOFS.EXE 'msg.0271
        return
    end
    else do
     cmd=cdrdir||'\mkisofs.exe -version 2>>&1 | rxqueue 2>NUL'
     cmd
     rc = 'Unknown'
     if queued() = 0 then rc = msg.0340
     else do while queued() > 0
         l = lineIN( "QUEUE:" )
         if pos('MKISOFS', translate(l)) > 0 then rc = l
     end
     call VRMessage VRWindow(), rc, msg.0341,"I"
   end
   if VRGet( "CB_1", "Set" ) = 1 then do
    exe = 'dvddao.exe'
    par = '-V'
   end
   else do
    exe = 'cdrecord.exe'
    par = '-version'
   end
   if stream(cdrdir'\'exe, 'c', 'query exists') = '' then do
        call vrmessage vrwindow(), cdrdir'\'exe' 'msg.0271
        return
    end
    else do
     cmd=cdrdir||'\'exe' 'par' 2>NUL | rxqueue 2>NUL'
     cmd
     if queued() = 0 then rc = msg.0339
     else rc = lineIN( "QUEUE:" )
     call VRMessage VRWindow(), rc, msg.0342,"I"
   end
return

/*:VRX         PB_15_Click
*/
PB_15_Click: 

    flpdrv = VRGet( "EF_5", "Value" )

    if VRGet( "RB_1", "Set" ) = 1 then do
        '@svdc /i:1.44 'flpdrv
        '@svdc /e 'flpdrv
    end
    else do
        '@vfctrl 'flpdrv' 0'
    end
    if rc <> 0 then call vrmessage vrwindow(), msg.0343
    else call vrmessage vrwindow(), msg.0344

return

/*:VRX         PB_16_Click
*/
PB_16_Click: procedure expose msg.
dir=""
strdir=VRGet("EF_1", "Value")
if strdir="" then dir=DirDialg(VRInfo("Window"),msg.0345)
else dir = DirDialg(VRInfo("Window"),msg.0345,strdir)
if dir = "" then return
else call VRSet "EF_1", "Value", dir
return

/*:VRX         PB_17_Click
*/
PB_17_Click: procedure expose msg.
dir=""
strdir=VRGet("EF_2", "Value")
if strdir="" then dir=DirDialg(VRInfo("Window"),msg.0345)
else dir = DirDialg(VRInfo("Window"),msg.0345,strdir)
if dir = "" then return
else call VRSet "EF_2", "Value", dir
return

/*:VRX         PB_18_Click
*/
PB_18_Click: procedure expose msg.
dir=""
strdir=VRGet("EF_3", "Value")
if strdir="" then dir=DirDialg(VRInfo("Window"),msg.0345)
else dir = DirDialg(VRInfo("Window"),msg.0345,strdir)
if dir = "" then return
else call VRSet "EF_3", "Value", dir
return

/*:VRX         PB_19_Click
*/
PB_19_Click: procedure expose msg.
dir=""
strdir=VRGet("EF_4", "Value")
if strdir="" then dir=DirDialg(VRInfo("Window"),msg.0345)
else dir = DirDialg(VRInfo("Window"),msg.0345,strdir)
if dir = "" then return
else call VRSet "EF_4", "Value", dir
return

/*:VRX         PB_1_Click
*/
PB_1_Click: 

    call Save_Config_File directory()||'\updcd.cfg'
    changed = 0

return

/*:VRX         PB_20_Click
*/
PB_20_Click: procedure expose msg.
dir=""
strdir=VRGet("EF_12", "Value")
if strdir="" then dir=DirDialg(VRInfo("Window"),msg.0345)
else dir = DirDialg(VRInfo("Window"),msg.0345,strdir)
if dir = "" then return
else call VRSet "EF_12", "Value", dir
return

/*:VRX         PB_21_Click
*/
PB_21_Click: procedure expose msg.
filename=VRFileDialog(VRInfo("Window"),msg.0346,"O","*.log")
if filename="" then return
else call VRSet "EF_6", "Value", filename
return

/*:VRX         PB_22_Click
*/
PB_22_Click: procedure expose msg.
filename=VRFileDialog(VRInfo("Window"),msg.0346,"O","*.log")
if filename="" then return
else call VRSet "EF_10", "Value", filename
return

/*:VRX         PB_23_Click
*/
PB_23_Click: procedure expose msg.
filename=VRFileDialog(VRInfo("Window"),msg.0346,"O","*.iso;*.img;*.trk;*.raw")
if filename="" then return
else call VRSet "EF_11", "Value", filename
return

/*:VRX         PB_24_Click
*/
PB_24_Click: 

    flpdrv = VRGet( "EF_5", "Value" )

    if VRGet( "RB_1", "Set" ) = 1 then do
        '@svdc /e 'flpdrv
        '@svdc /i:1.44 'flpdrv
    end
    else do
        '@vfctrl 'flpdrv' 0'
        '@vfctrl 'flpdrv' 1'
    end
    if rc <> 0 then call vrmessage vrwindow(), msg.0347
    else call vrmessage vrwindow(), msg.0344

return

/*:VRX         PB_25_Click
*/
PB_25_Click: 

    if VRGet( "RB_1", "Set" ) = 1 then do
        '@svdc /e 'flpdrv
        '@svdc /i:1.44 'flpdrv
        message = 'svdc.exe'
    end
    else do
        '@vfctrl 'flpdrv' 0'
        '@vfctrl 'flpdrv' 1'
        message = 'vfctrl.exe'
    end
    if rc <> 0 then call vrmessage vrwindow(), msg.0348' 'message
    else do
        free = SysDriveInfo(flpdrv)
        parse var free . . free .
        if free = '' then do
            call vrmessage vrwindow(), msg.0336
        end
        else do
            if datatype(free) = 'NUM' then do
                call vrmessage vrwindow(), free' 'msg.0349
            end
            else call vrmessage vrwindow(), msg.0338
        end
    end

return

/*:VRX         PB_26_Click
*/
PB_26_Click: 

    addons = VRGet( "EF_15", "Value" )
    call sysfiletree addons'\addonins.cmd', 'addons.', 'FSO'
    addons_cfg = '.\newinst\addons.cfg'
    length.produkt.max = 0
    length.directy.max = 0
    length.numberf.max = 0
    do i=1 to addons.0
        instdir = filespec('drive', addons.i)||filespec('path', addons.i)
        product = translate(substr(instdir, lastpos('_', instdir)-2, 8))
        product_name = msg.0350
        product_vers = '0.0'
        do while lines(addons_cfg)
            l=translate(linein(addons_cfg))
            if l = product then do
                parse value linein(addons_cfg) with w "=" "'"product_name"'"
                parse value linein(addons_cfg) with w '=' "'"product_vers"'"
            end
        end
        call lineout addons_cfg
        call sysfiletree instdir'*', 'iets.', 'SO'
        produkt.i = msg.0351' 'product_name product_vers
        length.produkt.i = length(produkt.i)
        if length.produkt.i > length.produkt.max then length.produkt.max = length.produkt.i
        directy.i = msg.0352' 'filespec('drive', addons.i)||filespec('path', addons.i)
        length.directy.i = length(directy.i)
        if length.directy.i > length.directy.max then length.directy.max = length.directy.i
        numberf.i = msg.0353' 'iets.0
        length.numberf.i = length(numberf.i)
        if length.numberf.i > length.numberf.max then length.numberf.max = length.numberf.i
        display.i = iets.0
    end

    j=1
    do i = 1 to addons.0
        if display.i > 1 then do
            add.j = left(produkt.i, length.produkt.max+1)' 'left(directy.i, length.directy.max+1)' 'left(numberf.i, length.numberf.max+1)
            j=j+1
        end
    end
    add.0 = j-1

    if addons.0 < 2 then do
        add.0 = 1
        add.1 = msg.0354
    end
    rc = VrMessageStem(VrWindow(), 'add.', msg.0355, 'N')

return

/*:VRX         PB_27_Click
*/
PB_27_Click: procedure expose msg.
dir=""
strdir=VRGet("EF_15", "Value")
if strdir="" then dir=DirDialg(VRInfo("Window"),msg.0345)
else dir = DirDialg(VRInfo("Window"),msg.0345,strdir)
if dir = "" then return
else call VRSet "EF_15", "Value", dir
return

/*:VRX         PB_28_Click
*/
PB_28_Click: 
    os2ver=VRGet("DDCB_1","Value")
    if os2ver = 'eCS 1.1' then do
        if stream('newinst\memboot.ecs', 'c', 'query exists') = '' then call vrmessage vrwindow(), msg.0542
        else address cmd 'start /F e.exe newinst\memboot.ecs <con >con 2>con'
    end
    else do
        if stream('newinst\memboot.scr', 'c', 'query exists') = '' then call vrmessage vrwindow(), msg.0543
        else address cmd 'start /F e.exe newinst\memboot.scr <con >con 2>con'
    end
return

/*:VRX         PB_29_Click
*/
PB_29_Click: 
    if stream('newinst\addons.cfg', 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0544
    end
    else do
        address cmd 'start /F e.exe newinst\addons.cfg <con >con 2>con'
    end

return

/*:VRX         PB_2_Click
*/
PB_2_Click: 

    bt.0=2
    bt.1=msg.0356
    bt.2=msg.0357

    /* check if go4it flag is present */
    if stream('go4it.bsy','c','query exists')<>'' then do
        call vrmessage vrwindow(),'Go4it 'msg.0358,msg.0361,'I','bt.',1,2
        if result=2 then return /* No */
    end

    if stream('record.bsy', 'c', 'query exists') <> '' then do
        call vrmessage vrwindow(), cdrprg' 'msg.0358,msg.0361, 'I', 'bt.', 1, 2
        if result = 2 then return /* No */
    end

    /* check for unsaved changes */
    if changed=1 then do
        /* beep */
        call beep 400,100
        call beep 600,200
        call vrmessage vrwindow(),msg.0359,msg.0360,'I','bt.',1,2
        if result=1 then do 
            call PB_1_Click
            changed=0
        end
    end

    /* check if (virtual) floppy is inserted */
    flpdrv = translate(VRGet( "EF_5", "Value" ))
    free = SysDriveInfo(flpdrv)
    parse var free . . free .
    if free <> 1457664 then do
        if flpdrv = 'A:' then do
            do while free <> 1457664
                call vrmessage vrwindow(), msg.0362, msg.0086,'I','bt.',1,2
                if result = 2 then return
                free = SysDriveInfo(flpdrv)
                parse var free . . free .
            end
        end
        else do
            call vrmessage vrwindow(), msg.0363, msg.0086,'I','bt.',1,2
            if result = 2 then return
            else do
                if VRGet( "RB_1", "Set" ) = 1 then do
                    '@svdc /e 'flpdrv
                    '@svdc /i:1.44 'flpdrv
                end
                else do
                    '@vfctrl 'flpdrv' 0'
                    '@vfctrl 'flpdrv' 1'
                end
                if rc <> 0 then do
                    call vrmessage vrwindow(), msg.0347
                    return
                end
            end
        end
    end

    if stream('go4it.cmd','c','query exists')='' then do
        call vrmessage vrwindow(),msg.0364,msg.0086,"E"
        return
    end
    address cmd 'start 'msg.0365' <con >con 2>con'

return

/*:VRX         PB_30_Click
*/
PB_30_Click:

    param_string = msg.0569'*'msg.0570'*'msg.0571'*'msg.0519'*'os2ver'*'nologo'*'msg.0572'*'msg.0573'*'nosniff'*'msg.0574'*'msg.0575'*'nodasd'*'msg.0576'*'msg.0577'*'nojoliet'*'msg.0578'*'msg.0579'*'rdrive'*'msg.0550'*'msg.0561'*'noshield'*'msg.0581'*'msg.0582'*'extrap2'*'msg.0583'*'msg.0584'*'nonetscape'*'msg.0585'*'msg.0586'*'nojava'*'msg.0587'*'msg.0588

    return_string = OptDialg(VRInfo("Window"),param_string)
    parse value return_string with options_changed '*' nologo '*' nosniff '*' nodasd '*' nojoliet '*' rdrive '*' noshield '*' extrap2 '*' nonetscape '*' nojava

    if options_changed = 1 then changed = 1

return

/*:VRX         PB_3_Click
*/
PB_3_Click: 

    if stream(cdrprg, 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0366
    end
    else do
        bt.0 = 2
        bt.1 = msg.0356
        bt.2 = msg.0357

        if stream('record.bsy', 'c', 'query exists') <> '' then do
            call vrmessage vrwindow(), cdrprg' 'msg.0358, msg.0361, 'I', 'bt.', 1, 2
            if result = 2 then return /* No */
        end

        if stream('go4it.bsy','c','query exists')<>'' then do
            call vrmessage vrwindow(),  'Go4it 'msg.0358, msg.0361, 'I', 'bt.', 1, 2
            if result=2 then return /* No */
        end

        if changed = 1 then do

            /* beep */
            call beep 400, 100
            call beep 600, 200

            bt.0 = 2
            bt.1 = msg.0356
            bt.2 = msg.0357
            call vrmessage vrwindow(), msg.0367, msg.0360, 'I', 'bt.', 1, 2

            if result = 1 then do 
                call PB_1_Click
                changed = 0
            end
        end

        address cmd 'start 'msg.0368' /F 'cdrprg' <con >con 2>con'

    end

return

/*:VRX         PB_4_Click
*/
PB_4_Click: 
    if stream('readme.eng', 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0333
    end
    else do
        address cmd 'start /F e.exe 'msg.0334' <con >con 2>con'
    end
return

/*:VRX         PB_5_Click
*/
PB_5_Click: 
  
    if changed = 1 then do

        /* beep */
        call beep 400, 100
        call beep 600, 200

        bt.0 = 2
        bt.1 = msg.0356
        bt.2 = msg.0357
        call vrmessage vrwindow(), msg.0369, msg.0360, 'I', 'bt.', 1, 2

        if result = 1 then /* OK */
            call PB_1_Click
    end
    call Quit

return

/*:VRX         PB_6_Click
*/
PB_6_Click: 
    go4it = 'lib\general.rlb'
    os2_version = VRGet( "DDCB_1", "Value" )
    if os2_version = 'Warp 4' then os2_version = 'WARP4'
    if os2_version = 'Warp 3' then os2_version = 'WARP3'
    if os2_version = 'MCP/ACP' then os2_version = 'CP'
    if os2_version = 'MCP1/ACP1' then os2_version = 'CP'
    if os2_version = 'eCS' then os2_version = 'eCS 1.0'
    if os2_version = 'eCS 1.1' then os2_version = 'CP'
    if stream(go4it, 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0370' 'go4it
    end
    else do
        lg = 'lg.cmd'
        call sysfiledelete lg
        call lineout lg, '/* rexx */'
        call lineout lg, 'fixes="'fixes'"'
        call lineout lg, 'call find_fixpaks fixes "'os2_version'"'
        call lineout lg, 'exit'

        read = 0
        do while lines(go4it)
            l = linein(go4it)
            if pos('find_fixpaks:', l) > 0 then read = 1
            if read = 1 & pos('return', l) > 0 then do
                call lineout lg, l
                read = 0
                leave
            end
            if read = 1 then do
                call lineout lg, l
            end
        end
        call lineout go4it

        read = 0
        do while lines(go4it)
            l = linein(go4it)
            if pos('get_fixpak_version:', l) > 0 then read = 1
            if read = 1 & pos('return', l) > 0 then do
                call lineout lg, l
                read = 0
                leave
            end
            if read = 1 then do
                call lineout lg, l
            end
        end
        call lineout go4it

        call lineout lg
        cmd=lg' 2>NUL | rxqueue 2>NUL'
        cmd

        i=1
        do while queued() <> 0
            l.i = linein("QUEUE:")
            i=i+1
        end
        i.0 = i-1
        call sysfiledelete lg

        l.0 = i.0
        /* rc = VrMessageStem(VrWindow(), 'l.', 'Recognized fixes', 'N') */
        listwindow_caption=msg.0371
        call VRLoadSecondary "ListWindow","Wait"
    end

return

/*:VRX         PB_7_Click
*/
PB_7_Click: 
    go4it = 'lib\general.rlb'
    os2_version = VRGet( "DDCB_1", "Value" )
    if os2_version = 'Warp 4' then os2_version = 'WARP4'
    if os2_version = 'Warp 3' then os2_version = 'WARP3'
    if os2_version = 'MCP/ACP' then os2_version = 'CP'
    if os2_version = 'MCP1/ACP1' then os2_version = 'CP'
    if os2_version = 'eCS' then os2_version = 'eCS 1.0'
    if os2_version = 'eCS 1.1' then os2_version = 'CP'
    if stream(go4it, 'c', 'query exists') = '' then  do
        call vrmessage vrwindow(), msg.0370
    end
    else do
        lg = 'lg.cmd'
        call sysfiledelete lg
        read = 0
        call lineout lg, '/* rexx */'
        call lineout lg, 'updates="'updates'"'
        call lineout lg, 'call find_updates updates "'os2_version'"'
        call lineout lg, 'exit'
        do while lines(go4it)
            l = linein(go4it)
            if pos('find_updates:', l) > 0 then read = 1
            if read = 1 & pos('return', l) > 0 then do
                call lineout lg, 'return'
                read = 0
                leave
            end
            if read = 1 then do
                call lineout lg, l
            end
        end
        call lineout go4it
        call lineout lg, 'exit'
        call lineout lg

        cmd=lg' 2>NUL | rxqueue 2>NUL'
        cmd

        i=1
        do while queued() <> 0
            l.i = linein("QUEUE:")
            i=i+1
        end
        i.0 = i-1
        call sysfiledelete lg

        l.0 = i.0
        /* rc = VrMessageStem(VrWindow(), 'l.', 'Recognized updates', 'N') */
        listwindow_caption=msg.0372
        call VRLoadSecondary "ListWindow","Wait"
    end

return

/*:VRX         PB_8_Click
*/
PB_8_Click: 
    ini = w4cd'\os2image\disk_2\syslevel.os2'
    if os2ver = 'Warp 3'    then    ini = w4cd'\os2image\disk_1\syslevel.os2'
    if os2ver = 'eCS 1.0'   then    ini = w4cd'\os2\install\syslevel.os2'

    if stream(ini, 'c', 'query exists') <> '' then do
	do while lines(ini)
    	   l=linein(ini)
  	   if pos('_Warp Server', l) > 0 then do
		lang = substr(l, pos('XR', l), 3)
    	        call vrmessage vrwindow(), msg.0374' 'lang
		/* say lang */
	   end
	   else if pos('_Convenience Package', l) > 0 then do
		lang = substr(l, pos('XR', l), 3)
    	        if os2ver = 'eCS 1.0' then call vrmessage vrwindow(), msg.0375' 'lang
                else call vrmessage vrwindow(), msg.0376' 'lang
		/* say lang */
	   end
          else /* if pos('5639A6100', l) > 0 | pos('562274700', l) > 0 then */ do
		lang = substr(l, pos('XR', l), 3)
    	        call vrmessage vrwindow(), msg.0373' 'lang
		/* say lang */
	   end

	end
       call lineout ini
    end
    else do
	call vrmessage vrwindow(), msg.0377
    end

return

/*:VRX         PB_9_Click
*/
PB_9_Click: 
    free = substr(burn, 1, 2)
    free = SysDriveInfo(free)
    parse var free . free .
    if free = '' then do
        call vrmessage vrwindow(), msg.0336
    end
    else do
        if datatype(free) = 'NUM' then do
            free = trunc(free/(1024*1024))'MB'
            call vrmessage vrwindow(), msg.0337' 'free
        end
        else call vrmessage vrwindow(), msg.0338
    end
return

/*:VRX         Quit
*/
Quit:
window = VRWindow()
call VRSet window, "Shutdown", 1
drop window
return

/*:VRX         RB_1_Click
*/
RB_1_Click: 
    call VRSet "RB_2", "Set", 0 
    call SysIni , 'UPDCD', 'VDISK', 'SVDISK'
return


/*:VRX         RB_2_Click
*/
RB_2_Click: 
    call VRSet "RB_1", "Set", 0 
    call SysIni , 'UPDCD', 'VDISK', 'VFDISK'
return

/*:VRX         RB_3_Click
*/
RB_3_Click: 
    call VRSet "RB_4", "Set", 0 
    call SysIni , 'UPDCD', 'BPROG', 'CDR'
    cdrdir = VRGet( "EF_12", "Value" )
    cdrdir = strip(cdrdir, 'T', '\')
    if stream(cdrdir'\mkisofs.exe', 'c', 'query exists') <> '' then do
        call VRSet "EF_11", "Enabled",1
        call VRSet "PB_23", "Enabled",1
        call VRSet "PB_12", "Enabled",1
        call VRSet "PB_3", "Enabled",1
        call VRSet "MN_File_Burn","Enabled",1
        call VRSet "CB_1", "Enabled", 1 
        if stream(cdrdir'\cdrecord.exe', 'c', 'query exists') <> '' then do
            call VRSet "EF_16", "Enabled",1
            call VRSet "EF_7", "Enabled",1
            call VRSet "EF_8", "Enabled",1
            call VRSet "EF_9", "Enabled",1
            call VRSet "EF_14", "Enabled",1
        end
    end
    else do
        call VRSet "EF_11", "Enabled",0
        call VRSet "PB_23", "Enabled",0
        call VRSet "PB_12", "Enabled",0
        call VRSet "EF_16", "Enabled",0
        call VRSet "EF_7", "Enabled",0
        call VRSet "EF_8", "Enabled",0
        call VRSet "EF_9", "Enabled",0
        call VRSet "EF_14", "Enabled",0
        enabled = VRGet( "RB_4", "Enabled" )
        set = VRGet( "RB_4", "Set" )
        if enabled = 0 | set = 0 then do
            call VRSet "PB_3", "Enabled", 0 
            call VRSet "MN_File_Burn","Enabled",0
        end
    end
return

/*:VRX         RB_4_Click
*/
RB_4_Click: 
    call VRSet "CB_6", "Set", 1 
    call VRSet "RB_3", "Set", 0 
    call SysIni , 'UPDCD', 'BPROG', 'RSJ'
    call VRSet "EF_11", "Enabled",0
    call VRSet "PB_23", "Enabled",0
    call VRSet "PB_12", "Enabled",0
    call VRSet "EF_16", "Enabled",0
    call VRSet "EF_7", "Enabled",0
    call VRSet "EF_8", "Enabled",0
    call VRSet "EF_9", "Enabled",0
    call VRSet "EF_14", "Enabled",0
    call VRSet "PB_3", "Enabled", 1 
    call VRSet "CB_1", "Enabled", 0 
return

/*:VRX         Read_Config_File
*/
Read_Config_File: 

    parse arg cfgfile

    if stream(cfgfile, 'c', 'query exists') = '' then do
        bt.0=1
        bt.1='OK'
        call vrmessage vrwindow(),msg.0152' updcd.cfg',msg.0361,'I','bt.',1
        call quit
    end

    do while lines(cfgfile)
        l=linein(cfgfile)
        interpret l
    end
    call lineout cfgfile 

    if datatype(iaddons)       <> 'NUM' then iaddons       = 1
    if datatype(compress)      <> 'NUM' then compress      = 1
    if datatype(add.dani.ide)  <> 'NUM' then add.dani.ide  = 0
    if datatype(add.dani.flt)  <> 'NUM' then add.dani.flt  = 0
    if datatype(add.dani.boot) <> 'NUM' then add.dani.boot = 0
    if datatype(add.dani.dasd) <> 'NUM' then add.dani.dasd = 0
    if datatype(add.up2tb)     <> 'NUM' then add.up2tb     = 0
    if datatype(add.fat32)     <> 'NUM' then add.fat32     = 0
    if datatype(add.usb)       <> 'NUM' then add.usb       = 0
    if datatype(add.dummy)     <> 'NUM' then add.dummy     = 0
    if datatype(speed)         <> 'NUM' then speed         = 2
    if datatype(emulate)       <> 'NUM' then emulate       = 1
    if datatype(use_dvd)       <> 'NUM' then use_dvd       = 0
    if datatype(nologo)        <> 'NUM' then nologo        = 0
    if datatype(nojoliet)      <> 'NUM' then nojoliet      = 0
    if datatype(nosniff)       <> 'NUM' then nosniff       = 0
    if datatype(noshield)      <> 'NUM' then noshield      = 0
    if datatype(nodasd)        <> 'NUM' then nodasd        = 1
    if datatype(nonetscape)    <> 'NUM' then nonetscape    = 0
    if datatype(nojava)        <> 'NUM' then nojava        = 0

    /* need to know full path */
    curdir = strip(directory(), , '\')
    if pos(':', fixes) = 0 then
        if substr(fixes, 1, 1) = '\' then fixes = translate(substr(curdir, 1, 2)||fixes)
        else fixes = translate(curdir'\'fixes)
    else fixes = translate(fixes)
    if pos(':', updates) = 0 then
        if substr(updates, 1, 1) = '\' then updates = translate(substr(curdir, 1, 2)||updates)
        else updates = translate(curdir'\'updates)
    else updates = translate(updates)
    if pos(':', addons) = 0 then
        if substr(addons, 1, 1) = '\' then addons = translate(substr(curdir, 1, 2)||addons)
        else addons = translate(curdir'\'addons)
    else addons = translate(addons)
    if pos(':', w4cd) = 0 then
        if substr(w4cd, 1, 1) = '\' then w4cd = translate(substr(curdir, 1, 2)||w4cd)
        else w4cd = translate(curdir'\'w4cd)
    else w4cd = translate(w4cd)
    if pos(':', burn) = 0 then
        if substr(burn, 1, 1) = '\' then burn = translate(substr(curdir, 1, 2)||burn)
        else burn = translate(curdir'\'burn)
    else burn = translate(burn)

    if substr(flpdrv, 2, 1) <> ':' | length(flpdrv) <> 2 then 
        flpdrv = 'A:' 
    else
        flpdrv = translate(flpdrv)

    log = translate(log)

    call VRSet "EF_1", "Value", fixes
    call VRSet "EF_2", "Value", updates
    call VRSet "EF_15", "Value", addons
    call VRSet "EF_3", "Value", w4cd
    call VRSet "EF_4", "Value", burn
    call VRSet "EF_5", "Value", flpdrv
    call VRSet "EF_16", "Value", speed 

    id.1 = substr(device, 1, 1)
    id.2 = substr(device, 3, 1)
    id.3 = substr(device, 5, 1)
    if datatype(id.1) <> 'NUM' then id.1 = 0
    if datatype(id.2) <> 'NUM' then id.2 = 0
    if datatype(id.3) <> 'NUM' then id.3 = 0
    call VRSet "EF_7", "Value", id.1 
    call VRSet "EF_8", "Value", id.2 
    call VRSet "EF_9", "Value", id.3 

    if Symbol('extrap')='VAR' then call VRSet "EF_14", "Value", extrap
    else extrap=""

    if Symbol('extrap2')<>'VAR' then extrap2=""

    if iaddons = 0 then 
        ok = VRSet( "CB_2", "Set", 0 )
    else 
        ok = VRSet( "CB_2", "Set", 1 )

    if compress = 0 then 
        ok = VRSet( "CB_3", "Set", 0 )
    else 
        ok = VRSet( "CB_3", "Set", 1 )

    if add.dani.ide = 0 then 
        ok = VRSet( "CB_4", "Set", 0 )
    else 
        ok = VRSet( "CB_4", "Set", 1 )

    if add.dani.flt = 0 then 
        ok = VRSet( "CB_7", "Set", 0 )
    else 
        ok = VRSet( "CB_7", "Set", 1 )

    if add.dani.boot = 0 then 
        ok = VRSet( "CB_8", "Set", 0 )
    else 
        ok = VRSet( "CB_8", "Set", 1 )

    if add.dani.dasd = 0 then 
        ok = VRSet( "CB_9", "Set", 0 )
    else 
        ok = VRSet( "CB_9", "Set", 1 )

    if add.up2tb = 0 then 
        ok = VRSet( "CB_10", "Set", 0 )
    else 
        ok = VRSet( "CB_10", "Set", 1 )

    if add.fat32 = 0 then 
        ok = VRSet( "CB_11", "Set", 0 )
    else 
        ok = VRSet( "CB_11", "Set", 1 )

    if add.usb = 0 then 
        ok = VRSet( "CB_12", "Set", 0 )
    else 
        ok = VRSet( "CB_12", "Set", 1 )

    if add.dummy = 0 then 
        ok = VRSet( "CB_5", "Set", 0 )
    else 
        ok = VRSet( "CB_5", "Set", 1 )

    if emulate = 0 then 
        ok = VRSet( "CB_6", "Set", 0 )
    else 
        ok = VRSet( "CB_6", "Set", 1 )

    if pos(':', log) = 0 then
        if substr(log, 1, 1) = '\' then log = translate(substr(curdir, 1, 2)||log)
        else log = translate(curdir'\'log)
    else log = translate(log)
    ok = VRSet( "EF_6", "Value", log ) 

    if pos(':', burnlog) = 0 then
        if substr(burnlog, 1, 1) = '\' then burnlog = translate(substr(curdir, 1, 2)||burnlog)
        else burnlog = translate(curdir'\'burnlog)
    else burnlog = translate(burnlog)  
    ok = VRSet( "EF_10", "Value", burnlog )

    if pos(':', tempraw) = 0 then
        if substr(tempraw, 1, 1) = '\' then tempraw = translate(substr(curdir, 1, 2)||tempraw)
        else tempraw = translate(curdir'\'tempraw)
    else tempraw = translate(tempraw)
    ok = VRSet( "EF_11", "Value", tempraw )

    if pos(':', cdrdir) = 0 then
        if substr(cdrdir, 1, 1) = '\' then cdrdir = translate(substr(curdir, 1, 2)||cdrdir)
        else cdrdir = translate(curdir'\'cdrdir)
    else cdrdir = translate(cdrdir)
    ok = VRSet( "EF_12", "Value", cdrdir )

    /* reservedriveletter */
    if length(rdrive) <> 1 | datatype(rdrive) = 'NUM' then rdrive = 'W'

    if use_dvd = 0 then 
        ok = VRSet( "CB_1", "Set", 0 )
    else 
        ok = VRSet( "CB_1", "Set", 1 )

    if viewer = '' then viewer = 'more <'

return

/*:VRX         Save_Config_File
*/
Save_Config_File: 

    parse arg cfgfile

    rc = SysFileDelete(cfgfile)
    rc = lineout(cfgfile, "/* UpdCD configuration file, edit with care! */")
    rc = lineout(cfgfile, " ")
    rc = lineout(cfgfile, "/* Go4It parameters */")
    rc = lineout(cfgfile, "burn    = '"burn"' /* location updated CD-ROM */")
    rc = lineout(cfgfile, "w4cd    = '"w4cd"' /* location original CD-ROM */")
    rc = lineout(cfgfile, "fixes   = '"fixes"' /* fixes directory */")
    rc = lineout(cfgfile, "updates = '"updates"' /* updates directory */")
    rc = lineout(cfgfile, "addons = '"addons"' /* addons directory */")
    rc = lineout(cfgfile, "iaddons  = "iaddons" /* 1 = integrate add-on products */")
    rc = lineout(cfgfile, "log     = '"log"'  /* log file */")
    rc = lineout(cfgfile, " ")
    rc = lineout(cfgfile, "/* updif parameters */")
    rc = lineout(cfgfile, "flpdrv  = translate('"flpdrv"') /* <----- change it match your virtual floppy */")
    rc = lineout(cfgfile, "compress = "compress" /* 0 = do not compress files on boot diskette */")
    rc = lineout(cfgfile, "add.dani.ide = "add.dani.ide" /* 1 = add DANI IDE driver if it is available as addon's */")
    rc = lineout(cfgfile, "add.dani.flt = "add.dani.flt" /* 1 = add DANI FLT driver if it is available as addon's */")
    rc = lineout(cfgfile, "add.dani.boot = "add.dani.boot" /* 1 = add DANI Boot driver if it is available as addon's */")
    rc = lineout(cfgfile, "add.dani.dasd = "add.dani.dasd" /* 1 = add DANI DASD driver if it is available as addon's */")
    rc = lineout(cfgfile, "add.up2tb = "add.up2tb" /* 1 = add Up2TB driver */")
    rc = lineout(cfgfile, "add.fat32 = "add.fat32" /* 1 = add FAT32 driver to boot CD */")
    rc = lineout(cfgfile, "add.usb = "add.usb" /* 1 = add USB driver to boot CD */")
    rc = lineout(cfgfile, "add.dummy = "add.dummy" /* 0 = do not add new ADD's and do not replace SCSI drivers with dummy driver to save space */")
    rc = lineout(cfgfile, "rdrive = '"rdrive"' /* drive letter to reserve with reservedriveletter in cfg.sys */")
    rc = lineout(cfgfile, "emulate = "emulate" /* floppy emulation mode; do not emulate floppy = 0 */")
    rc = lineout(cfgfile, "nologo = "nologo" /* 1 = remove os2logo */")
    rc = lineout(cfgfile, " ")
    rc = lineout(cfgfile, "/* misc parameters */")
    rc = lineout(cfgfile, "nosniff = "nosniff" /* 1 = do not detect ISA NIC's during install */")
    rc = lineout(cfgfile, "nodasd = "nodasd" /* 1 = do not check free disk space during install */")
    rc = lineout(cfgfile, "noshield = "noshield" /* 1 = disable installation shield */")
    rc = lineout(cfgfile, "nonetscape = "nonetscape" /* 1 = remove netscape communicator */")
    rc = lineout(cfgfile, "nojava = "nojava" /* 1 = remove old java run-time */")

    rc = lineout(cfgfile, " ")
    rc = lineout(cfgfile, "/* burning parameters */")
    rc = lineout(cfgfile, "rootdir = '"strip(rootdir, 'T', '\')"'")
    rc = lineout(cfgfile, "device  = '"id.1","id.2","id.3"' /* SCSI device ID (bus, unit, lun) */")
    rc = lineout(cfgfile, "speed   = "speed" /* burning speed  */")
    rc = lineout(cfgfile, "tempdir = '"strip(filespec('drive', tempraw)||filespec('path', tempraw), 'T', '\')"' /* imagefile dir  */")
    rc = lineout(cfgfile, "tempraw = '"tempraw"' /* ISO image file */")
    rc = lineout(cfgfile, "source  = '"burn"' /* burn directory */")
    rc = lineout(cfgfile, "cdrdir  = '"cdrdir"' /* mkisofs (and cdrecord) dir */")
    rc = lineout(cfgfile, "svdc_drive = flpdrv /* virtual flop   */")
    rc = lineout(cfgfile, "burnlog = '"burnlog"' /* burn log file  */")
    rc = lineout(cfgfile, "viewer  = '"viewer"'")
    rc = lineout(cfgfile, "extrap  = '"extrap"' /* Extra parameters for cdrecord/2 */")
    rc = lineout(cfgfile, "extrap2 = '"extrap2"' /* Extra parameters for mkisofs */")
    rc = lineout(cfgfile, "use_dvd = "use_dvd" /* 1 = use DVDDAO instead of CDRECORD */")
    rc = lineout(cfgfile, "nojoliet = "nojoliet" /* 1 = do not use joliet support */")
    rc = lineout(cfgfile)

return

/*:VRX         set_text_labels_of_main_window
*/
set_text_labels_of_main_window: 

    call VRSet vrwindow(), "Caption", msg.0325" updcd.cfg]"
    call vrset vrwindow(), "windowlisttitle", msg.0326

    call VRSet "DT_1", "Caption", msg.0389 
    call VRSet "DT_2", "Caption", msg.0378 
    call VRSet "DT_3", "Caption", msg.0379 
    call VRSet "DT_4", "Caption", msg.0381 
    call VRSet "DT_5", "Caption", msg.0382 
    call VRSet "DT_6", "Caption", msg.0390 
    call VRSet "DT_7", "Caption", msg.0380 
    call VRSet "DT_8", "Caption", msg.0384 
    call VRSet "DT_9", "Caption", msg.0388 
    call VRSet "DT_10", "Caption", msg.0385
    call VRSet "DT_11", "Caption", msg.0386
    call VRSet "DT_12", "Caption", msg.0387
    call VRSet "DT_15", "Caption", msg.0383 

    call VRSet "GB_1", "Caption", msg.0391
    call VRSet "GB_2", "Caption", msg.0392
    call VRSet "GB_3", "Caption", msg.0394
    call VRSet "GB_4", "Caption", msg.0395
    call VRSet "GB_5", "Caption", msg.0397
    call VRSet "GB_6", "Caption", msg.0393
    call VRSet "GB_7", "Caption", msg.0396
    call VRSet "GB_8", "Caption", msg.0431
    call VRSet "GB_9", "Caption", msg.0551

    call VRSet "PB_1", "Caption", msg.0401
    call VRSet "PB_2", "Caption", msg.0402
    call VRSet "PB_3", "Caption", msg.0403
    call VRSet "PB_4", "Caption", msg.0404
    call VRSet "PB_5", "Caption", msg.0405
    call VRSet "PB_6", "Caption", msg.0399
    call VRSet "PB_7", "Caption", msg.0399
    call VRSet "PB_8", "Caption", msg.0399
    call VRSet "PB_9", "Caption", msg.0399
    call VRSet "PB_10", "Caption", msg.0400
    call VRSet "PB_11", "Caption", msg.0400
    call VRSet "PB_12", "Caption", msg.0399
    call VRSet "PB_13", "Caption", msg.0552
    call VRSet "PB_14", "Caption", msg.0399
    call VRSet "PB_15", "Caption", msg.0407
    call VRSet "PB_16", "Caption", msg.0398
    call VRSet "PB_17", "Caption", msg.0398
    call VRSet "PB_18", "Caption", msg.0398
    call VRSet "PB_19", "Caption", msg.0398
    call VRSet "PB_20", "Caption", msg.0398
    call VRSet "PB_21", "Caption", msg.0398
    call VRSet "PB_22", "Caption", msg.0398
    call VRSet "PB_23", "Caption", msg.0398
    call VRSet "PB_24", "Caption", msg.0406
    call VRSet "PB_25", "Caption", msg.0399
    call VRSet "PB_26", "Caption", msg.0399
    call VRSet "PB_27", "Caption", msg.0398
    call VRSet "PB_28", "Caption", msg.0553
    call VRSet "PB_29", "Caption", msg.0554
    call VRSet "PB_30", "Caption", msg.0580

    call VRSet "CB_1", "Caption", msg.0555
    call VRSet "CB_2", "Caption", msg.0408
    call VRSet "CB_3", "Caption", msg.0409
    call VRSet "CB_4", "Caption", msg.0411
    call VRSet "CB_5", "Caption", msg.0410
    call VRSet "CB_6", "Caption", msg.0480
    call VRSet "CB_7", "Caption", msg.0545
    call VRSet "CB_8", "Caption", msg.0546
    call VRSet "CB_9", "Caption", msg.0547
    call VRSet "CB_10", "Caption", msg.0548
    call VRSet "CB_11", "Caption", msg.0549
    call VRSet "CB_12", "Caption", msg.0597

    call VRSet "RB_1", "Caption", msg.0412
    call VRSet "RB_2", "Caption", msg.0413
    call VRSet "RB_3", "Caption", msg.0414
    call VRSet "RB_4", "Caption", msg.0415

    call VRSet "MN_File", "Caption", msg.0416
    call VRSet "MN_File_Load", "Caption", msg.0417
    call VRSet "MN_File_Save", "Caption", msg.0418
    call VRSet "MN_File_SaveAs", "Caption", msg.0419
    call VRSet "MN_File_Build", "Caption", msg.0420
    call VRSet "MN_File_Burn", "Caption", msg.0421
    call VRSet "MN_File_Listaddons", "Caption", msg.0422
    call VRSet "MN_File_Exit", "Caption", msg.0423
    call VRSet "MN_Help", "Caption", msg.0424
    call VRSet "MN_Help_Readme", "Caption", msg.0425
    call VRSet "MN_Help_FAQ", "Caption", msg.0426
    call VRSet "MN_Help_About", "Caption", msg.0427

    call VRSet "PB_6", "HintText", msg.0430
    call VRSet "PB_7", "HintText", msg.0434
    call VRSet "PB_26", "HintText", msg.0435
    call VRSet "PB_8", "HintText", msg.0436
    call VRSet "PB_9", "HintText", msg.0437
    call VRSet "PB_14", "HintText", msg.0438
    call VRSet "PB_10", "HintText", msg.0439
    call VRSet "PB_11", "HintText", msg.0439
    call VRSet "PB_12", "HintText", msg.0440
    call VRSet "PB_16", "HintText", msg.0441
    call VRSet "PB_17", "HintText", msg.0441
    call VRSet "PB_27", "HintText", msg.0441
    call VRSet "PB_18", "HintText", msg.0441
    call VRSet "PB_19", "HintText", msg.0441
    call VRSet "PB_20", "HintText", msg.0441
    call VRSet "PB_21", "HintText", msg.0442
    call VRSet "PB_22", "HintText", msg.0442
    call VRSet "PB_23", "HintText", msg.0442
    call VRSet "PB_1", "HintText", msg.0443
    call VRSet "PB_2", "HintText", msg.0444
    call VRSet "PB_3", "HintText", msg.0445
    call VRSet "PB_4", "HintText", msg.0446
    call VRSet "PB_5", "HintText", msg.0447
    call VRSet "PB_13", "HintText", msg.0562
    call VRSet "PB_28", "HintText", msg.0563
    call VRSet "PB_29", "HintText", msg.0564
    call VRSet "DDCB_1", "HintText", msg.0448
    call VRSet "DDCB_2", "HintText", msg.0449
    call VRSet "CB_1", "HintText", msg.0565
    call VRSet "CB_3", "HintText", msg.0450
    call VRSet "CB_2", "HintText", msg.0451
    call VRSet "CB_5", "HintText", msg.0452
    call VRSet "CB_6", "HintText", msg.0481
    call VRSet "CB_7", "HintText", msg.0556
    call VRSet "CB_8", "HintText", msg.0557
    call VRSet "CB_9", "HintText", msg.0558
    call VRSet "CB_10", "HintText", msg.0559
    call VRSet "CB_11", "HintText", msg.0560
    call VRSet "CB_12", "HintText", msg.0598
    call VRSet "CB_4", "HintText", msg.0453
    call VRSet "PB_24", "HintText", msg.0455
    call VRSet "PB_15", "HintText", msg.0456
    call VRSet "PB_25", "HintText", msg.0457
    call VRSet "RB_1", "HintText", msg.0458
    call VRSet "RB_2", "HintText", msg.0459
    call VRSet "RB_3", "HintText", msg.0460
    call VRSet "RB_4", "HintText", msg.0461
    call VRSet "EF_5", "HintText", msg.0454
    call VRSet "EF_16", "HintText", msg.0462
    call VRSet "EF_7", "HintText", msg.0463
    call VRSet "EF_8", "HintText", msg.0464
    call VRSet "EF_9", "HintText", msg.0465
    call VRSet "EF_14", "HintText", msg.0466
    call VRSet "EF_1", "HintText", msg.0468
    call VRSet "EF_2", "HintText", msg.0469
    call VRSet "EF_15", "HintText", msg.0470
    call VRSet "EF_3", "HintText", msg.0471
    call VRSet "EF_4", "HintText", msg.0472
    call VRSet "EF_12", "HintText", msg.0473
    call VRSet "EF_6", "HintText", msg.0474
    call VRSet "EF_10", "HintText", msg.0475
    call VRSet "EF_11", "HintText", msg.0476

return

