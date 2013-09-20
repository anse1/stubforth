#ifndef PLATFORM_H
#define PLATFORM_H

/* #include "symbols.h" */
#include "stubforth.h"
#include <msp430g2553.h>
#include <stdint.h>

/* The platform needs to provide my_getchar() and putchar() */

void putchar(int c) {
  while (! (UCA0TXIFG & IFG2))
    ;
  UCA0TXBUF = c;

  if (!terminal.raw)
    if ('\n' == c)
      putchar('\r');
}

void *malloc(void) {
  static char buf[50];
  return buf;
}

int getchar(void) {

  while( !(UCA0RXIFG & IFG2)) {
  }

  int data = UCA0RXBUF;

  if (!terminal.raw)
    if (data == '\r')
      data='\n';
  if (!terminal.quiet)
    putchar(data);
  return data;
}


/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{
  /* light led0 */
  P1DIR |= (BIT0 | BIT6);
  P1OUT |= BIT0;

  WDTCTL = WDTPW | WDTHOLD;

/*   /\* use DCO at 16 MHz *\/ */
  DCOCTL = CALDCO_16MHZ;
  BCSCTL1 = CALBC1_16MHZ;

  /* CLKOUT on p1.4 */
  P1SEL |= 1<<4;
  P1DIR |= 1<<4;

  /* Setup USCI */
/* The recommended USCI initialization/re-configuration process is: */
/* 1. Set UCSWRST (BIS.B #UCSWRST,&UCAxCTL1) */

   UCA0CTL1 |= UCSWRST;

/* 2. Initialize all USCI registers with UCSWRST = 1 (including UCAxCTL1) */

   UCA0CTL1 |= UCSSEL_2; /* select SMCLK */
/*    UCA0ABCTL |= UCABDEN; /\* select autobaud *\/ */


/* Clock prescaler setting of the Baud rate generator. The 16-bit
   value of (UCAxBR0 + UCAxBR1 × 256) forms the prescaler value. */

  UCA0BR0 = 0x80;
  UCA0BR1 = 0x6;

/* 3. Configure ports. */
  P1SEL = BIT1 | BIT2;
  P1SEL2 = BIT1 | BIT2;


/* 4. Clear UCSWRST via software (BIC.B #UCSWRST,&UCAxCTL1) */
   UCA0CTL1 &= ~UCSWRST;

/* 5. Enable interrupts (optional) via UCAxRXIE and/or UCAxTXIE */

}


#endif
