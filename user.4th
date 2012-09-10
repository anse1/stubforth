\ non-platform-specific forth code

hex

: fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;
: tuck swap over ;
: gcd dup if tuck mod recurse else drop then ;

: strlen ( s -- n )
dup
begin dup c@ while 1+ repeat
swap - ;

: fstrlen ( s -- n )
dup
begin dup c@ 1 negate = 0= while 1+ repeat
swap - ;

: forget ( read a word to forget, adjusts dp )
 word find 0= if abort then
 >word dup  >link @ context ! >name @ dp ! ;

: dump ( addr n -- )
over + swap
( endaddr addr )
begin
dup c@ emit
1 + 2dup <
until
lf ;

\ bit flipping

: flip ( c a -- ) 
  swap over c@ xor swap c! ;
: set ( c a -- )
  swap over c@ or swap c! ;
: clear ( c a -- )
  swap over c@ swap ~ and swap c! ;

hex

: ehex
  dup 4 >> f and hexchars + c@ emit
  f and hexchars + c@ emit ;

: bl 20 emit ;

: dumpaddr ( addr n -- )
over cell begin 1-
2dup 8 * >> ff and ehex
dup 0= until
2drop ." : " ;

: dump8 ( addr n )
8 begin
2dup 0= 0= swap 0= 0= and while
2 pick c@ ehex bl
rot 1+ rot 1- rot 1-
repeat drop ;

: dump ( addr n -- )
begin dup while
dumpaddr dump8
dup 0= if exit then
."  " dump8 ." 
" repeat ." 
" ;

word hexchars find drop @ constant xtdocon
word hi find drop @ constant xtenter

: buildsnothing <builds does> ;
buildsnothing doesnothing
word doesnothing find drop @
forget doesnothing
constant xtdodoes

variable somevar
word somevar find drop @
forget somevar
constant xtdovar

\ xt &word -- \ throws 1 if found
: xtp1 begin 2dup >code = if 1 throw then >link @ dup 0= until ;

\ xt -- t/f \ check if xt is in the dictionary
: xtp context @ ' xtp1 catch if 2drop 1 else 2drop 0 then ;

: xttype >word >name @ type bl ;
: vlist begin dup >code xttype lf >link @ dup 0= until ;

\ addr -- \ disassemble thread

\ check for end of thread
: eotp \ &cfa -- &cfa t/f
dup @ ' exit =
over cell - @ ' lit =
2 pick cell + @ xtp
or 0= and ;

\ pretty print a cell value
: .pretty ( cell -- )
  dup xtp if
    xttype
  else
    case
      xtenter of ." &&enter" endof
      xtdocon of ." &&docon" endof
      xtdodoes of ." &&dodoes" endof
      xtdovar of ." &&dovar" endof
      ." .i = " r .
    endcase
  then
;

: ,key ' lit , key , ; immediate

: disas
  begin dup . dup @ .pretty lf eotp 0= while
  dup @ ' dostr = if
    cell +
    dup .
    ,key " emit
    dup type
    ,key " emit
    lf
    dup strlen + 1+ aligned
  else
    cell +
  then
repeat drop ;

: see
  word find 0= if -13 throw then
  ." .code: " dup @ .pretty lf
  ." .data: "
  dup cell +
  over @ case
    xtenter of lf disas endof
    xtdocon of @ .pretty lf endof
    xtdovar of @ .pretty lf endof
    xtdodoes of ." does>" lf @ disas endof
    drop lf
  endcase
  drop
; 

\ inline catching of exceptions


: try ( -- a xt )
  [ ' ahead , ] here xtenter , ; immediate

: catch> ( a xt -- a )
 ' exit , swap [ ' then , ]
 ' lit , , ' catch , ' ?dup , [ ' if , ] ; immediate

: endtry [ ' then , ] ; immediate
