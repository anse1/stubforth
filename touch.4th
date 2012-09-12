hex
1 6 << constant bbads7843_ncs
100 constant spimcont_xch
200 constant spimcont_enable

: touch_init
	bbads7843_ncs pbdata set
	bbads7843_ncs pbdir set
	7 pesel clear
	spimcont w@
	[ decimal ] 7 13 << or \ data rate
	spimcont_enable or \ enable
	7 or \ bit count-1
	spimcont w!
;

: touchcs bbads7843_ncs pbdata clear ;
: ¬touchcs bbads7843_ncs pbdata set ;

: binary 2 base c! ;

: spiwait
	[ hex ]
	begin
		spimcont w@ spimcont_xch and while
	repeat
;

: spitx
	spimdata w!
	spimcont w@ spimcont_xch or spimcont w!
	spiwait
;

: spirx
	spimdata w@
;

: sample ( channel -- sample )
	touchcs
	[ binary ]
	case
		0 of 0010000 endof \ x
		1 of 1010000 endof \ y
		10 of 0100000 endof \ aux1
		11 of 1100000 endof \ aux 2
	endcase
\	10000011  \ always-on, penirq off
	10000000  \ power-down, penirq enabled
	or
	spitx
	[ hex ]
	0 spitx
	spirx 8 <<
	0 spitx
	spirx or
	3 >>
	¬touchcs
;

decimal


: touchbug
	." x: " 0 sample .
	." y: " 1 sample .
	." aux1: " 2 sample .
	." aux2: " 3 sample .
	." penirq: " pfdata c@ 2 and .
	lf
;

' touchbug forth_vectors 5 cells + !

touch_init

debug
