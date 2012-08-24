decimal
lxmax @ 160 16 << or lxmax !
lymax @ 240 16 << or lymax !
160 16 / lvpw c!
8 lpicf c!
hex 80 lckcon c!
0 pcsel c!
: flip ( c a -- ) 
dup c@ 2 pick xor swap c! drop ;
: set ( c a -- )
dup c@ 2 pick or swap c! drop ;
: clear ( c a -- )
dup c@ 2 pick ~ and swap c! drop ;
1 6 << dup pfdir set pfdata set

0 lrra c!

: dac
3 4 << dup dup pfdir set
pfdata set pfdata clear
1 5 <<
begin
dup pfdata set
dup pfdata clear
swap 1 - swap 1 pick
0 < until ;

10 dac

: fb lssa @ ;
20000 lssa !
: test fb 1300 1 fill ;
: cls fb 1300 0 fill ;

test
