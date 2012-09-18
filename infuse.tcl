#!/usr/bin/expect

# Wait for echos so we don't overflow the buffers.


set tty [lindex $argv 0]
spawn -open [set port [open $tty "r+"]]

send "hi\n"
expect -re "stubforth .*"

set lines [split [read stdin] \n]

set timeout -1
foreach l $lines {

    send -- $l
    send "\n"
    expect -re .*abort:.* { error [list $expect_out(0,string)] } -re "\n"

}
