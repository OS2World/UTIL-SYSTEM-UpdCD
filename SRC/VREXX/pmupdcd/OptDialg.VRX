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

/*:VRX         CB_1_Click
*/
CB_1_Click: 
    temp = VRGet( "CB_1", "Set" )
    if temp <> nologo then do
        nologo = temp
        changed = 1
    end
return

/*:VRX         CB_2_Click
*/
CB_2_Click: 
    temp = VRGet( "CB_2", "Set" )
    if temp <> nosniff then do
        nosniff = temp
        changed = 1
    end
return

/*:VRX         CB_3_Click
*/
CB_3_Click: 
    temp = VRGet( "CB_3", "Set" )
    if temp <> nojoliet then do
        nojoliet = temp
        changed = 1
    end
return
/*:VRX         CB_4_Click
*/
CB_4_Click: 
    temp = VRGet( "CB_4", "Set" )
    if temp <> nodasd then do
        nodasd = temp
        changed = 1
    end
return

/*:VRX         CB_5_Click
*/
CB_5_Click: 
    temp = VRGet( "CB_5", "Set" )
    if temp <> noshield then do
        noshield = temp
        changed = 1
    end
return

/*:VRX         CB_6_Click
*/
CB_6_Click: 
    temp = VRGet( "CB_6", "Set" )
    if temp <> nonetscape then do
        nonetscape = temp
        changed = 1
    end
return

/*:VRX         CB_7_Click
*/
CB_7_Click: 
    temp = VRGet( "CB_7", "Set" )
    if temp <> nojava then do
        nojava = temp
        changed = 1
    end
return

/*:VRX         EF_1_Change
*/
EF_1_Change: 
    temp = translate(VRGet( "EF_1", "Value" ))
    if length(temp) <> 1 | datatype(temp) = 'NUM' then do
        temp = rdrive
        call VRSet  "EF_1", "Value", temp
    end    
    if temp <> rdrive then do
        rdrive = temp
        changed = 1
    end
return

/*:VRX         EF_2_Change
*/
EF_2_Change: 
    temp = VRGet( "EF_2", "Value" )
    if temp <> extrap2 then do
        extrap2 = temp
        changed = 1
    end
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return Retcode

/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:

    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1

    param_string = InitArgs.1
    i=1
    do while length(param_string) > 0
	parse value param_string with InitArgs.i '*' param_string
	i=i+1
    end

    /* parameters */
    call VRSet "OptDialg", "Caption", InitArgs.1
    call VRSet "GB_1", "Caption", InitArgs.2
    call VRSet "GB_2", "Caption", InitArgs.3
    call VRSet "PB_2", "Caption", InitArgs.4
    os2ver  = InitArgs.5

    nologo = InitArgs.6
    if nologo = 1 then call VRSet "CB_1", "Set", 1 
    else call VRSet "CB_1", "Set", 0
    call VRSet "CB_1", "Caption", InitArgs.7
    call VRSet "CB_1", "HintText", InitArgs.8

    nosniff = InitArgs.9
    if nosniff = 1 then call VRSet "CB_2", "Set", 1 
    else call VRSet "CB_2", "Set", 0
    call VRSet "CB_2", "Caption", InitArgs.10
    call VRSet "CB_2", "HintText", InitArgs.11

    nodasd = InitArgs.12
    if nodasd = 1 then call VRSet "CB_4", "Set", 1 
    else call VRSet "CB_4", "Set", 0
    call VRSet "CB_4", "Caption", InitArgs.13
    call VRSet "CB_4", "HintText", InitArgs.14

    nojoliet = InitArgs.15
    if nojoliet = 1 then call VRSet "CB_3", "Set", 1 
    else call VRSet "CB_3", "Set", 0
    call VRSet "CB_3", "Caption", InitArgs.16
    call VRSet "CB_3", "HintText", InitArgs.17

    rdrive = InitArgs.18
    call VRSet "EF_1", "Value", rdrive
    call VRSet "DT_1", "Caption", InitArgs.19
    call VRSet "EF_1", "HintText", InitArgs.20

    noshield = InitArgs.21
    if noshield = 1 then call VRSet "CB_5", "Set", 1
    else call VRSet "CB_5", "Set", 0
    call VRSet "CB_5", "Caption", InitArgs.22
    call VRSet "CB_5", "HintText", InitArgs.23

    extrap2 = InitArgs.24
    call VRSet "EF_2", "Value", extrap2
    call VRSet "DT_2", "Caption", InitArgs.25
    call VRSet "EF_2", "HintText", InitArgs.26

    nonetscape = InitArgs.27
    if nonetscape = 1 then call VRSet "CB_6", "Set", 1
    else call VRSet "CB_6", "Set", 0
    call VRSet "CB_6", "Caption", InitArgs.28
    call VRSet "CB_6", "HintText", InitArgs.29

    nojava = InitArgs.30
    if nojava = 1 then call VRSet "CB_7", "Set", 1
    else call VRSet "CB_7", "Set", 0
    call VRSet "CB_7", "Caption", InitArgs.31
    call VRSet "CB_7", "HintText", InitArgs.32

    if os2ver = 'eCS 1.0' | os2ver = 'eCS 1.1' then do
        call VRSet "EF_1", "Enabled", 0
        call VRSet "CB_2", "Enabled", 0
        call VRSet "CB_3", "Enabled", 0
        call VRSet "CB_4", "Enabled", 0
        call VRSet "CB_5", "Enabled", 0
        call VRSet "CB_6", "Enabled", 0
        call VRSet "CB_7", "Enabled", 0
        call VRSet "CB_3", "Set", 0
        nojoliet = 0
    end
    
    changed = 0
    Retcode = changed'*'nologo'*'nosniff'*'nodasd'*'nojoliet'*'rdrive'*'noshield'*'extrap2'*'nonetscape'*'nojava

    call VRMethod window, "Activate"
    drop window

return

/*:VRX         OptDialg_Close
*/
OptDialg_Close:
    call Quit
return

/*:VRX         PB_1_Click
*/
PB_1_Click: 
    Retcode = changed'*'nologo'*'nosniff'*'nodasd'*'nojoliet'*'rdrive'*'noshield'*'extrap2'*'nonetscape'*'nojava
    call Quit
return


/*:VRX         PB_2_Click
*/
PB_2_Click: 
    changed = 0
    call Quit
return
/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

