#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide my_getchar() and putchar() */

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{
}

volatile char rxhack[1000];
char *rx = rxhack;
static int getchar()
{
  while (!*rx)
    ;
  return (unsigned)*rx++;
}

volatile char txhack[1000];
char *tx = txhack;

static void putchar(int c)
{
  *tx++ = c;
  *tx = '\0';
}

void _exit(int i)
{
     while(1)
          ;
}


#endif
