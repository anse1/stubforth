decimal
lxmax @ 160 16 << or lxmax !
lymax @ 240 16 << or lymax !
160 16 / lvpw c!
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
: test fb 1300 1 fill ;
: cls fb 1300 0 fill ;

