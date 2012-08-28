#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

#define DASM(x)  do { int p; my_puts(x ": ") ; asm("move.w " x  ", %0" : "=r"(p));   cprint(p); } while (0)

/* The platform needs to provide getchar() and putchar() */

#include "MC68EZ328.h"

static void my_puts(const char *);

static int putchar(int c)
{
  if (!vmstate.raw)
    if (c=='\n')
      putchar('\r');

  while (! (UTX & UTX_TX_AVAIL))
        ;
  UTX_TXDATA = c;

  return 0;
}

__attribute__((noinline))
void sei()
{
  my_puts("enabling interrupts...");
  asm(" move.w #0x2000, %sr ");
  my_puts(" done.\n");
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

  my_puts("SR: ");
  {
    unsigned short sr;
    asm("move.w %%sr , %0" : "=r" (sr) );
    cprint(sr);
  }
}


define(excepth, `
__attribute__((interrupt_handler))
void ivect_$1 ()
{
  my_puts("\n x_x ");
  my_puts("$1");
  my_puts(" x_x ");
  my_puts("\n");

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
  asm("jmp _cinit");
} ')

excepth(bus_err)
excepth(addr_err)

define(defaulth, `
__attribute__((interrupt_handler))
void ivect_$1 ()
{
  my_puts("\n");
  my_puts(" x_x ");
  my_puts("$1");
  my_puts(" x_x ");
  my_puts("\n");

  DASM("4(%%fp)");
  DASM("6(%%fp)");
  DASM("8(%%fp)");
  DASM("10(%%fp)");
  DASM("12(%%fp)");
  DASM("14(%%fp)");
  DASM("16(%%fp)");

  dumpregs();

  asm("jmp _cinit");

}
')

defaulth(illinstr)
defaulth(zero_div)
defaulth(default)
defaulth(privilege)
defaulth(spurious)
defaulth(emu)
defaulth(trace)
defaulth(trap)
defaulth(chk)

struct {
  short beg;
  volatile short end;
  char buf[128];
} ring;

static void uart_interrupt()
{
  char c;
  int fifostate;

  while ((fifostate = URX) & URX_DATA_READY) {
    if (fifostate & URX_BREAK) {
      my_puts(" <BREAK> \n");
      asm("jmp _cinit");
    }
    c = fifostate & URX_RXDATA_MASK;
    ring.buf[ring.end] = c;
    ring.end = (ring.end + 1) % sizeof(ring.buf);
  }
}

__attribute__((interrupt_handler))
void ivect_level4 ()
{

  if (! (ISR & ISR_UART) ) {
     my_puts(__func__);
     my_puts(": huh?\n");
     dumpregs();
    return;
  }

  uart_interrupt();
  return;
}

/* Achtung: This table is offset by 2 wrt the manual because the
   linker script already put the reset PC and SP values in this
   section. */
void *vectors[] __attribute__((section(".vectors")))
    =  {
   [0] = ivect_bus_err,
   [1] = ivect_addr_err,
   [2] = ivect_illinstr,
   [3] = ivect_zero_div,
   [4] = ivect_chk,
   [5] = ivect_trap,
   [6] = ivect_privilege,
   [7] = ivect_trace,
   [8] = ivect_emu,
   [9] = ivect_emu,
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
  [22] = ivect_spurious,
  [23] = ivect_default,
  [24] = ivect_default,
  [25] = ivect_default,
  [26] = ivect_level4,
  [27] = ivect_default,
  [28] = ivect_default,
  [29] = ivect_default,
};

static int getchar()
{
  int c;
  while (ring.end == ring.beg) {
    /* Calling STOP will reduce power consumption when idle, but there
       is a race condition when an interrupt arrives between the check
       and the STOP. */
   /*  asm("stop #0x2000"); */
  }
  c = ring.buf[ring.beg];
  ring.beg = (ring.beg + 1) % sizeof(ring.buf);

  if (! vmstate.raw)
    if (c == '\r')
      c = '\n';
  if (! vmstate.quiet)
    putchar(c);
  return c;
}

__attribute__((noinline))
void initio(void)
{
  volatile int bogus;
  bogus = URX;
  IMR &= ~IMR_MUART;
  USTCNT |= USTCNT_RXRE;
  sei();
}

#endif
