
set tty [lindex $argv 0]
spawn -noecho -open [set port [open $tty "r+"]]

remove_nulls 0
set timeout 1

fconfigure stdout -translation binary

set timeout 0
expect -re $
set timeout 1

send -raw x
expect f/t/H/?>
send -raw f
expect P/H/?>
send -raw d
expect "Delete Firmware #"
send -raw 0
expect "are you sure?"
send -raw y
expect P/H/?>
send -raw d
expect "Delete Firmware #"
send -raw 1
expect "are you sure?"
send -raw y
expect P/H/?>
send -raw x
expect f/t/H/?>

