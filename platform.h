#ifndef PLATFORM_H
#define PLATFORM_H

#include "stubforth.h"
#include "hd6417708r.h"
#include "lancom.h"


/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{
  *SCSCR = 0x31;

  *SCSSR = 0;

/*               Initialize */
/* Clear TE and RE bits in SCSCR to 0 */

  *SCSCR &= ~0x30;

/* Set CKE1 and CKE0 bits in SCSCR */
/*        (TE and RE bits are 0)        (1) */
  *SCSCR = 0x01;


/*       Select transmit/receive        (2) */
/*          format in SCSMR */
  *SCSMR = 0;


/*         Set value to SCBRR           (3) */
  *SCBRR = 0x5;


/*                             Wait */
/*             Has a 1-bit            No */
/*          interval elapsed? */
/*                      Yes */
  { int i=0;
    while (i++ < 10000) {
      *LED18 = 0x10;
      *LED18 = 0x20;
    }
  }

/*  Set TE and RE bits in SCSCR to 1 */
/*  and set RIE, TEIE, and MPIE bits    (4) */


  *SCSCR |= 0x30;

/*                 End */

}

int putchar(int c) {

  char status;

  do {
    status = *SCSSR;
  } while (! (TDRE & status));

  *SCTDR = c;
  status &= ~TDRE;
  *SCSSR = status;

  if (!terminal.raw)
    if (c == '\n')
      putchar('\r');

  return c;
}

int getchar(void) {
  char status;
  int data;
  do {
    status = *SCSSR;
  } while (! (RDRF & status));

  data = *SCRDR;
  *SCSSR &= ~RDRF;

  if (!terminal.raw)
    if (data == '\r')
      data = '\n';
  if (!terminal.quiet)
    putchar(data);

  return data;
}

#endif
