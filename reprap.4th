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
: halfstep ( 0..7 -- 0..16 )
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

: xc xpos @ halfstep sx ;
: yc ypos @ halfstep sy ;
: zc zpos @ 7 swap - halfstep sz ;
: ec epos @ 7 swap - halfstep se ;

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
				2 /
				11 swap -
				5 max ms
			else
				11 ms
			then
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

\ gcode parser

decimal

: xpos2um ( halfsteps -- um ) 164000 * 2048 / ;
: ypos2um ( halfsteps -- um ) 164000 * 2048 / ;
: zpos2um ( halfsteps -- um ) 1250 * 200 / ;
: epos2um ( halfsteps -- um ) 160000 * 14336 / ;

: um2xpos ( um -- halfsteps ) 2048 * 164000 / ;
: um2ypos ( um -- halfsteps ) 2048 * 164000 / ;
: um2zpos ( um -- halfsteps ) 200 * 1250 / ;
: um2epos ( um -- halfsteps ) 14336 * 160000 / ;

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

: gmove
	g-xpos @ um2xpos
	g-ypos @ um2ypos
	g-zpos @ um2zpos
	g-epos @ um2epos
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
	xpos @ xpos2um g-xpos !
	ypos @ ypos2um g-ypos !
	zpos @ zpos2um g-zpos !
	epos @ epos2um g-epos !
;	

: gcode-collect-pos
	gkey
	eol? if exit then
	case
		[char] X of gcode-num g-xpos ! endof
		[char] Y of gcode-num g-ypos ! endof
		[char] Z of gcode-num g-zpos ! endof
		[char] E of gcode-num g-epos ! endof
		[char] F of gcode-num g-fpos ! endof
		[char] ; of skipline endof
		syntax throw
	endcase
;
			
: gcode-g1 \ controlled move
	begin
		gcode-collect-pos
	eol? until
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
	g-xpos @ um2xpos xpos !
	g-ypos @ um2ypos ypos !
	g-zpos @ um2zpos zpos !
	g-epos @ um2epos epos !
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
		104 of skipline ok endof \ set temperature
		109 of skipline ok endof \ wait for temperature
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
