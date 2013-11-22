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

: ec epos @ 7 swap - halfstep se ;
: zc zpos @ 7 swap - halfstep sz ;

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

: home
	begin
	xpos @ ypos @ zpos @ + +
	while
			xpos @ if -1 xpos +! xc then
			ypos @ if -1 ypos +! yc then
			zpos @ if -1 zpos +! zc then
			10 ms
	repeat
    0 epos ! ;

: x+ 1 xpos +! xc ;
: y+ 1 ypos +! yc ;
: z+ 1 zpos +! zc ;

: 2rel 
	ypos @ - swap xpos @ - swap ;

: 2abs 
	abs swap abs swap ;

: mkslave ( cpos spos dc ds -- b dc ds )
	2dup 2>r
	3 pick * swap / - swap drop
	2r>
;

: fx ( b dc ds x -- b dc ds y )
	
	
: 2move ( c-addr s-addr c-target b dc ds -- )
	>r >r >r
	\  c-addr s-addr c-target -- \ r: ds dc b
	2 pick @ over > if 1 else -1 then
	\  c-addr s-addr c-target increment -- \ r: ds dc b
	begin
		3 pick @ over 2 pick
		\  c-addr s-addr c-target increment c-pos c-target -- \ r: ds dc b
		<> while
			\  c-addr s-addr c-target increment -- \ r: ds dc b
			\  c-addr s-addr c-target increment increment -- \ r: ds dc b
			4 pick +!
			\  c-addr s-addr c-target increment -- \ r: ds dc b
			r> r> r> 2 pick 2 pick 2 pick >r >r >r
			\  c-addr s-addr c-target increment b dc ds -- \ r: ds dc b
			6 pick @ * / + 
			\  c-addr s-addr c-target increment new-s -- \ r: ds dc b
			
			\ c-addr s-addr c-target c-pos c-target
			> if 1 else -1 then
			\ c-addr s-addr c-target c-pos c-target incr
			
			
	repeat
	\ c-addr s-addr c-target c-pos c-target
	2drop 2drop drop
	r> r> r>
	2drop drop
;

: 2d ( x y -- two-dimensional tool move )
	2dup 2rel > if
		." x-constrained move" lf
		xpos @ ypos @ 2swap mkslave
		( x y b dc ds )
	else
		." y-constrained move" lf
		2rel swap ypos xpos 2swap
	then
	cmove
;
