#!/usr/bin/expect

spawn ./stubforth

sleep 0.1
set timeout 0

send "decimal \n"

expect plzflushkthx
expect *

set timeout 1

proc test {tx rx} {
    send "$tx\n"

    expect \
	timeout { error timeout } \
	-re abort { error abort } \
	-re $rx
    send_user " \[OK\]\n"
}

set true {-1 $}
set false {\s0 $}
set name {stubforth [0-9a-f]+}

test "hi\n" $name

test "66 i>f 44 i>f 2 i>f f* f- f>i . " {-22 $}
test "66 i>f 44 i>f 2 i>f f* f- f0< . " {1 $}

test "77 i>f 33 i>f fdup frot fswap f* fnegate f>i ." {-2541 $}
