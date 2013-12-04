
.( Loading reprap.4th...) lf

hex

\ stepper z
	
f gpiodr8r pd !
f gpioden pd !
f gpiodir pd !
: sz gpiodata pd f 2 << + ! ;

\ stepper x
	
f0 gpiodr8r pc !
f0 gpioden pc !
f0 gpiodir pc !
: sx 4 << gpiodata pc f0 2 << + ! ;

\ stepper y
	
f gpiodr8r pb !
f gpioden pb !
f gpiodir pb !
: sy gpiodata pb f 2 << + ! ;

\ stepper e
	
f gpiodr8r pe !
f gpioden pe !
f gpiodir pe !
: se gpiodata pe f 2 << + ! ;

\ current stepper positions in half-steps
variable xpos
variable ypos
variable zpos
variable epos

\ compute active coils of unipolar stepper for halfstep
: halfstep ( 0..7 -- 0..15 )
	7 and
	case
		0 of 1 endof
		1 of 3 endof
		2 of 2 endof
		3 of 6 endof
		4 of 4 endof
		5 of c endof
		6 of 8 endof
		7 of 9 endof
	endcase
;

: xc 7 xpos @ - halfstep sx ;
: yc 7 ypos @ - halfstep sy ;
: zc 7 zpos @ - halfstep sz ;
: ec 7 epos @ - halfstep se ;

: off 0 sx 0 sy 0 sz 0 se ;
: on xc yc zc ec ;

: 2rel ypos @ - swap xpos @ - swap ;
: 2abs abs swap abs swap ;

: mkline ( x1 y1 x2 y2 -- b dx dy )
	2 pick	\ x1 y1 x2 y2 y1
	- \ x1 y1 x2 y2-y1
	swap \ x1 y1 y2-y1 x2
	3 pick \ x1 y1 y2-y1 x2 x1
	- \ x1 y1 y2-y1 x2-x1
	swap \ x1 y1 x2-x1 y2-y1
	2dup 2>r \ x1 y1 x2-x1 y2-y1 r: x2-x1 y2-y1
	3 roll \ y1 x2-x1 y2-y1 x1 r: x2-x1 y2-y1
	* \ y1 x2-x1 (y2-y1)*x1 r: x2-x1 y2-y1
	swap \ y1 (y2-y1)*x1 x2-x1 r: x2-x1 y2-y1
	/ \ y1 (y2-y1)*x1/(x2-x1) r: x2-x1 y2-y1
	- \ y1-(y2-y1)*x1/(x2-x1) r: x2-x1 y2-y1
	2r>
;

\ functions for multidim. linear movement
variable xline 3 cells allot
variable yline 3 cells allot
variable zline 3 cells allot
variable eline 3 cells allot

: pos.
	." current position: "
	." x=" xpos @ .
	." y=" ypos @ .
	." z=" zpos @ .
	." e=" epos @ . lf ;

\ store linear function
: line! ( b dx dy a -- )
	tuck ! cell+ tuck ! cell+ ! ;
	
\ load linear function
: line@ ( a -- b dx dy )
	dup @ swap cell+ dup @ swap cell+ @ swap 2 roll ;

\ evaluate linear function
: leval ( a x -- y )
	>r line@ r> * swap / + ;

\ determine whether a linear function is constant
: lconst? ( a -- bool )
	line@ swap drop swap drop 0= ;

\ print a linear function
: line. ( a -- )
	line@ ." line: dy=" . ." dx=" . ." b=" . lf ;

: lines. lf
	xline line.
	yline line.
	zline line.
	eline line. ;

: ramp ( x2 x1 x -- y )
	>r
	2dup - abs 1 >> \ x2 x1 abs(x2-x1)/2  r: x
	>r \ x2 x1  r: x abs(x2-x1)/2
	+ 1 >> \ µ  r: x dx/2
	r> swap \ dx µ r: x
	r> - abs \ dx/2 abs(µ-x)
	-
;

variable g-speed
variable xy-max
variable xy-jerk
variable z-jerk

decimal
11 xy-max ! \ xy maximum speed (100us/step)
10 g-speed ! \ user speed
22 xy-jerk !
40 z-jerk ! \ z jerk speed (100us/step)

\ multidimensional linear movement from x1 to x2  {x,y,z,e}line
: domove ( x2 x1 -- )
	2dup < if -1 else 1 then rot rot
	\ inc x2 x1 --
	dup >r
	\ inc x2 i=x1 -- x1
	begin
		2dup <> while
			2 pick + \ increment x2 x1+inc -- 
			xline over leval xpos !
			yline over leval ypos !
			zline over leval zpos !
			eline over leval epos !
			xc yc zc ec
			zline lconst? if
				2dup r@ swap
				ramp
				2/
				xy-jerk @ swap -
				xy-max @ g-speed @ max
				max
			else
				z-jerk @
			then
			100us
	repeat
	r>
	2drop 2drop
