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

: dumpraw ( addr n -- )
over + swap
( endaddr addr )
begin
dup c@ emit
1 + 2dup <
until
lf ;

decimal

word hexchars find drop @ constant &&docon
word hi find drop @ constant &&enter

: buildsnothing <builds does> ;
buildsnothing doesnothing
word doesnothing find drop @
forget buildsnothing
constant &&dodoes

variable somevar
word somevar find drop @
forget somevar
constant &&dovar

\ xt &word -- \ throws 1 if found
: xtp1 begin 2dup >code = if 1 throw then >link @ dup 0= until ;

\ xt -- t/f \ check if xt is in the dictionary
: xtp context @ ' xtp1 catch if 2drop 1 else 2drop 0 then ;

: xttype >word >name @ type bl ;
: words context @ begin dup >code xttype lf >link @ dup 0= until ;

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
      &&enter of ." &&enter" endof
      &&docon of ." &&docon" endof
      &&dodoes of ." &&dodoes" endof
      &&dovar of ." &&dovar" endof
      ." .i = " r .
    endcase
  then
;

: ,key ' lit , key , ; immediate

: disas
begin dup . dup @ .pretty lf
  eotp 0= while
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
    &&enter of lf disas endof
    &&docon of @ .pretty lf endof
    &&dovar of @ .pretty lf endof
    &&dodoes of ." does>" lf @ disas endof
    drop lf
  endcase
  drop
; 

\ inline catching of exceptions

: try ( -- pad xt )
  postpone ahead here &&enter , ; immediate

: catch> ( pad xt -- pad )
  postpone exit swap postpone then
  postpone lit , postpone catch postpone ?dup  postpone if ; immediate

: endtry ( pad -- ) postpone then ; immediate

\ read and discard till [then] is read, recurse on [if]
: skip[if] ( -- )
 begin
   word
   dup s" [if]" compare 0= if
     drop" recurse 1
   else
     dup s" [then]" compare swap drop"
   then
   while
 repeat
;

\ read and discard till [then] or [else] is read, skipif on [if]
\ leaves t/f on stack when then/else was read
: skip[block] ( -- t/f )
 begin
   word
   dup s" [if]" compare 0= if
     drop" skip[if]
   else
     dup s" [then]" compare 0= if drop" 1 exit then
     dup s" [else]" compare 0= if drop" 0 exit then
     drop"
   then
again ;


: [else] -512 throw ; immediate
: [then] -513 throw ; immediate

: [if]
  0= if skip[block] if exit then then
  try
    begin
      word
      interpret
    again
  catch>
    case
      -512 of skip[if] endof
      -513 of endof
      r throw
    endcase
  endtry
; immediate
