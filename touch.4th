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
		10 of 0100100 endof \ aux1
		11 of 1100100 endof \ aux 2
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
	4 >>
	¬touchcs
;

decimal
300 constant touch.xmin
1492 constant touch.xmax
583 constant touch.ymin
1640 constant touch.ymax


: .cords
	2dup
	." cords: " swap . . lf
;

\ x y -- x y
: normalize
	touch.ymin -
	swap
	touch.xmin -
	swap
	ydim *
	touch.ymax touch.ymin - /
	swap
	xdim *
	touch.xmax touch.xmin - /
	swap
;

: between \ n1 n2 n3 -- (n2 <= n1)&&(n1 < n3)
	2 pick
	\ n1 n2 n3 n1
	> 0= if 2drop 0 exit then
	\ n1 n2
	< if 0 exit then
	1
;

\ x y -- t/f
: valid
	0 ydim between 0= if 0 exit then
	0 xdim between 0= if 0 exit then
	1
;
	
: touchpixel
	0 sample
	1 sample
	normalize
	2dup
	valid if setp else
		." invalid coords: "
		.cords
	then
;	

: touchbug
	." x: " 0 sample .
	." y: " 1 sample .
	." aux1: " 2 sample .
	." aux2: " 3 sample .
	." penirq: " pfdata c@ 2 and .
	lf
;

touch_init

\ ' touchbug forth_vectors 5 cells + !

' touchpixel forth_vectors 5 cells + !

: touchaux begin 2 sample . 3 sample . lf 500 ms again ;
