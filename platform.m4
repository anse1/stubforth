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

secondary(on,,,
	LIT, .i=0x60, T1CCTL1, STORE,
	LIT, .i=0xe0, T1CCTL2, STORE)

secondary(off,,,
	ZERO, T1CCTL1, STORE,
	ZERO, T1CCTL2, STORE)

secondary(sq, `s?',,
	      P1IN, CLOAD, LIT, .i=0x20, AND, NULLP)

secondary(duty,,,
	OFF, DUP, T1CCR0, LOAD, SWAP, SUB, T1CCR1, STORE,
	T1CCR2, STORE, ON)

secondary(period,,,
	OFF, T1CCR0, STORE, ON,)

