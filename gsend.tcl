
set tty [lindex $argv 1]
set gcodefile [lindex $argv 0]

set fh [open $gcodefile]
set data [read $fh]
set lines [split $data \n]

set timeout 10
spawn -open [set port [open $tty "r+"]]

send "\nhi\n"
expect \
    timeout { error timeout } \
    -re {stubforth .*}

send "ginterp\n"

foreach line $lines {

    regsub -all {\s*;.*$} $line {} line
    if ![string length "$line"] continue

    send "$line\n"

    expect \
	timeout { error timeout } \
	-re "abort" { error abort } \
	-re {ok}
}

 
