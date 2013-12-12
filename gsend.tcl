
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

send {
    decimal
    11 xy-max ! \ xy maximum speed (100us/step)
    10 g-speed ! \ user speed
    40 xy-jerk !
    40 z-jerk ! \ z jerk speed (100us/step)
    60 xy-accel !
    2048    164000  xcal 2!
    2048    164000  ycal 2!
    200      1250  zcal 2!  \ M8 threads
    \ 4096  44521  ecal 2!
    \ 14336   160000 ecal 2!
    \ 4096 43400  ecal 2!
    \ 4096 32000  ecal 2!
    \ 2000 22000  ecal 2! \ measured to free air @ 195°C
    \ 2040 22000  ecal 2! \ +2%
    \  2080 22000  ecal 2! \ +4%
    \ 2100 22000  ecal 2! \ +5%
    8192 68000 ecal 2! \ measured to free air @ 180°C, 0.5mm-Nozzle
    4000 28000 ecal 2! \ same with tapped bolt
}

send "hi\n"
expect \
    timeout { error timeout } \
    -re {stubforth}

set timeout 300

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
