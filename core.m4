dnl start consing a dodoes word
secondary(builds, <builds,,
  WORD, CONS, LIT, &&dodoes, COMMA, ZERO, COMMA, SMUDGE, SUSPEND)

dnl set the dodoes address to the thread following does>
secondary(does, does>,, RFROM, CONTEXT, LOAD, TOCODE, TOBODY, STORE)

primary(zlt, 0<)
sp[-1].i = sp[-1].i < 0 ;

define(ubinop, `
primary(`$1', ifelse(`$3',`',`$2',`$3'))
    t = *--sp;
    sp[-1].u = sp[-1].u $2 t.u;
')

ubinop(ult, <, u<)

primary(twomul, 2*)
sp[-1].i <<= 1;

primary(twodiv, 2/)
sp[-1].i >>= 1;

primary(twostore, 2!)
{
  cell *p = sp[-1].a;
  *p++ = sp[-2];
  *p++ = sp[-3];
  sp -= 3;
}

primary(twoload, 2@)
{
  cell *p = sp[-1].a;
  sp[-1] = *p++;
  *sp++ = *p++;
}

primary(twodup, 2dup)
  sp[0] = sp[-2];
  sp[1] = sp[-1];
  sp += 2;

primary(twodrop, 2drop)
  sp -= 2;

primary(twoover, 2over)
  sp[0] = sp[-4];
  sp[1] = sp[-3];
  sp += 2;

primary(twoswap, 2swap)
  t = sp[-1];
  sp[-1] = sp[-3];
  sp[-3] = t;
  t = sp[-2];
  sp[-2] = sp[-4];
  sp[-4] = t;

primary(abs)
  if (sp[-1].i < 0)
     sp[-1].i = -sp[-1].i;

secondary(evaluate,,, l(
 REDIRECT LOAD RTO
 REDIRECT STORE
 LIT QUIT CATCH
 QDUP
 ZBRANCH self[12]
 THROW
 RFROM REDIRECT STORE
))

secondary(ichar, [char], .immediate=1, l(
 KEY LITERAL EXIT
))
