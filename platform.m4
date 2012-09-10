/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

primary(mmul, m*)
{
  long long r = (long long)sp[-1].i * (long long)sp[-2].i;
  sp[-1].i = r >> 32;
  sp[-2].i = r;
}

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

primary(wstore, w!)
  *(short *)(void *)sp[-1].s = sp[-2].i;
  sp -= 2;

primary(wload, w@)
  sp[-1].i = *(short *)(void *)sp[-1].s;

primary(stop)
asm("stop #0x2000");

constant(redirect, &redirect)

dnl override boot

secondary(boot2, boot,,
   HI, LIT, .s="booting from block 0.\n", TYPE,
   LIT, .a=(void *)0x9f0000, REDIRECT, STORE, QUIT)
