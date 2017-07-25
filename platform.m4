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

primary(cpsie)
asm("cpsie i");

primary(cpsid)
asm("cpsid i");

primary(emitq, key?)
  sp[0].i = (ring.in != ring.out);
  sp++;

constant(f_tick,tick,.a=(int *)&tick)
constant(forth_vectors,, &forth_vectors)

define(mmio4, `constant(translit($2,A-Z,a-z),translit($2,A-Z,a-z), .i=0x$1)')

define(indirect, `secondary(translit($2,A-Z,a-z),translit($2,A-Z,a-z),, LIT, .i=0x$1, ADD)' )

constant(display,, .s=dpybuf)
constant(dpystate,, .a=&dpystate)

include(symbols.m4)

#define SEGA 0
#define SEGB 3
#define SEGC 1
#define SEGD 6
#define SEGE 4
#define SEGF 2
#define SEGG 5

static const unsigned char num2seg[] = {
       1<<SEGA
| 1<<SEGF |  1<<SEGB
|      0<<SEGG
| 1<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       0<<SEGA
| 0<<SEGF |  1<<SEGB
|      0<<SEGG
| 0<<SEGE |  1<<SEGC
|      0<<SEGD
       ,
       1<<SEGA
| 0<<SEGF |  1<<SEGB
|      1<<SEGG
| 1<<SEGE |  0<<SEGC
|      1<<SEGD
       ,
       1<<SEGA
| 0<<SEGF |  1<<SEGB
|      1<<SEGG
| 0<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       0<<SEGA
| 1<<SEGF |  1<<SEGB
|      1<<SEGG
| 0<<SEGE |  1<<SEGC
|      0<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  0<<SEGB
|      1<<SEGG
| 0<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  0<<SEGB
|      1<<SEGG
| 1<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  1<<SEGB
|      0<<SEGG
| 0<<SEGE |  1<<SEGC
|      0<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  1<<SEGB
|      1<<SEGG
| 1<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  1<<SEGB
|      1<<SEGG
| 0<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  1<<SEGB
|      1<<SEGG
| 1<<SEGE |  1<<SEGC
|      0<<SEGD
       ,
       0<<SEGA
| 1<<SEGF |  0<<SEGB
|      1<<SEGG
| 1<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       0<<SEGA
| 0<<SEGF |  0<<SEGB
|      1<<SEGG
| 1<<SEGE |  0<<SEGC
|      1<<SEGD
       ,
       0<<SEGA
| 0<<SEGF |  1<<SEGB
|      1<<SEGG
| 1<<SEGE |  1<<SEGC
|      1<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  0<<SEGB
|      1<<SEGG
| 1<<SEGE |  0<<SEGC
|      1<<SEGD
       ,
       1<<SEGA
| 1<<SEGF |  0<<SEGB
|      1<<SEGG
| 1<<SEGE |  0<<SEGC
|      0<<SEGD
} ;

constant(num2seg,, .s=num2seg)

static const unsigned char alpha2seg[30] = {
       1<<SEGA
| 1<<SEGF |  1<<SEGB
|      1<<SEGG
| 1<<SEGE |  1<<SEGC
|      0<<SEGD
      ,
       0<<SEGA
| 1<<SEGF |  0<<SEGB
|      1<<SEGG
| 1<<SEGE |  1<<SEGC
|      1<<SEGD
      ,
       0<<SEGA
| 0<<SEGF |  0<<SEGB
|      1<<SEGG
| 1<<SEGE |  0<<SEGC
|      1<<SEGD
      ,
        0<<SEGA
| 0<<SEGF  |  1<<SEGB
|       1<<SEGG
| 1<<SEGE  |  1<<SEGC
|       1<<SEGD
      ,
        1<<SEGA
| 1<<SEGF  |  0<<SEGB
|       1<<SEGG
| 1<<SEGE  |  0<<SEGC
|       1<<SEGD
      ,
        1<<SEGA
| 1<<SEGF  |  0<<SEGB
|       1<<SEGG
| 1<<SEGE  |  0<<SEGC
|       0<<SEGD
      ,
        1<<SEGA
| 1<<SEGF  |  0<<SEGB
|       0<<SEGG
| 1<<SEGE  |  1<<SEGC
|       1<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  1<<SEGB
|       1<<SEGG
| 1<<SEGE  |  1<<SEGC
|       0<<SEGD
      ,
        1<<SEGA
| 0<<SEGF  |  0<<SEGB
|       0<<SEGG
| 1<<SEGE  |  0<<SEGC
|       1<<SEGD
      ,
        1<<SEGA
| 0<<SEGF  |  0<<SEGB
|       0<<SEGG
| 0<<SEGE  |  1<<SEGC
|       1<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  1<<SEGB
|       1<<SEGG
| 1<<SEGE  |  1<<SEGC
|       0<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  0<<SEGB
|       0<<SEGG
| 1<<SEGE  |  0<<SEGC
|       1<<SEGD
      ,
        1<<SEGA
| 0<<SEGF  |  0<<SEGB
|       1<<SEGG
| 1<<SEGE  |  1<<SEGC
|       0<<SEGD
      ,
        0<<SEGA
| 0<<SEGF  |  0<<SEGB
|       1<<SEGG
| 1<<SEGE  |  1<<SEGC
|       0<<SEGD
      ,
        0<<SEGA
| 0<<SEGF  |  0<<SEGB
|       1<<SEGG
| 1<<SEGE  |  1<<SEGC
|       1<<SEGD
      ,
        1<<SEGA
| 1<<SEGF  |  1<<SEGB
|       1<<SEGG
| 1<<SEGE  |  0<<SEGC
|       0<<SEGD
      ,
        1<<SEGA
| 1<<SEGF  |  1<<SEGB
|       1<<SEGG
| 0<<SEGE  |  1<<SEGC
|       0<<SEGD
      ,
        0<<SEGA
| 0<<SEGF  |  0<<SEGB
|       1<<SEGG
| 1<<SEGE  |  0<<SEGC
|       0<<SEGD
      ,
        1<<SEGA
| 1<<SEGF  |  0<<SEGB
|       1<<SEGG
| 0<<SEGE  |  1<<SEGC
|       1<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  0<<SEGB
|       1<<SEGG
| 1<<SEGE  |  0<<SEGC
|       1<<SEGD
      ,
        0<<SEGA
| 0<<SEGF  |  0<<SEGB
|       0<<SEGG
| 1<<SEGE  |  1<<SEGC
|       1<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  1<<SEGB
|       1<<SEGG
| 1<<SEGE  |  0<<SEGC
|       0<<SEGD
      ,
        0<<SEGA
| 0<<SEGF  |  1<<SEGB
|       0<<SEGG
| 1<<SEGE  |  0<<SEGC
|       0<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  1<<SEGB
|       1<<SEGG
| 1<<SEGE  |  1<<SEGC
|       0<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  1<<SEGB
|       1<<SEGG
| 0<<SEGE  |  1<<SEGC
|       1<<SEGD
      ,
        1<<SEGA
| 0<<SEGF  |  1<<SEGB
|       0<<SEGG
| 1<<SEGE  |  0<<SEGC
|       1<<SEGD
      ,
        1<<SEGA
| 1<<SEGF  |  0<<SEGB
|       0<<SEGG
| 1<<SEGE  |  0<<SEGC
|       1<<SEGD
      ,
        0<<SEGA
| 1<<SEGF  |  0<<SEGB
|       1<<SEGG
| 0<<SEGE  |  1<<SEGC
|       0<<SEGD
      ,
        1<<SEGA
| 0<<SEGF  |  1<<SEGB
|       0<<SEGG
| 0<<SEGE  |  1<<SEGC
|       1<<SEGD
};

constant(alpha2seg,, .s=alpha2seg)

primary(dpynum)
{
	sp--;
	int idx = 3;

	while(idx > -1) {
		dpybuf[idx--] = num2seg[sp->u % 10];
		sp->u = sp->u/10;
	}
}

