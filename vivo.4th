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

hex 

\ power control

: sleep 80 pctlr c! ;


: DUMP flash 400 raw dump ;

: ms ( n --, pause for approx n milliseconds)
 [ decimal ]
  27 * begin 1 - dup while repeat drop ;

: honk ( n -- )
[ hex ]
1 7 << pbsel clear
80 pwmc c!
3c pwmc 1+ c!
4 pwms 1+ c!
8 pwmp c!
ms
0 pwmc 1+ c! ;

: max3221off 1 pbsel set 1 pbdir set 1 pbdata clear ;
: max3221on 1 pbsel set 1 pbdir set 1 pbdata set ;

1 6 << constant s3
1 7 << constant nlcdon

\ interrupts

: s3irq  s3 pdsel clear imr @ mirq3 ~ and imr ! ;
: penirq  2 pfsel clear imr @ mirq5 ~ and imr ! ;
: suspend 1 3 << pllcr 1+ set max3221off stop max3221on ;
: rtcirq imr @ mrtc ~ and imr ! ;
: batirq 1 7 << pdpuen set imr @ mirq6 ~ and imr ! ;

: chainload redirect @ if redirect ! then ;
    
1 fbblock chainload
