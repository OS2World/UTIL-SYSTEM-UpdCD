/* fix tcp/ip cmd files */

parse arg tcp_path

if tcp_path = '' then exit
else tcp_path = tcp_path'\BIN'

call RxFuncAdd 'SysFileTree', 'RexxUtil', 'SysFileTree'
call SysFileTree tcp_path'\*.cmd', 'cmd_prog.', 'FO'

do i=1 to cmd_prog.0
	call replace_string cmd_prog.i' tcpip\java\jvc.jar tcpip\java\jvc2.jar'
end

exit

replace_string: procedure

	parse upper arg file string_to_replace string_with_replace
	if stream(file, 'c', 'query exists') <> '' then do
		i=1
		do while lines(file)
			l.i = linein(file)
			p = pos(string_to_replace, translate(l.i))
			if p > 0 then l.i = substr(l.i, 1, p-1)||string_with_replace||substr(l.i, p+length(string_to_replace))
			i=i+1
		end
		call lineout file
		l.0 = i-1
		'@del 'file
		do i=1 to l.0
			call lineout file, l.i
		end
		call lineout file
	end

return
