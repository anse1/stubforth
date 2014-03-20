
marker terminal

decimal
2variable fontdim
8 12 fontdim 2!
2variable cursor
0 0 cursor 2!

: cursor2pix ( x y -- x y )
	fontdim 2@ \ x y x y
	swap >r \ x y y r: x
	* swap r> * swap
;

hex
: hwcursor
	cursor 2@
	cursor2pix
	lcyp w!
	8000 or lcxp w!
;
decimal

: cursor! ( x y -- )
	cursor 2!
	hwcursor
;

: drawchar ( x y c -- )
	gchar \ x y fa
	>r \ x y r:fa
	pxaddr swap drop \ pa r:fa
	r> \ pa fa
	fontdim 2@ swap drop \ pa fa i
	begin
		?dup while
			>r \ pa fa r:i
			dup >r c@ \ pa fa@ r:i fa
			over \ pa fa@ pa r:i fa
			c! \ pa r:i fa
			xdim 8 / +  \ pa+ydim/8 r:i fa
			r> 1+  \ pa+ydim/8 fa+1 r:i 
			r> 1-  \ pa+ydim/8 fa+1 i-1
	repeat
	2drop
;

: cwrap ( -- )
	cursor 2@
	drop 1+
	fontdim 2@ drop
	*
	xdim > if
		cursor 2@
		1+ swap drop 0 swap
		cursor!
	then
;

: scroll ( -- )
	lssa @ dup xdim 8 /
	fontdim 2@ swap drop * dup >r +
	swap 4800 r> - move
	cursor 2@ 1- cursor!
;

: ywrap ( -- )
	cursor 2@ swap drop
	fontdim 2@ swap drop
	*
	ydim > if
		scroll
	then
;

: advance ( -- )
	cursor 2@ \ cx cy
	swap 1+ swap cursor!
	cwrap
	ywrap
	hwcursor
;

: putchar ( c -- )
	>r
	cursor 2@ cursor2pix
	r>
	drawchar
	advance
;

: puts ( s -- )
	dup
	begin \ s c*
		dup c@ \ s c* c
		?dup while
			putchar
			1+
	repeat
	drop
	drop"
;

: cls
	cls 0 0 cursor!
;

: crel ( x y -- )
	cursor 2@
	swap >r + swap r> + swap
	cursor!
;

hex

: vt100
	begin
		key case
			07 of 100 honk endof
			d of cursor 2@ swap drop 0 swap cursor! endof
			a of 0 1 crel endof
			c of cls endof
			r@ putchar
		endcase
	again
;

\ hardware cursor
8000 lcxp w!
0 lcyp w!
ff lblkc c!

080c lcwch w!

0 redirect !
