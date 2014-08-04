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

/*:VRX         DDCB_1_Change
*/
DDCB_1_Change: 
    call detect_status        
return

/*:VRX         detect_status
*/
detect_status: 
    inst_drv = VRGet( "DDCB_1", "Value" )
    inst_path = VRGet( "EF_1", "Value" )
    if inst_path = '\' then
        call SysFileTree inst_drv||inst_path'*', 'inst_files.'
    else
        call SysFileTree inst_drv'\'inst_path'\*', 'inst_files.'
    if inst_files.0 > 0 then 
        call VRSet "EF_4", "Value", "Might be installed" 
    else
        call VRSet "EF_4", "Value", "Not installed" 
return

/*:VRX         DetlsDlg_Close
*/
DetlsDlg_Close:
    call Quit
return

/*:VRX         EF_1_Change
*/
EF_1_Change: 
    call detect_status
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return retcode

/*:VRX         get_parameters
*/
get_parameters: 

    cfgsection = cfgsection||'_'
    start = 0
    do while lines(cfgfile)
        l=linein(cfgfile)
        if start = 0 & substr(translate(l), 1, 3) = translate(cfgsection) then do
            start = 1
	    iterate
	end
	if start = 1 & translate(l) = 'END' then do
	   start = 0
	   call lineout cfgfile
	   leave
	end
	if start = 1 then do
	   interpret l
	end
    end
    call lineout cfgfile
		
return

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
    drv = filespec('drive', directory())
    instpath = 'warpsrv'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'grpware'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'ibminst'

    /* read product specific section of the configuration file */
    product_name    = ''
    product_version = '' 
    product_drv     = ''
    product_path    = ''
    target = drv
    cfgfile = drv'\'instpath'\tables\addons.cfg'
    cfgsection = InitArgs.1
    call get_parameters

    /* disable some controlls */
    if product_drv  = '' then call VRSet "DDCB_1", "Enabled", 0 
    if product_path = '' then call VRSet "EF_1",   "Enabled", 0 

    /* get the complete installation environment */
    cfgsection = 'XX'
    call get_parameters
    cfgsection = InitArgs.1
    call get_parameters

    /* fill drive list */
    /* call rxfuncadd sysdrivemap, rexxutil, sysdrivemap */
    DriveMap = SysDriveMap( "C:", "LOCAL" )
    call VRMethod "DDCB_1", "Clear" 
    i = 1
    do until DriveMap = ""
        parse var DriveMap Drive DriveMap
				/* check if drive not a CD-ROM */
				rc = sysdriveinfo(Drive)
        if rc = '' then iterate
        else do
         parse var rc . free total label
	       if free > 0 then do
								/* check if drive formatted */
								rc = stream(Drive'\updcd.tmp', 'C', 'Open Write')
								if rc = 'READY:' then do
									call lineout Drive'\updcd.tmp'
									'@del 'Drive'\updcd.tmp >nul 2>>&1'
               		call VRMethod "DDCB_1", "AddString", Drive 
                	drive.i = Drive
                	i = i + 1
								end
              end
        end
    end
    drive.0 = i - 1

    /* check if we had a change */
    if InitArgs.2 <> '' then product_drv = InitArgs.2
    if InitArgs.3 <> '' then product_path = InitArgs.3

    /* set drive */
    do i = 1 to drive.0
        if product_drv = drive.i then leave
    end
    ok = VRSet( "DDCB_1", "Selected", i )

    /* set path */
    call VRSet "EF_1", "Value", translate(product_path)

    /* set product name */
    call VRSet "EF_2", "Value", product_name

    /* set product version */
    call VRSet "EF_3", "Value", product_version

    /* set status */
    call detect_status

    /* remember it */
    prev_retcode = VRGet( "DDCB_1", "Value" ) ||' '|| VRGet( "EF_1", "Value" )

return

/*:VRX         PB_1_Click
*/
PB_1_Click: 
    retcode = VRGet( "DDCB_1", "Value" ) ||' '|| VRGet( "EF_1", "Value" )
    call quit
return

/*:VRX         PB_2_Click
*/
PB_2_Click: 
    retcode = prev_retcode
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

    call VRSet vrwindow(), "Caption", InitArgs.4
    call vrset vrwindow(), "windowlisttitle", InitArgs.4

    call VRSet "GB_1",  "Caption", InitArgs.5
    call VRSet "DT_1",  "Caption", InitArgs.6
    call VRSet "DT_2",  "Caption", InitArgs.7
    call VRSet "GB_3",  "Caption", InitArgs.8
    call VRSet "DT_3",  "Caption", InitArgs.9
    call VRSet "DT_5",  "Caption", InitArgs.10
    call VRSet "DT_6",  "Caption", InitArgs.11
    call VRSet "PB_1",  "Caption", InitArgs.12
    call VRSet "PB_2",  "Caption", InitArgs.13
    call VRSet "EF_2",  "Value",   InitArgs.14
    call VRSet "EF_3",  "Value",   InitArgs.15
    call VRSet "EF_4",  "Value",   InitArgs.16

return