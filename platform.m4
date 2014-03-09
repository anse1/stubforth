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

primary(us)
{
    TA0R = 0;
    sp--;
    sp->u *= 2;
    while ((uvmint)TA0R < sp->u)
        ;
}

secondary(ms,,,
	QDUP, ZBRANCH, self[9], MINUS1, LIT, .u=800, US, BRANCH, self[0])

dnl static unsigned char gray[4] = { 0, 1, 3, 2 };
dnl static unsigned char state;
dnl 
dnl primary(rotq, rot?)
dnl {
dnl      char new = ((P1IN >> 3)&3);
dnl      if (new == gray[(gray[state]+1)&3])
dnl           sp[0].i = -1;
dnl      else if (new == gray[(gray[state]-1)&3])
dnl           sp[0].i = 1;
dnl      else
dnl           sp[0].i = 0;
dnl      sp++;
dnl      state = new;
dnl }
dnl 
dnl 
dnl secondary(on,,,
dnl 	LIT, .i=0x60, T1CCTL1, STORE,
dnl 	LIT, .i=0xe0, T1CCTL2, STORE)
dnl 
dnl secondary(off,,,
dnl 	ZERO, T1CCTL1, STORE,
dnl 	ZERO, T1CCTL2, STORE)
dnl 
dnl secondary(sq, `s?',,
dnl 	      P1IN, CLOAD, LIT, .i=0x20, AND, NULLP)
dnl 
dnl secondary(duty,,,
dnl 	OFF, DUP, T1CCR0, LOAD, SWAP, SUB, T1CCR1, STORE,
dnl 	T1CCR2, STORE, ON)
dnl 
dnl secondary(period,,,
dnl 	OFF, T1CCR0, STORE, ON)
dnl 
