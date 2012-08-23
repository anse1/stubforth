#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide getchar() and putchar() */

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

#include "MC68EZ328.h"

int fifostate;


static void puts(const char *s)
{
  while (*s) {
    while (UTX & UTX_BUSY)
      ;
    UTX_TXDATA = *s++;
  }
}


static int getchar()
{
  int c;

  puts("getchar()\n");

  do {
    fifostate = URX;
  } while (! (fifostate & URX_DATA_READY));

  c = fifostate & URX_RXDATA_MASK;

  UTX_TXDATA = c;

  return c;
}

static int putchar(int c)
{
  puts("putchar()\n");
  while (! (UTX & UTX_TX_AVAIL))
        ;
      UTX_TXDATA = c;
  return 0;
}

static void initio(void)
{
  puts("initio()\n");
  fifostate = URX;
  puts("sizeof(cell): ");
  putchar(sizeof(cell) + '0');
  putchar('\n');
  puts("sizeof(int): ");
  putchar(sizeof(int) + '0');
  putchar('\n');
  puts("sizeof(void *): ");
  putchar(sizeof(void *) + '0');
  putchar('\n');
}


#endif
