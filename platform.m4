/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

primary(keyq, key?)
   sp[0].i = (UCA0RXIFG & IFG2);
   sp++;


define(mmio1, `constant($2,, .a=0x$1)')
define(mmio2, `constant($2,, .a=0x$1)')
include(symbols.m4)
