:TITLE
VGA32 main DSP

:KEY
VGA32

*:FILES :MODE=PRIMARY

*:FILES :MODE=PRIMARY :MODE=DOS

*:FILES :MODE=PRIMARY :MODE=WINDOWS

:CONFIG :MODE=PRIMARY
DEVINFO=SCR,VGA,%BOOTDRIVE%:\OS2\BOOT\VIOTBL.DCP
SET VIDEO_DEVICES=VIO_VGA
SET VIO_VGA=DEVICE(BVHVGA)

:CONFIG :MODE=PRIMARY :MODE=BIDI
SET VIO_VGA=DEVICE(BVHVGA,BDBVH)

:CONFIG :MODE=PRIMARY :MODE=DOS
DEVICE=%BOOTDRIVE%:\OS2\MDOS\VVGA.SYS

:CONFIG :MODE=DUAL :MODE=DOS
DEVICE=%BOOTDRIVE%:\OS2\MDOS\VVGA.SYS /DUAL

:OS2INI :MODE=PRIMARY
%BOOTDRIVE%:\OS2\INSTALL\REINSTAL.INI
InstallWindow VIOADAPTERSTR 4

:OS2INI :MODE=SECONDARY
%BOOTDRIVE%:\OS2\INSTALL\REINSTAL.INI
InstallWindow VIOADAPTER2STR 4

:OS2INI :MODE=PRIMARY
OS2.INI
PM_DISPLAYDRIVERS  IBMVGA32       IBMVGA32
PM_DISPLAYDRIVERS  CURRENTDRIVER  IBMVGA32
PM_DISPLAYDRIVERS  DEFAULTDRIVER  IBMVGA32
PM_Fonts           COURIERI
PM_Fonts           HELVI
PM_Fonts           TIMESI

:WININI :MODE=PRIMARY :MODE=WINDOWS
WIN.INI
fonts "Symbol %ANYSTRING%"
fonts "Helv %ANYSTRING%"
fonts "Tms Rmn %ANYSTRING%"
fonts "Courier %ANYSTRING%"
fonts "MS Sans Serif %ANYSTRING%"
fonts "MS Serif %ANYSTRING%"
fonts "Small Fonts %ANYSTRING%"
fonts "Roman (Plotter)"                           ROMAN.FON
fonts "Script (Plotter)"                          SCRIPT.FON
fonts "Modern (Plotter)"                          MODERN.FON
fonts "MS Sans Serif 8,10,12,14,18,24 (VGA res)"  sserife.fon
fonts "Courier 10,12,15 (VGA res)"                coure.fon
fonts "MS Serif 8,10,12,14,18,24 (VGA res)"       serife.fon
fonts "Symbol 8,10,12,14,18,24 (VGA res)"         symbole.fon
fonts "Small Fonts (VGA res)"                     smalle.fon
Desktop IconSpacing 75

:WININI :MODE=PRIMARY :MODE=WINDOWS
SYSTEM.INI
* boot   MAVDMApps    !printman
* boot   386grabber   vga.gr3
boot   fixedfon.fon vgafix.fon
boot   fonts.fon    vgasys.fon
boot   oemfonts.fon vgaoem.fon
boot   display.drv  vga.drv
* 386Enh display      *vddvga
boot   sdisplay.drv swinvga.drv

:CONFIG :MODE=SECONDARY
SET VIDEO_DEVICES = VIO_VGA,VIO_%PRI%
SET VIO_%PRI% = DEVICE(BVH%PRI%)
SET VIO_VGA   = DEVICE(BVHVGA)

:CONFIG :MODE=SECONDARY :MODE=BIDI
SET VIO_%PRI% = DEVICE(BVH%PRI%,BDBVH)

