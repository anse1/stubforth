set timeout 10

set tty [lindex $argv 0]
spawn -noecho -open [set port [open $tty "r+"]]
log_user 0
remove_nulls 0


proc readaddr {} {

    send "FFFFFFAA084E7114994E714E71\nFFFFFFAA00\n"
    expect -re "FFFFFFAA00(.)\n\$"

    binary scan $expect_out(1,string) c1 byte

    return [expr $byte%256]
}


send "FFFFFFAA084E7143F9[lindex $argv 1]\nFFFFFFAA00\n"
expect -re "FFFFFFAA00\n"
set base [expr 0x[lindex $argv 1]]



    puts -nonewline [format "%08x : " $base]
    incr base 16

set fmt "%02x "
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline " "
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]
puts -nonewline [format $fmt [readaddr]]

          puts  [format $fmt [readaddr]]



