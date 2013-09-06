
set tty [lindex $argv 0]
spawn -noecho -open [set port [open $tty "r+"]]

set timeout 1

expect -re $

send -raw X
expect f/t/H/?>$
send -raw F
expect P/H/?>$
send -raw D
expect "Delete Firmware #"
send -raw 0
expect "are you sure?"
send -raw y
expect P/H/?>
send -raw D
expect "Delete Firmware #"
send -raw 1
expect "are you sure?"
send -raw y
expect P/H/?>
send -raw X
expect f/t/H/?>
