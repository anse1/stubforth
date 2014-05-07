hex

.( Loading evalbot.4th...) lf

decimal
7 syst_csr !
: ms 40000 syst_cvr ! 40000 syst_rvr ! 0 tick ! begin wfi dup tick @ < until drop ;
: 100us 4000 syst_cvr ! 4000 syst_rvr ! 0 tick ! begin wfi dup tick @ < until drop ;

\ gpio

hex

: pa gpioa_apb ;
: pb gpiob_apb ;
: pc gpioc_apb ;
: pd gpiod_apb ;
: pe gpioe_apb ;
: pf gpiof_apb ;
: pg gpiog_apb ;
: ph gpioh_apb ;

: pd? gpiodata ff 2 << + pd ? ;
: pe? gpiodata ff 2 << + pe ? ;

: or! ( value addr -- )
	tuck @ or swap ! ;

: setgpout ( mask base -- )
	2dup gpiodir + or!
	2dup gpioden + or!
	gpiodr8r + or!
;	

: setgpin ( mask base -- )
	2dup gpiopur + or!
	gpioden + or!
;	

: gpoutbit ( bitno base -- )
	<builds
	swap 1 swap << tuck \ mask base mask
	2dup swap setgpout
	2 << + gpiodata + \ mask base+mask<<2+gpiodata
	, ,
  does>
	swap if
		2@ !
	else
		2@ 0 swap ! drop
	then
;

: gpinbit ( bitno base -- )
	<builds
	swap 1 swap << tuck \ mask base mask
	2dup swap setgpin
	2 << + gpiodata + \ mask base+mask<<2+gpiodata
	, ,
  does>
	@ @ 0=
;

6 0 pd gpinbit sw1?
7 0 pd gpinbit sw2?

0 0 pe gpinbit bumpr?
1 0 pe gpinbit bumpl?

f 2 << 0 pf setgpout

4 0 pf gpoutbit led1
5 0 pf gpoutbit led2

2 0 pf gpoutbit ledg
3 0 pf gpoutbit ledo

3 0 ph setgpout
: left gpiodata ph 3 2 << + ! ;

3 0 pd setgpout
: right gpiodata pd 3 2 << + ! ;

5 0 pd gpoutbit 12v

\ : sw1? gpiodata pf 10 2 << + @ 0= ;
\ : sw2? gpiodata pf 1 2 << + @ 0= ;

