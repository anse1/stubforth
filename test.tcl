#!/usr/bin/expect

spawn ./stub4th

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
set name {stub4th [0-9a-f]+}

test "hi\n" $name

send_user "the following should abort...\n"
send "should-abort\n"
expect {
    timeout { error }
    -re abort.*
}

send ".\n"
expect {
    timeout { error }
    -re abort.*
}

test "85 1 + ." {86 $}

send "hex\n"

test "1 2 3 4 5 * + * + ." {2f $}

test "key A ." {41 $}

test "1 2 3 4 5 6 7 8 9 swap mod + * xor or swap - hex ." {32 $}

test "1 2 3 4 5 6 7 8 9 << >> << swap / ." {99 $}

test "1234 2345 max 9999 min 11 + ." {2356 $}

test "55 emit 1234 2345 dup = 30 + emit = 30 + emit " {U10$}
test "55 emit 1234 2345 swap dup < 30 + emit < 30 + emit " {U01$}
test "55 emit 8 2345 dup dup and 0= 30 + emit and 0= 30 + emit " {U01$}

send "decimal : testsuite-marker 85 emit ;\n"
test "testsuite-marker" {U$}

send "decimal : ifelsethen 85 emit if 64 emit else 65 emit then 85 emit ;\n"

test "1 ifelsethen" U@U
test "0 ifelsethen" UAU

send ": fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;\n"
test "20 fib ." 6765

send ": tuck swap over ;\n"
send ": gcd dup if tuck mod recurse else drop then ;\n"

test "decimal 11111 12341 gcd ." {41 $}

send "hex\n"

send ": tloop begin 1 - dup 8 < if exit then again ;\n"
test "100 tloop ." {7 $}

send ": tuntil begin 1 - dup 197 < until ;\n"
test " 999 tuntil ." {196 $}

send "decimal\n"

send ": twhile 85 emit begin 64 emit 1 - dup 10 > while 65 emit repeat 85 emit ;\n"
test "16 twhile" {U@A@A@A@A@A@U$}

send "hex\n"

test "variable foo F6F 1 + foo ! foo ?" {f70 $}
test "2ff 1 + constant foo foo ." {300 $}

test "word fubar type" {fubar$}

send "0 variable scratch 10 allot\n"
test "scratch 10 55 fill scratch 8 + c@ 11 + ." {66 $}

test "8 base c! 777 1 + ." {1000 $}
send "decimal "

test "word \[ find drop immediatep ." $true
test "word : find drop immediatep ." $false

test "' hi execute" $name
test ": foo ' hi execute ; foo" $name

test " -3 3- * ." {9 $}
test " -3 3 * ." {-9 $}

send ": foo 666 throw ; "
send ": bar ' foo catch 666 = if 85 emit else 65 then ; "
test bar {U$}

send ": foo . ?stack ; "
send ": bar ' foo catch . ; "
test "bar" {-4 $}

send ": foo 85 ; "
send ": bar  ' foo catch . . ; "

test bar {0 85 $}

test ": foo 99 13 /mod . . ; foo" {7 8 $}

test "create foo 66 ,  foo @ 2 * . ;" {132 $}

send ": cst <builds , does> @ ;\n"
test "666 cst moo moo 1+ ." {667 $}

test ": t 7 8 2dup . . . . ; t" {8 7 8 7 $}
test ": t 1 2 3 4 2over . . . . . . ; t" {2 1 4 3 2 1 $}
test ": t 1 2 3 4 2swap . . . . ; t" {2 1 4 3 $}

send "abort\n" ;
expect -re abort.*

test "depth 1 2 3 666 5 .s" {#6 0 1 2 3 666 5}

send ": w2345678 ;\n"
test "here word w2345678 find drop drop here = ." {1 $}

test {" fox" " quick brown " type type} {quick brown fox$}
test {: t ," lazy dog" ," jumps over the " type type ; t} {jumps over the lazy dog$}

test {: t 85 emit ." moo" 85 emit ; t} {UmooU$}

test {: t 1 if ." moo" else ." bar" then ; t} {moo$}

send {: t case 0 of ." looks like zero" endof 1 of ." looks like one" endof 2 of ." looks like two" endof ." i dunno" endcase lf ; }

test "4 t" {i dunno}
test "1 t" {looks like one}

send ": t postpone if ; immediate\n"
test {: t2 1 t ." moo" else ." bar" then ; t2} {moo$}

send ": t postpone hi ; immediate\n"
test {: t2 t ; t2} {stub4th.*$}

test { " foo" " barz" compare .} {1 $}
test { " 999" " ba" compare .} {-1 $}
test { " hmm" " hmm" compare .} {0 $}

send "bye\n"
interact
