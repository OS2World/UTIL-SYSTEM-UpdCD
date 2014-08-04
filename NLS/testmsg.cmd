/* script to test message files */

parse arg f
if f = '' then do
	say
	say 'UpdCD message file tester'
	say 'Usage: testmsg.cmd <updcd message file>'
	say 'Example: testmsg message.eng'
	exit
end

i=1
do while lines(f)
	l=linein(f)	
	interpret l
	say 'Testing message: 'i' -> Result: OK'
	i=i+1
end

call lineout f
