
.( Loading reprap.4th...) lf


\ There are two design mistakes in here:
\
\ - The software uses the position of the fastest (constraining) axis
\   to compute the other axes' movements.  This made the computation
\   needlessly complicated when adding acceleration afterwards.
\
\ - The g-code interpreter besides the forth interpreter needs lots of
\   space.  Better translate g-code to forth on the host.

hex

\ display

0 led

\ the txcomplete interrupt handler does the multiplexing, we need to
\ send "something" to get it started.

0 ssidr ssi0 ! ;

\ : dpynum ( n -- )
\ 	0 >r
\ 	begin
\ 		?dup while
\ 			a /mod
\ 			swap
\ 			num2seg + c@
\ 			r> 100 * + >r
\ 	repeat
\ 	r> display !
\ ;

: dpystr ( str -- )
	dup
	begin
		dup c@ ?dup while
			[char] a - alpha2seg + c@
			18 <<
			display @ 8 >>
			+ display !
			1+
	repeat
	drop
	drop"
;

" helo" dpystr


\ stepper z
	
f gpiodr8r pd !
f gpioden pd !
f gpiodir pd !
: sz gpiodata pd f 2 << + ! ;

\ drv8825 upgrade

f gpiodr8r pb !
f gpioden pb !
f gpiodir pb !

: reset ( bool -- ) \ reset drv8825
   3 << gpiodata pb 8 2 << + !
;

f0 gpiodr8r pc !
f0 gpioden pc !
f0 gpiodir pc !

: ystep ( -- ) \ step drv8825 x
   [ 10 ] literal
   [ gpiodata pc 10 2 << + ] literal
   !
   0 + \ NOP, stubforth is too fast!
   [ 0 ] literal
   [ gpiodata pc 10 2 << + ] literal
   !
;

: ydir ( bool -- ) \ dir drv8825 x
   5 <<
   [ gpiodata pc 20 2 << + ] literal
   !
;

: xstep ( -- ) \ step drv8825 x
   [ 40 ] literal
   [ gpiodata pc 40 2 << + ] literal
   !
   0 + \ NOP, stubforth is too fast!
   [ 0 ] literal
   [ gpiodata pc 40 2 << + ] literal
   !
;

: xdir ( bool -- ) \ dir drv8825 x
   7 <<
   [ gpiodata pc 80 2 << + ] literal
   !
;

\ stepper e 
ff gpiodr8r pb !
ff gpioden pb !
ff gpiodir pb !
: se 4 << gpiodata pb f0 2 << + ! ;

\ display cathodes
f gpiodr8r pe !
f gpioden pe !
f gpiodir pe !
: sl gpiodata pe f 2 << + ! ;

\ current stepper positions in half-steps
variable xpos 0 xpos !
variable ypos 0 ypos !
variable zpos 0 zpos !
variable epos 0 epos !

\ bits for microstepping XY axes over EZ axes
3 constant xy-microstep

\ compute active coils of unipolar stepper for halfstep

variable halfstep_tab 1 cells allot
06020301 halfstep_tab !
09080c04 halfstep_tab 1 cells + !

: halfstep ( 0..7 -- 0..15 )
  	xy-microstep >>
	7 and
	halfstep_tab + c@
;

variable halfstepbi_tab 1 cells allot
06040501 halfstepbi_tab !
09080a02 halfstepbi_tab 1 cells + !

\ compute dual full bridge state for bipolar steppers
\ TODO: Rewire middle wires so it is identical to the former word.
: halfstepbi ( 0..7 -- 0..15 )
  	xy-microstep >>
	7 and
	halfstepbi_tab + c@
;

\ kludge to avoid touching too much code after drv8825 upgrade

variable prev_xpos 0 prev_xpos !
variable prev_ypos 0 prev_ypos !

: xc
  xpos @ prev_xpos @
  2dup = if 2drop exit then
  < xdir
  xstep
  xpos @ prev_xpos !
;

: yc
  ypos @ prev_ypos @
  2dup = if 2drop exit then
  < ydir
  ystep
  ypos @ prev_ypos !
