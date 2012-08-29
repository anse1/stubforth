\ non-platform-specific forth code

hex

: fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;
: tuck swap over ;
: gcd dup if tuck mod recurse else drop then ;
: 2dup 1 pick 1 pick ;

: c, here c! here 1+ dp ! ;
: " here begin key dup 22 = 0= while c, repeat drop 0 c, here aligned dp ! ;
: ," ' branch , here 0 , " swap here swap ! ' lit , , ; immediate
: ." ' ," execute ' type , ; immediate

: depth sp@ s0 - cell + cell / ;
: .s ." #" depth dup . begin dup 0 > while dup pick . 1 - repeat lf drop ;

: forget ( read a word to forget, adjusts dp )
 word find 0= if abort then
 >word dup  >link @ context ! dp ! ;

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
  dup c@ 2 pick xor swap c! drop ;
: set ( c a -- )
  dup c@ 2 pick or swap c! drop ;
: clear ( c a -- )
  dup c@ 2 pick ~ and swap c! drop ;
