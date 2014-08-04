/* rexx program to tune the config.sys during phase2 from user macro file  */
/* 04.15.2001: initial release by Jeffrey R Smick (jeff.smick@verizon.net) */
/* 04.30.2001: added to UpdCD version 1.54                                 */
/* 05.17.2001: added to UpdCD version 1.61                                 */
/* 07.14.2001: unicode.sys must always be added to the config.sys          */
/* 06.16.2002: changed ibminst to instdir to enable Warp 3 cfg.sys tuning  */
/* 06.18.2002: added some logging                                          */
/* 10.25.2003: macrofile -> cmd line parameter                             */
/* 03.06.2005: added more logging                                          */

parse arg target instdir macroFile

/* log file */
logFile = target||"\"instdir"\tune.log"
'@echo TuneCfg: Starting tunecfg.cmd 'date() time()' >> 'logFile

/* remark this line when debugging */
cfgfile = target||"\config.sys"

/* always append some entries to the config.sys */
call append_to_cfgsys target 'DEVICE=?:\OS2\BOOT\UNICODE.SYS'

macroFile = target||"\"instdir"\"macroFile
comment = ";"

/* create some constants which will be used as array tails */
add_top     = 1
add_bot     = 2
update      = 3
remark      = 4
ppnd        = 5
apnd        = 6

variable    = 1
upCaseVar   = 2
definition  = 3
upCaseDef   = 4

childArray  = 1
elementPos  = 2

setLine     = 1
miscLine    = 2
notUsed     = 3
ifsLine     = 4
callLine    = 5
deviceLine  = 6
basedevLine = 7
runLine     = 8

cfgAry.0 = 0         /* stores the contents of the config.sys */
tasks.0 = 0          /* store tasks listed in macro file */

tasks.add_top.0 = 0          /* hold all items to be added to top of file */
tasks.add_bot.0 = 0          /* hold all items to be added to bottom of file */
tasks.update.0 = 0        /* items to be updated in their entirety */
tasks.remark.0 = 0        /* items to be removed */
tasks.ppnd.0 = 0       /* items to be prepended to existing lists of items */
tasks.apnd.0 = 0        /* items to be appended to existing lists of items */

cfgAry.basedevLine.0 = 0
cfgAry.callLine.0 = 0
cfgAry.deviceLine.0 = 0
cfgAry.ifsLine.0 = 0
cfgAry.runLine.0 = 0
cfgAry.setLine.0 = 0
cfgAry.miscLine.0 = 0
cfgAry.notUsed.0 = 0

/* open the macro file to read it only */
if stream( macroFile, "C", "OPEN READ" ) \== "READY:" then return

bInCmd = 0
bIgnore = 0
pattern = "<"
Do while lines( macroFile )
   /* read next line in to variable */
   theLine = strip( linein( macroFile ) )

   /* check if line is comment or blank - if so ignore and jump back to top of loop */
   If ( theLine == "" | substr( theLine, 1, 1 ) == comment ) Then iterate

   /* test if line is a command beginning or end */
   If pos( pattern, theLine ) > 0 Then Do
      If pattern == "<" Then Do
         cmd = translate( strip( substr( theLine, 2, length( theLine )-2 ) ) )
         bInCmd = 1
         bIgnore = 1
         pattern = "</"    /* start looking for end of command body now */
      End /* Do */
      Else Do
         bInCmd = 0
         pattern = "<"     /* resume looking for beginning of next command body now */
      End /* Do */
   End /* Do */

   If bInCmd Then Do
      If \bIgnore Then Do
         parse var theLine aVar "=" aDef

         aDef = translate( aDef, target, "?:" )

         /* determine which tail we will be adding a new element to */
         if cmd == "UPDATE" Then taskType = update
         else if cmd == "ADD_BOT" Then taskType = add_bot
         else if cmd == "APPEND" Then taskType = apnd
         else if cmd == "REMOVE" Then taskType = remark
         else if cmd == "ADD_TOP" Then taskType = add_top
         else if cmd == "PREPEND" Then taskType = ppnd

         num = tasks.taskType.0 + 1
         tasks.taskType.num.variable = aVar
         tasks.taskType.num.definition = aDef
         tasks.taskType.num.0 = 2
         tasks.taskType.0 = num
      End /* Do */
      Else bIgnore = 0 /* stop ignoring lines - only ignore the first line */
   End /* Do */