;


: zc 7 zpos @ - halfstep sz ;
: ec 7 epos @ - halfstepbi se ;

: off \ motors off
  0 reset
  0 sz 0 se
;

: on \ motors on
   1 reset
   zc ec
;

: 2rel ypos @ - swap xpos @ - swap ;
: 2abs abs swap abs swap ;

: mkline ( x1 y1 x2 y2 -- b dx dy )
	2 pick		\ x1 y1 x2 y2 y1
	-		\ x1 y1 x2 y2-y1
	swap		\ x1 y1 y2-y1 x2
	3 pick		\ x1 y1 y2-y1 x2 x1
	-		\ x1 y1 y2-y1 x2-x1
	swap		\ x1 y1 x2-x1 y2-y1
	2dup 2>r	\ x1 y1 x2-x1 y2-y1 r: x2-x1 y2-y1
	3 roll		\ y1 x2-x1 y2-y1 x1 r: x2-x1 y2-y1
	*		\ y1 x2-x1 (y2-y1)*x1 r: x2-x1 y2-y1
	swap		\ y1 (y2-y1)*x1 x2-x1 r: x2-x1 y2-y1
	/		\ y1 (y2-y1)*x1/(x2-x1) r: x2-x1 y2-y1
	-		\ y1-(y2-y1)*x1/(x2-x1) r: x2-x1 y2-y1
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
	2dup - abs 1+ 1 >> \ x2 x1 abs(x2-x1)/2  r: x
	>r \ x2 x1  r: x abs(x2-x1)/2
	+ 1 >> \ µ  r: x dx/2
	r> swap \ dx µ r: x
	r> - abs \ dx/2 abs(µ-x)
	-
;

variable g-speed
variable xy-max
variable xy-accel
variable xy-jerk
variable z-jerk
variable xy-delay


decimal
1 xy-max ! \ xy maximum speed (100us/step)
0 g-speed ! \ user speed
48 xy-jerk !
21 z-jerk ! \ z jerk speed (100us/step)
6 xy-accel !
20 xy-delay \ delayed acceleration (steps)

: 25us 1000 syst_cvr ! 1000 syst_rvr ! 0 tick ! begin wfi dup tick @ < until drop ;

\ multidimensional linear movement from x1 to x2  {x,y,z,e}line
: domove ( x2 x1 -- )
	2dup < if -1 else 1 then rot rot
	\ inc x2 x1 --
	dup >r
	\ inc x2 i=x1 -- x1
        zline lconst? if
                begin 2dup <> while
			2 pick + \ increment x2 x1+inc -- 
			xline over leval xpos !
			yline over leval ypos !
			eline over leval epos !
			xc yc ec
			2dup r@ swap
			ramp
			xy-delay @ -
			dup 0< if
				drop 0
			then
			xy-accel @ << sqrt
			xy-jerk @ swap -
			xy-max @ g-speed @ max
			max
			?dup if 25us then
		repeat
	    else
		begin 2dup <> while
			2 pick + \ increment x2 x1+inc -- 
			xline over leval xpos !
			yline over leval ypos !
			zline over leval zpos !
			eline over leval epos !
			xc yc zc ec
			z-jerk @ 25us
		repeat
            then
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

: t >r xpos @ ypos @ zpos @ r> move ;
: x ypos @ zpos @ epos @ move ;
: y >r xpos @ r> zpos @ epos @  move ;
: z >r xpos @ ypos @ r> epos @  move ;

: jtest begin
		dup x dup negate x
		dup x dup negate x
		dup x dup negate x 1-
		?dup while
	repeat ;

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
variable t_ist

: t_hotend ( -- )
	adcaccu @ [ hex ] 319 adcount @ * -
	negate
	[ decimal ] 806 1000 */ \ mV
	10 17 */ \ dK
	adcount @ 10 / /
	200 + \ °C
	t_ist !
;

hex
variable t_soll 8c t_soll !


