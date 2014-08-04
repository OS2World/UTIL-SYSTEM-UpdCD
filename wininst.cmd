@echo off
cls
echo+

REM check
if not exist .\newinst\config.sys goto msg1
if "%1" == "" goto msg2
if not exist %1\CID\LOCINSTU\getrexx.cmd goto msg3

REM Add basic REXX
echo+
echo Installing basic REXX support to UpdCD directory...
call %1\CID\LOCINSTU\getrexx.cmd %1\os2image maint > wininst.log 2>>&1
if ERRORLEVEL 1 goto bad
copy %1\CID\LOCINSTU\srvrexx.exe maint\. >> wininst.log 2>>&1
if ERRORLEVEL 1 goto bad

REM Start REXX
echo+
echo Starting basic REXX...
copy a:\* maint\. >> wininst.log 2>>&1
cd maint
detach srvrexx

REM Start Swapping
echo+
echo Start swapping...
call ..\bin\startswp.cmd %1

REM Add more files
echo+
echo Adding more files...
call ..\bin\getfiles.cmd ..\bin\getfiles.txt %1
cd ..
copy bin\vfctrl.exe maint\. >> wininst.log 2>>&1

REM Update Config.Sys
call bin\updcfg.cmd %1 

REM reboot
echo+
echo Please insert UpdCD disk 0 into drive A: and reboot.

goto end

REM Usage Message
:msg1
        echo Did you run this script from the UpdCD directory?
goto end

REM Usage Message
:msg2
        echo Create UpdCD maintanance system
        echo+
        echo Usage: WinInst.Cmd [path to OS/2 installation CD-ROM]
        echo Example: WinInst.Cmd H:\CDROM\WARP4
        echo+
        echo Try again!
goto end

REM Usage Message
:msg3
        echo+
        echo %1 is not a valid CD-ROM location.
goto end

REM Error
:bad
        echo A problem occured during installation.
goto end

:end
