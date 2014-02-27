
\ 2 8 << \ src
\ 3 6 << or \ div
\ 2 4 << or \ mode
\ tactl !

\ ffff taccr0 !

\ fc00 taccr1 !

\ ec70 taccr1 !

\ ec70 ec70 fc20 + + 3 / taccr1 !

\ ec70 fc20 + 2 / taccr1 !

\ : s 4 << ec88 + taccr1 ! ;

\ 6 4 << \ output mode 6
\ tacctl1 !

\ \ p1.6/ta0.1 out1 output
\ 1 6 << p1sel +!

2 8 <<
3 6 << or

1 4 << or
t1ctl !

8000 t1ccr0 !

\ p2.1 T1.1
\ p2.4 T1.2

1 1 << dup p2sel +! p2dir +!
1 4 << dup p2sel +! p2dir +!

: duty dup t1ccr0 @ swap - t1ccr1 ! t1ccr2 ! ;

1 duty
3 5 <<
t1cctl1 !
7 5 <<
t1cctl2 !

0 duty
	
variable state
10 state !

: s? p1in c@ 1 5 << and 0= ;

: loop
	begin
		rot?
		s? if
			100 *
			t1ccr0 +!
		else
			state +!
			state @ 0 < if 0 state ! then
		then
		state @ duty
	again
;

