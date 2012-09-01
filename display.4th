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
swap minus swap
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

hex
6000 variable max_abs
18 variable max_iter
10 variable shift

: csq ( r i -- r i )
over sq over sq - a >>
>r * 9 >> r> swap ;

: c+ ( r i r i -- r i )
swap >r + swap r> + swap ;

: zn ( cr ci zr zi )
csq >r >r 2dup r> r> c+ ;

: zabs ( r i -- n )
dup 0 < if minus then swap
dup 0 < if minus then + ;

: divp ( cr ci -- n)
0 >r 0 0 begin
zn
2dup zabs max_abs @ > if drop drop drop drop r> exit then
r> 1+ dup >r max_iter @ > if drop drop drop drop r> drop 0 exit then
again ;

: mset2nd
xdim 1- begin
." ."
ydim 1- begin
2dup
2 << swap 2 << swap
divp
0= if 2dup setp then
1- dup 0= until drop
1- dup 0= until drop
;

: mset
xdim 1- begin
." ."
ydim 1- begin
2dup
ydim 1 >> -
ydim 2 >> - c *
swap xdim 1 >> - c *
divp
0= if 2dup setp then
1- dup 0= until drop
1- dup 0= until drop
;
