
primary(srload, sr@)
{
  short sr;
  asm("move.w %%sr , %0" : "=r" (sr) );
  (sp++)->i = sr;
}

primary(srstore, sr!)
{
  short sr;
  sr = (--sp)->i;
  asm("move.w  %0, %%sr" : /* no outputs */ : "r" (sr));
}

primary(stop)
asm("stop #0x2000");

primary(redirect)
  redirect = (--sp)->s;

