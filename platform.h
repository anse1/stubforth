#ifndef PLATFORM_H
#define PLATFORM_H

#include "stubforth.h"
#include "hd6417708r.h"


/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{

}

int putchar(int c) {
  while (! (TDRE & *SCSSR))
    ;
  *SCTDR = c;
  return c;
}

int getchar(void) {
  while (! (RDRF & *SCSSR))
    ;
  return *SCRDR;
}

#endif
