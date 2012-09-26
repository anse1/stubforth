
constant(putchar,, putchar)

dnl argn ... arg0 nargs func -- result
primary(call)
{
  cell (*fun)() = (--sp)->a;
  vmint nargs = (--sp)->i;
  cell result;

  if (nargs > 6)
    cthrow(-11, result out of range);

  result = fun(sp[-1], sp[-2], sp[-3], sp[-4], sp[-5], sp[-6]);

  while(nargs--)
    sp--;
  *sp++ = result;
}
