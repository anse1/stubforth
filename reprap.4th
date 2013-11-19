.( Loading reprap.4th...) lf

hex

\ stepper z
	
f gpiodr8r pd !
f gpioden pd !
f gpiodir pd !

: sz gpiodata pd f 2 << + ! ;
: zd begin ?dup while 1- 9 sz 9 ms 1 sz 9 ms 3 sz 9 ms 2 sz 9 ms 6 sz 9 ms 4 sz 9 ms c sz 9 ms 8 sz 9 ms repeat ;
: zu begin ?dup while 1- 9 sz 9 ms 8 sz 9 ms c sz 9 ms 4 sz 9 ms 6 sz 9 ms 2 sz 9 ms 3 sz 9 ms 1 sz 9 ms repeat ;

\ stepper x
	
f0 gpiodr8r pc !
f0 gpioden pc !
f0 gpiodir pc !

: sx 4 << gpiodata pc f0 2 << + ! ;

: xd begin ?dup while 1- 9 sx 5 ms 1 sx 5 ms 3 sx 5 ms 2 sx 5 ms 6 sx 5 ms 4 sx 5 ms c sx 5 ms 8 sx 5 ms repeat ;
: xu begin ?dup while 1- 9 sx 5 ms 8 sx 5 ms c sx 5 ms 4 sx 5 ms 6 sx 5 ms 2 sx 5 ms 3 sx 5 ms 1 sx 5 ms repeat ;

\ stepper y
	
f gpiodr8r pb !
f gpioden pb !
f gpiodir pb !

: sy gpiodata pb f 2 << + ! ;

: yd begin ?dup while 1- 9 sy 5 ms 1 sy 5 ms 3 sy 5 ms 2 sy 5 ms 6 sy 5 ms 4 sy 5 ms c sy 5 ms 8 sy 5 ms repeat ;
: yu begin ?dup while 1- 9 sy 5 ms 8 sy 5 ms c sy 5 ms 4 sy 5 ms 6 sy 5 ms 2 sy 5 ms 3 sy 5 ms 1 sy 5 ms repeat ;

\ stepper e
	
f gpiodr8r pe !
f gpioden pe !
f gpiodir pe !

: se gpiodata pe f 2 << + ! ;
: ed begin ?dup while 1- 9 se 5 ms 1 se 5 ms 3 se 5 ms 2 se 5 ms 6 se 5 ms 4 se 5 ms c se 5 ms 8 se 5 ms repeat ;
: eu begin ?dup while 1- 9 se 5 ms 8 se 5 ms c se 5 ms 4 se 5 ms 6 se 5 ms 2 se 5 ms 3 se 5 ms 1 se 5 ms repeat ;

