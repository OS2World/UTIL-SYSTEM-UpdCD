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
    call VRMethod window, "CenterWindow"
    call set_text_labels
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window

    /* determine instdir */
    drv = translate(filespec('drive', directory()))
    instpath = 'warpsrv'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'grpware'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'ibminst'

    /* updcd tuning */
    address cmd drv'\'instpath'\tunecfg.cmd 'drv instpath' tunecfg.cfg <con >con 2>con'
    address cmd drv'\'instpath'\tuneini.cmd 'drv instpath' tuneini.cfg <con >con 2>con'
    address cmd drv'\'instpath'\tunefls.cmd 'drv instpath' tunefls.cfg <con >con 2>con'

    /* enable cancel in case user tuning might hang */
    call VRSet "PB_1", "Enabled", 1 

    /* user tuning */
    if stream(drv'\'instpath'\tunecfg.cfu', 'c', 'query exists') <> '' then
        address cmd drv'\'instpath'\tunecfg.cmd 'drv instpath' tunecfg.cfu <con >con 2>con'
    if stream(drv'\'instpath'\tuneini.cfu', 'c', 'query exists') <> '' then
        address cmd drv'\'instpath'\tuneini.cmd 'drv instpath' tuneini.cfu <con >con 2>con'
    if stream(drv'\'instpath'\tunefls.cfu', 'c', 'query exists') <> '' then
        address cmd drv'\'instpath'\tunefls.cmd 'drv instpath' tunefls.cfu <con >con 2>con'

    call quit

return

/*:VRX         PB_1_Click
*/
PB_1_Click: 
    call quit
return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         TuneDLG_Close
*/
TuneDLG_Close:
    call Quit
return

/*:VRX         set_text_labels
*/
set_text_labels: 

    call VRSet vrwindow(), "Caption", InitArgs.1
    call vrset vrwindow(), "windowlisttitle", InitArgs.1

    call VRSet "DT_1",  "Caption", InitArgs.2
    call VRSet "PB_1",  "Caption", InitArgs.3

return
