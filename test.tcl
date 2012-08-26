#!/usr/bin/expect

spawn ./stub4th

sleep 0.1
set timeout 0

send " decimal \n"

expect plzflushkthx
expect *

set timeout 1

proc test {tx rx} {
    send "$tx\n"

    expect \
	timeout { exit 1 } \
	-re abort: { exit 2 } \
	-re $rx
}

test "hi\n" {stub4th [0-9a-f]+}

send "should-abort\n"
expect {
    timeout { exit 1 }
    -re abort:.*
}

test "85 ." "55 $"

send ": foo 85 emit ;\n"
test "foo" {U$}

send ": fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;\n"
test "20 fib ." 0*1a6d

