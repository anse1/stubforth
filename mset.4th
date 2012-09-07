variable radius
variable iterations
variable zoom
variable roff
variable ioff

decimal
: fix 26 << ; : unfix 26 >> ;

4 fix radius !

: fix* m* 6 << swap 26 >> 1 6 << 1 - and or ;
: fixsq dup fix* ;

: csq ( r i -- r i )
over fixsq over fixsq - >r
fix* 1 << r> swap ;

: zn ( cr ci zr zi )
csq 2over c+ ;

: divp ( cr ci -- n)
0 >r 0 0 begin
zn
2dup zabs radius @ > if 2drop 2drop r> exit then
r> 1+ dup >r iterations @ > if 2drop 2drop r> drop 0 exit then
again ;

: mset
xdim 1- begin
." ."
ydim 1- begin
2dup
ydim 1 >> - zoom @ * roff @ +
swap xdim 1 >> - zoom @ * ioff @ +
divp
0= if 2dup setp then
1- dup 0= until drop
1- dup 0= until drop
;

: cell+ cell + ;
: @+dup cell+ dup @ ;

: save <builds
   lssa @ , radius @ , iterations @ , 
   zoom @ , ioff @ , roff @ ,
does> dup @ lssa ! @+dup radius ! @+dup iterations !
      @+dup zoom ! @+dup ioff ! @+dup roff ! ;

: new here lssa ! 4800 allot cls ;

\ entire
\ 3 fix ydim / zoom !
\ -1 fix 3 * 4 / roff !
\ 0 fix ioff !
\ 16 iterations !

\ 
\ pretty
\ 60 iterations !
\ -39817688 roff !
\ -33292653 ioff !
\ 3 fix ydim / 4600 / zoom !
\  
\ spiral
\ 60 iterations !
\ -38306646 roff !
\ 37746640 ioff !
\ 3 fix ydim / 200 / zoom !
\
\ underflows :-/
\ -49353771 roff !
\ -15639236 ioff !
\ 70 iterations !
\ 3 fix ydim / 10000 / zoom !

\ [-1.118664654, 0.303922178]

\ bolt
\ 3 fix ydim / 245 / zoom !
\ -75072314 roff !
\ 20395872 ioff !
\ 35 iterations !
