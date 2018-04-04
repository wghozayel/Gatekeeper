#!/usr/bin/expect -f

spawn /root/proxmark3/client/proxmark3 /dev/ttyACM0

expect "proxmark3>" {
        send "lf search\r\n"
        expect "proxmark3>" {
                send "lf search\r\n"
        }
}
