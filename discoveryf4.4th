decimal
80000 syst_rvr !
7 syst_csr !
: ms 10 / >r tick @ begin wfi tick @ over - r@ > until r> 2drop ;

hex

: moder  0 + ;
: otyper  4 + ;
: ospeedr  8 + ;
: pupdr  12 + ;
: idr  10 + ;
: odr  14 + ;
: bsrr  18 + ;
: lckr  1c + ;
: afrl  20 + ;
: afrh  24 + ;

\ 4 leds @ gpiod:12  

rcc_ahb1enr @ 1 3 << or rcc_ahb1enr !

55 c 2 * << gpiod moder !
f c << gpiod odr !

hex
: ledon cells [ c gpiod odr bb2a ] literal + 1 swap ! ;
: ledoff cells [ c gpiod odr bb2a ] literal + 0 swap ! ;
: ledflip cells [ c gpiod odr bb2a ] literal + 1 swap +! ;

decimal
: heartbeat begin 900 ms 2 ledon 100 ms 2 ledoff again ;

hex
: unused 10010000 here - ;
