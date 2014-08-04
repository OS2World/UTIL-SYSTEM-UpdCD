/*-----------------------------------------------------------------------------

  Name:                   play.cmd
  Date Created:    12/27/92
                Copyright (c) IBM Corporation  1992, 1993
                          All Rights Reserved


  OS/2 REXX command file that uses MultiMedia REXX functions
  to play a file.

 -----------------------------------------------------------------------------*/

address cmd      /* Send commands to OS/2 command processor.  */
signal on error   /* When commands fail, call "error" routine. */
signal on halt    /* When user does a ctrl break               */

trace off
/*trace ?r*/

/* initialize variables */
FILE=''
LIST=''
FROM=''
TO=''
DEV=''
TIMEFMT=''
RANDOMIZEIT=0

REXXALIAS=0
DLLINIT=0

/* Setup keyword string array */
kwd.0 = 6
kwd.1 = 'FILE'
kwd.2 = 'DEV'
kwd.3 = 'TO'
kwd.4 = 'FROM'
kwd.5 = 'TIMEFMT'
kwd.6 = 'LIST'

/* Clear out argx variables */
do i = 1 to 6
  junk = value('arg'i,'')
end

arg inline                      /* Get the command line parms */
if (inline='' | inline='?') then
   do
     call Help
     exit 0
   end

/*
 * Check for each keyword
 * If "FILE" is found, look for quotes which signify possible embedded
 *   blanks.
 * Set argx (x is 1 to 5) to the entire keyword string, which ends in
 *   either a blank or a quote.
 */
do i = 1 to kwd.0

  kwdpos = pos(kwd.i, inline)   /* Position of matching keyword */
  if kwdpos > 0  then           /* Found a keyword */
  do

    if kwd.i = 'FILE' then      /* Check for quote after FILE= */
    do
      endchar = substr(inline, kwdpos+length(kwd.i)+1,1)
      if endchar <> '"' then endchar = ' '
    end
    else if kwd.i = 'LIST' then      /* Check for quote after LIST= */
    do
      endchar = substr(inline, kwdpos+length(kwd.i)+1,1)
      if endchar <> '"' then endchar = ' '
    end

    else  endchar = ' '         /* Not FILE=, use blank as delimiter */

    /*  Find delimiter (either next quote or blank) */
    fnend = pos(endchar, inline, kwdpos+length(kwd.i)+2)
    if fnend = 0 then           /* Ending quote/blank not found */
    do
      if endchar = '"' then
        say 'Missing ending quote mark for' kwd.i 'keyword'
      fnend = length(inline)    /* Assume it's just end of line */
    end

    /* Set argx to the keyword=data */
    junk = value('arg'i, substr(inline, kwdpos, fnend-kwdpos+1))

  end                           /* End if a keyword was found */

end                             /* End do i = 1 to num of keywords */

/* display values of the argx variables */
/* do i = 1 to 6
    say 'arg'i 'is' value('arg'i)
   end        */

parse var arg1 arg1a'='arg1b
parse var arg2 arg2a'='arg2b
parse var arg3 arg3a'='arg3b
parse var arg4 arg4a'='arg4b
parse var arg5 arg5a'='arg5b
parse var arg6 arg6a'='arg6b


/* Set the variables. */
call keyword arg1a, arg1b
call keyword arg2a, arg2b
call keyword arg3a, arg3b
call keyword arg4a, arg4b
call keyword arg5a, arg5b
call keyword arg6a, arg6b

if pos( 'RANDOM', inline ) > 0 then RANDOMIZEIT = 1

if RANDOMIZEIT = 1 & LIST = '' then
do
  say 'Nothing to randomize!  Play list was not specified.'
  exit 1
end

if LIST<>'' then
do
  status = STREAM(LIST,C,'OPEN READ')
  if status <> 'READY:' then
  do
    say 'Unable to open list file: 'LIST
    exit 1
  end
  say 'Reading play list from file: 'LIST
end

/* Load the DLL, initialize MCI REXX support */

rc = RXFUNCADD('mciRxInit','MCIAPI','mciRxInit')

InitRC = mciRxInit()
DLLINIT = 1

songNum = 0
SONGS.0 = 0