1 5 << rcgcwtimer +! \ clock gate for wtimer5
7 7 4 * << gpiopctl pd +! \ PD7 AF: wt5ccp1
1 7 << gpioafsel pd +! \ enable AF for PD7

\ 1. Ensure the timer is disabled (the TnEN bit is cleared) before
\ making any changes.

0 tmctl widetimer5 ! \ clear TBEN

\ 2. Write the GPTM Configuration (GPTMCFG) register with a value of
\ 0x0000.0004.

4 tmcfg widetimer5 !

\ 3. In the GPTM Timer Mode (GPTMTnMR) register, set the TnAMS bit to
\ 0x1, the TnCMR bit to 0x0, and the TnMR field to 0x2.

1 3 << ( tbams ) 1 2 << ( tbcmr ) or 2 ( tbmr ) or
tmtbmr widetimer5 !

\ 4. Configure the output state of the PWM signal (whether or not it
\ is inverted) in the TnPWML field of the GPTM Control (GPTMCTL)
\ register.

1 0e << tmctl widetimer5 !

\ 5. If a prescaler is to be used, write the prescale value to the
\ GPTM Timer n Prescale Register (GPTMTnPR).

0 tmtbpr widetimer5 !

\ 6. If PWM interrupts are used, configure the interrupt condition in
\ the TnEVENT field in the GPTMCTL register and enable the interrupts
\ by setting the TnPWMIE bit in the GPTMTnMR register. Note that edge
\ detect interrupt behavior is reversed when the PWM output is
\ inverted (see page 690).

\ 7. Load the timer start value into the GPTM Timer n Interval Load
\ (GPTMTnILR) register.

2000000 tmtbilr widetimer5 !

\ 8. Load the GPTM Timer n Match (GPTMTnMATCHR) register with the
\ match value.

200000 tmtbmatchr widetimer5 !

\ 9. Set the TnEN bit in the GPTM Control (GPTMCTL) register to enable
\ the timer and begin generation of the output PWM signal.

1 8 << tmctl widetimer5 +! \ set TBEN

\ In PWM Timing mode, the timer continues running after the PWM signal
\ has been generated. The PWM period can be adjusted at any time by
\ writing the GPTMTnILR register, and the change takes effect at the
\ next cycle after the write.

\ tmtbr widetimer5 ?
\ 10 tmtbv widetimer5 !
\ tmtbv widetimer5 ?

decimal 900 t_soll !

hex

variable pid_p
variable pid_i
variable pid_d
variable pid_i_min
variable pid_i_max
variable pid_droop

variable pid_err_accu
variable pid_err_last
variable pid_err_diff
variable pid_i_decay

0 pid_i !	 
68000 pid_p !
-c0000 pid_d !
0 pid_err_accu !
18 pid_droop !
64 pid_i_decay !

: pid_sample ( -- )
	t_soll @ t_ist @ -
	dup pid_err_accu @ pid_i_decay @ 64 */ + pid_err_accu !
	pid_p @ * \ P
	t_ist @ pid_err_last @ -
	dup pid_err_diff !
	pid_d @ * \ D
	pid_err_accu @ pid_i @ * \ I
	+ +
	dup	tmtbilr widetimer5 @ 1- > if
		drop tmtbilr widetimer5 @ 1-
	then
	dup 0 < if
		drop 0
	then
	tmtbmatchr widetimer5 !
	t_ist @ pid_err_last !
;

: t_loop
	t_hotend
	t_ist @ 0 < if
		." hotend sensor fault!" lf
		," fail" dpystr
		0 tmtbmatchr widetimer5 !
		exit
	then
	t_ist @
	dpynum
	pid_sample
;

: adcint
	1 adcount +!
	8 adcisc adc0 !
	adcssfifo3 adc0 @ adcaccu +!
	1000 adcount @ < if
		t_loop
		0 adcount !
		0 adcaccu !
	then
;

' adcint forth-vectors 21 cells + !

11 ise!

: .temp
		decimal
		." hotend=" t_ist @ .
		." soll=" t_soll @ .
		." pid_err_accu=" pid_err_accu @ . 
		." pid_err_diff=" pid_err_diff @ . 
	hex ." matchr=" tmtbmatchr widetimer5 @ . lf
