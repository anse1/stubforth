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


\ i2c master

\ | pg0  |      | oled_sda    | i2c1 |
\ | pg1  |      | oled_scl    | i2c1 |

1000 rcgc1 or! \ i2c0
4000 rcgc1 or! \ i2c1

3 gpioafsel pg or!
3 gpioodr pg or!
3 gpiopctl pg or!

\ 10 i2cmcr i2c1 !
\ 9 i2cmtpr i2c1 !

\ 78 i2cmsa i2c1 !
\ data i2cmdr i2c1 !
\ 7 i2cmcs i2c1 !
\ \ poll i2cmcs
\ \ check i2cmcs for ack/error

\ \        a  1    2      3     4   5 6    7        8    9 a b 
\ \ PG0 19 - U2Rx PWM0 I2C1SCL PWM4 - - USB0EPEN EPI0S13 - - -
\ \ PG1 18 - U2Tx PWM1 I2C1SDA PWM5 - -     -    EPI0S14 - - -
