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

/*:VRX         CB_0_Click
*/
CB_0_Click: 

    i=0
    call process_checkbox_event

return

/*:VRX         CB_10_Click
*/
CB_10_Click:

    i=10
    call process_checkbox_event

return

/*:VRX         CB_11_Click
*/
CB_11_Click: 

    i=11
    call process_checkbox_event

return


/*:VRX         CB_12_Click
*/
CB_12_Click:

    i=12
    call process_checkbox_event

return


/*:VRX         CB_13_Click
*/
CB_13_Click: 

    i=13
    call process_checkbox_event

return


/*:VRX         CB_14_Click
*/
CB_14_Click: 

    i=14
    call process_checkbox_event

return


/*:VRX         CB_15_Click
*/
CB_15_Click: 

    i=15
    call process_checkbox_event

return

/*:VRX         CB_16_Click
*/
CB_16_Click: 

    i=16
    call process_checkbox_event

return


/*:VRX         CB_17_Click
*/
CB_17_Click: 

    i=17
    call process_checkbox_event

return


/*:VRX         CB_18_Click
*/
CB_18_Click: 

    i=18
    call process_checkbox_event

return


/*:VRX         CB_19_Click
*/
CB_19_Click: 

    i=19
    call process_checkbox_event

return


/*:VRX         CB_1_Click
*/
CB_1_Click: 

    i=1
    call process_checkbox_event

return


/*:VRX         CB_20_Click
*/
CB_20_Click: 

    i=20
    call process_checkbox_event

return

/*:VRX         CB_21_Click
*/
CB_21_Click: 

    i=21
    call process_checkbox_event

return

/*:VRX         CB_22_Click
*/
CB_22_Click: 

    i=22
    call process_checkbox_event

return

/*:VRX         CB_23_Click
*/
CB_23_Click: 

    i=23
    call process_checkbox_event

return

/*:VRX         CB_24_Click
*/
CB_24_Click: 

    i=24
    call process_checkbox_event

return

/*:VRX         CB_25_Click
*/
CB_25_Click: 

    i=25
    call process_checkbox_event

return

/*:VRX         CB_26_Click
*/
CB_26_Click: 

    i=26
    call process_checkbox_event

return


/*:VRX         CB_27_Click
*/
CB_27_Click: 

    i=27
    call process_checkbox_event

return


/*:VRX         CB_28_Click
*/
CB_28_Click:

    i=28
    call process_checkbox_event

return


/*:VRX         CB_29_Click
*/
CB_29_Click: 

    i=29
    call process_checkbox_event

return


/*:VRX         CB_2_Click
*/
CB_2_Click:

    i=2
    call process_checkbox_event

return


/*:VRX         CB_30_Click
*/
CB_30_Click:

    i=30
    call process_checkbox_event

return

/*:VRX         CB_31_Click
*/
CB_31_Click: 

    i=31
    call process_checkbox_event

return

/*:VRX         CB_32_Click
*/
CB_32_Click:

    i=32
    call process_checkbox_event

return


/*:VRX         CB_33_Click
*/
CB_33_Click: 

    i=33
    call process_checkbox_event

return

/*:VRX         CB_34_Click
*/
CB_34_Click:

    i=34
    call process_checkbox_event

return


/*:VRX         CB_35_Click
*/
CB_35_Click:

    i=35
    call process_checkbox_event

return

/*:VRX         CB_36_Click
*/
CB_36_Click: 

    i=36
    call process_checkbox_event

return

/*:VRX         CB_37_Click
*/
CB_37_Click: 

    i=37
    call process_checkbox_event

return


/*:VRX         CB_38_Click
*/
CB_38_Click: 

    i=38
    call process_checkbox_event

return

/*:VRX         CB_39_Click
*/
CB_39_Click: 

    i=39
    call process_checkbox_event

return


/*:VRX         CB_3_Click
*/
CB_3_Click: 

    i=3
    call process_checkbox_event

return


/*:VRX         CB_40_Click
*/
CB_40_Click:

    i=40
    call process_checkbox_event

return

/*:VRX         CB_41_Click
*/
CB_41_Click: 

    i=41
    call process_checkbox_event

return

/*:VRX         CB_42_Click
*/
CB_42_Click: 

    i=42
    call process_checkbox_event

return

/*:VRX         CB_43_Click
*/
CB_43_Click: 

    i=43
    call process_checkbox_event

return

/*:VRX         CB_44_Click
*/
CB_44_Click:

    i=44
    call process_checkbox_event

return

/*:VRX         CB_45_Click
*/
CB_45_Click: 

    i=45
    call process_checkbox_event

return

/*:VRX         CB_46_Click
*/
CB_46_Click: 

    i=46
    call process_checkbox_event

return

/*:VRX         CB_47_Click
*/
CB_47_Click:

    i=47
    call process_checkbox_event

return

/*:VRX         CB_48_Click
*/
CB_48_Click: 

    i=48
    call process_checkbox_event

return

/*:VRX         CB_49_Click
*/
CB_49_Click: 

    i=49
    call process_checkbox_event

return

/*:VRX         CB_4_Click
*/
CB_4_Click:

    i=4
    call process_checkbox_event

return


/*:VRX         CB_50_Click
*/
CB_50_Click:

    i=50
    call process_checkbox_event

return

/*:VRX         CB_51_Click
*/
CB_51_Click: 

    i=51
    call process_checkbox_event

return

/*:VRX         CB_52_Click
*/
CB_52_Click: 

    i=52
    call process_checkbox_event

return

/*:VRX         CB_53_Click
*/
CB_53_Click:

    i=53
    call process_checkbox_event

return

/*:VRX         CB_54_Click
*/
CB_54_Click:

    i=54
    call process_checkbox_event

return


/*:VRX         CB_55_Click
*/
CB_55_Click: 

    i=55
    call process_checkbox_event

return


/*:VRX         CB_56_Click
*/
CB_56_Click: 

    i=56
    call process_checkbox_event

return


/*:VRX         CB_57_Click
*/
CB_57_Click:

    i=57
    call process_checkbox_event

return


/*:VRX         CB_58_Click
*/
CB_58_Click: 

    i=58
    call process_checkbox_event

return


/*:VRX         CB_59_Click
*/
CB_59_Click: 

    i=59
    call process_checkbox_event

return


/*:VRX         CB_5_Click
*/
CB_5_Click: 

    i=5
    call process_checkbox_event

return

/*:VRX         CB_60_Click
*/
CB_60_Click:

    i=60
    call process_checkbox_event

return

/*:VRX         CB_61_Click
*/
CB_61_Click: 

    i=61
    call process_checkbox_event

return

/*:VRX         CB_62_Click
*/
CB_62_Click: 

    i=62
    call process_checkbox_event

return

/*:VRX         CB_63_Click
*/
CB_63_Click: 

    i=63
    call process_checkbox_event

return

/*:VRX         CB_64_Click
*/
CB_64_Click: 

    i=64
    call process_checkbox_event

return

/*:VRX         CB_65_Click
*/
CB_65_Click:

    i=65
    call process_checkbox_event

return

/*:VRX         CB_66_Click
*/
CB_66_Click: 

    i=66
    call process_checkbox_event

return

/*:VRX         CB_67_Click
*/
CB_67_Click: 

    i=67
    call process_checkbox_event

return

/*:VRX         CB_68_Click
*/
CB_68_Click: 

    i=68
    call process_checkbox_event

return

/*:VRX         CB_69_Click
*/
CB_69_Click: 

    i=69
    call process_checkbox_event

return

/*:VRX         CB_6_Click
*/
CB_6_Click: 

    i=6
    call process_checkbox_event

return


/*:VRX         CB_70_Click
*/
CB_70_Click: 

    i=70
    call process_checkbox_event

return

/*:VRX         CB_71_Click
*/
CB_71_Click:

    i=71
    call process_checkbox_event

return

/*:VRX         CB_72_Click
*/
CB_72_Click: 

    i=72
    call process_checkbox_event

return

/*:VRX         CB_73_Click
*/
CB_73_Click: 

    i=73
    call process_checkbox_event

return

/*:VRX         CB_74_Click
*/
CB_74_Click: 

    i=74
    call process_checkbox_event

return

/*:VRX         CB_75_Click
*/
CB_75_Click: 

    i=75
    call process_checkbox_event

return

/*:VRX         CB_76_Click
*/
CB_76_Click: 

    i=76
    call process_checkbox_event

return

/*:VRX         CB_77_Click
*/
CB_77_Click:

    i=77
    call process_checkbox_event

return

/*:VRX         CB_78_Click
*/
CB_78_Click: 

    i=78
    call process_checkbox_event

