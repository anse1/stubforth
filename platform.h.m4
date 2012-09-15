#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"
#include "MC68EZ328.h"
#include <vivo.h>

#define DASM(x)  do { int p; my_puts(x ": ") ; asm("move.w " x  ", %0" : "=r"(p));   cprint(p); } while (0)

unsigned char *redirect;

void **forth_vectors[8];

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

static void banner(const char *s)
{
  my_puts("\n x_x ");
  my_puts(s);
  my_puts(" x_x ");
  my_puts("\n");
}

define(excepth, `
__attribute__((interrupt_handler))
void ivect_$1 ()
{
  long l;
  short s;

  banner("$1");
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
  banner("$1");

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

struct {
  short beg;
  volatile short end;
  char buf[1024];
} ring;

static void uart_interrupt()
{
  char c;
  int fifostate;

  while ((fifostate = URX) & URX_DATA_READY) {
    if (fifostate & URX_BREAK) {
      my_puts(" <BREAK> \n");
      redirect = 0;
      asm("jmp _cinit");
    }
    c = fifostate & URX_RXDATA_MASK;
    ring.buf[ring.end] = c;
    ring.end = (ring.end + 1) % sizeof(ring.buf);
  }
}

void forth_handler(int level)
{
  struct vmstate irqstate = vmstate;
  void **xt = forth_vectors[level];
  if (!xt) return;
  cell ps[100];
  cell rs[100];
  irqstate.rp = rs;
  irqstate.sp = ps;
  cell result = vm(&irqstate, xt);
  if(result.s) {
    my_puts("\n x_x ");
    my_puts("exception in Forth interrupt handler level ");
    putchar('0' + level);
    my_puts(": ");
    my_puts(result.s);
    my_puts(" x_x ");
  }
}

__attribute__((interrupt_handler))
void ivect_level4 ()
{

  if ((ISR & ISR_UART) ) {
    uart_interrupt();
    return;
  }

  forth_handler(4);
  return;

}

define(userirq, `
__attribute__((interrupt_handler))
void ivect_level$1 ()
{
  forth_handler($1);
  return;
} ')

userirq(1)
userirq(2)
userirq(3)
userirq(5)
userirq(6)

/* Achtung: This table is offset by 2 wrt the manual because the
   linker script already put the reset PC and SP values in this
   section. */
void *vectors[] __attribute__((section(".vectors")))
    =  {
   [0] = ivect_bus_err,
   [1] = ivect_addr_err,
   [2] = ivect_illinstr,
   [3] = ivect_zero_div,
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
  [23] = ivect_level1,
  [24] = ivect_level2,
  [25] = ivect_level3,
  [26] = ivect_level4,
  [27] = ivect_level5,
  [28] = ivect_level6,
  [29] = ivect_default,
};

static int getchar()
{
  int c;

  if (redirect) {
    c = *redirect++;
    if (!c || c == 0xff)
      return redirect = 0, '\n';
    else
      return c;
  }

  while (ring.end == ring.beg) {
    /* Calling STOP will reduce power consumption when idle, but there
       is a race condition when an interrupt arrives between the check
       and the STOP. */
   /*  asm("stop #0x2000"); */
  }
  c = (unsigned char) ring.buf[ring.beg];
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
  (void) bogus;
  IMR &= ~IMR_MUART;
  USTCNT |= USTCNT_RXRE;
  sei();
}

#endif
