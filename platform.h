#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide getchar() and putchar() */

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

#include "MC68EZ328.h"

int fifostate;

static int putchar(int c)
{
  if (c=='\n')
    putchar('\r');
  while (! (UTX & UTX_TX_AVAIL))
        ;
  UTX_TXDATA = c;

  return 0;
}

static int getchar()
{
  int c;

  do {
    fifostate = URX;
  } while (! (fifostate & URX_DATA_READY));

  c = fifostate & URX_RXDATA_MASK;

  putchar(c);

  return c;
}

static void initio(void)
{
  UTX_TXDATA = ' ';
  fifostate = URX;
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

#endif
