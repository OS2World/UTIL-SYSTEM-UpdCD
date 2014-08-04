/* resmgr.cmd -- A "zip-like" .RES manager                  20020429 */
/* (c) Copyright Martin Lafaix 1995-1996, 2002                       */

say 'Operating System/2  Resource Manager'
say 'Version 0.06.000 Apr 29 2002'
say '(C) Copyright Martin Lafaix 1995-1996, 2002'
say 'All rights reserved.'
say

parse upper value translate(arg(1),'\','/') with param orgfile outfile x y
tempneeded = 0; modified = 0; nl = '0d0a'x; rid = ''; rtype = ''; found = 0
typeName = '/POINTER /BITMAP /MENU /DIALOG /STRINGTABLE /FONTDIR /FONT /ACCELTABLE /RCDATA',
           '/MESSAGETABLE /DLGINCLUDE /VKEYTBL /KEYTBL /CHARTBL /DISPLAYINFO /FKASHORT',
           '/FKALONG /HELPTABLE /HELPSUBTABLE /FDDIR /FD'

call RxFuncAdd 'SysTempFileName', 'RexxUtil', 'SysTempFileName'

if param = '-H' | param = '' then
   do
      say 'Usage:  resmgr <option> <.RES file> [id.type] [file]'
      say '        -a              - Add specified resources'
      say '        -d              - Delete specified resources'
      say '        -l              - List resources (short format)'
      say '        -v              - List resources (long format)'
      say '        -x              - Extract specified resources'
      say '        -h              - Access Help'
      say
      say '        .RES file       = .RES, .EXE or .DLL file name'
      say '        file            = Input or output file name'
      say '        type            = Resource type or *'
      say '        id              = Resource ID or *'
      say
      say 'Possible type value (with -d, -l, -v or -x):'
      say
      say '  Acceltable Bitmap   Chartbl Dialog  Displayinfo  Dlginclude Fd     Fddir'
      say '  Fkalong    Fkashort Font    Fontdir Helpsubtable Helptable  Keytbl Menu'
      say '  Messagetable        Pointer RCData  Stringtable  Vkeytbl'
      say
      say 'Environment variables:'
      say '        TMP=temporary file path'
      say '        TEMP=temporary file path'
      if orgfile \= '' then
         exit 1
      else
         exit
   end

call check

if stream(orgfile,'c','query size') = 0 then
   infile = orgfile
else
if charin(orgfile,1,1) \= 'FF'x then
   do
      call stream orgfile, 'c', 'close'
      tempneeded = 1
      tempname = gettemp('RES?????.RES')
      '@call rdc -r' orgfile tempname '>nul'
      if RC = 2 then
         nop /* no resources, not an error */
      else
      if RC \= 0 then
         call error 'Invalid input file :' orgfile, 1
      infile = tempname
   end
else
   infile = orgfile

call initialize

call charin infile,1,0
do while chars(infile) > 0
   call skip 1
   rt = readw()
   call skip 1
   id = readw()
   opt = readw()
   cb = readl()

   if (rtype = '*' | rt = rtype) & (rid = '*' | id = rid) then
      select
         when param = '-A' then call add
         when param = '-D' then do; modified = 1; say '    'id'.'rt' ('cb' bytes)'; end
         when param = '-L' then call shows
         when param = '-V' then call showl
         when param = '-X' then do; say '    'id'.'rt' ('cb' bytes)'; call extract; end
      end  /* select */
   else
   if param = '-D' then
      call extract

   call skip cb
end /* do */

call terminate

exit

terminate: /* do option-dependant termination */
   if param = '-D' then
      do
         call stream infile, 'c', 'close'
         call stream outfile, 'c', 'close'
         if modified then
            if stream(outfile,'c','query exists') \= '' then
               do
                  '@copy' outfile infile '>nul'
                  '@del /f' outfile
               end
            else
               call removeall
      end
   else
   if param = '-A' then
      do
         call stream infile, 'c', 'close'
         call stream outfile, 'c', 'close'
         if modified then
            '@copy' outfile infile '>nul'
         '@del /f' outfile
         if words(addedResources) - found \= 0 then
            do
               say nl'Added' words(addedResources)-found 'resource(s).'
               if found \= 0 then
                  say 'Replaced' found 'resource(s).'
            end
         else
         if found \= 0 then
            say nl'Replaced' found 'resource(s).'
      end
   else
   if param = '-L' | param = '-V' then
      do
         if found = 0 then
            say 'No resources found matching pattern :' rid'.'rtype
         else
            say nl'Found' found 'resource(s) matching pattern :' rid'.'rtype
      end
   if tempneeded & modified then
      '@call rc' infile orgfile '>nul'
   if tempneeded then
      do
         call stream infile, 'c', 'close'
         if stream(infile,'c','query exists') \= '' then
            '@del /f' infile
      end
   return

initialize: /* do option-dependant initialisation */
   select
      when param = '-A' then
         do
            if x \= '' then
               call error 'Too many arguments for -A :' x, 1
            if outfile = '' then
               call error 'Missing input file name', 1
            if verify(outfile,'*?<>|"','M') > 0 then
               call error 'Invalid file name :' outfile, 1
            if stream(outfile,'c','query exists') = '' then
               call error 'File not found :' outfile, 1
            call getspec ''
            oinfile = infile; infile = outfile; addedResources = ''
            call charin infile,1,0
            do while chars(infile) > 0
               if \ modified then
                  say 'Reading...'
               modified = 1
               if charin(infile,,1) \= 'FF'x then
                  call error 'Invalid input file :' infile, 1
               rt = readw()
               call skip 1
               id = readw()
               opt = readw()
               addedResources = addedResources id'.'rt
               cb = readl()
               call skip cb
               say '    'id'.'rt' ('cb' bytes)'
            end /* do */
            call stream infile, 'c', 'close'
            outfile = gettemp('RES?????.TMP')
            if stream(infile,'c','query size') = 0 then
               /* copy does not like empty files */
               do
                  call charout outfile
                  call stream outfile, 'c', 'close'
               end
            else
               '@copy' infile outfile '>nul'
            if addedResources = '' then
               say 'Nothing to add!'
            infile = oinfile
         end
      when param = '-L' | param = '-V' then
         do
            if x \= '' then
               call error 'Too many arguments for' param ':' x, 1
            call getspec outfile
            if param = '-L' then
               header = 'Res.ID   Resource type   Res. size'
            else
               header = 'Res.ID   Resource type       Res. size   Res. flags'
         end
      when param = '-X' then
         do
            if x = '' then
               call getspec ''
            else
               do
                  call getspec outfile
                  outfile = x
               end
            if verify(outfile,'*?<>|"','M') > 0 then
               call error 'Invalid file name :' outfile, 1
            if stream(outfile,'c','query exists') \= '' then
               '@del' outfile
            say 'Extracting...'
         end
      when param = '-D' then
         do
            if x \= '' then
               call error 'Too many arguments for -D :' x, 1
            call getspec outfile
            outfile = gettemp('RES?????.TMP')
            say 'Removing...'
         end
   otherwise
   end  /* select */
   return

removeall: /* remove all resources from orgfile */
   if stream(infile,'c','query exists') \= '' then
      '@del /f' infile
   infile = gettemp('RES?????.RC')
   call charout infile,,1
   call stream infile,'c','close'
   '@call rc' infile orgfile '>nul'
   if RC \= 0 then
      do
         say 'Warning: RC failed to remove all resources, inserting a dummy one...'
         call charout infile,'STRINGTABLE'nl'BEGIN'nl'1 ""'nl'END'nl
         call stream infile,'c','close'
         '@call rc' infile orgfile '>nul'
      end
   modified = 0
   return

add:     /* add specified resource to outfile if not present */
   if \ modified then
      return
   if wordpos(id'.'rt,addedResources) > 0 then
      do
         found = found + 1
         return
      end
   say '    'id'.'rt' ('cb' bytes)'
extract: /* extract specified resource */
   call emit 'FF'x||d2w(rt)'FF'x||d2w(id)d2w(opt)d2l(cb)
   call emit charin(infile,,cb)
   cb = 0
   return

shows:   /* display specified resource info (short format) */
   if found = 0 then
      call showh
   call charout ,right(id,6)'   '
   if rt < 22 then
      call charout ,left(substr(word(typeName,rt),2),15)
   else
      call charout ,left(rt,15)
   call charout ,right(cb,10)nl
   found = found + 1
   return

showl:   /* display specified resource info (long format) */
   if found = 0 then
      call showh
   call charout ,right(id,6)'   '
   if rt < 22 then
      call charout ,left(substr(word(typeName,rt),2) '('rt')',19)
   else
      call charout ,left(rt,19)
   call charout ,right(cb,10)'   'option()nl
   found = found + 1
   return

showh:   /* display resources list header */
   say header
   say copies('-',length(header))
   return

option:  /* convert flags to option string */
   if bit(opt,10) then r = 'PRELOAD'; else r = 'LOADONCALL'
   if bit(opt,12) then r = r' MOVEABLE'
   if bit(opt, 4) then r = r' DISCARDABLE'
   if \ (bit(opt,4) | bit(opt,12)) then r = r' FIXED'
   if r = 'LOADONCALL MOVEABLE DISCARDABLE' then r = ''
   return r

getspec: /* get resources specs as described in arg(1) */
   procedure expose rid rtype typeName
   if arg(1) \= '' then
      parse value arg(1) with rid '.' rtype
   parse value rid rtype '* *' with rid rtype .
   if wordpos('/'rtype, typeName) > 0 then
      rtype = wordpos('/'rtype, typeName)
   if \ (rid = '*' | datatype(rid) = 'NUM') then
      call error 'Invalid resource ID :' rid, 1
   if \ (rtype = '*' | datatype(rtype) = 'NUM') then
      call error 'Invalid resource type :' rtype, 1
   return

gettemp: /* get a temp file name following arg(1) specs */
   procedure
   tempdir = value('TMP',,'OS2ENVIRONMENT')
   if tempdir = '' then tempdir = value('TEMP',,'OS2ENVIRONMENT')
   if tempdir = '' then tempdir = directory()
   tempdir = translate(tempdir,'\','/')
   if tempdir \= '' & right(tempdir,1) \= '\' then tempdir = tempdir||'\'
   return SysTempFileName(tempdir||arg(1))

emit:    /* write data to output file */
   return charout(outfile,arg(1))

readw:   /* read one word from infile */
   return w2d(charin(infile,,2))

readl:   /* read one long from infile */
   return l2d(charin(infile,,4))

skip:    /* skip arg(1) chars */
   return charin(infile,,arg(1))

bit:     /* return bit arg(2) of arg(1) */
   return substr(x2b(d2x(arg(1),4)), arg(2),1)

w2d:     /* littleendian word to decimal */
   w = c2x(arg(1))
   return x2d(substr(w,3,2)substr(w,1,2))

d2w:     /* decimal to littleendian word */
   w = d2x(arg(1),4)
   return x2c(substr(w,3,2)substr(w,1,2))

l2d:     /* littleendian long to decimal */
   l = c2x(arg(1))
   return x2d(substr(l,7,2)substr(l,5,2)substr(l,3,2)substr(l,1,2))

d2l:     /* decimal to littleindian long */
   l = d2x(arg(1),8)
   return x2c(substr(l,7,2)substr(l,5,2)substr(l,3,2)substr(l,1,2))

error:   /* display arg(1) and exit with code arg(2) */
   say arg(1)
   exit arg(2)

check:   /* check parameters validity */
   if param \= '-A' & param \= '-D' & param \= '-L' & param \= '-X' & param \= '-V' then
      call error 'Invalid option :' param, 2
   if orgfile = '' then
      call error 'Missing .RES, .EXE or .DLL file name', 1
   if y \= '' then
      call error 'Too many parameters :' y,1
   if verify(orgfile,'*?<>|"','M') > 0 then
      call error 'Invalid file name :' orgfile, 1
   return 1
