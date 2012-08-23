#!/usr/bin/expect

# Wait for echos so we don't overflow the buffers.

set timeout -1

set tty [lindex $argv 0]
spawn -open [set port [open $tty "r+"]]

set lines [split [read stdin] \n]

foreach l $lines {

    # Exploit the 12 byte RX FIFO of the Dragonball.
    foreach {a b c d e f g h i j k l}  [split $l ""] {
	send -- "$a$b$c$d$e$f$g$h$i$j$k$l"
	expect -- "$a$b$c$d$e$f$g$h$i$j$k$l"
    }
    send "\r"
    expect "\r"
}
