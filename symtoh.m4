changecom(/*,*/)

define(mmio1, `#define $2 ((volatile unsigned char *)0x$1)')
define(mmio2, `#define $2 ((volatile unsigned short *)0x$1)')
define(mmio4, `#define $2 ((volatile unsigned int *)0x$1)')
define(const, `#define $2 0x$1')

include(symbols.m4)
