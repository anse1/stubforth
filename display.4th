decimal
160 constant xdim
240 constant ydim
0 lxmax c!
xdim lxmax 1+ c!
0 lymax c!
ydim lymax 1+ c!

xdim 16 / lvpw c!
8 lpicf c!
0 lrra c!

0 pcsel c!

hex

: lcdon
  80 lckcon c!
  1 6 << dup pfdir set pfdata set
;

: lcdoff
  1 6 << pfdata clear
  0 lckcon c!
;

lcdon

: dac ( n -- set lcd contrast )
3 4 << dup dup pfdir set
pfdata set pfdata clear
dup
0 > if
1 5 <<
else
1 4 <<
swap negate swap
then
begin
dup pfdata set
dup pfdata clear
swap 1 - swap 1 pick
0 < until ;

: fb lssa @ ;
: cls fb [ decimal ] 4800 0 fill ;

hex

: pxaddr ( x y -- c a )
[ hex ]
xdim * over + 3 >> fb +
swap
7 and 80 swap >>
swap ;

: setp  ( x y -- )
pxaddr set ;

: clp  ( x y -- )
pxaddr clear ;

: getp ( x y -- n )
pxaddr c@ and ;

: sq dup * ;