return

/*:VRX         CB_79_Click
*/
CB_79_Click: 

    i=79
    call process_checkbox_event

return

/*:VRX         CB_7_Click
*/
CB_7_Click: 

    i=7
    call process_checkbox_event

return


/*:VRX         CB_80_Click
*/
CB_80_Click: 

    i=80
    call process_checkbox_event

return

/*:VRX         CB_81_Click
*/
CB_81_Click: 

    i=81
    call process_checkbox_event

return

/*:VRX         CB_82_Click
*/
CB_82_Click: 

    i=82
    call process_checkbox_event

return

/*:VRX         CB_83_Click
*/
CB_83_Click: 

    i=83
    call process_checkbox_event

return

/*:VRX         CB_84_Click
*/
CB_84_Click: 

    i=84
    call process_checkbox_event

return

/*:VRX         CB_85_Click
*/
CB_85_Click: 

    i=85
    call process_checkbox_event

return

/*:VRX         CB_86_Click
*/
CB_86_Click:

    i=86
    call process_checkbox_event

return

/*:VRX         CB_87_Click
*/
CB_87_Click: 

    i=87
    call process_checkbox_event

return

/*:VRX         CB_88_Click
*/
CB_88_Click: 

    i=88
    call process_checkbox_event

return

/*:VRX         CB_89_Click
*/
CB_89_Click: 

    i=89
    call process_checkbox_event

return

/*:VRX         CB_8_Click
*/
CB_8_Click:

    i=8
    call process_checkbox_event

return


/*:VRX         CB_90_Click
*/
CB_90_Click: 

    i=90
    call process_checkbox_event

return

/*:VRX         CB_91_Click
*/
CB_91_Click: 

    i=91
    call process_checkbox_event

return

/*:VRX         CB_92_Click
*/
CB_92_Click: 

    i=92
    call process_checkbox_event

return

/*:VRX         CB_93_Click
*/
CB_93_Click: 

    i=93
    call process_checkbox_event

return

/*:VRX         CB_94_Click
*/
CB_94_Click: 

    i=94
    call process_checkbox_event

return

/*:VRX         CB_95_Click
*/
CB_95_Click: 

    i=95
    call process_checkbox_event

return

/*:VRX         CB_96_Click
*/
CB_96_Click: 

    i=96
    call process_checkbox_event

return

/*:VRX         CB_97_Click
*/
CB_97_Click: 

    i=97
    call process_checkbox_event

return

/*:VRX         CB_98_Click
*/
CB_98_Click:

    i=98
    call process_checkbox_event

return

/*:VRX         CB_99_Click
*/
CB_99_Click: 

    i=99
    call process_checkbox_event

return

/*:VRX         CB_9_Click
*/
CB_9_Click:

    i=9
    call process_checkbox_event

return


/*:VRX         check_drive
*/
/* check if cddrv contains the updcd CD-ROM */
check_drive: procedure

  parse arg cddrv

	if cddrv = '' | cddrv = 'CDDRV' | cddrv = 'ER' then cddrv = 'X:'
  rcode = ''
	Call rxfuncadd 'SysDriveInfo', 'REXXUTIL', 'SysDriveInfo'
  rc = sysdriveinfo(cddrv)
  if rc <> '' then do
    rm1 = stream(cddrv'\updcd\addons\read.me', 'c', 'query exists')
    rm2 = stream(cddrv'\updcd\bin\unlock.exe', 'c', 'query exists')
    if rm1 <> '' & rm2 <> '' then rcode = cddrv
  end

return rcode

