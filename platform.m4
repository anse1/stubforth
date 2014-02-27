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

static unsigned char gray[4] = { 0, 1, 3, 2 };
static unsigned char state;

primary(rotq, rot?)
{
     char new = ((P1IN >> 3)&3);
     if (new == gray[(gray[state]+1)&3])
          sp[0].i = -1;
     else if (new == gray[(gray[state]-1)&3])
          sp[0].i = 1;
     else
          sp[0].i = 0;
     sp++;
     state = new;
}


include(symbols.m4)
