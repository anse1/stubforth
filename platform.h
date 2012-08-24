#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide getchar() and putchar() */


#include "MC68EZ328.h"

register cell *ip asm ("a5");
cell exception_cell[2];

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

__attribute__((interrupt_handler))
void ivect_default ()
{
  void *p;

  char *s;
    while(1) {
      asm("move.w (%%fp), %0" : "=r"(p));
      cprint(p);
      UTX_TXDATA = ' ';
      asm("move.l 2(%%fp), %0" : "=r"(p));
      cprint(p);
      UTX_TXDATA = ' ';
      asm("move.l 4(%%fp), %0" : "=r"(p));
      cprint(p);
      UTX_TXDATA = ' ';
      asm("move.l 6(%%fp), %0" : "=r"(p));
      cprint(p);
      UTX_TXDATA = ' ';
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "default interrupt handler\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

volatile static struct {
  short beg;
  short end;
  char buf[128];
} ring;


__attribute__((interrupt_handler))
void ivect_28 ()
{
  char c;
  int fifostate;

/*   if (! (ISR & ISR_UART) ) */
/*     return; */

  while ((fifostate = URX) & URX_DATA_READY) {

    if (fifostate & URX_BREAK) {
      if (exception_cell[1].a)
	ip = exception_cell;
    }
    c = fifostate & URX_RXDATA_MASK;
    ring.buf[ring.end] = c;
    ring.end = (ring.end + 1) % sizeof(ring.buf);
  }

  return;
}

void *vectors[] __attribute__((section(".vectors")))
    =  {
  [2] = ivect_default,
  [3] = ivect_default,
  [4] = ivect_default,
  [5] = ivect_default,
  [6] = ivect_default,
  [7] = ivect_default,
  [8] = ivect_default,
  [9] = ivect_default,
  [10] = ivect_default,
  [11] = ivect_default,
  [12] = ivect_default,
  [13] = ivect_default,
  [14] = ivect_default,
  [15] = ivect_default,
  [16] = ivect_default,
  [17] = ivect_default,
  [18] = ivect_default,
  [19] = ivect_default,
  [20] = ivect_default,
  [21] = ivect_default,
  [22] = ivect_default,
  [23] = ivect_default,
  [24] = ivect_default,
  [25] = ivect_default,
  [26] = ivect_default,
  [27] = ivect_default,
  [28] = ivect_28,
  [29] = ivect_default,
  [30] = ivect_default,
  [31] = ivect_default,
};


static int getchar()
{
  int c;

  while (ring.end == ring.beg)
    ;
  c = ring.buf[ring.beg];
  ring.beg = (ring.beg + 1) % sizeof(ring.buf);

  if (c == '\r')
    c = '\n';

  putchar(c);

  return c;
}

static void initio(void)
{
  int bogus;
  UTX_TXDATA = ' ';
  bogus = URX;
  IMR &= ~IMR_MUART;
  USTCNT |= USTCNT_RXRE;

  asm(" move.w  0x2000, %sr ");
}


#endif
