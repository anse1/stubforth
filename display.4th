decimal
lxmax @ 160 16 lshift or lxmax !
lymax @ 240 16 lshift or lymax !
160 16 / lvpw c!
8 lpicf c!
hex 80 lckcon c!
0 pcsel c!
: flip ( c a -- ) 
dup c@ 2 pick xor swap c! drop ;
: set ( c a -- )
dup c@ 2 pick or swap c! drop ;
: clear ( c a -- )
dup c@ 2 pick invert and swap c! drop ;
1 6 lshift dup pfdir set pfdata set

: dac
3 4 lshift dup dup pfdir set pfdata set pfdata clear
1 5 lshift
begin
dup pfdata set
dup pfdata clear
swap 1 - swap 1 pick
0 < until
;
0 lrra c!
