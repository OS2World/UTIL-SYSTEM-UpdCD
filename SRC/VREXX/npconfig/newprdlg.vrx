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

/*:VRX         CB_10_Click
*/
CB_10_Click: 
    set = VRGet( "CB_10", "Set" )
    call VRSet "CB_9", "Set", set
return

/*:VRX         CB_9_Click
*/
CB_9_Click: 
    set = VRGet( "CB_9", "Set" )
    call VRSet "CB_10", "Set", set
return

/*:VRX         DDCB_4_Change
*/
DDCB_4_Change: 
    value = VRGet( "DDCB_4", "Value" )
    call VRSet "DDCB_11", "Value", value 
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:

    window = VRWindow()
    call VRMethod window, "CenterWindow", "Desktop"
    call set_text_labels

    /* determine instdir */
    drv = translate(filespec('drive', directory()))
    instpath = 'warpsrv'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'grpware'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'ibminst'

    /* fill drive list */
    DriveMap = SysDriveMap( "C:", "LOCAL" )
    i = 1
    do until DriveMap = ""
        parse var DriveMap Drive DriveMap
        call VRMethod "DDCB_3", "AddString", Drive 
        call VRMethod "DDCB_4", "AddString", Drive 
        call VRMethod "DDCB_5", "AddString", Drive 
        call VRMethod "DDCB_6", "AddString", Drive 
        call VRMethod "DDCB_7", "AddString", Drive 
        call VRMethod "DDCB_8", "AddString", Drive 
        call VRMethod "DDCB_9", "AddString", Drive 
        call VRMethod "DDCB_10", "AddString", Drive 
        call VRMethod "DDCB_11", "AddString", Drive 
        call VRMethod "DDCB_12", "AddString", Drive 
        call VRMethod "DDCB_13", "AddString", Drive 
        drive.i = Drive
        i = i + 1
    end
    drive.0 = i - 1

    /* set default drive */
    do i = 1 to drive.0
        if drv = drive.i then leave
    end
    ok = VRSet( "DDCB_3", "Selected", i )
    ok = VRSet( "DDCB_4", "Selected", i )
    ok = VRSet( "DDCB_5", "Selected", i )
    ok = VRSet( "DDCB_6", "Selected", i )
    ok = VRSet( "DDCB_7", "Selected", i )
    ok = VRSet( "DDCB_8", "Selected", i )
    ok = VRSet( "DDCB_9", "Selected", i )
    ok = VRSet( "DDCB_10", "Selected", i )
    ok = VRSet( "DDCB_11", "Selected", i )
    ok = VRSet( "DDCB_12", "Selected", i )
    ok = VRSet( "DDCB_13", "Selected", i )

    /* get the drive letter of the installation CD */
    imagedir = value("SOURCEPATH", ,"OS2ENVIRONMENT")

    /* enable/disable things for wseb */
    if stream(drv'\'instpath'\npconfig.wsb', 'c', 'query exists') <> '' then do
        call VRSet "DDCB_3", "Visible", 0 
        call VRSet "EF_2", "Visible", 0 
        call VRSet "CB_1", "Visible", 0 
        call VRSet "GB_1", "Visible", 0 
        call VRSet "DT_3", "Visible", 0 
        call VRSet "DT_4", "Visible", 0 
        call VRSet "CB_2", "Enabled", 1 
        imagedir  = filespec('drive', imagedir)||'\CID\SERVER\JAVA' 
        nimagedir = filespec('drive', imagedir)||'\CID\SERVER\NETSCAPE' 
    end
    else
        if instpath = 'warpsrv' then do
           imagedir  = filespec('drive', imagedir)||'\CID\SERVER\JAVA' 
           nimagedir = filespec('drive', imagedir)||'\CID\SERVER\NETSCAPE' 
        end
        else do
           imagedir  = filespec('drive', imagedir)||'\CID\IMG\JAVA' 
           nimagedir = filespec('drive', imagedir)||'\CID\IMG\NETSCAPE' 
        end

    /* no netscape */
    ns_found = 1
    if stream(nimagedir'\install.exe', 'c', 'query exists') = '' then do
        ns_found = 0
        call VRSet "DDCB_3", "Visible", 0 
        call VRSet "EF_2", "Visible", 0 
        call VRSet "CB_1", "Visible", 0 
        call VRSet "GB_1", "Visible", 0 
        call VRSet "DT_3", "Visible", 0 
        call VRSet "DT_4", "Visible", 0 
        call VRSet "CB_2", "Enabled", 1 
    end

    /* get the java syslevel files */
    i=0; jsl.0 = 0
    do while jsl.0 < 1 & i < 5
        call SysFileTree imagedir'\syslevel.*', 'jsl.', 'FO'
        if result <> 0 then call syssleep 1
        i=i+1
    end

    /* find and enable java components */
    java_rt_found = 0
    do i=1 to jsl.0
        if pos('.JAV', translate(jsl.i)) > 0 then do
            java_rt_found = 1
        end
        if pos('.JUF', translate(jsl.i)) > 0 then do
            call VRSet "CB_9", "Enabled", 1  
            call VRSet "CB_10", "Enabled", 1  
        end
        if pos('.JTK', translate(jsl.i)) > 0 then do
            call VRSet "CB_7", "Enabled", 1 
            call VRSet "DDCB_6", "Enabled", 1 
            call VRSet "CB_11", "Enabled", 1 
            call VRSet "DDCB_13", "Enabled", 1 
            java_tk = 1
        end
        if pos('.JSP', translate(jsl.i)) > 0 then do
            call VRSet "CB_3", "Enabled", 1 
            call VRSet "DDCB_5", "Enabled", 1 
        end
        if pos('.ICA', translate(jsl.i)) > 0 then do
            call VRSet "CB_5", "Enabled", 1 
            call VRSet "DDCB_7", "Enabled", 1 
        end
        if pos('.SWR', translate(jsl.i)) > 0 then do
            call VRSet "CB_6", "Enabled", 1 
            call VRSet "DDCB_8", "Enabled", 1 
        end
        if pos('.SWT', translate(jsl.i)) > 0 then do
            call VRSet "CB_4", "Enabled", 1 
            call VRSet "DDCB_9", "Enabled", 1 
        end
        if pos('.RMI', translate(jsl.i)) > 0 then do
            call VRSet "CB_8", "Enabled", 1 
            call VRSet "DDCB_10", "Enabled", 1 
        end
    end

		/* warp 3/4 */
    if ns_found = 0 & java_rt_found = 0 then call PB_1_Click
		/* wseb */
		if stream(drv'\'instpath'\npconfig.wsb', 'c', 'query exists') <> '' & java_rt_found = 0 then call PB_1_Click

    if java_rt_found = 0 then call VRSet "CB_2", "Set", 0 

    if java_tk <> 1 then do
        call VRSet "CB_3", "Enabled", 0 
        call VRSet "DDCB_5", "Enabled", 0 
        call VRSet "CB_5", "Enabled", 0 
        call VRSet "DDCB_7", "Enabled", 0         
    end

    window = VRWindow()
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window

return

/*:VRX         newprdlg_Close
*/
newprdlg_Close:
    call Quit
return

/*:VRX         PB_1_Click
*/
PB_1_Click: 
    
    /* netscape */
    ns_st   = VRGet( "CB_1", "Set" )
    ns_drv  = VRGet( "DDCB_3", "Value" )
    ns_path = VRGet( "EF_2", "Value" )
    ns_path = ns_drv'\'ns_path

    /* java rt */
    java_rt_st  = VRGet( "CB_2", "Set" )
    java_rt_drv = VRGet( "DDCB_4", "Value" )

    /* java un */
    java_un_st  = VRGet( "CB_9", "Set" )
    java_un_drv = VRGet( "DDCB_11", "Value" )

    /* java tt */
    java_tt_st  = VRGet( "CB_10", "Set" )
    java_tt_drv = VRGet( "DDCB_12", "Value" )

    /* java tk */
    java_tk_st  = VRGet( "CB_7", "Set" )
    java_tk_drv = VRGet( "DDCB_6", "Value" )

    /* java td */
    java_td_st  = VRGet( "CB_11", "Set" )
    java_td_drv = VRGet( "DDCB_13", "Value" )

    /* java sp */
    java_sp_st  = VRGet( "CB_3", "Set" )
    java_sp_drv = VRGet( "DDCB_5", "Value" )

    /* java db */
    java_db_st  = VRGet( "CB_5", "Set" )
    java_db_drv = VRGet( "DDCB_7", "Value" )

    /* java sw */
    java_sw_st  = VRGet( "CB_6", "Set" )
    java_sw_drv = VRGet( "DDCB_8", "Value" )

    /* java sr */
    java_sr_st  = VRGet( "CB_4", "Set" )
    java_sr_drv = VRGet( "DDCB_9", "Value" )

    /* java rm */
    java_rm_st  = VRGet( "CB_8", "Set" )
    java_rm_drv = VRGet( "DDCB_10", "Value" )

    drv = filespec('drive', directory())
    out = drv'\'instpath'\npconfig.out'
    'del 'out
    call lineout out, ns_path
    call lineout out, 'runtime 'java_rt_st' 'java_rt_drv
    call lineout out, 'unicode 'java_un_st' 'java_un_drv
    call lineout out, 'ttengine 'java_tt_st' 'java_tt_drv
    call lineout out, 'toolkit 'java_tk_st' 'java_tk_drv
    call lineout out, 'tlktdoc 'java_td_st' 'java_td_drv
    call lineout out, 'samples 'java_sp_st' 'java_sp_drv
    call lineout out, 'debugger 'java_db_st' 'java_db_drv
    call lineout out, 'swingruntime 'java_sw_st' 'java_sw_drv
    call lineout out, 'swingtoolkit 'java_sr_st' 'java_sr_drv
    call lineout out, 'rmiiioptoolkit 'java_rm_st' 'java_rm_drv
    call lineout out

    call quit
return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         set_text_labels
*/
set_text_labels: 

    call VRSet vrwindow(), "Caption", InitArgs.1
    call vrset vrwindow(), "windowlisttitle", InitArgs.1

    call VRSet "GB_1",  "Caption", InitArgs.2
    call VRSet "DT_3",  "Caption", InitArgs.3
    call VRSet "DT_4",  "Caption", InitArgs.4
    call VRSet "GB_2",  "Caption", InitArgs.5
    call VRSet "DT_5",  "Caption", InitArgs.6
    call VRSet "DT_12", "Caption", InitArgs.7
    call VRSet "DT_13", "Caption", InitArgs.8
    call VRSet "DT_7",  "Caption", InitArgs.9
    call VRSet "DT_14", "Caption", InitArgs.10
    call VRSet "DT_6",  "Caption", InitArgs.11
    call VRSet "DT_8",  "Caption", InitArgs.12
    call VRSet "DT_9",  "Caption", InitArgs.13
    call VRSet "DT_10", "Caption", InitArgs.14
    call VRSet "DT_11", "Caption", InitArgs.15
    call VRSet "PB_1",  "Caption", InitArgs.16

return