;

\ move tool to pos (x,y,z,e)
: move ( x y z e -- )
	2over 2over
	epos @ - abs
	swap
	zpos @ - abs
 	max
	swap
	ypos @ - abs
	max
	swap
	xpos @ - abs
	max
	tuck swap
	0 epos @ 2swap
	mkline eline line!
	tuck swap
	0 zpos @ 2swap
	mkline zline line!
	tuck swap
	0 ypos @ 2swap
	mkline yline line!
	tuck swap
	0 xpos @ 2swap
	mkline xline line!
	0 domove
;

: home
	0 epos ! \ just reset the extruder
	0 0 0 0 move ;

\ temperature regulation

\ ADC
hex
\ 12 channels, 2 converters @ 12 bit, 1 MS/s

\ Pin Name Pin Number Pin Mux /
\                     Assignment
\   AIN0        6         PE3
\   AIN1        7         PE2
\   AIN2        8         PE1
\   AIN3        9         PE0
\   AIN4        64        PD3
\   AIN5        63        PD2
\   AIN6        62        PD1
\   AIN7        61        PD0
\   AIN8        60        PE5
\   AIN9        59        PE4
\  AIN10        58        PB4
\  AIN11        57        PB5

\ Table 13-2. Samples and FIFO Depth of Sequencers
\             Sequencer                  Number of Samples Depth of FIFO
\                SS3                             1               1
\                SS2                             4               4
\                SS1                             4               4
\                SS0                             8               8

\ => use SS3

\ 13.4.1 Module Initialization
\        Initialization of the ADC module is a simple process with very few steps: enabling the clock to the
\        ADC, disabling the analog isolation circuit associated with all inputs that are to be used, and
\        reconfiguring the sample sequencer priorities (if needed).
\        The initialization sequence for the ADC is as follows:
\        1. Enable the ADC clock using the RCGCADC register (see page 322).

1 rcgcadc !

\        2. Enable the clock to the appropriate GPIO modules via the RCGCGPIO register (see page 310).
\             To find out which GPIO ports to enable, refer to "Signal Description" on page 754.
\ All up already

\        3. Set the GPIO AFSEL bits for the ADC input pins (see page 624). To determine which GPIOs to
\             configure, see Table 21-4 on page 1130.

\ PE4: Bed sensor - AIN9
\ PE5: Hotend sensor - AIN8

gpioafsel pe dup @ 30 or swap !

\        4. Configure the AINx signals to be analog inputs by clearing the corresponding DEN bit in the
\             GPIO Digital Enable (GPIODEN) register (see page 635).

gpioden pe dup @ 30 ~ and swap !

\        5. Disable the analog isolation circuit for all ADC input pins that are to be used by writing a 1 to
\             the appropriate bits of the GPIOAMSEL register (see page 640) in the associated GPIO block.

gpioamsel pe dup @ 30 or swap !

\        6. If required by the application, reconfigure the sample sequencer priorities in the ADCSSPRI
\           register. The default configuration has Sample Sequencer 0 with the highest priority and Sample
\           Sequencer 3 as the lowest priority.


\ oversampling 64x

6 adcsac adc0 ! 

\ 13.4.2 Sample Sequencer Configuration
\        Configuration of the sample sequencers is slightly more complex than the module initialization
\        because each sample sequencer is completely programmable.
\        The configuration for each sample sequencer should be as follows:
\        1. Ensure that the sample sequencer is disabled by clearing the corresponding ASENn bit in the
\           ADCACTSS register. Programming of the sample sequencers is allowed without having them
\           enabled. Disabling the sequencer during programming prevents erroneous execution if a trigger
\           event were to occur during the configuration process.

0 adcactss adc0 !

\        2. Configure the trigger event for the sample sequencer in the ADCEMUX register.
\        3. For each sample in the sample sequence, configure the corresponding input source in the
\           ADCSSMUXn register.

f000 adcemux adc0 !

\        4. For each sample in the sample sequence, configure the sample control bits in the corresponding
\           nibble in the ADCSSCTLn register. When programming the last nibble, ensure that the END bit
\           is set. Failure to set the END bit causes unpredictable behavior.

6 adcssctl3 adc0 !

\        5. If interrupts are to be used, set the corresponding MASK bit in the ADCIM register.

