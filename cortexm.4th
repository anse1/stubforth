\ rcc
\ sample = 24e0540
\ default = 7803ad1
\ 00000010010011100000010101000000
\ rrrr|   ||rrrrrrrr|r|    | |rr|^moscdis
\     ^ACG|usesysdiv| |    | |  ^-ioscdis
\         ^-sysdiv  | |    | ^-oscsrc = MOSC
\            => /5  | |    ^-xtal = 16MHz
\                   | ^--pll bypass
\                   ^--pll pwrdn

.( Loading cortexm.4th...) lf
hex
400fe000 constant rcc_base
7c rcc_base + constant moscctl
60 rcc_base + constant rcc
70 rcc_base + constant rcc2
10 rcc_base + constant dc1

e000ed14 constant ccr

decimal
: bboffset ( bit# a bb-start alias-start - alias-a )
	>r - 32 * swap 4 * + r> + ;

hex
: bb2a ( bit# a -- alias-a )
 	dup 20000000 20100000 within if
		20000000 22000000 bboffset
		exit then
	dup 40000000 40100000 within if
		40000000 42000000 bboffset
		exit then
	," invalid bit-band" throw
;

\ bit a -- ; compile code to set/clear/flip bit using bit-banding
: ,set bb2a postpone 1 postpone literal postpone ! ;
: ,clear bb2a postpone 0 postpone literal postpone ! ;
: ,flip postpone 1 bb2a postpone literal postpone +! ;


\ NVIC
hex
e000e100 constant nvic_iser
e000e180 constant nvic_icer
e000e200 constant nvic_ispr
e000e280 constant nvic_icpr
e000e300 constant nvic_iabr
e000e400 constant nvic_ipr
e000e004 constant ictr

decimal


: isecer ( int# -- mask reg_offset ) 32 /mod cells swap 1 swap << swap ;

: ise@ ( int# -- ; get status ) isecer nvic_iser + @ and ;
: ise! ( int# -- ; enable ) isecer nvic_iser + ! ;
: ice! ( int# -- ; disable ) isecer nvic_icer + ! ;

: isp@ ( int# -- ; get pending ) isecer nvic_ispr + @ and ;
: isp! ( int# -- ; set pending ) isecer nvic_ispr + ! ;
: icp! ( int# -- ; clear pending ) isecer nvic_icpr + ! ;

