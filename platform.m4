/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

primary(keyq, key?)
   sp[0].i = (UCA0RXIFG & IFG2);
   sp++;


define(mmio1, `constant(translit($2,A-Z,a-z),, .i=0x$1)')
define(mmio2, `constant(translit($2,A-Z,a-z),, .i=0x$1)')
include(symbols.m4)
