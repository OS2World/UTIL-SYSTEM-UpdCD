�MKMSGF CB2�     �         ��(�q�G���
+\z�[�	�	�	�
0������ #&),/258;R���i�� p�n� �� �4w Y � � 4!�!h"�"�"(#F#I#L#O#R#U#z#�#�#$R$�$�$�$6%]%�%�%)&f&�&�&:'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�'�''(9(X(s(�(�(�(�())=)S)n)�)�)�)�)�)�)�)�)�) *
*****7*D*P*`*i*w*z*}*     �                              CB2Gr.msg                                                                                                                                                                                                                                                            II CB2Gr.msg
EE Can't load message %1 from messagefile %2. Please report this problem to the author.
II Can't load message from NLS (National Language Support) message file, trying US English version.
EE Can't load message from NLS (National Language Support) and from US English message files. CD Boot/2 can't continue, press "Close" to exit.
EE Fehler SYS%1 beim Schreiben der Logdatei %2. CD Boot/2 schreibt keine Logdatei.
II DLL Ausf�hrung fehlgeschlagen! CD Boot/2 kann nicht fortfahren, dr�cken Sie den "%1" Druckknopf.
II Dr�cken Sie den "%1" Druckknopf um CD Boot/2 zu beenden.
IX                                 CD Boot/2 V2.00
IX              (C) Roman Stangl (Roman_Stangl@at.ibm.com)  05, 2002
IX               http://www.geocities.com/SiliconValley/Pines/7885/
IX Beenden
II Initialisiere CD Boot/2 Environment ...
II Lade CD Boot/2 Meldungen ...
II CD Boot/2 L�uft unter dem %1 Environment ...
II Lade CD Boot/2 Module ...
II Lade CD Boot/2 Resourcen DLL ...
II Fehler beim Laden der CD Boot/2 Meldungen Datei "%1". Meldungen werden m�glicherweise in Englisch angezeigt!
II Fehler SYS%1 beim Laden der CD Boot/2 Resourcen DLL "%2", Modul "%3" trug zum Fehler bei. CD Boot/2 beendet.
Probieren Sie bitte CD Boot/2 mit einer unterst�tzten Sprache (z.B. Englisch mit "/Language Us") als Parameter zu starten.
Resourcen werden daher Englisch geladen! CD Boot/2 beendet wenn das auch nicht funktioniert.
EE Falsche Version der CD Boot/2 Resourcen DLL "%1", benutzen Sie OS/2's BLDLEVEL Befehl um die Versionen von Modulen anzuzeigen. CD Boot/2 beendet.
II Lade CD Boot/2 Compiler DLL %1 ...
EE Fehler SYS%1 beim Laden der CD Boot/2 Compiler DLL "%2", Modul "%3" trug zum Fehler bei.
Bitte �berpr�fen Sie ob diese DLL korrekt installiert ist! CD Boot/2 beendet.
II Lade CD Boot/2 Code DLL ...
EE Fehler SYS%1 beim Laden der CD Boot/2 Code DLL "%2", Modul "%3" trug zum Fehler bei.
Bitte �berpr�fen Sie die Aufrufumgebung ob diese DLL korrekt installiert ist! CD Boot/2 beendet.
EE Falsche Version der CD Boot/2 Code DLL "%1", benutzen Sie OS/2's BLDLEVEL Befehl um die Versionen von Modulen anzuzeigen. CD Boot/2 beendet.
EE Fehler SYS%1 beim Laden der Einsprungaddresse def CD Boot/2 Code DLL "%2". CD Boot/2 beendet.
EE Fehler beim Starten des Threads der die CD Boot/2 Code DLL "%1" ausf�hrt. CD Boot/2 beendet.
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
II Syntax: CDBOOT/CDBOOTPM [/?] [/LANGUAGE ll] [/LOG [logdatei]]
          [/CID ciddatei] [/DRIVE d /TIMEOUT tt] [/CPYCOLOR c]
          [/MSG1 text] [/MSG2 text] [/MSG3 text] [/MSGCOLOR m]
          [/HARDDISK | /REMOVEABLE] [/CLEAR] [/BM] [/PASSWORD kennwort] 
          Wobei:
                  ?  ........ Zeigt diese Hilfe
                  ll ........ Sprache die verwendet werden soll (CB2ll.msg ist
                              dazu erforderlich sonst wird Englisch verwendet)
                  logdatei... Optionale Logdatei (Standard: CB2.LOG)
                  ciddatei .. Datei aus der Parameter gelesen werden
                  d  ........ Bootf�higes Wechselmedium wo CD Boot/2
                              installiert werden soll (A, B, ... ,Z)
                  tt ........ Periode nach der CD Boot/2 weiter von der ersten
                              Festplatte bootet (1...60)
                  c ......... Farbe der Copyright Nachricht (0...15)
                  text ...... Benutzerdefinierte Nachricht die durch CD Boot/2
                              angezeigt wird (max. 79 Zeichen)
                  m ......... Farbe der Benutzerdefinierten Nachricht (0...15)
                  kennwort .. Kennwort um vom Wechselmedium zu booten (max. 7 
                              Zeichen, 0...9, A...Z, a...z)
          R�ckgabewerte:
                  0  ........ Erfolgreiche Durchf�hrung
                  1  ........ Warnung, ung�ltiger Parameter
                  2  ........ Fatal, interner Verarbeitungsfehler
II Syntax: CDBOOT/CDBOOTPM [/?] [/LANGUAGE ll] [/LOG [logdatei]] [/CID cidfile] [/DRIVE d /TIMEOUT tt] [/CPYCOLOR c] [/MSG1 text] [/MSG2 text] [/MSG3 text] [/MSGCOLOR m] [/PASSWORD kennwort]
          Wobei:
                  ?  ........ Zeigt diese Hilfe
                  ll ........ Sprache die verwendet werden soll (CB2ll.msg ist dazu erforderlich sonst wird Englisch verwendet)
                  logdatei .. Optionale Logdatei (Standard: CB2.LOG)
                  ciddatei .. Datei aus der Parameter gelesen werden
                  d  ........ Bootf�higes Wechselmedium wo CD Boot/2 installiert werden soll (A, B, ..., Z)
                  tt ........ Periode nach der CD Boot/2 weiter von der ersten Festplatte bootet (1...60)
                  c ......... Farbe der Copyright Nachricht (0...15)
                  text ...... Benutzerdefinierte Nachricht die durch CD Boot/2 angezeigt wird (max. 79 Zeichen)
                  m ......... Farbe der Copyright Nachricht (0...15)
                  kennwort .. Kennwort um vom Wechselmedium zu booten (max. 7 Zeichen, 0...9, A...Z, a...z)
          R�ckgabewerte:
                  0  ........ Kein Fehler, Erfolgreiche Durchf�hrung
                  1  ........ Warnung, ung�ltiger Parameter angegeben
                  2  ........ Fataler Verarbeitungsfehler
EE Optionaler Parameter "/DRIVE d" (wobei d ein Wechselmedium ist, wie z.B. A) unvollst�ndig oder ung�ltig! CD Boot/2 beendet.
EE Optionaler Parameter "/TIMEOUT tt" (wobei tt die Periode von 1 bis 60 Sekunden ist) unvollst�ndig oder ung�ltig! CD Boot/2 beendet.
EE Optionale Parameter "/DRIVE d" und "/TIMEOUT tt" m�ssen zusammen angegeben werden! CD Boot/2 beendet.
EE Optionale Parameter "/HARDDISK" und "/REMOVEABLE" d�rfen nicht zusammen angegeben werden! CD Boot/2 beendet.
II Unterst�tzte Befehlszeilenparameter sind g�ltig und werden verwendet.
EE Optionaler Parameter "/MSG? text" ist zu lange (>79 Zeichen) f�r "text"! CD Boot/2 beendet.
EE Optionaler Parameter "/PASSWORD kennwort" ist zu lange (>7 Zeichen) oder enth�lt ung�ltige Zeichen (d.h. nicht 0...9, A...Z, a...z). CD Boot/2 beendet.
II Angegebene Parameter ausreichend, CD Boot/2 l�uft ohne Benutzerinverventionen.
I
I
I
I
I
I
I
I
I
I
EE Erzeugung des Anchor Blocks schlug mit Fehler 0x%1 fehl. CD Boot/2 beendet.
EE Erzeugung der Message Queue schlug mit Fehler 0x%1 fehl. CD Boot/2 beendet.
EE Erzeugung des Dialog Fensters schlug mit Fehler 0x%1 fehl. CD Boot/2 beendet.
EE �ffnen des ausgew�hlten Wechselmediums schlug mit Fehler SYS%1 fehl. CD Boot/2 beendet.
EE Sperren des ausgew�hlten Wechselmediums schlug mit Fehler SYS%1 fehl. CD Boot/2 beendet.
EE Lesen/Schreiben des Bootsektors schlug mit Fehler SYS%1 fehl. CD Boot/2 beendet.
EE Schliessen des ausgew�hlten Wechselmediums schlug mit Fehler SYS%1 fehl. CD Boot/2 beendet.
EE Lesen/Schreiben von CD2BOOT schlug fehl. CD Boot/2 beendet.
EE Der Inhalt von CD2BOOT ist ung�ltig, probieren Sie eine Neuinstallation. CD Boot/2 beendet.
EE Ung�ltiger Bootsektor, Referenz auf "OS2BOOT" fehlt. Bitte stellen Sie sicher dass Sie den Bootsektor eines Wechselmediums ausw�hlen. CD Boot/2 beendet.
II Die Laufwerke %1 unterst�tzen vermutlich Wechselmedien auf denen der CD Boot/2 Boot Lader installiert werden kann.
IQ Auf welches Wechsellaufwerk wollen Sie CD Boot/2 installieren?
II CD Boot/2 erlaubt es eine Periode von %1 bis %2 Sekunden zu definieren in der sie durch die Tasten 1 oder 2 von einem anderem als dem Standardmedium booten k�nnen.
IQ Wieviele Sekunden wollen Sie CD Boot/2 warten lassen?
II Lese den Bootsektor vom Wechselmedium %1.
II Lese den CD2BOOT Kode aus Datei %1.
WW Der Bootsektor vom Wechselmedium %1 wurde schon durch einen Lauf von CD Boot/2 modifiziert! CD Boot/2 wird dies ber�cksichtigen.
II Der Bootsektor vom Wechselmedium scheint ein FAT-basierender nicht-OS/2 Bootsektor (z.B. von DOS) zu sein. Wahrscheinlich ist er dennoch kompatibel mit CD Boot/2.
WW Der Bootsektor vom Wechselmedium scheint OS/2 oder FAT-basierender Bootsektor zu sein. Wahrscheinlich ist er inkompatibel mit CD Boot/2!
II Schreibe den CD2BOOT Kode in Datei %1. 
II Modifiziere den Bootsektor vom Wechselmedium um CD2BOOT statt OS2BOOT zu laden.
II Schreibe den modifizierten Bootsektor auf Wechselmedium %1.
IX CD2BOOT - CD Boot/2 V2.00
I
I
I
I
I
II CD Boot/2 wird initialisiert ...
II Warten auf Ende der Verarbeitung von CD Boot/2 ...
IX CD2BOOT - CD Boot/2 V2.00
IX Copyright (C) Roman Stangl (Roman_Stangl@at.ibm.com) 05, 2002
IX           http://www.geocities.com/SiliconValley/Pines/7885/
IX Bitte w�hlen Sie das Medium ( ist Standardmedium) von dem Sie booten wollen:
IX   1 ... Von der ersten Festplatte
IX   2 ... Vom Wechselmedium
IX Bitte innerhalb %d Sekunden w�hlen, sonst wird Standardmedium gebootet!
IX Boote weiter vom Wechselmedium ...
IX Boote weiter von der ersten Festplatte ...
IX CD2Boot SYS02025: Lesefehler bei der Partitionstabelle der ersten Festplatte!
IX CD2Boot SYS02027: Systemdiskette einsetzen und das System neu starten!
IX Bitte Kennwort eingeben um vom Wechselmedium zu booten: 
IX Ung�ltiges Kennwort, neu eingeben oder mit ALT+CTRL+DEL rebooten: 
IX Partitionstabelle enth�lt keine aktive OS/2 Bootmanager Partition.
IX Partitionstabelle enth�lt eine aktive OS/2 Bootmanager Partition.
IX CD2BOOT ist defekt o. fragmentiert - System gestoppt! Mit ALT+CTRL+DEL rebooten!
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
I
IX CD Boot/2 Boot Lader "CD2BOOT" Einstellungen:
IX Installation:
IX Installieren auf Laufwerk:
IX Pfad von CD2BOOT Kode:
IX Verz�gerung [Sekunden]:
IX Standard ist ~Festplatten Boot
IX Standard ist ~Wechselmedium Boot
IX ~BIOS Schirm l�schen
IX Optionaler Kennwortschutz:
IX ~Aktivieren
IX Erweitertes Harddisk Boot
IX Akti~vieren      
IX Copyright Nachrichten:
IX Optionale Benutzerdefinierte Nachrichten:
IX ~Installieren
IX ~Beenden
IX Farbe
IX Schwarz
IX Blau
IX Gr�n
IX Cyan
IX Rot
IX Magenta
IX Braun
IX Weiss
IX Grau
IX Hellblau
IX Hellgr�n
IX Hellcyan
IX Hellrot
IX Hellmagenta
IX Gelb
IX Hellweiss
I
I
I
