/* rdc.cmd -- Resource decompiler                           20020429 */
/* (c) Copyright Martin Lafaix 1994-1996, 2000, 2002                 */

say 'Operating System/2  Resource Decompiler'
say 'Version 2.15.001 Apr 29 2002'
say '(C) Copyright Martin Lafaix 1994-1996, 2000, 2002'
say 'All rights reserved.'
say

parse upper value translate(arg(1),'\','/') with param infile outfile x
nl = '0d0a'x; includedlg=0; list = ''; parsed = ''; orgoutfile = ''; nc = 0
randomnames = 1 /* 1=RES?????.* 0=Bitmap123.* filenames */

call RxFuncAdd 'SysTempFileName', 'RexxUtil', 'SysTempFileName'
call RxFuncAdd 'SysSearchPath', 'RexxUtil', 'SysSearchPath'

if param = '-L' then
   parse value 'ON -R' with list param

if param = '-H' | param = '' then
   do
      say 'Usage:  rdc [<option>] <.EXE input file> [<.RC output file>]'
      say '        -r              - Extract .res file only'
      say '        -l              - List resources (but do not extract)'
      say '        -k              - Keep resources IDs in filenames'
      say '        -h              - Access Help'
      say
      say 'Environment variables:'
      say '        PATH=application file path'
      if x \= '' then
         exit 1
      else
         exit
   end

select
   when (param = '-K' | param = '-R') & infile = '' then
      call error 'Missing input file name', 1
   when x \= '' then
      call error 'Too many parameters :' x, 1
   when param \= '-K' & param \= '-R' & outfile \= '' then
      call error 'Too many parameters :' outfile x, 1
   when list = 'ON' & outfile \= '' then
      call error 'Too many parameters :' outfile x, 1
otherwise
   nop
end  /* select */

if param = '-K' then
   do
      randomnames = 0
      orgoutfile = outfile
      outfile = ''
   end
else
if param \= '-R' then
   do
      outfile = infile
      infile = param
      orgoutfile = outfile
      outfile = ''
   end

outfile = outname(infile,'res')

step1:   /* convert from .EXE to .RES */
if charin(infile,,2) = 'MZ' then
   base = 1+l2d(charin(infile,61,4))
else
   base = 1

type = charin(infile,base,2)
if  type \= 'LX' & type \= 'NE' then
   do
      if param = '-R' then
         call error 'Invalid input file header :' infile, 1
      else
         signal step2
   end

if type = 'NE' then
   do
      cseg = w2d(charin(infile,base+28,2))
      call skip 4
      segtab = readw()
      rsrctab = readw()
      restab = readw()
      call skip 10
      segshift = readw()
      rsrccnt = readw()
      tabsize = 4
      say 'Reading OS/2 v1.x .EXE file'
   end
else
   do
      call charin infile,base+44,0
      pageshift = readl()
      call skip 16
      objtab = readl()
      call skip 4
      objmap = readl()
      call skip 4
      rsrctab = readl()
      rsrccnt = readl()
      restab = readl()
      call skip 36
      datapage = readl()
      tabsize = 14
      say 'Reading OS/2 v2.x .EXE file'
   end

if rsrccnt = 0 then
   call error nl'No resources!', 2

if list = 'ON' then
   do
      do cnt = 0 to rsrccnt-1
         call charin infile,base+rsrctab+cnt*tabsize,0
         if type = 'NE' then
            call tab16in
         else
            call tab32in
         say '    'ename'.'etype' ('cb' bytes)'
      end /* do */
      exit
   end

call RDCPP

step1a:  /* conversion done */
call stream infile, 'c', 'close'
call stream outfile,'c', 'close'
infile = outfile
outfile = orgoutfile
parsed = 'DONE'

step2:   /* convert from .RES to .RC */
if param \= '-R' then
   do
      if parsed \= 'DONE' then
         if param = '-K' then
            arg . infile outfile
         else
            arg infile outfile
      outfile = outname(infile,'rc2')
      if charin(infile,1,1)\= 'FF'x then
         call error 'Invalid .RES input file :' infile, 1
      call charin infile,1,0
      say 'Reading binary resources from .RES file'
      if stream(outfile,'c','query exists') \= '' then
         '@del /f' outfile '>nul'
      call emit '#include <os2.h>'nl||nl
      do while chars(infile) > 0
         call res2rc
      end /* do */
      if includedlg=1 then
         do
            res2dlg = SysSearchPath('PATH','RES2DLG.EXE')
            outf=outfile; outfile='';
            if res2dlg = '' then
               rcincl=outname(infile,'dlg')
            else
               rcincl=outname(infile,'dl2')
            outfile=outf
            call emit nl'RCINCLUDE "'rcincl'"'nl
            call stream infile, 'C', 'CLOSE'
            if res2dlg \= '' then
               '@'res2dlg infile rcincl
         end
      say nl'Writing extracted resources to 'outfile
   end
exit

segin:   /* read segment map entry */
   call charin infile,base+segtab+(arg(1)-1)*8,0
   ssector = readw()
   cb = readw()
   sflags = readw()
   smin = readw()
   pos = 1+(2**segshift)*ssector
   flags = 0
   if bit(sflags,10) then flags = flags+64
   if bit(sflags,12) then flags = flags+16
   if bit(sflags,4) then flags = flags+4096
   if \ bit(sflags,11) then flags = flags+32
   return

tab16in: /* read resource table entry (16bits) */
   etype = readw()
   ename = readw()
   call segin cseg-rsrccnt+1+cnt
   return

objin:   /* read object map entry */
   call charin infile,base+objtab+(arg(1)-1)*24,8
   oflags = readl()
   opagemap = readl()
   omapsize = readl()
   opagedataoffset = l2d(charin(infile,base+objmap+(opagemap-1)*8,4))
   opagedatasize = readw()
   opagedataflags = readw()
   pos = 1+datapage+eoffset+(2**pageshift)*opagedataoffset
   flags = 0
   if bit(oflags,10) then flags = flags+64
   if bit(oflags,11) then flags = flags+16
   if bit(oflags,12) then flags = flags+4096
   if \ bit(oflags,15) then flags = flags+32
   return

tab32in: /* read resource table entry (32bits) */
   etype = readw()
   ename = readw()
   cb = readl()
   eobj = readw()
   eoffset = readl()
   call objin eobj
   return

res2rc:  /* convert .RES format to .RC */
   if charin(infile,,1) \= 'FF'x then
      call error nl'Invalid resource entry.  Aborting!', 1
   rt = readw()
   id = readid()
   opt = readw()
   cb = readl()
   select
      when rt = 1  then call emit 'POINTER' id option() file('Pointer',id,'ptr')nl
      when rt = 2  then call emit 'BITMAP' id option() file('Bitmap',id,'bmp')nl
      when rt = 3  then call emit menuout('  ','MENU 'id option()nl'BEGIN'nl)'END'nl
      when rt = 4  then includedlg=1
      when rt = 5  then call emit 'STRINGTABLE 'option() readw()nl'BEGIN'strout()'END'nl
      when rt = 6  then call emit 'RESOURCE' rt id option() file('Fontdir',id,'dir') '/* FONTDIR */'nl
      when rt = 7  then call emit 'FONT' id option() file('Font',id,'fon')nl
      when rt = 8  then do; call emit 'ACCELTABLE' id option()nl'BEGIN'nl||keyout()'END'nl; end
      when rt = 9  then call emit 'RCDATA' id||nl'BEGIN'rcout()'END'nl
      when rt = 10 then call emit 'MESSAGETABLE 'option() readw()nl'BEGIN'strout()'END'nl
      when rt = 11 then do; call emit 'DLGINCLUDE' id strip(charin(infile,,cb),'T','00'x)nl; cb = 0; end
      when rt = 12 then call emit 'RESOURCE' rt id option() file('VKeyTbl',id,'vkt') '/* VKEYTBL */'nl
      when rt = 13 then call emit 'RESOURCE' rt id option() file('KeyTbl',id,'kt') '/* KEYTBL */'nl
      when rt = 14 then call emit 'RESOURCE' rt id option() file('CharTbl',id,'ct') '/* CHARTBL */'nl
      when rt = 15 then call emit 'RESOURCE' rt id option() file('DisplayInfo',id,'di') '/*DISPLAYINFO */'nl
      when rt = 16 then call emit 'FKASHORT 'id||nl
      when rt = 17 then call emit 'FKALONG 'id||nl
      when rt = 18 then call emit 'HELPTABLE 'id||nl'BEGIN'htout()'END'nl
      when rt = 19 then call emit 'HELPSUBTABLE 'id||hstout()nl
      when rt = 20 then call emit 'FDDIR 'id||nl
      when rt = 21 then call emit 'FD 'id||nl
   otherwise
      call emit 'RESOURCE' rt id option() file('Res',id,'dat')nl
   end  /* select */
   if rt \= 4 then
      call emit nl
   call skip cb
   call charout ,'.'
   return

emit:    /* write data to output file */
   return charout(outfile,arg(1))

option:  /* convert flags to option string */
   if bit(opt,10) then r = 'PRELOAD'; else r = 'LOADONCALL'
   if bit(opt,12) then r = r' MOVEABLE'
   if bit(opt, 4) then r = r' DISCARDABLE'
   if \ (bit(opt,4) | bit(opt,12)) then r = r' FIXED'
   if r = 'LOADONCALL MOVEABLE DISCARDABLE' then r = ''
   return r

file:    /* write cb bytes to resxxxx.arg(3) or arg(1)arg(2).arg(3) */
   if randomnames then
       r = SysTempFileName('res?????.'arg(3))
   else
       r = arg(1)arg(2)'.'arg(3)
   if stream(r,'c','query exists') \= '' then
      '@del /f' r '>nul'
   call charout r,charin(infile,,cb)
   cb = 0
   call stream r,'c','close'
   return '"'r'"'

rcout:   /* extract RCDATA resources */
   procedure expose nl cb infile
   buf = charin(infile,,cb)
   needending = 0; rcdata = ''
   select
      when cb // 2 = 0 then len = cb
      when right(buf,1) = '00'x then do; len = cb-1; needending=1; end
      when lastpos('00'x, buf) = 0 then call error 'Invalid RCDATA entry.  Aborting!', 1
   otherwise
      /* even length, and does not end with a string */
      len = lastpos('00'x,buf)-1
      rcdata = data2str(substr(buf,1,len))'  , "",'nl
      buf = substr(buf, len+2)
      len = length(buf)
   end  /* select */
   rcdata = rcdata || data2str(buf)
   cb = 0
   return rcdata

data2str: /* returns a RC-readable version of arg(1) */
   procedure expose nl len needending
   res = nl
   do l = 0 for len % 16
      line = substr(arg(1),1+l*16,16)
      res = res' '
      do b = 0 for 4
         res = res makel(substr(line,1+b*4,4))','
      end /* do */
      if (len // 16 = 0) & (l = (len % 16) - 1) then
         res = strip(res,'T',',')
      res = res' /*' clean(line) '*/'nl
   end /* do */

   if len // 16 \= 0 then
      do
         line = substr(arg(1),1+16*(len % 16))
         lres = ' '
         last = len // 16
         do while last >= 4
            lres = lres makel(substr(line,1+(len // 16)-last,4))','
            last = last-4
         end /* do */
         if last > 0 then
            lres = lres makew(substr(line,1+(len // 16)-last,2))','
         if needending = 0 then
            lres = strip(lres,'T',',')
         else
            lres = lres '""'
         res = res||left(lres, 54)'/*' clean(line) '*/'nl
      end

   return res

strout:  /* extract strings definitions */
   id = (id-1)*16; cb = cb-2; r = nl
   do while cb > 0
      len = x2d(c2x(charin(infile,,1)))
      if len > 1 then
         do
            buf = charin(infile,,len-1)
            r = r'  'left(id,8)'"'str2rc(buf)'"'nl
            if nc then
               r = r'         'comment(buf)nl
         end
      call skip 1
      id = id+1; cb = cb-len-1
   end /* do */
   return r

itemout: /* extract menu item definition */
   procedure expose nl cb infile outfile nc
   cb = cb-6; s = ''; a = ''; r = arg(1)'MENUITEM "'; x = '| MIS_'; y = '| MIA_'
   sty = readw()
   att = readw()
   iid = readw()
   if \ (bit(sty,13) | bit(sty,14)) then
      do
         c = charin(infile); cb = cb-1; str = ''
         if c = 'FF'x & bit(sty,15) then do; str = '#'readw(); cb = cb-2; end
         else do while c \= '00'x; str = str||c; c = charin(infile); cb = cb-1; end
         r = r||str2rc(str)
      end
   else
      str = ''
   if bit(sty,15) then s = s x'BITMAP'
   if bit(sty,14) then s = s x'SEPARATOR'
   if bit(sty,13) then s = s x'OWNERDRAW'
   if bit(sty,12) then s = s x'SUBMENU'
   if bit(sty,11) then s = s x'MULTMENU'
   if bit(sty,10) then s = s x'SYSCOMMAND'
   if bit(sty, 9) then s = s x'HELP'
   if bit(sty, 8) then s = s x'STATIC'
   if bit(sty, 7) then s = s x'BUTTONSEPARATOR'
   if bit(sty, 6) then s = s x'BREAK'
   if bit(sty, 5) then s = s x'BREAKSEPARATOR'
   if bit(sty, 4) then s = s x'GROUP'
   if bit(sty, 3) then s = s x'SINGLE'
   if bit(att,11) then a = a y'NODISMISS'
   if bit(att, 4) then a = a y'FRAMED'
   if bit(att, 3) then a = a y'CHECKED'
   if bit(att, 2) then a = a y'DISABLED'
   if bit(att, 1) then a = a y'HILITED'
   if a \= '' then a = ','substr(a,3)
   if s \= '' then s = ','substr(s,3); else if a \= '' then s = ','
   item = r'"'comment(str)', 'iid||s||a||nl
   if bit(sty,12) then do; item = item||arg(1)'BEGIN'nl||menuout(arg(1)'  ','')arg(1)'END'nl; end
   return item

presparamcolor: /* extract a presparam color */
   col = '0x'd2x(readl())'L'
   cb = cb-4; size = size-4
   return col

presparamcolorindex: /* extract a presparam color index */
   colidx = readl()'L'
   cb = cb-4; size = size-4
   return colidx

presparam: /* extract PRESPARAMS */
   procedure expose nl cb infile outfile
   size = readl()
   cb = cb-4
   pres = ''
   do while size \= 0
      type = readl()
      plen = readl()
      cb = cb-8; size = size-8
      pres = pres||arg(1)'PRESPARAMS'
      select
         when type = 1 then pres = pres 'PP_FOREGROUNDCOLOR,' presparamcolor()
         when type = 2 then pres = pres 'PP_FOREGROUNDCOLORINDEX,' presparamcolorindex()
         when type = 3 then pres = pres 'PP_BACKGROUNDCOLOR,' presparamcolor()
         when type = 4 then pres = pres 'PP_BACKGROUNDCOLORINDEX,' presparamcolorindex()
         when type = 5 then pres = pres 'PP_HILITEFOREGROUNDCOLOR,' presparamcolor()
         when type = 6 then pres = pres 'PP_HILITEFOREGROUNDCOLORINDEX,' presparamcolorindex()
         when type = 7 then pres = pres 'PP_HILITEBACKGROUNDCOLOR,' presparamcolor()
         when type = 8 then pres = pres 'PP_HILITEBACKGROUNDCOLORINDEX,' presparamcolorindex()
         when type = 9 then pres = pres 'PP_DISABLEDFOREGROUNDCOLOR,' presparamcolor()
         when type = 10 then pres = pres 'PP_DISABLEDFOREGROUNDCOLORINDEX,' presparamcolorindex()
         when type = 11 then pres = pres 'PP_DISABLEDBACKGROUNDCOLOR,' presparamcolor()
         when type = 12 then pres = pres 'PP_DISABLEDBACKGROUNDCOLORINDEX,' presparamcolorindex()
         when type = 13 then pres = pres 'PP_BORDERCOLOR,' presparamcolor()
         when type = 14 then pres = pres 'PP_BORDERCOLORINDEX,' presparamcolorindex()
         when type = 15 then do; pres = pres 'PP_FONTNAMESIZE, "'charin(infile,,plen-1)'"'; call skip 1; cb = cb-plen; size = size-plen; end
      otherwise
         pres = pres type
         do while plen > 0
            pres = pres',' readl()'L'
            cb = cb-4; size = size-4; plen = plen - 4
         end /* do */
      end /* select */
      pres = pres||nl
   end /* do */
   return pres

menuout: /* extract menus definitions */
   procedure expose nl cb infile outfile nc
   cb = cb-10
   cbs = readw()
   typ = readw()
   cp = readw()
   off = readw()
   cnt = readw()
   menu = ''
   if typ = 1 then
      do; ppoffs = readw(); cb = cb-2; end
   else
      ppoffs = 0;
   if arg(2) \= '' then
      do
         menu = 'CODEPAGE 'cp||nl
         menu = menu||arg(2)
      end /* do */
   items = ''
   do cnt; items = items||itemout(arg(1)); end
   presparams = ''
   if typ = 1 & ppoffs \= 0 then presparams = presparam(arg(1))
   return menu||presparams||items

keyout:  /* extract acceltable definitions */
   procedure expose nl cb infile outfile
   r = ''
   cnt = readw()
   cp = readw()
   cb = cb-4
   call emit 'CODEPAGE 'cp||nl
   do cnt
      typ = readw()
      key = readw()
      if \ bit(typ,15) & key >= 32 & key <= 255 then key = '"'d2c(key)'"'; else key = '0x'd2x(key)
      if key = '"""' then key = '""""'
      if key = '"\"' then key = '"\\"'
      cmd = readw()
      cb = cb-6; t = ''
      if bit(typ,16) then t = t', CHAR'
      if bit(typ,15) then t = t', VIRTUALKEY'
      if bit(typ,14) then t = t', SCANCODE'
      if bit(typ,13) then t = t', SHIFT'
      if bit(typ,12) then t = t', CONTROL'
      if bit(typ,11) then t = t', ALT'
      if bit(typ,10) then t = t', LONEKEY'
      if bit(typ, 8) then t = t', SYSCOMMAND'
      if bit(typ, 7) then t = t', HELP'
      r = r'  'left(key',',8)left(cmd',',8)substr(t,3)nl
   end /* do */
   return r

htout:   /* extract helptable definitions */
   r = nl
   i = readw()
   do while i \= 0
      r = r'  HELPITEM 'i', 'readw()
      call skip 2
      r = r', 'readw()nl; cb = cb-8
      i = readw()
   end /* do */
   cb = cb-2
   return r

hstout:  /* extract helpsubtable definitions */
   sis = readw()
   if sis \= 2 then r = nl'SUBITEMSIZE 'sis; else r = ''
   r = r||nl'BEGIN'nl; cb = cb-2
   i = readw()
   do while i \= 0
      r = r||'  HELPSUBITEM 'i
      do sis-1; r = r', 'readw(); end
      cb = cb-2*sis; r = r||nl
      i = readw();
   end /* do */
   cb = cb-2
   return r'END'

outname: /* return name made from infile and extension */
   if outfile = '' then
      if lastpos('.',arg(1)) > lastpos('\',arg(1)) then
         outfile = left(arg(1),lastpos('.',arg(1)))arg(2)
      else
         outfile = arg(1)'.'arg(2)
   return outfile

RDCPP:    /* call RDCPP.EXE  */
  call stream infile, 'c', 'close'
  '@RDCPP' infile outfile
  if rc \= 0 then exit 1
  return

str2rc:  /* convert a string to its RC-readable equivalent */
   procedure expose nc
   i = arg(1); o = ''; s = 0; nc = 0
   do while i \== ''
      c = left(i,1); i = substr(i,2)
      if s & pos(c,'abcdefABCDEF0123456789') \= 0 then
         do
            /* some versions of RC are broken in that they interpret
               "\x3132" as "12" instead of "132", hence this check */
            o = o||'\x'c2x(c)
            nc = 1
         end
      else
         do
            s = 0
            select
               when c = '\' then o = o||'\\'
               when c = '01'x then o = o||'\a'
               when c = '09'x then o = o||'\t'
               when c = '"' then o = o||'""'
               when c2d(c) < 32 then do; o = o||'\x'c2x(c); s = 1; end
            otherwise
               o = o||c
            end  /* select */
         end
   end /* do */
   return o

comment: /* if nc, returns a commented arg(1), else returns '' */
   procedure expose nc
   if \ nc then
      return ''
   /* to be safe, we replace '*' too so that there is no risks
      an imbeded ending comment mark lies in the string */
   nc = 0
   return ' /* "'clean(arg(1))'" */'

clean:   /* returns a comment-friendly form  of arg(1) */
   return translate(arg(1),copies('.',33),xrange(,'1f'x)'*')

readid:  /* read an integer or string ID from infile */
   procedure expose infile
   c = charin(infile,,1)
   if c = 'FF'x then
      return readw()
   id = ''
   do while c \= '00'x
      id = id || c
      c = charin(infile,,1)
   end /* do */
   /* id should _not_ be mangled; i.e., it must be taken verbatim */
   return '"'id'"'

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

makel:   /* 4 character string to littleendian long */
   return '0x'translate('78563412',c2x(arg(1)),'12345678')'L'

makew:   /* 2 character string to littleendian word */
   return '0x'translate('3412',c2x(arg(1)),'1234')

error:   /* display arg(1) and exit with code arg(2) */
   say arg(1)
   exit arg(2)

