#/usr/bin/expect -f

spawn /root/proxmark3/client/proxmark3 /dev/ttyACM0

set tag [lindex $argv 0]
set cmd "lf hid clone "
append cmd $tag

expect "proxmark3>" {
	send "$cmd\r\n"
	expect "#db# DONE!" {
		send_user "WASEEM"
	}
}
