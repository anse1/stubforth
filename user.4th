\ non-platform-specific forth code

hex

: fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;
: tuck swap over ;
: gcd dup if tuck mod recurse else drop then ;

: c, here c! here 1+ dp ! ;
: " here begin key dup 22 = 0= while c, repeat drop 0 c, here aligned dp ! ;
: ," ' branch , here 0 , " swap here swap ! ' lit , , ; immediate
: ." ' ," execute ' type , ; immediate

: strlen ( s -- n )
dup
begin dup c@ while 1+ repeat
swap - ;

: fstrlen ( s -- n )
dup
begin dup c@ 1 negate = 0= while 1+ repeat
swap - ;

: forget ( read a word to forget, adjusts dp )
 word find 0= if abort then
 >word dup  >link @ context ! >name @ dp ! ;

: dump ( addr n -- )
over + swap
( endaddr addr )
begin
dup c@ emit
1 + 2dup <
until
lf ;

\ bit flipping

: flip ( c a -- ) 
  swap over c@ xor swap c! ;
: set ( c a -- )
  swap over c@ or swap c! ;
: clear ( c a -- )
  swap over c@ swap ~ and swap c! ;

hex

: ehex
  dup 4 >> f and hexchars + c@ emit
  f and hexchars + c@ emit ;

: bl 20 emit ;

: dumpaddr ( addr n -- )
over cell begin 1-
2dup 8 * >> ff and ehex
dup 0= until
2drop ." : " ;

: dump8 ( addr n )
8 begin
2dup 0= 0= swap 0= 0= and while
2 pick c@ ehex bl
rot 1+ rot 1- rot 1-
repeat drop ;

: dump ( addr n -- )
begin dup while
dumpaddr dump8
dup 0= if exit then
."  " dump8 ." 
" repeat ." 
" ;
