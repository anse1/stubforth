\ stepper z
	
f gpiodr8r pd !
f gpioden pd !
f gpiodir pd !

: z gpiodata pd f 2 << + ! ;

: down begin ?dup while 1- 1 z 26 ms 2 z 26 ms 4 z 26 ms 8 z 26 ms repeat ;
: up begin ?dup while 1- 8 z 26 ms 4 z 26 ms 2 z 26 ms 1 z 26 ms repeat ;

: md begin ?dup while 1- 9 z 10 ms 1 z 10 ms 3 z 10 ms 2 z 10 ms 6 z 10 ms 4 z 10 ms c z 10 ms 8 z 10 ms repeat ;
: mu begin ?dup while 1- 9 z 10 ms 8 z 10 ms c z 10 ms 4 z 10 ms 6 z 10 ms 2 z 10 ms 3 z 10 ms 1 z 10 ms repeat ;

\ stepper y
	
f0 gpiodr8r pc !
f0 gpioden pc !
f0 gpiodir pc !

: y 4 << gpiodata pc f0 2 << + ! ;

: yd begin ?dup while 1- 9 y 4 ms 1 y 4 ms 3 y 4 ms 2 y 4 ms 6 y 4 ms 4 y 4 ms c y 4 ms 8 y 4 ms repeat ;
: yu begin ?dup while 1- 9 y 4 ms 8 y 4 ms c y 4 ms 4 y 4 ms 6 y 4 ms 2 y 4 ms 3 y 4 ms 1 y 4 ms repeat ;