8 adcim adc0 !

\        6. Enable the sample sequencer logic by setting the corresponding ASENn bit in the ADCACTSS
\           register.

8 adcactss adc0 !

adcssfifo3 adc0 ?

: adc. begin
	adcssfifo3 adc0 ?
	500 ms again
;

8 adcssmux3 adc0 !

\ vnr bitnr voffs
\ 30 14 0x0000.0078 ADC0 Sequence 0
\ 31 15 0x0000.007C ADC0 Sequence 1
\ 32 16 0x0000.0080 ADC0 Sequence 2
\ 33 17 0x0000.0084 ADC0 Sequence 3
\ 64 48 0x0000.0100 ADC1 Sequence 0
\ 65 49 0x0000.0104 ADC1 Sequence 1
\ 66 50 0x0000.0108 ADC1 Sequence 2
\ 67 51 0x0000.010C ADC1 Sequence 3

\ Value     Description
\ 0x0       Reserved
\ 0x1       125 ksps
\ 0x2       Reserved
\ 0x3       250 ksps
\ 0x4       Reserved
\ 0x5       500 ksps
\ 0x6       Reserved
\ 0x7       1 Msps
\ 0x8 - 0xF Reserved
1 adcpc adc0 !

adcris adc0 ?

6 adcsac adc0 !
hex

4c4f434b gpiolock pd !
ff gpiocr pd !
80 gpiodr8r pd +!
80 gpiodir pd +!
80 gpioden pd +!

\ turn hotend heater on/off
: hotend ( bool -- )
	dup 1+ led
	7 << gpiodata pd 80 2 << + ! ;

variable adcount 0 adcount !
variable adcaccu 0 adcaccu !

: t_hotend
	adcaccu @ adcount @ / [ hex ] 319 -
	negate
	[ decimal ] 806 1000 */ \ mV
	10 17 */ \ dK
	20 + \ °C
;

hex
variable t_soll 5a t_soll !

: t_loop
	t_hotend 0 < if
		." hotend sensor fault!" lf
		0 hotend
	then
	t_soll @ t_hotend > hotend
;

hex
: adcint
	1 adcount +!
	8 adcisc adc0 !
	adcssfifo3 adc0 @ adcaccu +!
	100 adcount @ < if
		t_loop
		0 adcount !
		0 adcaccu !
	then
;

' adcint forth-vectors 21 cells + !

11 ise!

: demo
	begin
	." hotend: " decimal t_hotend . ." °C "
		1000 ms
	again
;



\ G1 X55.198 Y101.768 E524.16628

\ G92 E524.16628

\ gcode parser

decimal

\               steps       µm
2variable xcal  2048    164000  xcal 2!
2variable ycal  2048    164000  ycal 2!
2variable zcal   200      1250  zcal 2!
\ 2variable ecal  4096     44521  ecal 2!
2variable ecal  2000     22000  ecal 2! \ free air, 195°C

variable g-xpos
variable g-ypos
variable g-zpos
variable g-epos
variable g-fpos  \ feedrate

: home
	0 epos ! \ just reset the extruder
	0 0 0 0 move
    0 0 0 0 0 g-xpos ! g-ypos ! g-zpos ! g-epos ! g-fpos ! ; 

: g-pos.
	." g-code position: "
	." x=" g-xpos @ . 
	." y=" g-ypos @ .
	." z=" g-zpos @ .
	." e=" g-epos @ .
	." f=" g-fpos @ . lf ;

: diffabs ( x1 y1 x2 y2 -- dx_abs dy_abs )
	swap >r - abs swap r> - abs ;

: sqrt-closer ( square guess -- square guess adjustment) 2dup / over - 2 / ;
: sqrt ( square -- root ) 1 begin sqrt-closer dup while + repeat drop nip ;

: axis-speed ( dx dy toolspeed -- axis_speed )
	>r 2dup max >r  \ dx dy -- r: toolspeed max(dx,dy)
	dup * swap dup * + sqrt  \ sqrt(dx²+dy²) r: toolspeed d_axis
	r> r> \ sqrt(dx²+dy²) d_axis toolspeed
	rot rot swap */
;

: gspeed
	\ compute step-delay
	g-xpos @ xcal 2@ */
	g-ypos @ ycal 2@ */
	xpos @
	ypos @
	diffabs
	\ dx dy --
	g-fpos @ \ dx dy um/s --
	xcal 2@ */ \ dx dy steps/s --
	axis-speed
	10000 swap / g-speed !
;

: gmove
	g-xpos @ xcal 2@ */
	g-ypos @ ycal 2@ */
	g-zpos @ zcal 2@ */
	g-epos @ ecal 2@ */
	move
