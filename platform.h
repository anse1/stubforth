#ifndef PLATFORM_H
#define PLATFORM_H

#include "stubforth.h"
#include "symbols.h"

__attribute__((interrupt_handler))
void default_handler (void) {

  my_puts("default_handler invoked\n\r");
  return;
}

static int lowest_bit_set (int value) {
  int i;
  for (i=0; (i<32) && !(1 & value); i++)
    value>>=1;
  return i;
}

void set_vbr(void *addr) {
  asm("ldc %0, vbr" : /* no outputs */ : "r"(addr));
}

void led_pwr(int new) {
  int state = *LED18;
  state &= ~LED1_MASK;
  state |= new << lowest_bit_set(LED1_MASK);
  *LED18 = state;
}


void led_dsl(int new) {
  int state = *LED18;
  state &= ~LED8_MASK;
  state |= new << lowest_bit_set(LED8_MASK);
  *LED18 = state;
}

void led_chan1(int new) {
  int state = *LED34;
  state &= ~LED3_MASK;
  state |= new << lowest_bit_set(LED3_MASK);
  *LED34 = state;
}

void led_chan2(int new) {
  int state = *LED34;
  state &= ~LED4_MASK;
  state |= new << lowest_bit_set(LED4_MASK);
  *LED34 = state;
}

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{

  led_pwr(0);
  led_dsl(0);
  led_chan1(0);
  led_chan2(0);

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

  led_dsl(2);
  do {
    status = *SCSSR;
  } while (! (TDRE & status));

  *SCTDR = c;
  status &= ~TDRE;
  *SCSSR = status;

  if (!terminal.raw)
    if (c == '\n')
      putchar('\r');

  led_dsl(0);

  return c;
}

void warmstart(void) {
      led_dsl(2);
      led_chan1(2);
      led_chan2(2);
      my_puts("warmstart...\n");
      asm (" mov.l .restart, r1");
      asm (" jmp @r1");
      asm (" nop");
      asm (" .align 2");
      asm (".restart:");
      asm (" .long _restart");
}

int getchar(void) {
  char status;
  int data;

  led_dsl(1);

  do {
    status = *SCSSR;
  } while (! (RDRF & status));

  data = *SCRDR;
  *SCSSR &= ~RDRF;


  if (!terminal.raw) {
    if (data == 3) {
      warmstart();
    }
    if (data == '\r')
      data = '\n';
  }
  if (!terminal.quiet)
    putchar(data);

  led_dsl(0);

  return data;
}

#endif
