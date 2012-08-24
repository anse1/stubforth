#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide getchar() and putchar() */

/* vmstate.break_condition can be set in an ISR to interrupt the
   interpreter. */

#include "MC68EZ328.h"

static int putchar(int c)
{
  if (c=='\n')
    putchar('\r');
  while (! (UTX & UTX_TX_AVAIL))
        ;
  UTX_TXDATA = c;

  return 0;
}

volatile int fifostate;

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

    s = "Spurious interrupt!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default31 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 31!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default30 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 30!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default29 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 29!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default27 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 27!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default26 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 26!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default25 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 25!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default24 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 24!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default23 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 23!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default22 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 22!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default21 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 21!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default20 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 20!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default19 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 19!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default18 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 18!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default17 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 17!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default16 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 16!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default15 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 15!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default14 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 14!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default13 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 13!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default12 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 12!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default11 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 11!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default10 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 10!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}


__attribute__((interrupt_handler))
void ivect_default9 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 9!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default8 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 8!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default7 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 7!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default6 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 6!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default5 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 5!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default4 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 4!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default3 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 3!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_default2 ()
{
  char *s;
    while(1) {
      cprint(ISR);
      UTX_TXDATA = ' ';
      cprint(IPR);
      UTX_TXDATA = '\r';
      UTX_TXDATA = '\n';

    s = "Spurious interrupt 2!\r\n";
    while (*s) {
      while (UTX & UTX_BUSY)
	;
      UTX_TXDATA = *s++;
    }
    }
  return;
}

__attribute__((interrupt_handler))
void ivect_28 ()
{
/*   if (! (ISR & ISR_UART) ) */
/*     return; */

/*   if (! fifostate) */
/*     fifostate = URX; */
/*   if (fifostate & URX_BREAK) { */
    vmstate.break_condition = 1;
/*   } */

/*   if (!(fifostate & URX_DATA_READY)) */
/*     fifostate = 0; */

  putchar('\n');
  putchar('i');
  putchar('\n');
  return;
}

void *vectors[] __attribute__((section(".vectors")))
    =  {
  [2] = ivect_default2,
  [3] = ivect_default3,
  [4] = ivect_default4,
  [5] = ivect_default5,
  [6] = ivect_default6,
  [7] = ivect_default7,
  [8] = ivect_default8,
  [9] = ivect_default9,
  [10] = ivect_default10,
  [11] = ivect_default11,
  [12] = ivect_default12,
  [13] = ivect_default13,
  [14] = ivect_default14,
  [15] = ivect_default15,
  [16] = ivect_default16,
  [17] = ivect_default17,
  [18] = ivect_default18,
  [19] = ivect_default19,
  [20] = ivect_default,
  [21] = ivect_default21,
  [22] = ivect_default22,
  [23] = ivect_default23,
  [24] = ivect_default24,
  [25] = ivect_default25,
  [26] = ivect_default26,
  [27] = ivect_default27,
  [28] = ivect_28,
  [29] = ivect_default29,
  [30] = ivect_default30,
  [31] = ivect_default31,
};


static int getchar()
{
  int c;

  do {
    fifostate = URX;
  } while (! (fifostate & URX_DATA_READY));

/*    while (! (fifostate & URX_DATA_READY)) */
/*     ; */

  c = fifostate & URX_RXDATA_MASK;

  if (c == '\r')
    c = '\n';

  putchar(c);

  return c;
}

static void initio(void)
{
  UTX_TXDATA = ' ';
  fifostate = URX;
  fifostate = 0;
  IMR &= ~IMR_MUART;
  USTCNT |= USTCNT_RXRE;
}


#endif