;
	
: demo
	begin
		.temp
		700 ms
	again
;

\ gcode parser

decimal

\               steps       µm
2variable xcal  4000    79895  xcal 2!
2variable ycal  4000    79895  ycal 2!
2variable zcal   1600      1227  zcal 2!
\ 2variable ecal  4096     44521  ecal 2!
\ 2variable ecal  2000     22000  ecal 2! \ free air, 195°C
2variable ecal 8192 10225 ecal 2! \ new tapped bold

variable g-xpos
variable g-ypos
variable g-zpos
variable g-epos
variable g-fpos  \ feedrate
variable g-relative-p

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
	25000 swap / g-speed !
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
 		[char] * of 1 endof
		0
	endcase
;

: space? ( -- bool )
	lastkey @ 32 =
;

: word? ( -- bool )
	lastkey @ dup 32 >
	swap [char] * <> and
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
  	lastkey @ 10 = if exit then
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
		[char] X of
		    gcode-num g-xpos
		    g-relative-p @ if +! else ! then
		endof
		[char] Y of
		     gcode-num g-ypos
                     g-relative-p @ if +! else ! then
		endof
		[char] Z of
 		     gcode-num g-zpos
                     g-relative-p @ if +! else ! then
                endof
		[char] E of
                     gcode-num g-epos
                     g-relative-p @ if +! else ! then
                endof
		[char] F of gcode-num
			\ unit is mm/minute, using mm/s internally
			60 / g-fpos !
                endof
		[char] ; of skipline endof
		[char] * of skipline endof
		syntax throw
	endcase
;

: ok 
  skipline
  ." ok " .s 
;

: gcode-g1 \ controlled move
	begin
	   gcode-collect-pos
	eol? until
	ok
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

: gcode-g
	on
	gword number
	case
		0 of gcode-g1 endof \ rapid linear move
		1 of gcode-g1 endof \ linear move
		92 of gcode-g92 ok endof \ set position
		90 of 0 g-relative-p ! ok endof \ set absolute positioning
		91 of 1 g-relative-p ! ok endof \ set absolute positioning
		21 of ok endof \ set units to mm
		28 of gcode-g28 ok endof \ move to origin
		unimplemented throw
	endcase
;

: gcode-m104
	key [char] S = if
		gcode-num 100 / pid_droop @ + t_soll !
	else
		syntax throw
	then
;

decimal

: gcode-m105
       base @ decimal
       ." ok T:" t_ist @  10 / . lf
       base !
;

: gcode-m109
	gcode-m104
	begin
		t_ist @ t_soll @ pid_droop @ - <
		.temp
		750 ms
		sw1? 0= and
	while
	repeat
;

: gcode-m114
       base @ decimal
       ." ok X:" g-xpos @ 1000 / .
       ." Y:" g-ypos @ 1000 / .
       ." Z:" g-zpos @ 1000 / .
       ." E:" g-epos @ 1000 / .
       base !
       lf
;

: gcode-m226
	begin
		sw1? 0= while
	repeat
;
	
: gcode-m
	gword number
	case
		82 of ok endof
		113 of skipline ok endof
		108 of skipline ok endof
		107 of ok endof \ fan off
		106 of skipline ok endof \ fan on
		105 of gcode-m105 endof \ temperature reading
		104 of gcode-m104 ok endof
		109 of gcode-m109 ok endof \ wait for temperature
		110 of skipline ok endof \ get current position
		114 of gcode-m114 ok endof \ get current position
		140 of skipline ok endof \ bed temperature
		226 of gcode-m226 ok endof \ user pause
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
		[char] N of gword number drop recurse endof
		unimplemented throw
	endcase
	skipline
;

: ginterp
	begin
		gcode
	again
;

: GCODE ginterp ; \ pronterface capitalizes everything

\ end of parser

\ Make the forth interpreter understand g-code directly

\ comments
: ; state if postpone ; else postpone \ then ;