;

" eol" constant eol
" syntax error" constant syntax
" unimplemented" constant unimplemented
" nan" constant nan

variable lastkey

: gkey
	key dup lastkey !
;

: eol? ( -- bool )
	lastkey @
	case
		10 of 1 endof
		13 of 1 endof
		0
	endcase
;

: space? ( -- bool )
	lastkey @ 32 =
;

: word? ( -- bool )
	lastkey @ 32 >
;

: gword ( -- char* ) \ like word, use gkey instead
	here
	begin
		gkey word? while
			c,
	repeat
	drop
	0 c, align
;

: digit? ( -- bool )
	lastkey @
	[char] 0 dup 10 + within
;
	
: skipdigits ( -- )
	begin
		gkey drop digit? while
	repeat
;

: skipline ( -- )
	begin gkey 10 = until
;

decimal
\ parse mm w/ point as um
: gcode-num
	\ parse mm part
	gkey digit? if
		1 swap \ sign
	else
		[char] - = if
			-1 \ sign
			gkey
		else
			syntax throw
		then
	then
	0 swap \ accu
	begin
		digit? while
			[char] 0 -
			swap 10 * swap +
			gkey
	repeat
	swap
	1000 *
	swap
	case
		[char] . of
			\ parse um part
			gkey digit? if
				[char] 0 - 100 * +
				gkey digit? if
					[char] 0 - 10 * +
					gkey digit? if
						[char] 0 - +
					else drop then
				else drop then
			else drop then
		endof
	endcase
	digit? if skipdigits then
	* \ sign
;

: gcode-default-pos
	xpos @ xcal @ swap */ g-xpos !
	ypos @ ycal @ swap */ g-ypos !
	zpos @ zcal @ swap */ g-zpos !
	epos @ ecal @ swap */ g-epos !
;	

: gcode-collect-pos
	gkey
	eol? if exit then
	case
		[char] X of gcode-num g-xpos ! endof
		[char] Y of gcode-num g-ypos ! endof
		[char] Z of gcode-num g-zpos ! endof
		[char] E of gcode-num g-epos ! endof
		[char] F of gcode-num
			\ unit is mm/minute, using mm/s internally
			60 / g-fpos ! endof
		[char] ; of skipline endof
		syntax throw
	endcase
;
			
: gcode-g1 \ controlled move
	begin
		gcode-collect-pos
	eol? until
	gspeed
	gmove
;

: gcode-g28 \ controlled move
	eol? if home exit then
	gcode-g1 \ TODO: standard says ignore actual values
;

: gcode-g92 \ set position
	begin
		gcode-collect-pos
	eol? until
	g-xpos @ xcal 2@ */ xpos !
	g-ypos @ ycal 2@ */ ypos !
	g-zpos @ zcal 2@ */ zpos !
	g-epos @ ecal 2@ */ epos !
;

: ok ." ok" lf ;

: gcode-g
	gword number
	case
		1 of gcode-g1 ok endof
		92 of gcode-g92 ok endof
		90 of ok endof
		21 of ok endof
		28 of gcode-g28 ok endof
		unimplemented throw
	endcase
;

: gcode-m104
	key [char] S = if
		gword number t_soll !
	else
		syntax throw
	then
;

decimal
: gcode-m109
	gcode-m104
	begin
		t_hotend t_soll @ <
		200 ms
		t_hotend t_soll @ <
		200 ms
		and
		t_hotend t_soll @ <
		200 ms
		and
	while
	repeat
;
	
: gcode-m
	gword number
	case
		82 of ok endof
		113 of skipline ok endof
		108 of skipline ok endof
		101 of ok endof \ filament retract undo
		103 of ok endof \ filament retract
		107 of ok endof \ fan off
		106 of skipline ok endof \ fan on
		104 of gcode-m104 ok endof
		109 of gcode-m109 ok endof \ wait for temperature
		84 of off ok endof \ filament retract
		unimplemented throw
	endcase
;

: gcode
	decimal
	gkey
	begin
		eol? if exit then
		space? while
			gkey
	repeat
	case
		[char] G of gcode-g endof
		[char] M of gcode-m endof
		[char] ; of skipline endof
		unimplemented throw
	endcase
;

: ginterp
	begin
		gcode
	again
;

\ end of parser

hex

: e >r xpos @ ypos @ zpos @ r> move ;
: x ypos @ zpos @ epos @ move ;
: y >r xpos @ r> zpos @ epos @  move ;
: z >r xpos @ ypos @ r> epos @  move ;

