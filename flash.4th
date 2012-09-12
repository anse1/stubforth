hex

\ flash chip control

: flash 800000 ;
: w? w@ . ;

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
 swap 8 << FF or
then
10 << FFFF or
swap
10 fcmd
! ;

: fwait
begin
 fsr 80 and until ;

\ Write raw input bytes to flash, starting at the specified address.
\ Use out-of-band BREAK to stop flashing.
: fstrap ( a -- )
raw
quiet
begin
 dup key dup emit swap
 fwait
 fwrite
 1 +
 0 until ;

\ Return address of block number
: fblock ( n -- addr )
flash
begin
1 pick while
10000 +
swap 1- swap
repeat
;

\ Return address of boot block number
: fbblock ( n -- addr )
flash 1F0000 +
begin
1 pick while
2000 +
swap 1- swap
repeat
swap drop
;

: fchiperase ( -- )
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

: fstrlen
dup
begin dup c@ 1 negate = 0= while 1+ repeat
swap - ;