/*:VRX         display_product_controls
*/
display_product_controls: 

				/* '@echo 'date()' 'time()': display_product_controls 'i' >> npdebug.txt' */

        sectionid = i
        if length(sectionid) = 1 then sectionid = '0'sectionid
        entryid = 'EF_'i
        ctrlid = 'CB_'i
        boxid = 'PB_'i

		    call VRSet boxid, "Caption", msg.0528

        entryname = value("addonins."sectionid".name")
        if i = '00' then entryname = msg.0529 /* bypass */
        /* '@echo 'sectionid'='entryname' >> npdebug.txt' */
        call VRSet entryid, "Value", entryname

        /* disable undefined addons */
        if entryname = "Undefined" then do
            call VRSet ctrlid, "Enabled", 0
            call VRSet ctrlid, "Visible", 0
            call VRSet entryid, "Visible", 0
            call VRSet boxid, "Visible", 0
        end

        /* disable empty addons */
        if InitArgs.1 <> '/UNINSTALL' then
					if sysdriveinfo(cddrv) <> '' then do
            if stream(cddrv'\updcd\addons\read.me', 'c', 'query exists') <> '' then do
                call sysfiletree cddrv'\updcd\addons\'sectionid.i'\*', 'junk.'
                call sysfiletree cddrv'\updcd\addons\'sectionid.i'\addonins.*', 'junk1.'
								junk.0 = junk.0 - junk1.0
                if junk.0 = 0 then do
                    call VRSet ctrlid, "Enabled", 0
                    if entryname <> "Undefined" & i <> '00' & i <> '99' then call VRSet entryid, "ForeColor", "Red"
                end
            end
          end

        /* disable some controls */
        if value("addonins."sectionid".ininst") = 'NO' & InitArgs.1 <> '/REINSTALL' & InitArgs.1 <> '/UNINSTALL' then call VRSet ctrlid, "Enabled", 0
        restriction_list = value("addonins."sectionid".instrst")
        do while restriction_list <> ''
            parse var restriction_list extension restriction_list
            if stream(drv'\'instpath'\npconfig.'space(extension), 'c', 'query exists') <> '' then do
                call VRSet ctrlid, "Enabled", 0
                call VRSet entryid, "ForeColor", "Black"
            end
        end

return

/*:VRX         EF_0_Change
*/
EF_0_Change: 

return

/*:VRX         EF_0_GotFocus
*/
EF_0_GotFocus: 
		i = 0
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_10_GotFocus
*/
EF_10_GotFocus: 
		i = 10
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_11_GotFocus
*/
EF_11_GotFocus: 
		i = 11
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_12_GotFocus
*/
EF_12_GotFocus: 
		i = 12
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_13_GotFocus
*/
EF_13_GotFocus: 
		i = 13
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_14_GotFocus
*/
EF_14_GotFocus: 
		i = 14
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_15_GotFocus
*/
EF_15_GotFocus: 
		i = 15
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_16_GotFocus
*/
EF_16_GotFocus: 
		i = 16
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_17_GotFocus
*/
EF_17_GotFocus: 
		i = 17
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_18_GotFocus
*/
EF_18_GotFocus: 
		i = 18
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_19_GotFocus
*/
EF_19_GotFocus: 
		i = 19
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_1_GotFocus
*/
EF_1_GotFocus: 
		i = 1
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_20_GotFocus
*/
EF_20_GotFocus: 
		i = 20
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_21_GotFocus
*/
EF_21_GotFocus: 
		i = 21
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_22_GotFocus
*/
EF_22_GotFocus: 
		i = 22
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_23_GotFocus
*/
EF_23_GotFocus: 
		i = 23
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_24_GotFocus
*/
EF_24_GotFocus: 
		i = 24
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_25_GotFocus
*/
EF_25_GotFocus: 
		i = 25
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_26_GotFocus
*/
EF_26_GotFocus: 
		i = 26
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_27_GotFocus
*/
EF_27_GotFocus: 
		i = 27
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_28_GotFocus
*/
EF_28_GotFocus: 
		i = 28
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_29_GotFocus
*/
EF_29_GotFocus: 
		i = 29
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_2_GotFocus
*/
EF_2_GotFocus: 
		i = 2
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_30_GotFocus
*/
EF_30_GotFocus: 
		i = 30
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_31_GotFocus
*/
EF_31_GotFocus: 
		i = 31
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_32_GotFocus
*/
EF_32_GotFocus: 
		i = 32
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_33_GotFocus
*/
EF_33_GotFocus: 
		i = 33
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_34_GotFocus
*/
EF_34_GotFocus: 
		i = 34
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_35_GotFocus
*/
EF_35_GotFocus: 
		i = 35
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_36_GotFocus
*/
EF_36_GotFocus: 
		i = 36
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_37_GotFocus
*/
EF_37_GotFocus: 
		i = 37
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_38_GotFocus
*/
EF_38_GotFocus: 
		i = 38
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_39_GotFocus
*/
EF_39_GotFocus: 
		i = 39
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_3_GotFocus
*/
EF_3_GotFocus: 
		i = 3
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_40_GotFocus
*/
EF_40_GotFocus: 
		i = 40
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_41_GotFocus
*/
EF_41_GotFocus: 
		i = 41
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_42_GotFocus
*/
EF_42_GotFocus: 
		i = 42
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_43_GotFocus
*/
EF_43_GotFocus: 
		i = 43
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_44_GotFocus
*/
EF_44_GotFocus: 
		i = 44
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_45_GotFocus
*/
EF_45_GotFocus: 
		i = 45
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_46_GotFocus
*/
EF_46_GotFocus: 
		i = 46
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_47_GotFocus
*/
EF_47_GotFocus: 
		i = 47
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_48_GotFocus
*/
EF_48_GotFocus: 
		i = 48
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_49_GotFocus
*/
EF_49_GotFocus: 
		i = 49
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_4_GotFocus
*/
EF_4_GotFocus: 
		i = 4
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_50_GotFocus
*/
EF_50_GotFocus: 
		i = 50
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_51_GotFocus
*/
EF_51_GotFocus: 
		i = 51
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_52_GotFocus
*/
EF_52_GotFocus: 
		i = 52
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_53_GotFocus
*/
EF_53_GotFocus: 
		i = 53
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_54_GotFocus
*/
EF_54_GotFocus: 
		i = 54
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_55_GotFocus
*/
EF_55_GotFocus: 
		i = 55
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_56_GotFocus
*/
EF_56_GotFocus: 
		i = 56
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_57_GotFocus
*/
EF_57_GotFocus: 
		i = 57
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_58_GotFocus
*/
EF_58_GotFocus: 
		i = 58
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_59_GotFocus
*/
EF_59_GotFocus: 
		i = 59
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_5_GotFocus
*/
EF_5_GotFocus: 
		i = 5
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_60_GotFocus
*/
EF_60_GotFocus: 
		i = 60
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_61_GotFocus
*/
EF_61_GotFocus: 
		i = 61
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_62_GotFocus
*/
EF_62_GotFocus: 
		i = 62
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_63_GotFocus
*/
EF_63_GotFocus: 
		i = 63
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_64_GotFocus
*/
EF_64_GotFocus: 
		i = 64
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_65_GotFocus
*/
EF_65_GotFocus: 
		i = 65
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_66_GotFocus
*/
EF_66_GotFocus: 
		i = 66
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_67_GotFocus
*/
EF_67_GotFocus: 
		i = 67
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_68_GotFocus
*/
EF_68_GotFocus: 
		i = 68
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_69_GotFocus
*/
EF_69_GotFocus: 
		i = 69
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_6_GotFocus
*/
EF_6_GotFocus: 
		i = 6
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_70_GotFocus
*/
EF_70_GotFocus: 
		i = 70
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_71_GotFocus
*/
EF_71_GotFocus: 
		i = 71
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_72_GotFocus
*/
EF_72_GotFocus: 
		i = 72
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_73_GotFocus
*/
EF_73_GotFocus: 
		i = 73
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_74_GotFocus
*/
EF_74_GotFocus: 
		i = 74
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_75_GotFocus
*/
EF_75_GotFocus: 
		i = 75
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_76_GotFocus
*/
EF_76_GotFocus: 
		i = 76
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_77_GotFocus
*/
EF_77_GotFocus: 
		i = 77
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_78_GotFocus
*/
EF_78_GotFocus: 
		i = 78
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_79_GotFocus
*/
EF_79_GotFocus: 
		i = 79
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_7_GotFocus
*/
EF_7_GotFocus: 
		i = 7
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_80_GotFocus
*/
EF_80_GotFocus: 
		i = 80
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_81_GotFocus
*/
EF_81_GotFocus: 
		i = 81
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_82_GotFocus
*/
EF_82_GotFocus: 
		i = 82
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_83_GotFocus
*/
EF_83_GotFocus: 
		i = 83
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_84_GotFocus
*/
EF_84_GotFocus: 
		i = 84
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_85_GotFocus
*/
EF_85_GotFocus: 
		i = 85
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_86_GotFocus
*/
EF_86_GotFocus: 
		i = 86
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_87_GotFocus
*/
EF_87_GotFocus: 
		i = 87
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_88_GotFocus
*/
EF_88_GotFocus: 
		i = 88
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_89_GotFocus
*/
EF_89_GotFocus: 
		i = 89
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_8_GotFocus
*/
EF_8_GotFocus: 
		i = 8
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_90_GotFocus
*/
EF_90_GotFocus: 
		i = 90
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_91_GotFocus
*/
EF_91_GotFocus: 
		i = 91
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_92_GotFocus
*/
EF_92_GotFocus: 
		i = 92
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_93_GotFocus
*/
EF_93_GotFocus: 
		i = 93
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_94_GotFocus
*/
EF_94_GotFocus: 
		i = 94
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_95_GotFocus
*/
EF_95_GotFocus: 
		i = 95
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_96_GotFocus
*/
EF_96_GotFocus: 
		i = 96
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_97_GotFocus
*/
EF_97_GotFocus: 
		i = 97
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_98_GotFocus
*/
EF_98_GotFocus: 
		i = 98
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_99_GotFocus
*/
EF_99_GotFocus: 
		i = 99
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         EF_9_GotFocus
*/
EF_9_GotFocus: 
		i = 9
    if VRGet( "CB_"i, "Enabled" ) = 1 then do
			if VRGet( "CB_"i, "Set" ) = 1 then call VRSet  "CB_"i, "Set", 0 
			else  call VRSet  "CB_"i, "Set", 1
	    call process_checkbox_event
		end
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return 0

/*:VRX         get_ini_key
*/
get_ini_key: procedure

       /* get apps key value from OS2.INI */

	parse upper arg apps key

	call rxfuncadd sysini, rexxutil, sysini
	call SysIni 'USER', 'All:', 'Apps.'
	do i = 1 to Apps.0	
		if translate(apps.i) = apps then do
			call SysIni 'USER', Apps.i, 'All:', 'Keys'
 	   	do j=1 to Keys.0
 	   		if translate(Keys.j) = key then do
					val = SysIni('USER', Apps.i, Keys.j)
					return val
				end
    	end
  	end
	end

return ''

/*:VRX         get_parameters
*/
get_parameters: 

    start = 0
    do while lines(cfgfile)
        l=linein(cfgfile)
        if start = 0 & translate(l) = translate(cfgsection) then do
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

    /* disable console */
    Call VRRedirectSTDIO "off" 

    /* read command line parameters */
    parameters = ''
    do i = 1 to InitArgs.0
        parameters = parameters||InitArgs.i||' '
    end

    /* do not add extra options for eCS */
		npoptions = ''
		if stream(drv'\'instpath'\npconfig.wp3', 'c', 'query exists') <> '' then npoptions = linein(drv'\'instpath'\npconfig.wp3')
		if stream(drv'\'instpath'\npconfig.wp4', 'c', 'query exists') <> '' then npoptions = linein(drv'\'instpath'\npconfig.wp4')
		if stream(drv'\'instpath'\npconfig.wsb', 'c', 'query exists') <> '' then npoptions = linein(drv'\'instpath'\npconfig.wsb')
		if stream(drv'\'instpath'\npconfig.acp', 'c', 'query exists') <> '' then npoptions = linein(drv'\'instpath'\npconfig.acp')
		if stream(drv'\'instpath'\npconfig.mcp', 'c', 'query exists') <> '' then npoptions = linein(drv'\'instpath'\npconfig.mcp')
		npoptions = space(npoptions)
		parse upper var npoptions option1 option2 .
		if pos(option1, translate(parameters)) = 0 then parameters = parameters' 'option1
		if pos(option2, translate(parameters)) = 0 then parameters = parameters' 'option2
		parameters = space(parameters)

    /* debug */
    /* '@echo 'date()' 'time()': 'parameters' >> c:\npdebug.txt' */

    /* determine instdir */
    drv = filespec('drive', directory())
    instpath = 'warpsrv'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'grpware'
    if stream(drv'\'instpath'\coninst.exe', 'c', 'query exists') = '' then instpath = 'ibminst'

		/* load language file */
		call load_language_file drv'\'instpath'\npconfig.msg'
		if stream(drv'\'instpath'\npconfig.msg', 'c', 'query exists') = '' then do
			call quit
			return
		end
		else call set_text_labels_of_main_window

    /* backup config */
    bak = drv'\'instpath'\npconfig.bak'
    out = drv'\'instpath'\npconfig.out'
    if stream(bak, 'c', 'query exists') <> '' then '@del 'bak
    if stream(out, 'c', 'query exists') <> '' then '@copy 'out' 'bak

    /* unknown argument was passed */
    if InitArgs.1 <> '/UNINSTALL' & InitArgs.1 <> '/REINSTALL' & InitArgs.1 <> '/PASS2' & InitArgs.1 <> '/PASS1' then do

        /* start original npconfig.exe */
				/* '@echo 'date()' 'time()': init1 npcfg2 'parameters' >> npdebug.txt' */
        address cmd drv'\'instpath'\npcfg2.exe 'parameters' <con >con 2>con'

        /* hide our window */
        window = VRWindow()
        call VRMethod window, "Minimize"
        call quit
        return

    end

    /* load rexxutil */
    If RXFUNCQUERY('SysLoadFuncs') Then Do
        Call rxfuncadd 'SysLoadFuncs', 'REXXUTIL', 'SYSLOADFUNCS'
        Call sysloadfuncs
    End

    if InitArgs.1 <> '/PASS2' then do

        /* determine CD drive */
        /* try default x: */
        cddrv = 'x:'
        cddrv = check_drive(cddrv)
        /*'@echo cddrv='cddrv' >> npdebug.txt'*/
    
        /* try env */
        if cddrv = '' then do
    	   cddrv = space(substr(value("SOURCEPATH", ,"OS2ENVIRONMENT"), 1, 2))
    	   if cddrv <> '' then cddrv = check_drive(cddrv)
        end
        /* '@echo cddrv='cddrv' >> npdebug.txt' */

        /* try npcfg.cmd */
        if cddrv = '' then do
					cmd_file = drv'\'instpath'\npcfg.cmd'
					if stream(cmd_file, 'c', 'query exists') <> '' then do
						do while lines(cmd_file)
							l = translate(linein(cmd_file))
							if pos('IBMINST\RSP\LOCAL\ADDON.CMD', l) > 0 then do
								parse var l . . cddrv .
								if cddrv <> '' then cddrv = check_drive(cddrv)
								leave
							end
						end
						call lineout cmd_file
					end
        end
        /* '@echo cddrv='cddrv' >> npdebug.txt' */

        /* try local.cmd */
        if cddrv = '' then do
					cmd_file = drv'\'instpath'\rsp\local\local.cmd'
					if stream(cmd_file, 'c', 'query exists') <> '' then do
						do while lines(cmd_file)
							l = translate(linein(cmd_file))
							parse var l w1 w2 cddrv
							if w1 = 'CD_DRIVE' & w2 = '=' then do 
								cddrv = strip(cddrv, 'B', '"')
								if cddrv <> '' then cddrv = check_drive(cddrv)
								leave
							end
						end
						call lineout cmd_file
					end
        end
        /* '@echo cddrv='cddrv' >> npdebug.txt' */

        /* try reinstal.ini */
        if cddrv = '' then do
					ini_file = drv'\OS2\INSTALL\REINSTAL.INI'
					cddrv = substr(SysIni(ini_file, 'InstallWindow', 'SOURCEPATH'), 1, 2)
					if cddrv <> '' then cddrv = check_drive(cddrv)
				end
        /* '@echo cddrv='cddrv' >> npdebug.txt' */

        /* try os2.ini */
        if cddrv = '' then do
					ini_file = 'USER'
					cddrv = substr(SysIni(ini_file, 'PM_INSTALL', 'PDR_DIR'), 1, 2)
					if cddrv <> '' then cddrv = check_drive(cddrv)
        end
        /* '@echo cddrv='cddrv' >> npdebug.txt' */

        /* search available drives and ask */
        not_sure = 0
        if cddrv = '' then do
					drives = SysDriveMap('C:', 'LOCAL')
					do while length(drives) > 0
						parse var drives cddrv drives
						cddrv = check_drive(cddrv)
						if cddrv <> '' then do
							not_sure = 1
							leave
						end
					end
        end
        /* '@echo cddrv='cddrv' >> npdebug.txt' */

        /* ask */
        if (cddrv = '' | not_sure = 1) &  InitArgs.1 <> '/PASS2' &  InitArgs.1 <> '/UNINSTALL' then do
					if cddrv = '' then cddrv = 'X:'
					cddrv = cddlg( vrwindow(), translate(cddrv), msg.0405, msg.0496, msg.0497, msg.0498 )
					do while stream(cddrv'\updcd\addons\read.me', 'c', 'query exists') = '' 
						if cddrv = -18967 then do /* cancel */
							if InitArgs.1 <> '/REINSTALL' & InitArgs.1 <> '/UNINSTALL' then do
								/* start original npconfig.exe */
								/* '@echo 'date()' 'time()': init2 npcfg2 'parameters' >> npdebug.txt' */
								address cmd drv'\'instpath'\npcfg2.exe 'parameters' <con >con 2>con'
								/* hide our window */
								window = VRWindow()
								call VRMethod window, "Minimize"
							end
							call quit
							return
						end
						else cddrv = cddlg( vrwindow(), translate(cddrv), msg.0405, msg.0496, msg.0497, msg.0498 )
	   			end
        end

    end /* not pass2 */
 
    /* call first netscape/java dialog for Warp 4 and WSEB but not for MCP, ACP and Warp 3 */
    if InitArgs.1 = '/PASS1' & stream(drv'\'instpath'\npconfig.mcp', 'c', 'query exists') = '' & stream(drv'\'instpath'\npconfig.acp', 'c', 'query exists') = '' then call newprdlg vrwindow(), msg.0499, msg.0500, msg.0501, msg.0502, msg.0503, msg.0504, msg.0505, msg.0506, msg.0507, msg.0508, msg.0509, msg.0510, msg.0511, msg.0512, msg.0513, msg.0514

    /* during pass 2 change files and then quit */
    if InitArgs.1 = '/PASS2' then do
        address cmd 'copy 'drv'\config.sys+'drv'\'instpath'\npconfig.tmp 'drv'\config.sys'

        /* tune config.sys, but only during installation */
        if stream(drv'\'instpath'\tunecfg.flg', 'c', 'query exists') = '' then do
            '@echo do not remove this file > 'drv'\'instpath'\tunecfg.flg'
						call tunedlg vrwindow(), msg.0517, msg.0518, msg.0519
        end

        /* start original npconfig */
				/* '@echo 'date()' 'time()': init3 npcfg2 'parameters' >> npdebug.txt' */
        address cmd drv'\'instpath'\npcfg2.exe 'parameters' <con >con 2>con' 

        window = VRWindow()
        call VRMethod window, "Minimize"
        call quit
    end

		/* quit if no addons are added */
		if stream(cddrv'\updcd\addons\00_PRPRC\addonins.cmd', 'c', 'query exists') <> '' then do

			/* display selections */
	    window = VRWindow()
	    call VRMethod window, "CenterWindow"
	    call VRSet window, "Visible", 1
	    call VRMethod window, "Activate"
	    call VRSet window, "Enabled", 0

	    /* reset some variables */
	    addonins. = ''
	    target = drv
	    cfgfile = drv'\'instpath'\tables\addons.cfg'
	    cfgsection = 'XX_GLOBAL'
	    call get_parameters
  	  do i=0 to 99
        sectionid = i
        if length(sectionid) = 1 then sectionid = '0'sectionid
        interpret 'addonins.'sectionid'.name=product_name'
        interpret 'addonins.'sectionid'.version=product_version'
        interpret 'addonins.'sectionid'.log=product_log'
        interpret 'addonins.'sectionid'.drv=product_drv'
        interpret 'addonins.'sectionid'.path=product_path'
        interpret 'addonins.'sectionid'.rsp=product_rsp'
        interpret 'addonins.'sectionid'.ininst=product_ininst'
        interpret 'addonins.'sectionid'.instrst=product_instrst'
        interpret 'addonins.'sectionid'.set=product_set'
        interpret 'addonins.'sectionid'.reset=product_reset'
        interpret 'addonins.'sectionid'.warning=product_warning'
        interpret 'addonins.'sectionid'.license=product_license'
    	end

    	/* load settings from cfg file */
    	sectionid. = '00_XXXXX'
    	do while lines(cfgfile)
				l=linein(cfgfile)
				if substr(l, 3, 1) = '_' & datatype(substr(l, 1, 2)) = 'NUM' then do
					interpret 'sectionid.'substr(l, 1, 2)'='l 
				end
    	end
    	call lineout cfgfile
    	do i = 0 to 99
        if length(i) = 1 then i='0'i
        cfgsection = 'XX_GLOBAL'
        call get_parameters
        cfgsection = sectionid.i
        call get_parameters
        temp_sectionid = substr(sectionid.i, 1, 2)
        interpret 'addonins.'temp_sectionid'.name=product_name'
        interpret 'addonins.'temp_sectionid'.drv=product_drv'
        interpret 'addonins.'temp_sectionid'.path=product_path'
        interpret 'addonins.'temp_sectionid'.ininst=product_ininst'
        interpret 'addonins.'temp_sectionid'.instrst=product_instrst'
        interpret 'addonins.'temp_sectionid'.set=product_set'
        interpret 'addonins.'temp_sectionid'.reset=product_reset'
        interpret 'addonins.'temp_sectionid'.warning=product_warning'
    	end

    	call VRSet "DT_1", "Visible", 0 

	    /* display second page by default */
  	  call VRSet "NB_1", "Selected", 2

	    /* enable next/cancel buttons */ 
	    call VRSet "PB_100", "Enabled", 1 
	    call VRSet "PB_101", "Enabled", 1 
  	  call VRSet window, "Enabled", 1
    	drop window
		end
		else do /* cancel */
			if InitArgs.1 = '/PASS1' then call PB_101_Click 
		end

return

/*:VRX         load_language_file
*/
load_language_file: 

	parse arg lfile

	/* check */
	if stream(lfile, 'c', 'query exists') = '' then do
		bt.0=1
		bt.1='OK'
		call vrmessage vrwindow(),'Fatal error: cannot find language file: 'lfile'. Aborting...','Error','I','bt.',1
	end
	else do
		/* load */
		do while lines(lfile)
			l = linein(lfile)
			interpret l
		end
		call lineout lfile
	end

return

/*:VRX         PB_0_Click
*/
PB_0_Click: 
    call DetlsDlg vrwindow(), '00', addonins.00.drv, addonins.00.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.00.drv addonins.00.path
return

/*:VRX         PB_100_Click
*/
PB_100_Click: 
    parameters = ''
    do i = 1 to InitArgs.0
        parameters = parameters||InitArgs.i||' '
    end

    /* read selections */
    do i = 0 to 99
        if length(i) = 1 then j='0'i
        else j=i
        interpret "addonins."sectionid.j"=VRGet( CB_"i",  'Set' )"
    end

    /* put it in a temp file */
    /* it will be added to config.sys during phase2 */
    cfg=drv'\'instpath'\npconfig.tmp'
    if stream(cfg, 'c', 'query exists') <> '' then 'del 'cfg
    call lineout cfg, ' '
    
    do i=0 to 99
        if length(i) = 1 then i='0'i
        set = value('addonins.'sectionid.i)
        if set = 1 then call lineout cfg, 'SET ADDONINS_'substr(sectionid.i, 4)'='set
    end
    call lineout cfg, ' '
    call lineout cfg

    if InitArgs.1 = '/REINSTALL' | InitArgs.1 = '/UNINSTALL' then do    
        cmf=drv'\'instpath'\npcfg.cmd'
        if stream(cmf, 'c', 'query exists') <> '' then 'del 'cmf
        call lineout cmf, '/* rexx */'
        do while lines(cfg)
            l=linein(cfg)
            if pos('SET', l) > 0 then call lineout cmf, "'"l"'"
        end
        call lineout cfg
        call lineout cmf, "call rxfuncadd 'ProgressChangeProduct', RLANUTIL, 'ProgressChangeProduct'"
        if InitArgs.1 = '/REINSTALL' then do
            if instpath = 'grpware' then call lineout cmf, "'call "drv"\"instpath"\clients\addon.cmd "cddrv drv" 0'"
            else if instpath = 'warpsrv' then call lineout cmf, "'call "drv"\"instpath"\addon.cmd "cddrv drv" 0'"
            else call lineout cmf, "'call "drv"\"instpath"\rsp\local\addon.cmd "cddrv drv" 0'"
        end
        else do
            if instpath = 'grpware' then call lineout cmf, "'call "drv"\"instpath"\clients\addon.cmd "cddrv drv" 0 UNINSTALL'"
            else if instpath = 'warpsrv' then call lineout cmf, "'call "drv"\"instpath"\addon.cmd "cddrv drv" 0 UNINSTALL'"
            else call lineout cmf, "'call "drv"\"instpath"\rsp\local\addon.cmd "cddrv drv" 0 UNINSTALL'"
        end
        call lineout cmf, "'@del inst.sem >nul 2>>&1'"
        call lineout cmf
    end

    /* build new addons.cfg */
    if InitArgs.1 <> '/UNINSTALL' then do
        cfgfile = drv'\'instpath'\tables\addons.cfg'
        bckfile = drv'\'instpath'\tables\addons.bak'
        call sysfiledelete bckfile

        change = 0
        do while lines(cfgfile)
            l=linein(cfgfile)
            if change = 0 then call lineout bckfile, l
            parse value l with number '_' pid rest
            if datatype(number) = 'NUM' & (translate(pid) <> 'PRPRC' | translate(pid) <> 'PSPRC') then do 
               if value('addonins.'||l) = 1 then do
                    change = 1
                    product_id = number
                end
                iterate
            end
            if change = 1 then do
                if translate(l) = 'END' then do
                    change = 0
                    call lineout bckfile, l
                    iterate
                end
                if pos('PRODUCT_DRV', translate(l)) > 0 then do
                    call lineout bckfile, "	product_drv = '"value("addonins."||product_id||".drv")"'"
                    iterate
                end
                if pos('PRODUCT_PATH', translate(l)) > 0 then do
                    call lineout bckfile, "	product_path = '"value("addonins."||product_id||".path")"'"
                    iterate
                end
                call lineout bckfile, l
            end
        end
        call lineout cfgfile
        call lineout bckfile
        call sysfiledelete cfgfile
        '@copy 'bckfile cfgfile' >nul 2>>&1'
        call sysfiledelete bckfile
    end

    /* hide this window */
    call VRSet "Window1", "Visible", 0

    /* start original npconfig */
    if InitArgs.1 <> '/REINSTALL' & InitArgs.1 <> '/UNINSTALL' then do
			/* '@echo 'date()' 'time()': pb_100 npcfg2 'parameters' >> npdebug.txt' */
			address cmd drv'\'instpath'\npcfg2.exe 'parameters' <con >con 2>con' 
		end

    /* or reinstall */
    if InitArgs.1 = '/REINSTALL' then do
        button.0 = 2
        button.1 = 'OK'
        button.2 = msg.0519
        rc = vrmessage(vrwindow(), msg.0530, msg.0531, "I", "button.", 1, 2)
        if rc = 1 then do
            '@echo sem file > inst.sem'
            address cmd 'start "NpCfg.Cmd" /F /C npcfg.cmd <con >con 2>con'
            do while stream('inst.sem', 'c', 'query exists') <> ''
                call syssleep 1
            end
            button.1 = msg.0532
            button.2 = msg.0533
            rc = vrmessage(vrwindow(), msg.0534, msg.0535, "I", "button.", 1, 2)
            if rc = 1 then call RebootDG vrwindow(), '30', substr(drv, 1, 1), msg.0515, msg.0516
            if rc = 2 then do
                if instpath = 'grpware' then 'e 'drv'\'instpath'\clients\logs\addon\addons.log'
                else 'e 'drv'\'instpath'\logs\addon\addons.log'
            end
        end
    end

    /* or uninstall */
    if InitArgs.1 = '/UNINSTALL' then do
        button.0 = 2
        button.1 = 'OK'
        button.2 = msg.0519
        rc = vrmessage(vrwindow(), msg.0536, msg.0537, "I", "button.", 1, 2)
        if rc = 1 then do
            '@echo sem file > inst.sem'
            address cmd 'start "'msg.0538'" /F /C npcfg.cmd <con >con 2>con'
            do while stream('inst.sem', 'c', 'query exists') <> ''
                call syssleep 1
            end
            button.1 = msg.0532
            button.2 = msg.0533
            rc = vrmessage(vrwindow(), msg.0539, msg.0540, "I", "button.", 1, 2)
            if rc = 1 then call RebootDG vrwindow(), '30', substr(drv, 1, 1), msg.0515, msg.0516 
            if rc = 2 then do
                if instpath = 'grpware' then 'e 'drv'\'instpath'\clients\logs\addon\addons.log'
                else 'e 'drv'\'instpath'\logs\addon\addons.log'
            end
        end
    end

    call quit
return

/*:VRX         PB_101_Click
*/
PB_101_Click: 

    parameters = ''
    do i = 1 to InitArgs.0
        parameters = parameters||InitArgs.i||' '
    end
    
    /* minimize this window */
    call VRMethod "Window1", "Minimize"

    /* start original npconfig */
    if InitArgs.1 <> '/REINSTALL' & InitArgs.1 <> '/UNINSTALL' then do
        drv = filespec('drive', directory())
				/* '@echo 'date()' 'time()': pb_101 npcfg2 'parameters' >> npdebug.txt' */
        address cmd drv'\'instpath'\npcfg2.exe 'parameters' <con >con 2>con' 
    end

    call quit

return

/*:VRX         PB_10_Click
*/
PB_10_Click: 
    call DetlsDlg vrwindow(), '10', addonins.10.drv, addonins.10.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.10.drv addonins.10.path
return

/*:VRX         PB_11_Click
*/
PB_11_Click: 
    call DetlsDlg vrwindow(), '11', addonins.11.drv, addonins.11.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.11.drv addonins.11.path
return

/*:VRX         PB_12_Click
*/
PB_12_Click: 
    call DetlsDlg vrwindow(), '12', addonins.12.drv, addonins.12.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.12.drv addonins.12.path
return

/*:VRX         PB_13_Click
*/
PB_13_Click: 
    call DetlsDlg vrwindow(), '13', addonins.13.drv, addonins.13.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.13.drv addonins.13.path
return

/*:VRX         PB_14_Click
*/
PB_14_Click: 
    call DetlsDlg vrwindow(), '14', addonins.14.drv, addonins.14.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.14.drv addonins.14.path
return

/*:VRX         PB_15_Click
*/
PB_15_Click: 
    call DetlsDlg vrwindow(), '15', addonins.15.drv, addonins.15.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.15.drv addonins.15.path
return

/*:VRX         PB_16_Click
*/
PB_16_Click: 
    call DetlsDlg vrwindow(), '16', addonins.16.drv, addonins.16.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.16.drv addonins.16.path
return

/*:VRX         PB_17_Click
*/
PB_17_Click: 
    call DetlsDlg vrwindow(), '17', addonins.17.drv, addonins.17.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.17.drv addonins.17.path
return

/*:VRX         PB_18_Click
*/
PB_18_Click: 
    call DetlsDlg vrwindow(), '18', addonins.18.drv, addonins.18.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.18.drv addonins.18.path
return

/*:VRX         PB_19_Click
*/
PB_19_Click: 
    call DetlsDlg vrwindow(), '19', addonins.19.drv, addonins.19.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.19.drv addonins.19.path
return

/*:VRX         PB_1_Click
*/
PB_1_Click: 
    call DetlsDlg vrwindow(), '01', addonins.01.drv, addonins.01.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.01.drv addonins.01.path
return

/*:VRX         PB_20_Click
*/
PB_20_Click: 
    call DetlsDlg vrwindow(), '20', addonins.20.drv, addonins.20.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.20.drv addonins.20.path
return

/*:VRX         PB_21_Click
*/
PB_21_Click: 
    call DetlsDlg vrwindow(), '21', addonins.21.drv, addonins.21.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.21.drv addonins.21.path
return

/*:VRX         PB_22_Click
*/
PB_22_Click: 
    call DetlsDlg vrwindow(), '22', addonins.22.drv, addonins.22.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.22.drv addonins.22.path
return

/*:VRX         PB_23_Click
*/
PB_23_Click: 
    call DetlsDlg vrwindow(), '23', addonins.23.drv, addonins.23.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.23.drv addonins.23.path
return

/*:VRX         PB_24_Click
*/
PB_24_Click: 
    call DetlsDlg vrwindow(), '24', addonins.24.drv, addonins.24.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.24.drv addonins.24.path
return

/*:VRX         PB_25_Click
*/
PB_25_Click: 
    call DetlsDlg vrwindow(), '25', addonins.25.drv, addonins.25.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.25.drv addonins.25.path
return

/*:VRX         PB_26_Click
*/
PB_26_Click: 
    call DetlsDlg vrwindow(), '26', addonins.26.drv, addonins.26.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.26.drv addonins.26.path
return

/*:VRX         PB_27_Click
*/
PB_27_Click: 
    call DetlsDlg vrwindow(), '27', addonins.27.drv, addonins.27.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.27.drv addonins.27.path
return

/*:VRX         PB_28_Click
*/
PB_28_Click: 
    call DetlsDlg vrwindow(), '28', addonins.28.drv, addonins.28.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.28.drv addonins.28.path
return

/*:VRX         PB_29_Click
*/
PB_29_Click: 
    call DetlsDlg vrwindow(), '29', addonins.29.drv, addonins.29.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.29.drv addonins.29.path
return

/*:VRX         PB_2_Click
*/
PB_2_Click: 
    call DetlsDlg vrwindow(), '02', addonins.02.drv, addonins.02.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.02.drv addonins.02.path
return

/*:VRX         PB_30_Click
*/
PB_30_Click: 
    call DetlsDlg vrwindow(), '30', addonins.30.drv, addonins.30.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.30.drv addonins.30.path
return

/*:VRX         PB_31_Click
*/
PB_31_Click: 
    call DetlsDlg vrwindow(), '31', addonins.31.drv, addonins.31.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.31.drv addonins.31.path
return

/*:VRX         PB_32_Click
*/
PB_32_Click: 
    call DetlsDlg vrwindow(), '32', addonins.32.drv, addonins.32.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.32.drv addonins.32.path
return

/*:VRX         PB_33_Click
*/
PB_33_Click: 
    call DetlsDlg vrwindow(), '33', addonins.33.drv, addonins.33.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.33.drv addonins.33.path
return

/*:VRX         PB_34_Click
*/
PB_34_Click: 
    call DetlsDlg vrwindow(), '34', addonins.34.drv, addonins.34.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.34.drv addonins.34.path
return

/*:VRX         PB_35_Click
*/
PB_35_Click: 
    call DetlsDlg vrwindow(), '35', addonins.35.drv, addonins.35.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.35.drv addonins.35.path
return

/*:VRX         PB_36_Click
*/
PB_36_Click: 
    call DetlsDlg vrwindow(), '36', addonins.36.drv, addonins.36.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.36.drv addonins.36.path
return

/*:VRX         PB_37_Click
*/
PB_37_Click: 
    call DetlsDlg vrwindow(), '37', addonins.37.drv, addonins.37.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.37.drv addonins.37.path
return

/*:VRX         PB_38_Click
*/
PB_38_Click: 
    call DetlsDlg vrwindow(), '38', addonins.38.drv, addonins.38.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.38.drv addonins.38.path
return

/*:VRX         PB_39_Click
*/
PB_39_Click: 
    call DetlsDlg vrwindow(), '39', addonins.39.drv, addonins.39.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.39.drv addonins.39.path
return

/*:VRX         PB_3_Click
*/
PB_3_Click: 
    call DetlsDlg vrwindow(), '03', addonins.03.drv, addonins.03.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.03.drv addonins.03.path
return

/*:VRX         PB_40_Click
*/
PB_40_Click: 
    call DetlsDlg vrwindow(), '40', addonins.40.drv, addonins.40.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.40.drv addonins.40.path
return

/*:VRX         PB_41_Click
*/
PB_41_Click: 
    call DetlsDlg vrwindow(), '41', addonins.41.drv, addonins.41.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.41.drv addonins.41.path
return

/*:VRX         PB_42_Click
*/
PB_42_Click: 
    call DetlsDlg vrwindow(), '42', addonins.42.drv, addonins.42.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.42.drv addonins.42.path
return

/*:VRX         PB_43_Click
*/
PB_43_Click: 
    call DetlsDlg vrwindow(), '43', addonins.43.drv, addonins.43.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.43.drv addonins.43.path
return

/*:VRX         PB_44_Click
*/
PB_44_Click: 
    call DetlsDlg vrwindow(), '44', addonins.44.drv, addonins.44.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.44.drv addonins.44.path
return

/*:VRX         PB_45_Click
*/
PB_45_Click: 
    call DetlsDlg vrwindow(), '45', addonins.45.drv, addonins.45.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.45.drv addonins.45.path
return

/*:VRX         PB_46_Click
*/
PB_46_Click: 
    call DetlsDlg vrwindow(), '46', addonins.46.drv, addonins.46.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.46.drv addonins.46.path
return

/*:VRX         PB_47_Click
*/
PB_47_Click: 
    call DetlsDlg vrwindow(), '47', addonins.47.drv, addonins.47.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.47.drv addonins.47.path
return

/*:VRX         PB_48_Click
*/
PB_48_Click: 
    call DetlsDlg vrwindow(), '48', addonins.48.drv, addonins.48.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.48.drv addonins.48.path
return

/*:VRX         PB_49_Click
*/
PB_49_Click: 
    call DetlsDlg vrwindow(), '49', addonins.49.drv, addonins.49.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.49.drv addonins.49.path
return

/*:VRX         PB_4_Click
*/
PB_4_Click: 
    call DetlsDlg vrwindow(), '04', addonins.04.drv, addonins.04.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.04.drv addonins.04.path
return

/*:VRX         PB_50_Click
*/
PB_50_Click: 
    call DetlsDlg vrwindow(), '50', addonins.50.drv, addonins.50.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.50.drv addonins.50.path
return

/*:VRX         PB_51_Click
*/
PB_51_Click: 
    call DetlsDlg vrwindow(), '51', addonins.51.drv, addonins.51.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.51.drv addonins.51.path
return

/*:VRX         PB_52_Click
*/
PB_52_Click: 
    call DetlsDlg vrwindow(), '52', addonins.52.drv, addonins.52.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.52.drv addonins.52.path
return

/*:VRX         PB_53_Click
*/
PB_53_Click: 
    call DetlsDlg vrwindow(), '53', addonins.53.drv, addonins.53.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.53.drv addonins.53.path
return

/*:VRX         PB_54_Click
*/
PB_54_Click: 
    call DetlsDlg vrwindow(), '54', addonins.54.drv, addonins.54.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.54.drv addonins.54.path
return

/*:VRX         PB_55_Click
*/
PB_55_Click: 
    call DetlsDlg vrwindow(), '55', addonins.55.drv, addonins.55.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.55.drv addonins.55.path
return

/*:VRX         PB_56_Click
*/
PB_56_Click: 
    call DetlsDlg vrwindow(), '56', addonins.56.drv, addonins.56.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.56.drv addonins.56.path
return

/*:VRX         PB_57_Click
*/
PB_57_Click: 
    call DetlsDlg vrwindow(), '57', addonins.57.drv, addonins.57.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.57.drv addonins.57.path
return

/*:VRX         PB_58_Click
*/
PB_58_Click: 
    call DetlsDlg vrwindow(), '58', addonins.58.drv, addonins.58.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.58.drv addonins.58.path
return

/*:VRX         PB_59_Click
*/
PB_59_Click: 
    call DetlsDlg vrwindow(), '59', addonins.59.drv, addonins.59.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.59.drv addonins.59.path
return

/*:VRX         PB_5_Click
*/
PB_5_Click: 
    call DetlsDlg vrwindow(), '05', addonins.05.drv, addonins.05.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.05.drv addonins.05.path
return

/*:VRX         PB_60_Click
*/
PB_60_Click: 
    call DetlsDlg vrwindow(), '60', addonins.60.drv, addonins.60.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.60.drv addonins.60.path
return

/*:VRX         PB_61_Click
*/
PB_61_Click: 
    call DetlsDlg vrwindow(), '61', addonins.61.drv, addonins.61.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.61.drv addonins.61.path
return

/*:VRX         PB_62_Click
*/
PB_62_Click: 
    call DetlsDlg vrwindow(), '62', addonins.62.drv, addonins.62.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.62.drv addonins.62.path
return

/*:VRX         PB_63_Click
*/
PB_63_Click: 
    call DetlsDlg vrwindow(), '63', addonins.63.drv, addonins.63.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.63.drv addonins.63.path
return

/*:VRX         PB_64_Click
*/
PB_64_Click: 
    call DetlsDlg vrwindow(), '64', addonins.64.drv, addonins.64.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.64.drv addonins.64.path
return

/*:VRX         PB_65_Click
*/
PB_65_Click: 
    call DetlsDlg vrwindow(), '65', addonins.65.drv, addonins.65.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.65.drv addonins.65.path
return

/*:VRX         PB_66_Click
*/
PB_66_Click: 
    call DetlsDlg vrwindow(), '66', addonins.66.drv, addonins.66.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.66.drv addonins.66.path
return

/*:VRX         PB_67_Click
*/
PB_67_Click: 
    call DetlsDlg vrwindow(), '67', addonins.67.drv, addonins.67.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.67.drv addonins.67.path
return

/*:VRX         PB_68_Click
*/
PB_68_Click: 
    call DetlsDlg vrwindow(), '68', addonins.68.drv, addonins.68.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.68.drv addonins.68.path
return

/*:VRX         PB_69_Click
*/
PB_69_Click: 
    call DetlsDlg vrwindow(), '69', addonins.69.drv, addonins.69.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.69.drv addonins.69.path
return

/*:VRX         PB_6_Click
*/
PB_6_Click: 
    call DetlsDlg vrwindow(), '06', addonins.06.drv, addonins.06.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.06.drv addonins.06.path
return

/*:VRX         PB_70_Click
*/
PB_70_Click: 
    call DetlsDlg vrwindow(), '70', addonins.70.drv, addonins.70.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.70.drv addonins.70.path
return

/*:VRX         PB_71_Click
*/
PB_71_Click: 
    call DetlsDlg vrwindow(), '71', addonins.71.drv, addonins.71.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.71.drv addonins.71.path
return

/*:VRX         PB_72_Click
*/
PB_72_Click: 
    call DetlsDlg vrwindow(), '72', addonins.72.drv, addonins.72.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.72.drv addonins.72.path
return

/*:VRX         PB_73_Click
*/
PB_73_Click: 
    call DetlsDlg vrwindow(), '73', addonins.73.drv, addonins.73.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.73.drv addonins.73.path
return

/*:VRX         PB_74_Click
*/
PB_74_Click: 
    call DetlsDlg vrwindow(), '74', addonins.74.drv, addonins.74.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.74.drv addonins.74.path
return

/*:VRX         PB_75_Click
*/
PB_75_Click: 
    call DetlsDlg vrwindow(), '75', addonins.75.drv, addonins.75.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.75.drv addonins.75.path
return

/*:VRX         PB_76_Click
*/
PB_76_Click: 
    call DetlsDlg vrwindow(), '76', addonins.76.drv, addonins.76.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.76.drv addonins.76.path
return

/*:VRX         PB_77_Click
*/
PB_77_Click: 
    call DetlsDlg vrwindow(), '77', addonins.77.drv, addonins.77.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.77.drv addonins.77.path
return

/*:VRX         PB_78_Click
*/
PB_78_Click: 
    call DetlsDlg vrwindow(), '78', addonins.78.drv, addonins.78.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.78.drv addonins.78.path
return

/*:VRX         PB_79_Click
*/
PB_79_Click: 
    call DetlsDlg vrwindow(), '79', addonins.79.drv, addonins.79.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.79.drv addonins.79.path
return

/*:VRX         PB_7_Click
*/
PB_7_Click: 
    call DetlsDlg vrwindow(), '07', addonins.07.drv, addonins.07.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.07.drv addonins.07.path
return

/*:VRX         PB_80_Click
*/
PB_80_Click: 
    call DetlsDlg vrwindow(), '80', addonins.80.drv, addonins.80.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.80.drv addonins.80.path
return

/*:VRX         PB_81_Click
*/
PB_81_Click: 
    call DetlsDlg vrwindow(), '81', addonins.81.drv, addonins.81.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.81.drv addonins.81.path
return

/*:VRX         PB_82_Click
*/
PB_82_Click: 
    call DetlsDlg vrwindow(), '82', addonins.82.drv, addonins.82.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.82.drv addonins.82.path
return

/*:VRX         PB_83_Click
*/
PB_83_Click: 
    call DetlsDlg vrwindow(), '83', addonins.83.drv, addonins.83.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.83.drv addonins.83.path
return

/*:VRX         PB_84_Click
*/
PB_84_Click: 
    call DetlsDlg vrwindow(), '84', addonins.84.drv, addonins.84.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.84.drv addonins.84.path
return

/*:VRX         PB_85_Click
*/
PB_85_Click: 
    call DetlsDlg vrwindow(), '85', addonins.85.drv, addonins.85.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.85.drv addonins.85.path
return

/*:VRX         PB_86_Click
*/
PB_86_Click: 
    call DetlsDlg vrwindow(), '86', addonins.86.drv, addonins.86.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.86.drv addonins.86.path
return

/*:VRX         PB_87_Click
*/
PB_87_Click: 
    call DetlsDlg vrwindow(), '87', addonins.87.drv, addonins.87.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.87.drv addonins.87.path
return

/*:VRX         PB_88_Click
*/
PB_88_Click: 
    call DetlsDlg vrwindow(), '88', addonins.88.drv, addonins.88.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.88.drv addonins.88.path
return

/*:VRX         PB_89_Click
*/
PB_89_Click: 
    call DetlsDlg vrwindow(), '89', addonins.89.drv, addonins.89.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.89.drv addonins.89.path
return

/*:VRX         PB_8_Click
*/
PB_8_Click: 
    call DetlsDlg vrwindow(), '08', addonins.08.drv, addonins.08.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.08.drv addonins.08.path
return

/*:VRX         PB_90_Click
*/
PB_90_Click: 
    call DetlsDlg vrwindow(), '90', addonins.90.drv, addonins.90.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.90.drv addonins.90.path
return

/*:VRX         PB_91_Click
*/
PB_91_Click: 
    call DetlsDlg vrwindow(), '91', addonins.91.drv, addonins.91.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.91.drv addonins.91.path
return

/*:VRX         PB_92_Click
*/
PB_92_Click: 
    call DetlsDlg vrwindow(), '92', addonins.92.drv, addonins.92.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.92.drv addonins.92.path
return

/*:VRX         PB_93_Click
*/
PB_93_Click: 
    call DetlsDlg vrwindow(), '93', addonins.93.drv, addonins.93.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.93.drv addonins.93.path
return

/*:VRX         PB_94_Click
*/
PB_94_Click: 
    call DetlsDlg vrwindow(), '94', addonins.94.drv, addonins.94.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.94.drv addonins.94.path
return

/*:VRX         PB_95_Click
*/
PB_95_Click: 
    call DetlsDlg vrwindow(), '95', addonins.95.drv, addonins.95.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.95.drv addonins.95.path
return

/*:VRX         PB_96_Click
*/
PB_96_Click: 
    call DetlsDlg vrwindow(), '96', addonins.96.drv, addonins.96.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.96.drv addonins.96.path
return

/*:VRX         PB_97_Click
*/
PB_97_Click: 
    call DetlsDlg vrwindow(), '97', addonins.97.drv, addonins.97.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.97.drv addonins.97.path
return

/*:VRX         PB_98_Click
*/
PB_98_Click: 
    call DetlsDlg vrwindow(), '98', addonins.98.drv, addonins.98.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.98.drv addonins.98.path
return

/*:VRX         PB_99_Click
*/
PB_99_Click: 
    call DetlsDlg vrwindow(), '99', addonins.99.drv, addonins.99.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.99.drv addonins.99.path
return

/*:VRX         PB_9_Click
*/
PB_9_Click: 
    call DetlsDlg vrwindow(), '09', addonins.09.drv, addonins.09.path, msg.0520, msg.0521, msg.0501, msg.0502, msg.0329, msg.0522, msg.0523, msg.0524, msg.0525, msg.0519, msg.0025, msg.0526, msg.0527
    parse var result addonins.09.drv addonins.09.path
return

/*:VRX         process_checkbox_event
*/
process_checkbox_event: 

    ctrlid = 'CB_'i
    pbutid = 'PB_'i
    if length(i)=1 then sectionid='0'i
    else sectionid = i
    bt.0 = 2
    bt.1 = 'OK'
    bt.2 = msg.0519
    if InitArgs.1 <> '/UNINSTALL' then msg_text = value("addonins."sectionid".warning")
    else msg_text = ''

    enabled = VRGet( pbutid, "Enabled" )
    selected = VRGet( ctrlid, "Set" )
    if selected = 1 then do
				call VRMethod 'PB_100', 'SetFocus'
        if msg_text <> '' then call vrmessage vrwindow(), msg_text, 'Are you sure?', 'I', 'bt.', 1, 2
        if msg_text = '' | result = 1 then do
            call VRSet pbutid, "Enabled", 1 
            if InitArgs.1 <> '/UNINSTALL' then do
        	     restriction_list = value("addonins."sectionid".reset")
                do while restriction_list <> ''
                    parse var restriction_list extension restriction_list
                    extension = substr(extension, 1, 2)
                    call VRSet "CB_"space(extension), "Set", 0 
                    call VRSet "PB_"space(extension), "Enabled", 0 
                end
        	      restriction_list = value("addonins."sectionid".set")
                do while restriction_list <> ''
                    parse var restriction_list extension restriction_list
                    extension = substr(extension, 1, 2)
                    call VRSet "CB_"space(extension), "Set", 1 
                    call VRSet "PB_"space(extension), "Enabled", 1 
                end
            end
        end
        else call VRSet ctrlid, "Set", 0 
    end
    else do
        call VRSet pbutid, "Enabled", 0 
        call VRSet ctrlid, "Enabled", 1 
    end

return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         set_text_labels_of_main_window
*/
set_text_labels_of_main_window: 

    call VRSet vrwindow(), "Caption", msg.0495
    call vrset vrwindow(), "windowlisttitle", msg.0495

    call VRSet "DT_1", "Caption", msg.0494 
    call VRSet "PB_100", "Caption", msg.0514 
    call VRSet "PB_101", "Caption", msg.0519

return
/*:VRX         SW_0_Close
*/
SW_0_Close: 
    call SW_0_Fini
return

/*:VRX         SW_0_Create
*/
SW_0_Create: 
    call SW_0_Init

    /* display products */
    do i=0 to 9
        call display_product_controls
    end

return

/*:VRX         SW_0_Fini
*/
SW_0_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_0_Init
*/
SW_0_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_1_Close
*/
SW_1_Close: 
    call SW_1_Fini
return

/*:VRX         SW_1_Create
*/
SW_1_Create: 
    call SW_1_Init

    /* display products */
    do i=10 to 19
        call display_product_controls
    end

return

/*:VRX         SW_1_Fini
*/
SW_1_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_1_Init
*/
SW_1_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_2_Close
*/
SW_2_Close: 
    call SW_2_Fini
return

/*:VRX         SW_2_Create
*/
SW_2_Create: 
    call SW_2_Init

    /* display products */
    do i=20 to 29
        call display_product_controls
    end

return

/*:VRX         SW_2_Fini
*/
SW_2_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_2_Init
*/
SW_2_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_3_Close
*/
SW_3_Close: 
    call SW_3_Fini
return

/*:VRX         SW_3_Create
*/
SW_3_Create: 
    call SW_3_Init

   /* display products */
    do i=30 to 39
        call display_product_controls
    end

return

/*:VRX         SW_3_Fini
*/
SW_3_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_3_Init
*/
SW_3_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_4_Close
*/
SW_4_Close: 
    call SW_4_Fini
return

/*:VRX         SW_4_Create
*/
SW_4_Create: 
    call SW_4_Init

   /* display products */
    do i=40 to 49
        call display_product_controls
    end

return

/*:VRX         SW_4_Fini
*/
SW_4_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_4_Init
*/
SW_4_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_5_Close
*/
SW_5_Close: 
    call SW_5_Fini
return

/*:VRX         SW_5_Create
*/
SW_5_Create: 
    call SW_5_Init

   /* display products */
    do i=50 to 59
        call display_product_controls
    end

return

/*:VRX         SW_5_Fini
*/
SW_5_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_5_Init
*/
SW_5_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_6_Close
*/
SW_6_Close: 
    call SW_6_Fini
return

/*:VRX         SW_6_Create
*/
SW_6_Create: 
    call SW_6_Init

   /* display products */
    do i=60 to 69
        call display_product_controls
    end

return

/*:VRX         SW_6_Fini
*/
SW_6_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_6_Init
*/
SW_6_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_7_Close
*/
SW_7_Close: 
    call SW_7_Fini
return

/*:VRX         SW_7_Create
*/
SW_7_Create: 
    call SW_7_Init

    /* display products */
    do i=70 to 79
        call display_product_controls
    end

return

/*:VRX         SW_7_Fini
*/
SW_7_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_7_Init
*/
SW_7_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_8_Close
*/
SW_8_Close: 
    call SW_8_Fini
return

/*:VRX         SW_8_Create
*/
SW_8_Create: 
    call SW_8_Init

    /* display products */
    do i=80 to 89
        call display_product_controls
    end

return

/*:VRX         SW_8_Fini
*/
SW_8_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_8_Init
*/
SW_8_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         SW_9_Close
*/
SW_9_Close: 
    call SW_9_Fini
return

/*:VRX         SW_9_Create
*/
SW_9_Create: 
    call SW_9_Init

   /* display products */
    do i=90 to 99
        call display_product_controls
    end

return

/*:VRX         SW_9_Fini
*/
SW_9_Fini: 
    window = VRInfo( "Window" )
    call VRDestroy window
    drop window
return
/*:VRX         SW_9_Init
*/
SW_9_Init: 
    window = VRInfo( "Object" )
    if( \VRIsChildOf( window, "Notebook" ) ) then do
        call VRMethod window, "CenterWindow"
        call VRSet window, "Visible", 1
        call VRMethod window, "Activate"
    end
    drop window
return

/*:VRX         Window1_Close
*/
Window1_Close:
    call Quit
return

