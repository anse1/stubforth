#!/usr/bin/expect

set tty [lindex $argv 0]
spawn -open [set port [open $tty "r+"]]

sleep 0.1
set timeout 0

send "decimal \n"

expect plzflushkthx
expect *

set timeout 4

proc test {tx rx} {
    send "$tx\n"

    expect \
	timeout { error timeout } \
	-re abort: { error abort } \
	-re $rx
    send_user " \[OK\]\n"
}

set true {ffff $}
set false {\s0 $}
set name {stub4th [0-9a-f]+}

test "hi\n" $name

send_user "the following should abort...\n"
send "should-abort\n"
expect {
    timeout { error }
    -re abort:.*
}

send ".\n"
expect {
    timeout { error }
    -re abort:.*
}

test "85 ." {55 $}

send "hex\n"

test "1 2 3 4 5 * + * + ." {2f $}

test "key A ." {41 $}

test "1 2 3 4 5 6 7 8 9 swap mod + * xor or swap - hex ." {32 $}

test "1 2 3 4 5 6 7 8 9 << >> << swap / ." {99 $}

test "1234 2345 max 9999 min 11 + ." {2356 $}

test "55 emit" {U$}
test "1234 2345 dup = 30 + emit" {1$}
test "= 30 + emit" {0$}
test "1234 2345 swap dup < 30 + emit" {0$}
test "< 30 + emit" {1$}
test "8 2345 dup dup and 0= 30 + emit" {0$}
test "and 0= 30 + emit" {1$}

send "decimal : testsuite-marker 85 emit ;\n"
test "testsuite-marker" {U$}

send "decimal : ifelsethen 85 emit if 64 emit else 65 emit then 85 emit ;\n"

test "1 ifelsethen" U@U
test "0 ifelsethen" UAU

send ": fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;\n"
test "20 fib ." 0*1a6d

send ": tuck swap over ;\n"
send ": gcd dup if tuck mod recurse else drop then ;\n"

test "decimal 11111 12341 gcd ." {29 $}

send "hex\n"

send ": tloop begin 1 - dup 8 < if exit then again ;\n"
test "100 tloop ." {7 $}

send ": tuntil begin 1 - dup 197 < until ;\n"
test " 999 tuntil ." {196 $}

send "decimal\n"

send ": twhile 85 emit begin 64 emit 1 - dup 10 > while 65 emit repeat 85 emit ;\n"
test "16 twhile" {U@A@A@A@A@A@U$}

send "hex\n"

test "F6F 1 + variable foo foo ?" {f70 $}
test "2ff 1 + constant foo foo ." {300 $}

test "word fubar type" {fubar$}

send "0 variable scratch 10 allot\n"
test "scratch 10 55 fill scratch 8 + c@ 11 + ." {66 $}

test "8 base c! 777 ." {1ff $}

test "word \[ find drop immediatep ." $true
test "word : find drop immediatep ." $false

test "' hi execute" $name
test ": foo ' hi execute ; foo" $name

send "bye\n"
interact