if LIST<>'' then
do
  theSong = LINEIN( LIST )
  do until theSong=''
    exists = STREAM( theSong, C, 'QUERY EXISTS' )
    if exists='' then
    do
      say 'Play list entry does not exist: 'theSong
      theSong = LINEIN( LIST )
      ITERATE
    end
    songNum = songNum + 1
    SONGS.0 = songNum
    SONGS.songNum = theSong
    SONGUSED.0 = songNum
    SONGUSED.songNum = 0
    theSong = LINEIN( LIST )
  end
  say 'Songs in playlist: 'SONGS.0
  if RANDOMIZEIT > 0 then say 'Randomizing play list.'
  say 'Press CTRL-Break to exit or skip to the next media clip.'
  
  if RANDOMIZEIT > 0 then
    do i=1 to songNum
      theMax = songNum - i + 1
      thePick = RANDOM( 1, theMax )
      curPick = 0
      do j=1 to songNum while curPick < thePick
        if SONGUSED.j = 0 then
          curPick = curPick + 1
        if curPick = thePick then
        do
          FILE = '"'SONGS.j'"'
          SONGUSED.j = 1
          say 'Playing file: 'SONGS.j
          call PlayIt
          if REXXALIAS <> 0 then
          do
            MacRC = SendString("close rexxalias wait")
            REXXALIAS = 0
            if MacRC <> 0 then signal ErrExit
          end
        end
      end
    end
  else
    do i=1 to songNum
      say 'Playing file: 'SONGS.i
      FILE = '"'SONGS.i'"'
      call PlayIt
      if REXXALIAS <> 0 then
      do
        MacRC = SendString("close rexxalias wait")
        REXXALIAS = 0
        if MacRC <> 0 then signal ErrExit
      end
    end
  
  MacRC = mciRxExit()       /* Tell the DLL we're going away */

  exit 0
end

call PlayIt

if REXXALIAS <> 0 then
do
  MacRC = SendString("close rexxalias wait")
  REXXALIAS = 0
  if MacRC <> 0 then signal ErrExit
end

if DLLINIT <> 0 then
do
  MacRC = mciRxExit()       /* Tell the DLL we're going away */
  DLLINIT = 0
end

exit 0

PlayIt:

MciCmd = 'open'
/*
** Check to see if the FILE && DEV variables are valid.
*/
     if FILE<>'' then
        do
          if DEV<>'' then
             MciCmd = MciCmd FILE 'type' DEV
          else
             MciCmd = MciCmd FILE
        end
     else if DEV<>'' then
        MciCmd = MciCmd DEV
     else
           do
             call Help
             exit 0
           end

/*
** Append the rest of the command line.
*/
    MciCmd = MciCmd 'alias rexxalias wait'

/*
** Issue the open command.
*/
    MacRC = SendString(MciCmd)
     if MacRC <> 0 then 
     do
       if MacRC = 5033 then
       do
         /* Duplicate alias... attempt to close and re-open */
         MacRC = SendString("close rexxalias wait")
         if MacRC <> 0 then signal ErrExit
         MacRC = SendString(MciCmd)
         if MacRC <> 0 then signal ErrExit
       end
       else signal ErrExit
     end
     else
     do
       REXXALIAS = 1
       if DEV='' then    /* device not specified */
         do     /* determine the device type */
          MacRC = SendString("capability rexxalias device type wait")
          if MacRC <> 0 then
              do
                 junk = SendString("close rexxalias wait")
                 REXXALIAS = 0
                 signal ErrExit
              end
         end
       else   /* set the device specified as the device type */
         RetSt = DEV

       /* If a wave file is to be played then do a status length */
       /* to determine if the wave file exists.  A wave file is  */
       /* the only type of device that if it doesn't exist and   */
       /* you play it, it won't come back as file not found      */
       if TRANSLATE(RetSt) = 'WAVEAUDIO' then
         do
            MacRC = SendString("status rexxalias length wait")      /* If length is 0 no file exists */
             if MacRC <> 0 then
              do
                 junk = SendString("close rexxalias wait")
                 signal ErrExit
              end
             if RetSt = 0 then
              do
                 junk = SendString("close rexxalias wait")
                 REXXALIAS = 0
                 ErrRC = 70555
                 MacRC = mciRxGetErrorString(ErrRC, 'ErrStVar')
                 say 'mciRxGetErrorString('ErrRC') =' ErrStVar
                 signal ErrExit
              end
         end
     end

/*
** Exercise mciRxGetDeviceID function
*/
DeviceID = mciRxGetDeviceID(""rexxalias"")

/*
**  Check to see if a time format was given.
*/
if TIMEFMT <> '' then
do
    MciCmd = 'set rexxalias time format' TIMEFMT 'wait'
    MacRC = SendString(MciCmd)
     if MacRC <> 0 then
        do
         junk = SendString("close rexxalias wait")
         REXXALIAS = 0
         signal ErrExit
        end
end

/*
** Formulate the play command.
*/
MciCmd = 'play rexxalias'

/*
** check to see if an origin was set.
*/
 if FROM<>'' then
        MciCmd = MciCmd 'from' FROM

/*
** check to see if a terminating point was given.
*/
 if TO<>'' then
        MciCmd = MciCmd 'to' TO