End /* Do */

/* close file now - done with it */
call stream macroFile, "C", "CLOSE"

/* now read config.sys into our array */
if stream( cfgfile, "C", "OPEN" ) \== "READY:" Then exit

currentLine = 0
Do while lines( cfgfile )
   theLine = linein( cfgfile )
   parse var theLine aVar "=" aDef
   aUpCaseVar = translate( aVar )

   /* determine which tail to add new element into */
   lineType = getLineType( aUpCaseVar )

   num = cfgAry.lineType.0 + 1
   /* create new array with variable and definition as elements and add to our cfgAry */
   cfgAry.lineType.num.variable = aVar
   cfgAry.lineType.num.upCaseVar = translate( aUpCaseVar )
   cfgAry.lineType.num.definition = aDef
   cfgAry.lineType.num.upCaseDef = translate( aDef )
   cfgAry.lineType.num.0 = 4
   cfgAry.lineType.0 = num

   currentLine = currentLine + 1
   originalOrder.currentLine.childArray = lineType
   originalOrder.currentLine.elementPos = num
   originalOrder.currentLine.0 = 2

End /* Do */
cfgAry.0 = currentLine
originalOrder.0 = currentLine

/* now begin updating the config.sys list by examining the tasks list */
/* that means we examine four of its tails - update remark apnd ppnd */

Do i = 1 to tasks.update.0
   upperCaseVar = translate( tasks.update.i.variable )
   lineType = getLineType( upperCaseVar )
   test = filespec( "N", word( translate( tasks.update.i.definition ), 1 ) )
   j = 1
   success = 0
   Do while ( ( j <= cfgAry.lineType.0 ) & \success )
      If cfgAry.lineType.j.upCaseVar == upperCaseVar Then Do
         If ( lineType > notUsed ) Then Do
            junk = word( cfgAry.lineType.j.upCaseDef, 1 )
            If filespec( "N", junk ) == test Then success = 1
         End /* Do */
         Else success = 1
      End /* Do */

      If success Then do
         cfgAry.lineType.j.definition = tasks.update.i.definition
         cfgAry.lineType.j.upCaseDef = translate( tasks.update.i.definition )
      end

      j = j + 1
   end /* do */
End /* Do */

Do i = 1 to tasks.remark.0
   upperCaseVar = translate( tasks.remark.i.variable )
   lineType = getLineType( upperCaseVar )
   test = word( translate( tasks.remark.i.definition ), 1 )
   j = 1
   success = 0
   Do while ( ( j <= cfgAry.lineType.0 ) & \success )

      If cfgAry.lineType.j.upCaseVar == upperCaseVar Then Do
         If ( lineType > notUsed ) Then Do
            If word( cfgAry.lineType.j.upCaseDef, 1 ) == test Then success = 1
         End /* Do */
         Else success = 1
      End /* Do */

      If success Then
         cfgAry.lineType.j.variable = "REM "||cfgAry.lineType.j.variable

      j = j + 1
   End /* Do */
End /* Do */

Do i = 1 to tasks.apnd.0
   upperCaseVar = translate( tasks.apnd.i.variable )
   lineType = getLineType( upperCaseVar )
   /* make sure there is a semi-colon at end of the new value to appended */
   If right( tasks.apnd.i.definition, 1 ) \== ";" Then tasks.apnd.i.definition = tasks.apnd.i.definition||";"
   j = 1
   success = 0
   Do while ( ( j <= cfgAry.lineType.0 ) & \success )
      If cfgAry.lineType.j.upCaseVar == upperCaseVar Then Do
         success = 1
         /* make sure there is a semi-colon at end of line */
         If right( cfgAry.lineType.j.definition, 1 ) \== ";" Then cfgAry.lineType.j.definition = cfgAry.lineType.j.definition||";"
         /* append new item to end of line */
         cfgAry.lineType.j.definition = cfgAry.lineType.j.definition||tasks.apnd.i.definition
      End /* Do */
      j = j + 1
   End /* Do */

