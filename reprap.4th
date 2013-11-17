\ stepper z
	
f gpiodr8r pd !
f gpioden pd !
f gpiodir pd !

: z gpiodata pd f 2 << + ! ;
: zd begin ?dup while 1- 9 z 9 ms 1 z 9 ms 3 z 9 ms 2 z 9 ms 6 z 9 ms 4 z 9 ms c z 9 ms 8 z 9 ms repeat ;
: zu begin ?dup while 1- 9 z 9 ms 8 z 9 ms c z 9 ms 4 z 9 ms 6 z 9 ms 2 z 9 ms 3 z 9 ms 1 z 9 ms repeat ;

\ stepper y
	
f0 gpiodr8r pc !
f0 gpioden pc !
f0 gpiodir pc !

: y 4 << gpiodata pc f0 2 << + ! ;
: yd begin ?dup while 1- 9 y 5 ms 1 y 5 ms 3 y 5 ms 2 y 5 ms 6 y 5 ms 4 y 5 ms c y 5 ms 8 y 5 ms repeat ;
: yu begin ?dup while 1- 9 y 5 ms 8 y 5 ms c y 5 ms 4 y 5 ms 6 y 5 ms 2 y 5 ms 3 y 5 ms 1 y 5 ms repeat ;

\ stepper x
	
f gpiodr8r pb !
f gpioden pb !
f gpiodir pb !

: x gpiodata pb f 2 << + ! ;
: xd begin ?dup while 1- 9 x 5 ms 1 x 5 ms 3 x 5 ms 2 x 5 ms 6 x 5 ms 4 x 5 ms c x 5 ms 8 x 5 ms repeat ;
: xu begin ?dup while 1- 9 x 5 ms 8 x 5 ms c x 5 ms 4 x 5 ms 6 x 5 ms 2 x 5 ms 3 x 5 ms 1 x 5 ms repeat ;