/*
** append a wait onto the end of the play string.
*/
MciCmd = MciCmd 'wait'

/*
** actually send the play string.
*/
MacRC = SendString(MciCmd)
     if MacRC <> 0 then
        do
         say 'Play returned: 'MacRC
         junk = SendString("close rexxalias wait")
         REXXALIAS = 0
         signal ErrExit
        end

/*
** Exit, return code = 0.
*/
return
/*
** close the instance.
*/

/*   --- SendString --
** Call DLL function.  Pass the command to process and the
** name of a REXX variable that will receive textual return
** information.
*/
SendString:
   arg CmndTxt
   /* Last two parameters are reserved, must be set to 0           */
   /* Future use of last two parms are for notify window handle    */
   /* and userparm.                                                 */
   MacRC = mciRxSendString(CmndTxt, 'RetSt', '0', '0')
   if MacRC<>0 then
      do
      ErrRC = MacRC
      say 'MciCmd=' CmndTxt
      say 'Err:mciRxSendString RC=' ErrRC RetSt
      MacRC = mciRxGetErrorString(ErrRC, 'ErrStVar')
      say 'mciRxGetErrorString('ErrRC') =' ErrStVar
      MacRC = ErrRC /* return the error rc */
      end
   return MacRC

/* -- keywords --
**
** Parse the arguments according to the keywords.
*/
keyword:
        arg key, value
        if key='FILE' then
            FILE=value
        else if key='DEV' then
            DEV=value
        else if key='FROM' then
             FROM=value
        else if key='TO' then
              TO=value
        else if key='TIMEFMT' then
                TIMEFMT=value
        else if key='LIST' then
                LIST=value

return

/*  -- help --
** Display help text
*/
Help:
   say
   say 'PLAY.CMD -- Original by IBM (with appropriate copyrights)'
   say '         -- modified and enhanced by Marty Amodeo'
   say
   say 'This command file plays a file or device using the MultiMedia'
   say 'REXX string interface.'
   say
   say 'play [FILE="filename"] [LIST="filename" [RANDOM]] [DEV=device]'
   say '     [TIMEFMT=timefmt] [FROM=from_position] [TO=to_position]'
   say
   say 'Where FILE plays the single file name, LIST specifies a playlist file,'
   say 'DEV specifies a device, TIMEFMT is the time format, FROM and TO are the'
   say 'start and stop positions in the media, and RANDOM indicates to randomize'
   say 'the playlist.'
   say
   say 'Playlist file consists of one media file name per line.'
return

/*  --- ErrExit --
** Common routine for error clean up/program exit.
** Gets called when commands to DLL fail.
*/
ErrExit:
   if REXXALIAS <> 0 then
   do
     MacRC = SendString("close rexxalias wait")
     REXXALIAS = 0
   end
   if DLLINIT <> 0 then
   do
     MacRC = mciRxExit() /* Tell the DLL we're going away        */
     DLLINIT = 0
   end
   exit 1;               /* exit, tell caller things went poorly */


/*   ---- error --
** Routine gets control when any command to the external
** environment (usually OS/2) returns a non-zero RC.
** This routine does not get called when the macapi.dll
** returns non-zero as it is a function provider rather
** than a command environment.
*/
error:
   ErrRC = rc
   say 'Error' ErrRC 'at line' sigl ', sourceline:' sourceline(sigl)
   if REXXALIAS <> 0 then
   do
     MacRC = SendString("close rexxalias wait")
     REXXALIAS = 0
   end
   if DLLINIT <> 0 then
   do
     MacRC = mciRxExit()     /* Tell the DLL we're going away */
     DLLINIT = 0
   end
   exit ErrRC                /* exit, tell caller things went poorly */

/*   ---- halt --
** Routine gets control when user hits ctrl break to end
*/
halt:
   if REXXALIAS <> 0 then
   do
     MacRC = SendString("close rexxalias wait")
     REXXALIAS = 0
   end
   if LIST<>'' then
   do
     response = 'x'
     
     say 'Would you like to skip to the next media clip?  [Y/N] (N exits): '
     do until response = 'Y' | response = 'y' | response = 'N' | response = 'n'
       response = charin()
       if chars() then junk = linein()
     end
     
     if response = 'N' | response = 'n' then
     do
       if DLLINIT <> 0 then
       do
         MacRC = mciRxExit()       /* Tell the DLL we're going away */
         DLLINIT = 0
       end
       exit 0
     end
     
     return 0
   end
   else do
     say 'Halting...'
     if DLLINIT <> 0 then
     do
       MacRC = mciRxExit()       /* Tell the DLL we're going away */
       DLLINIT = 0
     end
     exit 0
   end
   exit 999

