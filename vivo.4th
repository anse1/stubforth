hex
: lshift << ;
: rshift >> ;
: flash 800000 ;
: c? c@ . ;
: fcmd flash c! ;
: funlock 60 fcmd D0 swap c! ;
: fsr 70 fcmd flash 1 + c@ ;
: flstatus 90 fcmd 5 + c? ;
: fcsr 50 fcmd ;
: farr FF fcmd ;

: ferase ( a -- )
dup funlock 20 fcmd D0 swap c! ;

: fwrite ( c a -- )
dup 1 and
if
 1 xor
 swap FF00 or
else
 swap 8 lshift FF or
then
10 lshift FFFF or
swap
10 fcmd
! ;

: fwait
begin
 fsr 80 and until ;

: strap ( a -- )
begin
 dup key dup emit swap
 fwrite
 1 +
 fwait
 0 until ;

: chiperase ( -- )
flash
begin
 dup .
 dup funlock
 dup ferase fwait
 10000 + dup
 flash 1F0000 +
 1 - 
 >
  until
flash 1F0000 +
begin
 dup .
 dup funlock
 dup ferase fwait
 2000 + dup
 flash 200000 +
 1 -
 >
  until ;

: fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;
: tuck swap over ;
: gcd dup if tuck mod recurse else drop then ;

: 2dup 1 pick 1 pick ;

: dump ( addr n -- )
over + swap
( endaddr addr )
begin
dup c@ emit
1 + 2dup <
until
lf ;
