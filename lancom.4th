.( Loading lancom.4th...) lf

marker lancom

hex

: sw1 SWITCHES c@ 40 and 0= ;

\ .( activating cache...)
\ 1 CCR !
\ .( ok) lf


: key? SCSSR c@ RDRF and ;

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

: bank SMSC e + c! ;
: sd SMSC 10 dump ;