End /* Do */

Do i = 1 to tasks.ppnd.0
   upperCaseVar = translate( tasks.ppnd.i.variable )
   lineType = getLineType( upperCaseVar )
   /* make sure there is a semi-colon at end of the new value to prepended */
   If right( tasks.ppnd.i.definition, 1 ) \== ";" Then tasks.ppnd.i.definition = tasks.ppnd.i.definition||";"
   j = 1
   success = 0
   Do while ( ( j <= cfgAry.lineType.0 ) & \success )
      If cfgAry.lineType.j.upCaseVar == upperCaseVar Then Do
         success = 1
         cfgAry.lineType.j.definition = tasks.ppnd.i.definition||cfgAry.lineType.j.definition
      End /* Do */
      j = j + 1
   End /* Do */
End /* Do */

/* reposition the write pointer back to beginning of file for overwriting */
call stream cfgfile, "C", "SEEK =1"

/* write any lines to top of config.sys file */
Do i = 1 to tasks.add_top.0
   call printLn tasks.add_top.i.variable, tasks.add_top.i.definition
End /* Do */

/* print out edited contents of cfgAry to file */
Do i = 1 to originalOrder.0
   lineType = originalOrder.i.childArray
   num = originalOrder.i.elementPos
   call printLn cfgAry.lineType.num.variable, cfgAry.lineType.num.definition
End /* Do */

/* write any lines to bottom of config.sys file */
Do i = 1 to tasks.add_bot.0
   call printLn tasks.add_bot.i.variable, tasks.add_bot.i.definition
End /* Do */

/* close file now - done with it */
call stream cfgfile, "C", "CLOSE"

'@echo TuneCfg: Ending tunecfg.cmd 'date() time()' >> 'logFile

exit

/* create a printable string from the elements previously saved in an array */
printLn: procedure expose cfgfile
   parse arg variable, definition

   If definition \== "" Then Do
      variable = variable||"="||definition
   End /* Do */

   call lineout cfgfile, variable
   return

getLineType: procedure expose notUsed setLine basedevLine callLine deviceLine ifsLine runLine miscLine
   parse arg upperCaseVar

   /* determine which tail we will be adding a new element to */
   if words( upperCaseVar ) == 2 Then lineType = setLine
   else if upperCaseVar == "DEVICE" Then lineType = deviceLine
   else if upperCaseVar == "BASEDEV" Then lineType = basedevLine
   else if upperCaseVar == "RUN" Then lineType = runLine
   else if upperCaseVar == "IFS" Then lineType = ifsLine
   else if upperCaseVar == "CALL" Then lineType = callLine
   else if word( upperCaseVar, 1 ) ==  "REM" | upperCaseVar == "" Then lineType = notUsed
   else lineType = miscLine

   return lineType

   /*   The order of the extended if --- then --- else is based  */
   /*   on the results, listed below, of an analysis on my config.sys of which    */
   /*   lines were used most frequently, with exception that      */
   /*   miscLine has to be last                                  */
   /*                                                            */
   /*   Number of set lines = 94                                 */
   /*   Number of basedev lines = 9                              */
   /*   Number of device lines = 50                              */
   /*   Number of call lines = 2                                 */
   /*   Number of run lines = 9                                  */
   /*   Number of ifs lines = 4                                  */
   /*   Number of misc lines = 27                                */


/* appends line cfgfile to config.sys if it is not present */
append_to_cfgsys: procedure expose LogFile

	parse upper arg drv cfgline
	cfgfile = drv'\config.sys'
	if stream(cfgfile, 'c', 'query exists') = '' then return
	cfgline = translate(cfgline, drv, '?')
	found = 0
	do while lines(cfgfile)
		l = translate(linein(cfgfile))
		if l = cfgline then do
			found = 1
			leave
		end
	end
	call lineout cfgfile
	if found = 0 & stream(substr(cfgline, pos('=', cfgline)+1), 'c', 'query exists') <> '' then do
		'@echo 'cfgline' >> 'cfgfile
		'@echo TuneCfg: Appended line "'cfgline'" with result "'result'" >> 'logFile
	end

return
