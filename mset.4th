
decimal
: fix 26 << ; : unfix 26 >> ;

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
2dup zabs max_abs @ > if 2drop 2drop r> exit then
r> 1+ dup >r max_iter @ > if 2drop 2drop r> drop 0 exit then
again ;

6 fix max_abs !

variable zoom
variable roff
variable ioff
1 fix ydim / zoom !

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

-79667952 roff !
20351413 ioff !

3 fix ydim / 150 / zoom !

0 ioff !
-109236968 roff !

mset

-39817688 roff !
-33292653 ioff !
3 fix ydim / 4600 / zoom !

mset

-38306646 roff !
37746640 ioff !
3 fix ydim / 200 / zoom !

mset
