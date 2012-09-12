hex 

\ VIVO peripherals apart from flash

: sleep 80 pctlr c! ;


: DUMP flash 400 raw dump ;

: ms ( n -- )
 [ decimal ]
  27 * begin 1 - dup while repeat drop ;

: honk ( ms -- )
[ hex ]
1 7 << pbsel clear
80 pwmc c!
3c pwmc 1+ c!
4 pwms 1+ c!
8 pwmp c!
ms
0 pwmc 1+ c! ;

: max3221off 1 pbsel set 1 pbdir set 1 pbdata clear ;
: max3221on 1 pbsel set 1 pbdir set 1 pbdata set ;

1 6 << constant s3
1 7 << constant nlcdon

\ interrupts

: s3irq  s3 pdsel clear imr @ mirq3 ~ and imr ! ;
: penirq  2 pfsel clear imr @ mirq5 ~ and imr ! ;
: suspend 1 3 << pllcr 1+ set max3221off stop max3221on ;
: rtcirq imr @ mrtc ~ and imr ! ;
: batirq 1 7 << pdpuen set imr @ mirq6 ~ and imr ! ;

: time&date
	[ hex ]
	rtctime @
	dup 3f and swap
	10 >> dup 3f and swap
	8 >> 1f and
	0 0 0
;

: handler
	." yay, this is forth handling an interrupt" lf
	hex
	." ISR: " isr ? lf
	." IPR: " ipr ? lf
	." SR: " sr@ . lf
;

' handler forth_vectors 1 cells + !
' handler forth_vectors 2 cells + !
' handler forth_vectors 3 cells + !
' handler forth_vectors 4 cells + !
' handler forth_vectors 5 cells + !
' handler forth_vectors 6 cells + !

