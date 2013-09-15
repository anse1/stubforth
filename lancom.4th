.( Loading lancom.4th...) lf

marker lancom

hex

: sw1 switches c@ 40 and 0= ;

\ .( activating cache...)
\ 1 CCR !
\ .( ok) lf


: emit? scssr c@ tdre and ;

\ try to figure out CPLD wiring
: peek ( increment address )
	begin
		dup . dup @ drop over + key [char] n = while
	repeat
;

: apeek ( increment address )
	begin dup @ drop over + key? until
;

: apoke ( increment address )
	begin dup @ drop over + key? until
;

: bank smsc e + c! ;
: sd smsc 10 dump ;

: reboot 0 a0000000 call ;

.( enabling cache...)
8 ccr !
1 ccr !
.( ok) lf

: putchar 0 c3f0c60 call ;
: puts 1 c3f2ac0 call ;
