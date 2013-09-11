hex

.( Loading launchpad.4th...) lf

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

000 constant gpiodata
400 constant gpiodir
404 constant gpiois
408 constant gpioibe
40c constant gpioiev
410 constant gpioim
414 constant gpioris
418 constant gpiomis
41c constant gpioicr
420 constant gpioafsel
500 constant gpiodr2r
504 constant gpiodr4r
508 constant gpiodr8r
50c constant gpioodr
510 constant gpiopur
514 constant gpiopdr
518 constant gpioslr
51c constant gpioden
520 constant gpiolock
524 constant gpiocr
528 constant gpioamsel
52c constant gpiopctl
530 constant gpioadcctl
534 constant gpiodmactl

40004000 constant gpioaapbbase
40058000 constant gpioaahbbase
40005000 constant gpiobapbbase
40059000 constant gpiobahbbase
40006000 constant gpiocapbbase
4005a000 constant gpiocahbbase
40007000 constant gpiodapbbase
4005b000 constant gpiodahbbase
40024000 constant gpioeapbbase
4005c000 constant gpioeahbbase
40025000 constant gpiofapbbase
4005d000 constant gpiofahbbase

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

