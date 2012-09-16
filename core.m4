primary(zlt, 0<)
sp[-1].i = sp[-1].i < 0 ;

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
