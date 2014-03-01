/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

extern char _binary_builtin_4th_start[];
constant(builtin,, .s=_binary_builtin_4th_start)
secondary(boot2,boot,, BUILTIN, EVALUATE, HI, QUIT)

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

primary(emitq, key?)
  sp[0].i = (ring.in != ring.out);
  sp++;

constant(f_tick,tick,.a=(int *)&tick)
constant(forth_vectors,, &forth_vectors)

define(mmio4, `constant(translit($2,A-Z,a-z),, .i=0x$1)')

define(indirect, `
secondary(translit($2,A-Z,a-z),,,
	LIT, .i=0x$1, ADD)' )

include(symbols.m4)
