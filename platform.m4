/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

dnl extern char _binary_builtin_4th_start[];
dnl constant(builtin,, .s=_binary_builtin_4th_start)
dnl secondary(boot2,boot,, BUILTIN, EVALUATE, HI, QUIT)

primary(xpsr)
{
  register int xpsr;
  asm ("mrs %0, xpsr": "=r" (xpsr)) ;
  sp[0].i = xpsr;
  sp++;
}

primary(wfi)
asm("wfi");

primary(wfe)
asm("wfe");

constant(f_tick,tick,.a=(int *)&tick)
