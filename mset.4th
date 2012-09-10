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

: zabs ( r i -- n )
dup 0 < if negate then swap
dup 0 < if negate then + ;

: c+ ( r i r i -- r i )
swap >r + swap r> + swap ;

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

3 fix ydim / zoom !
-1 fix 3 * 4 / roff !
0 fix ioff !
16 iterations !
save entire

60 iterations !
-39817688 roff !
-33292653 ioff !
3 fix ydim / 4600 / zoom !
save pretty

60 iterations !
-38306646 roff !
37746640 ioff !
3 fix ydim / 200 / zoom !
save spiral

-49353771 roff !
-15639236 ioff !
70 iterations !
3 fix ydim / 9000 / zoom !
save deep

3 fix ydim / 245 / zoom !
-75072314 roff !
20395872 ioff !
35 iterations !
save bolt

-55606285 roff !
14428028 ioff !
3 fix ydim / 2000 / zoom !
60 iterations !
save dragon

-50162660 roff !
-9096344 ioff !
3 fix ydim / 700 / zoom !
100 iterations !
save horses

27787769 roff !
14156046 ioff !
3 fix ydim / 600 / zoom !
100 iterations !
save antenna

-50013170 roff !
-7587480 ioff !
3 fix ydim / 9500 / zoom !
160 iterations !
save tail

-17343002 roff !
44280635 ioff !
3 fix ydim / 3000 / zoom !
100 iterations !
save spots
