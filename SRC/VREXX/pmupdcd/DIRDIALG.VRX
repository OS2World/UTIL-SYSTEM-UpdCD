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

VRLoadSecondary: procedure
    name = arg( 1 )

    window = VRLoad( VRWindow(), VRWindowPath(), name )
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
return window

/*:VRX         0_Copyright
*/
0_Copyright:
/*
    This is DirDialog V1.0. (C) 1994 by Ralf G. R. Bergs

    E-mail:     rabe@pool.informatik.rwth-aachen.de
    Snail mail: Hueckeswagener Str. 42, 51647 Gummersbach, FR of Germany
    Phone/fax:  +49 2261 21968


    License:
    =======
    "This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public
    License along with this library; if not, write to the Free
    Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA."


    Purpose:
    =======
    DirDialg() is a dialog similar to the system file dialog. In contrast
    to the latter it is NOT used to select individual files, but a directory
    from a list.


    Usage:
    =====
    dir = DirDialg( caption, startdir )

        caption:  the dialog window's title (default: "Select a directory")
        startdir: the directory initially displayed when you call DirDialg()
                    (default: the current working directory at the time your
                    application was started)
        dir:      either a directory you selected or "" if you pressed
                    "Cancel."

    History:
    =======
    08/21/94    First public release V1.0

*/
return

/*:VRX         Fini
*/
Fini:
    window = VRWindow()
    call VRSet window, "Visible", 0
    drop window
return RetCode                  /* return selected directory */
/*:VRX         Halt
*/
Halt:
    signal _VREHalt
return

/*:VRX         Init
*/
Init:
/* Arguments to DirDialg:
    1: Caption (the dir dialog's title header)
    2: startDir (the starting directory to be displayed in the dir dialog)
*/

    retcode = ""                    /* used to return selected directory */

    if InitArgs.0 >= 1 then do
        call VRSet "W_DirDialog", "Caption", InitArgs.1
    end

    if InitArgs.0 = 2 then do
        startDir = InitArgs.2
    end
    else do                         /* if no start dir given, use current */
                                    /* working directory */
        startDir = VRGet( "Application", "WorkingDirectory" )
    end

    window = VRWindow()
    call VRMethod window, "CenterWindow"
    call VRSet window, "Visible", 1
    call VRMethod window, "Activate"
    drop window

    call InitDriveList
    call InitDirList startDir

    drop startDir
return

/*:VRX         InitDirList
*/
InitDirList: procedure
parse arg cwd
    Call VRSet "EF_CurrDir", "Value", cwd

    call VRSet "W_DirDialog", "Enabled", 0      /* prevent input into window */
    call VRSet "W_DirDialog", "Pointer", "Wait" /* show "Busy" mouse pointer */

    call VRMethod "LB_Dirs", "Clear"
    call UpdateDirList cwd

    call VRSet "EF_CurrDir", "SelectedStart", 1 /* pre-select EntryField's */
    call VRSet "EF_CurrDir", "SelectedEnd", ,   /* contents */
            Length(cwd)+1
    call VRMethod  "EF_CurrDir", "SetFocus"

    call VRSet "W_DirDialog", "Pointer", "<Default>"
    call VRSet "W_DirDialog", "Enabled", 1      /* allow input again */
return

/*:VRX         InitDriveList
*/
InitDriveList: procedure
/* get currently available drives and update drive list box accordingly */

    notRegistered = RxFuncQuery( "SysDriveMap" )
    if notRegistered then do
        call RxFuncAdd "SysDriveMap", "RexxUtil", "SysDriveMap"
    end
    DriveMap = SysDriveMap( "A:", "USED" )      /* returns available drives */
    if notRegistered then do
        call RxFuncDrop( "SysDriveMap" )
    end

    ok = VRMethod( "LB_Drives", "Clear" )       /* clear all list items */

    do until DriveMap = ""                      /* "unpack" drive map */
        parse var DriveMap Drive DriveMap
        if Drive \= "A:" & Drive \= "B:" then do
            Drive = Drive || " [" || VRDiskLabel( Drive ) || "]"
        end
        ok = VRMethod( "LB_Drives", "AddString", ,
                Drive )                         /* add drive to list box */
    end
return
/*:VRX         LB_Dirs_DoubleClick
*/
LB_Dirs_DoubleClick: procedure
    cwd = VRGet( "EF_CurrDir", "Value" )
    dir = VRExpandFileName( cwd || "\" || VRGet( "LB_Dirs", "SelectedString" ),
             || "\" )
    Call InitDirList dir
return

/*:VRX         LB_Drives_DoubleClick
*/
LB_Drives_DoubleClick: procedure
    drive = word( VRGet( "LB_Drives", "SelectedString" ), 1)
    cwd = VRExpandFileName( drive || VRCurrDir( drive ) )
    Call InitDirList cwd
return

/*:VRX         PB_Cancel_Click
*/
PB_Cancel_Click:
    call Quit
return

/*:VRX         PB_Ok_Click
*/
PB_Ok_Click:
    Dir = VRGet( "EF_CurrDir", "Value" )
    if VRIsDir( Dir ) then do
        Retcode = Dir
        call Quit
    end
    else do
        call VRMethod  "EF_CurrDir", "SetFocus"
    end
return

/*:VRX         Quit
*/
Quit:
    window = VRWindow()
    call VRSet window, "Shutdown", 1
    drop window
return

/*:VRX         UpdateDirList
*/
UpdateDirList: procedure
/* Arguments:
    dir:    path for which to return an array with all subdirectory names in it
            WITHOUT trailing backslash
*/
arg dir
if (length(dir) = 3) then do
 d = VRDir( dir || "*", "N", "D" )
 do while d \= ""
  if d \= "." & VRIsDir( dir || d) then do
   call VRMethod "LB_Dirs", "AddString", d
  end
  d = VRDir( , "N", )
 end
end; else do
 d = VRDir( dir || "\*", "N", "D" )
 do while d \= ""
  if d \= "." & VRIsDir( dir || "\" || d) then do
   call VRMethod "LB_Dirs", "AddString", d
  end
  d = VRDir( , "N", )
 end
end
return

/*:VRX         W_DirDialog_Close
*/
W_DirDialog_Close:
    call Quit
return

