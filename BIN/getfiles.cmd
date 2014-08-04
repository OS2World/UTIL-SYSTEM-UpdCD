/* get more files */

parse arg list cddir
cddir = cddir'\os2image'

/* primitive pause */
do i=1 to 1000
	nop;
end

/* empty queue */
do while queued() > 0
	junk = linein('queue:')
end

/* get list of files we are looking for */
i=1
do while lines(list)
	file.i = translate(linein(list))
	i = i+1
end
file.0 = i-1

/* get list of dirs */
'@dir 'cddir'\disk_* /f | RXQUEUE'
i=1
do while queued() > 0
	dir.i = linein('queue:')
	i = i+1
end
dir.0 = i-1

/* scan all these dirs for files we need */
do i=1 to dir.0

	/* say 'Scanning 'dir.i */
	'@dir 'dir.i'\* /f | RXQUEUE'
	k=1
	do while queued() > 0
		q.k = linein('queue:')
		k = k+1
	end
	q.0 = k-1

	do k=1 to q.0
		f = translate(filespec('name', q.k))
		if test_compressed_file(q.k) then do
			'@..\bin\unpack2 "'q.k'" /show | RXQUEUE'
			l=1
			c.l = linein('queue:')
			do while queued() > 0
				c.l = translate(linein('queue:'))
				c.l = substr(c.l, lastpos('\', c.l)+1)
				do j=1 to file.0
					if c.l = file.j then do
						'@..\bin\unpack2 "'q.k'" . /N:'file.j' >> ..\wininst.log 2>>&1'
						say 'Found 'file.j' in 'dir.i'\'f
						file.j.found = 1
					end
				end
				l = l+1
			end
			c.0 = l-1
		end
		else do
			do j=1 to file.0
				if f = file.j then do
					'@copy 'dir.i'\'file.j' . >> ..\wininst.log 2>>&1'
					say 'Found 'file.j' in 'dir.i
					file.j.found = 1
				end
			end
		end
	end

end

/* check */
do j=1 to file.0
	if file.j.found <> 1 then '@echo File 'file.j' was not found! >> ..\wininst.log'
end

/* fix */
if stream('a:\vcu.msg', 'c', 'query exists') = '' then do
	'@..\bin\unpack2 ..\newinst\flpfix . /N:FLPFIX.FIX >> ..\wininst.log'
	'@copy flpfix.fix rexxutil.dll >> ..\wininst.log'
end

exit

/****************************************/
/* test file to see if it is compressed */
/* return 1 = compressed                */
/* return 0 = not compressed            */
/****************************************/
test_compressed_file: procedure

	parse arg f
	'@..\bin\unpack2 "'f'" /show | RXQUEUE'
	if queued() > 1 then do
		l=linein('queue:')
		l=linein('queue:')
		if substr(l, 1, 2) = '->' then rcode = 1
		else rcode = 0
	end
	else rcode = 0
	do while queued() > 0
		l = linein('queue:')
	end

return rcode
