hex

: unused [ hex ] 20008000 here - ;

000 constant tmcfg
004 constant tmtamr
008 constant tmtbmr
00c constant tmctl
010 constant tmsync
018 constant tmimr
01c constant tmris
020 constant tmmis
024 constant tmicr
028 constant tmtailr
02c constant tmtbilr
030 constant tmtamatchr
034 constant tmtbmatchr
038 constant tmtapr
03c constant tmtbpr
040 constant tmtapmr
044 constant tmtbpmr
048 constant tmtar
04c constant tmtbr
050 constant tmtav
054 constant tmtbv
058 constant tmrtcpd
05c constant tmtaps
060 constant tmtbps
064 constant tmtapv
068 constant tmtbpv
fc0 constant tmpp

40030000 constant timer0
40031000 constant timer1
40032000 constant timer2
40033000 constant timer3
40034000 constant timer4
40035000 constant timer5
40036000 constant widetimer0
40037000 constant widetimer1
4004c000 constant widetimer2
4004d000 constant widetimer3
4004e000 constant widetimer4
4004f000 constant widetimer5

000 constant GPIODATA \  R/W Data                      615
400 constant GPIODIR \   R/W Direction                 616
404 constant GPIOIS \    R/W Interrupt Sense           617
408 constant GPIOIBE \   R/W Interrupt Both Edges      618
40C constant GPIOIEV \   R/W Interrupt Event           619
410 constant GPIOIM \    R/W Interrupt Mask            620
414 constant GPIORIS \   RO  Raw Interrupt Status      621
418 constant GPIOMIS \   RO  Masked Interrupt Status   622
41C constant GPIOICR \   W1C Interrupt Clear           623
420 constant GPIOAFSEL \ R/W Alternate Function Select 624
500 constant GPIODR2R \  R/W 2-mA Drive Select         626
504 constant GPIODR4R \  R/W 4-mA Drive Select         627
508 constant GPIODR8R \  R/W 8-mA Drive Select         628
50C constant GPIOODR \   R/W Open Drain Select         629
510 constant GPIOPUR \   R/W Pull-Up Select            630
514 constant GPIOPDR \    R/W GPIO Pull-Down Select         632
518 constant GPIOSLR \    R/W GPIO Slew Rate Control Select 634
51C constant GPIODEN \    R/W GPIO Digital Enable           635
520 constant GPIOLOCK \   R/W GPIO Lock                     637
524 constant GPIOCR \      -  GPIO Commit                   638
528 constant GPIOAMSEL \  R/W GPIO Analog Mode Select       640
52C constant GPIOPCTL \   R/W GPIO Port Control             641
530 constant GPIOADCCTL \ R/W GPIO ADC Control              643
534 constant GPIODMACTL \ R/W GPIO DMA Control              644

40004000 constant GPIOAAPBBASE
40058000 constant GPIOAAHBBASE
40005000 constant GPIOBAPBBASE
40059000 constant GPIOBAHBBASE
40006000 constant GPIOCAPBBASE
4005A000 constant GPIOCAHBBASE
40007000 constant GPIODAPBBASE
4005B000 constant GPIODAHBBASE
40024000 constant GPIOEAPBBASE
4005C000 constant GPIOEAHBBASE
40025000 constant GPIOFAPBBASE
4005D000 constant GPIOFAHBBASE

\ PD0:TCK PD1:TMS PD2:TDI PD3:TDO

: jtaginit
	7 GPIODIR GPIODAPBBASE + !
;

: red 8 << tmtbmatchr timer0 + ! ;
: green 8 << tmtbmatchr timer1 + ! ;
: blue 8 << tmtamatchr timer1 + ! ;

: col
	dup 10 >> ff and red
	dup 8 >> ff and green
	ff and blue
;

decimal
400000 syst_rvr !
: ms 10 / >r tick @ begin wfi tick @ over - r@ > until r> 2drop ;
: heartbeat begin 900 ms [ hex ] 300000 col [ decimal ] 100 ms [ hex ] 000000 col again ;

