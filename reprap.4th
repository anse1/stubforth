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

\ current half-step (0..7)
variable xpos
variable ypos
variable zpos
variable epos

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

: xmove ( pos -- )
	begin
		dup xpos @
		= 0= while
		dup xpos @ > if
			1 xpos +!
		else
			-1 xpos +!
		then
		xc
		9 ms
    repeat drop ;

: ymove ( pos -- )
	begin
		dup ypos @
		= 0= while
		dup ypos @ > if
			1 ypos +!
		else
			-1 ypos +!
		then
		yc
		9 ms
    repeat drop ;

: zmove ( pos -- )
	begin
		dup zpos @
		= 0= while
		dup zpos @ > if
			1 zpos +!
		else
			-1 zpos +!
		then
		zc
		10 ms
    repeat drop ;

: emove ( pos -- )
	begin
		dup epos @
		<> while
		dup epos @ > if
			1 epos +!
		else
			-1 epos +!
		then
		ec
		7 ms
    repeat drop ;

: x+ 1 xpos +! xc ;
: y+ 1 ypos +! yc ;
: z+ 1 zpos +! zc ;

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
: leval ( b dx dy x -- y )
	* swap / + ;

\ print a linear function
: line. ( a -- )
	line@ ." line: dy=" . ." dx=" . ." b=" . lf ;

: lines. lf
	xline line.
	yline line.
	zline line.
	eline line. ;

\ multidimensional linear movement from x1 to x2  {x,y,z,e}line
: domove ( x2 x1 -- )
	2dup < if -1 else 1 then rot rot
	\ increment x2 x1 --
	begin
\		." domove loop: " .s lf
		2dup <> while
			2 pick + \ increment+1 x2 x1 -- 
			dup >r xline line@ r> leval xpos !
			dup >r yline line@ r> leval ypos !
			dup >r zline line@ r> leval zpos !
			dup >r eline line@ r> leval epos !
\			pos.
			xc yc zc ec
			10 ms
	repeat
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
