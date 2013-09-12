primary(pick)
  sp[-1] = sp[-2 - sp[-1].i];

dnl ( a -- )
secondary(again,, .immediate=1, LIT, BRANCH, COMMA, COMMA)

dnl -- 0
secondary(case,, .immediate=1,
 ZERO, LIT, RTO, COMMA)

dnl n -- ofpad n+1
secondary(of,, .immediate=1, l(
 PLUS1
 LIT RLOAD COMMA LIT EQ COMMA
 IF  SWAP
))

dnl ofpad n -- endofpad n
secondary(endof,, .immediate=1, l(
 RTO ELSE  RFROM
))

dnl pad1 ... padn n --
secondary(endcase,, .immediate=1, l(
 QDUP ZBRANCH self[8]
  MINUS1 SWAP
  THEN
 BRANCH self[0]
 LIT RFROM COMMA LIT DROP COMMA
))

dnl -- pad xt
secondary(try,, .immediate=1, l(
  AHEAD HERE
  LIT &&enter COMMA
))

dnl pad xt -- pad
secondary(catchfrom, catch>, .immediate=1, l(
  LIT EXIT COMMA
  SWAP THEN
  LITERAL
  LIT CATCH COMMA
  LIT QDUP COMMA
  IF))

dnl pad --
secondary(endtry,,.immediate=1, l(
  THEN EXIT
))

primary(dotparen, `.(', immediate)
while ((t.i = my_getchar()) != ')')
  putchar(t.i);

dnl ( 1 2 -- 2 1 2 )
primary(tuck)
sp[0] = sp[-1];
sp[-1] = sp[-2];
sp[-2] = sp[0];
sp++;

dnl ( 1 2 -- 2 )
primary(nip)
sp[-2] = sp[-1];
sp--;

primary(celladd, cell+)
sp[-1].aa++;

primary(zne, 0<>)
sp[-1].i = sp[-1].i != 0 ;

primary(ne, <>)
sp[-1].i = sp[-1].i != sp[-2].i ;
sp--;

primary(zgt, 0>)
sp[-1].i = sp[-1].i > 0 ;

primary(twotor, 2>r)
*rp++ = *--sp;
*rp++ = *--sp;

primary(tworto, 2r>)
*sp++ = *--rp;
*sp++ = *--rp;

primary(tworload, 2r@)
*sp++ = rp[-2];
*sp++ = rp[-1];

primary(within)
{
  uvmint u1 = sp[-3].u;
  uvmint u2 = sp[-2].u;
  uvmint u3 = sp[-1].u;

  sp[-3].u =  (u1-u2) < (u3-u2);
  sp-=2;
}

ubinop(ugt, >, u>)

constant(true,,.i=-1)
constant(false,,.i=0)

primary(backslash, `\\', immediate)
while((t.i = my_getchar()) != '\n') {
  if (t.i < 0) cthrow(-39, unexpected end of file);
}

secondary(marker,,, l(
 CONTEXT LOAD DP LOAD
 BUILDS COMMA COMMA
 DOES DUP LOAD DP STORE CELL ADD
 LOAD CONTEXT STORE))

static void *pad;
primary(pad)
if (!pad)
   pad = __builtin_alloca(1024);
sp[0].a = pad;
sp++;
