\ non-platform-specific forth code

: forget ( read a word to forget, adjusts dp )
	?word >word dup >link @ context ! >name @ dp ! ;

\ bit flipping

: flip ( c a -- ) 
  tuck c@ xor swap c! ;
: set ( c a -- )
  tuck c@ or swap c! ;
: clear ( c a -- )
  tuck c@ swap ~ and swap c! ;

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
bl dump8 lf repeat lf ;

: dumpraw ( addr n -- )
over + swap
begin
dup c@ emit
1 + 2dup <
until
lf ;

decimal

?word hexchars @ constant &&docon
?word hi @ constant &&enter

: buildsnothing <builds does> ;
buildsnothing doesnothing
?word doesnothing @
forget buildsnothing
constant &&dodoes

variable somevar
?word somevar @
forget somevar
constant &&dovar

\ xt &word -- \ throws 1 if found
: xtp1 begin 2dup >code = if 1 throw then >link @ dup 0= until ;

\ xt -- t/f \ check if xt is in the dictionary
: xtp context @ ['] xtp1 catch if 2drop 1 else 2drop 0 then ;

: xttype >word >name @ type bl ;
: words context @ begin dup >code xttype lf >link @ dup 0= until ;

\ addr -- \ disassemble thread

\ check for end of thread
: eotp \ &cfa -- &cfa t/f
dup @ ['] exit =
over cell - @ ['] lit =
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
      ." .i = " r@ .
    endcase
  then
;

: [char] key postpone literal ; immediate

: disas
  begin dup . dup @ .pretty lf eotp 0= while
  dup @ ['] dostr = if
    cell +
    dup .
    [char] " emit
    dup type
    [char] " emit
    lf
    dup strlen + 1+ aligned
  else
    cell +
  then
repeat drop ;

: see
  ?word
  ." .code: " dup @ .pretty lf
  ." .immediate: " dup immediatep . lf
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

: skip[if] ( -- )
 begin
   word
   dup ," [if]" compare 0= if
     drop" recurse 1
   else
     dup ," [then]" compare swap drop"
   then
   while
 repeat
;

\ read and discard till [then] or [else] is read, skipif on [if]
\ leaves t/f on stack when then/else was read
: skip[block] ( -- t/f )
 begin
   word
   dup ," [if]" compare 0= if
     drop" skip[if]
   else
     dup ," [then]" compare 0= if drop" 1 exit then
     dup ," [else]" compare 0= if drop" 0 exit then
     drop"
   then
again ;

" dangling else" constant err[else]
" dangling then" constant err[then]

: [else] err[else] throw ; immediate
: [then] err[then] throw ; immediate

: [if]
  0= if skip[block] if exit then then
  try
    begin
      word
      interpret
    again
  catch>
    case
      err[else] of skip[if] endof
      err[then] of endof
      r@ throw
    endcase
  endtry
; immediate

: restart
	postpone branch
	context @ >code >body ,
; immediate

: octal 8 base c! ;
: binary 2 base c! ;

: x
	redirect @
	," " redirect ! ['] quit catch
	swap redirect ! ;
x
forget x
constant erreof

: evaluate ( s -- )
	redirect @ >r
	redirect !
	['] quit catch
	dup erreof = 0= if throw then
	r> redirect !
;
