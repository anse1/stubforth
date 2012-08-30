
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

constant(redirect, &redirect)

dnl override boot

secondary(boot2, boot,,
   HI, LIT, .s="booting from block 0.\n", TYPE,
   LIT, .a=0x9f0000, REDIRECT, STORE, QUIT)
