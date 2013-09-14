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

\ .( enabling cache...)
\ 1 ccr !
\ .( ok) lf

