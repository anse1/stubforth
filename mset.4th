variable iterations
variable zoom
variable roff
variable ioff

decimal
: fix 26 << ; : unfix 26 >> ;

4 fix constant radius

: fix* m* 6 << swap 26 >>
	[ 1 6 << 1 - ] literal \ undo sign extension
	and or ;

: csq ( r i -- r i )
over dup fix* over dup fix* - >r
fix* 2* r> swap ;

: zabs ( r i -- n )
abs swap abs + ;

: c+ ( r i r i -- r i )
swap >r + swap r> + swap ;

: zn ( cr ci zr zi )
csq 2over c+ ;

: divp ( cr ci -- n)
iterations @ >r 0 0 begin
zn
2dup zabs radius > if 2drop 2drop r> exit then
r> 1- dup >r 0= if 2drop 2drop r> drop 0 exit then
again ;

\ x y -- r i
: screen2set
	ydim 2/ - zoom @ * roff @ +
	swap xdim 2/ - zoom @ * ioff @ +
;	

: mset
	xdim begin 1-
\		[char] . emit
		ydim begin 1-
			2dup
			screen2set
			divp
			0= if
				2dup setp
			else
				2dup clp
			then
		dup 0= until drop
	dup 0= until drop
;

\ iterations roff ioff zoom --
: fractal <builds , , , ,
does>
 dup @ 3 fix swap / ydim / zoom ! cell +
 dup @ ioff ! cell +
 dup @ roff ! cell +
 dup @ iterations ! cell +
drop ; 

: save <builds
   lssa @ ,
does> @ lssa ! ;

: new here lssa ! 4800 allot cls ;

16 -1 fix 0 fix 1
fractal entire

60 -39817688 -33292653 4600
fractal pretty

60 -38306646 37746640 200
fractal spiral

70 -49353771 -15639236 9000
fractal deep

35 -75072314 20395872 245
fractal bolt

60 -55606285 14428028 2000
fractal dragon

100 -50162660 -9096344 700
fractal horses

100 27787769 14156046 600
fractal antenna

160 -50013170 -7587480 9500
fractal tail

100 -17343002 44280635 3000
fractal spots

64 10695398 42580524 100
fractal shallow

(
	
new entire mset save entirefb
new pretty mset save prettyfb
new spiral mset save spiralfb
new deep mset save deepfb
new bolt mset save boltfb
new dragon mset save dragonfb
new horses mset save horsesfb
new antenna mset save antennafb
new tail mset save tailfb
new spots mset save spotsfb

)

\ copied from gforth's bench directory
variable seed
: initiate-seed ( -- )  rtctime @ seed ! ;
: random  ( -- n )  seed @ 1309 * 13849 + 65535 and dup seed ! ;

initiate-seed

\ find random edge
: edge
	random xdim 2 - mod 1+
	random ydim 2 - mod 1+
	2dup
	pxaddr c@ and
	0=
	>r
	2dup
	random 3 mod 1- +
	swap
	random 3 mod 1- +
	swap
	pxaddr c@ and
	0=
	r> = if 2drop restart then
	\ edge detected
	.cords
;

\ draw a cross with center at x y --
: cross
	xdim
	begin
		?dup while
			1-
			over over swap pxaddr set
	repeat
	drop
	ydim
	begin
		?dup while
			1-
			over over pxaddr set
	repeat
	drop
;

\ zoom by 10 into x y --
: dozoom
	screen2set
	.cords
	ioff ! roff !
	zoom @ 10 / zoom !
	16 iterations +!
;

variable iset
: init
	new
	entire
	mset
	lssa @ iset !
	new
	iset @ lssa @ 4800 move
;

: demo
	entire
	iset @ lssa @ 4800 move
	begin
		edge 2dup cross dozoom
		zoom @ 0= if restart then
		mset
	again
;
