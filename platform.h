#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"
#define DF my_puts("->");my_puts(__func__);  my_puts("()\n");
#define RF my_puts("<-");my_puts(__func__); my_puts("()\n") ;

#define DASM(x)  do { int p; my_puts(x ": ") ; asm("move.w " x  ", %0" : "=r"(p));   cprint(p); } while (0)



/* The platform needs to provide getchar() and putchar() */

#include "MC68EZ328.h"

register cell *ip asm ("a5");
dnl volatile cell *ip;

cell exception_cell[2];

static void my_puts(const char *);

__attribute__((noinline))
void sei()
{
  asm(" move.w  0x2000, %sr ");
}

static int putchar(int c)
{
  if (c=='\n')
    putchar('\r');
  while (! (UTX & UTX_TX_AVAIL))
        ;
  UTX_TXDATA = c;

  return 0;
}

static int cprint(int i)
{
  char *hex = "0123456789abcdef";
  int j;
  for (j=8 * sizeof(i) - 4; j>=0; j-=4) {
    putchar(hex[0xf & (i>>j)]);
  }
  putchar('\n');
  return 0;
}

void dumpregs()
{
  my_puts("ISR: ");
  cprint(ISR);
  my_puts("IPR: ");
  cprint(IPR);
  my_puts("SCR: ");
  cprint(SCR);
  my_puts("IVR: ");
  cprint(IVR);
  my_puts("ICEMSR: ");
  cprint(ICEMSR);

  my_puts("SR: ");
  {
    unsigned short sr;
    asm("move.w %%sr , %0" : "=r" (sr) );
    cprint(sr);
  }
}


__attribute__((interrupt_handler))
void ivect_bus_err ()
{
  DF

  long l;
  short s;

 my_puts("function: ") ;
 asm("move.w 4(%%fp), %0" : "=r"(s));
 cprint(s);

 my_puts("address: ") ;
 asm("move.l 6(%%fp), %0" : "=r"(l));
 cprint(l);

 my_puts("instruction & status: ") ;
 asm("move.l 10(%%fp), %0" : "=r"(l));
 cprint(l);

 my_puts("PC: ") ;
 asm("move.l 14(%%fp), %0" : "=r"(l));
 cprint(l);

 dumpregs();

  while(1);
}


define(defaulth, `
__attribute__((interrupt_handler))
void ivect_$1 ()
{
  DF
  DASM("4(%%fp)");
  DASM("6(%%fp)");
  DASM("8(%%fp)");
   DASM("10(%%fp)");
   DASM("12(%%fp)");
   DASM("14(%%fp)");
   DASM("16(%%fp)");

   dumpregs();
   while(1) ;
}
')


defaulth(addr_err)
defaulth(illinstr)
defaulth(zero_div)
defaulth(default)
defaulth(privilege)
defaulth(spurious)
defaulth(uninitialized)
defaulth(emu1111)
defaulth(emu1010)
defaulth(trace)
defaulth(trap)
defaulth(chk)
defaulth(high)

volatile static struct {
  short beg;
  short end;
  char buf[128];
} ring;


__attribute__((interrupt_handler))
void ivect_level4 ()
{
  char c;
  int fifostate;
dnl  asm(" moveml %d0-%d6/%a0-%a6, %sp@- ");

dnl   DF;
dnl 
dnl   my_puts("ISR: ");
dnl   cprint(ISR);
dnl   my_puts("IPR: ");
dnl   cprint(IPR);
dnl 
dnl   DASM("4(%%fp)");
dnl   DASM("6(%%fp)");
dnl   DASM("8(%%fp)");
dnl 
  if (! (ISR & ISR_UART) ) {
dnl    RF
    return;
  }

  while ((fifostate = URX) & URX_DATA_READY) {
dnl   putchar('c');
    if (fifostate & URX_BREAK) {
      putchar('B');
      putchar('R');
      if (exception_cell[1].a) {
        putchar('K');
	ip = exception_cell;
      }
    }
    c = fifostate & URX_RXDATA_MASK;
    ring.buf[ring.end] = c;
    ring.end = (ring.end + 1) % sizeof(ring.buf);
  }
dnl  putchar('\n');
dnl  RF
dnl  asm(" moveml %sp@+, %d0-%d6/%a0-%a6 ");
  return;
}

void *vectors[] __attribute__((section(".vectors")))
    =  {
   [2] = ivect_bus_err,
   [3] = ivect_addr_err,
   [4] = ivect_illinstr,
   [5] = ivect_zero_div,
   [6] = ivect_chk,
   [7] = ivect_trap,
   [8] = ivect_privilege,
   [9] = ivect_trace,
  [10] = ivect_emu1010,
  [11] = ivect_emu1111,
  [12] = ivect_default,
  [13] = ivect_default,
  [14] = ivect_default,
  [15] = ivect_uninitialized,
  [16] = ivect_default,
  [17] = ivect_default,
  [18] = ivect_default,
  [19] = ivect_default,
  [20] = ivect_default,
  [21] = ivect_default,
  [22] = ivect_default,
  [23] = ivect_default,
  [24] = ivect_spurious,
  [25] = ivect_default,
  [26] = ivect_default,
  [27] = ivect_default,
  [28] = ivect_level4,
  [29] = ivect_default,
  [30] = ivect_default,
  [31] = ivect_default,
  [32] = ivect_high,
  [33] = ivect_high,
  [34] = ivect_high,
  [35] = ivect_high,
  [36] = ivect_high,
  [37] = ivect_high,
  [38] = ivect_high,
  [39] = ivect_high,
  [40] = ivect_high,
  [41] = ivect_high,
  [42] = ivect_high,
  [43] = ivect_high,
  [44] = ivect_high,
  [45] = ivect_high,
  [46] = ivect_high,
  [47] = ivect_high,
  [48] = ivect_high,
  [49] = ivect_high,
  [50] = ivect_high,
  [51] = ivect_high,
  [52] = ivect_high,
  [53] = ivect_high,
  [54] = ivect_high,
  [55] = ivect_high,
  [56] = ivect_high,
  [57] = ivect_high,
  [58] = ivect_high,
  [59] = ivect_high,
  [60] = ivect_high,
  [61] = ivect_high,
  [62] = ivect_high,
  [63] = ivect_high
};

static int getchar()
{
  int c;
/*   DF */
  while (ring.end == ring.beg) {

dnl     PCTLR = 0x80;
dnl  asm("stop #0x2000");

}
  c = ring.buf[ring.beg];
  ring.beg = (ring.beg + 1) % sizeof(ring.buf);

  if (c == '\r')
    c = '\n';

  putchar(c);
/*   RF */
  return c;
}

__attribute__((noinline))
void initio(void)
{
  int bogus;
  bogus = URX;
  IMR &= ~IMR_MUART;
  USTCNT |= USTCNT_RXRE;

  sei();
}


#endif

