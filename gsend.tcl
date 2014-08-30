#!/usr/bin/expect

set tty [lindex $argv 1]
set gcodefile [lindex $argv 0]

set fh [open $gcodefile]
set data [read $fh]
set lines [split $data \n]

set timeout 5
spawn -noecho -open [set port [open $tty "r+"]]

log_user 0

send "\nhi\nhi\n"
expect \
    timeout { error timeout } \
    -re {stubforth}

log_user 1

send {
    decimal
    5 xy-max ! \ xy maximum speed (100us/step)
    0 g-speed ! \ user speed
    24 xy-jerk !
    42 z-jerk ! \ z jerk speed (100us/step)
    5 xy-delay !
    20000 xy-accel !
    \ 2048    164000  xcal 2! \ ruler
    \ 2048    164000  ycal 2!
    1000    79895 xcal 2! \ dial gauge
    1000    79895 ycal 2!
    \ 200  1250  zcal 2! \ M8 thread pitch
    200    1227  zcal 2! \ measured pitch
    \ 2000 22000  ecal 2! \ measured to free air @ 195°C
    \ 8192 68000 ecal 2! \ measured to free air @ 180°C, 0.5mm-Nozzle
    \ 4000 28000 ecal 2! \ same with tapped bolt
    1024 10225 ecal 2! \ latest tapped bolt
    0 pid_i !

    hex
    \ oscillates...
    \ -300000 pid_d !
    \ c0000 pid_p !
    \ 10 pid_droop !
    -c0000 pid_d !
    68000 pid_p !
    18 pid_droop !
}

send "hi\n"
expect \
    timeout { error timeout } \
    -re {stubforth}

set timeout 3000

send "ginterp\n"

log_user 1
set i 0
set len [llength $lines]

foreach line $lines {
    regsub -all {\s*;.*$} $line {} line
    if ![string length "$line"] continue

    send "$line\n"

    expect \
	timeout { error timeout } \
	-re "abort" { error abort } \
	-re {ok}

    puts -nonewline "sent [incr i] of $len\n"
    flush stdout
}
