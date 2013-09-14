#ifndef PLATFORM_H
#define PLATFORM_H

#include "symbols.h"
#include "stubforth.h"

static void ehex(unsigned int);

static int lowest_bit_set (int value) {
  int i;
  for (i=0; (i<32) && !(1 & value); i++)
    value>>=1;
  return i;
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

int led34_state;

void led_chan1(int new) {
  led34_state &= ~LED3_MASK;
  led34_state |= new << lowest_bit_set(LED3_MASK);
  *LED34 = led34_state;
}

void led_chan2(int new) {
  led34_state &= ~LED4_MASK;
  led34_state |= new << lowest_bit_set(LED4_MASK);
  *LED34 = led34_state;
}

#define RING_SIZE 1024

#define RING_NEXT(x) x = (x + 1) % RING_SIZE
volatile struct {
  unsigned int buf[RING_SIZE];
  int in;
  int out;
} ring;

void warmstart(int silent) {
      led_dsl(2);
      led_chan1(2);
      led_chan2(2);

      if (!silent) {
	my_puts("SPC: ");
	unsigned short *spc;
	asm (" stc spc, %0" : "=r"(spc));
	ehex(spc);
/* 	my_puts(" ("); */
/* 	ehex(*spc); */
/* 	my_puts(")"); */

	my_puts("\nring.in: ");
	ehex(ring.in);
	my_puts(" ring.out: ");
	ehex(ring.out);

	my_puts("warmstart...\n");
      }

      asm (" mov.l .restart, r1");
/*       asm (" jmp @r1"); */
      asm (" ldc r1, spc");
      asm (" rte");
      asm (" nop");
      asm (" .align 2");
      asm (".restart:");
      asm (" .long _restart");
}

/*                                                                   Code */

const char *exceptstr(int code) {
  switch(code) {
  case 0x000:
    return "Power-on";
  case 0x020:
    return "Manual reset";
  case 0x040:
    return "TLB miss/invalid (load)";
  case 0x060:
    return "TLB miss/invalid (store)";
  case 0x080:
    return "Initial page write";
  case 0x0A0:
    return "TLB protection violation (load)";
  case 0x0C0:
    return "TLB protection violation (store)";
  case 0x0E0:
    return "Address error (load)";
  case 0x100:
    return "Address error (store)";
  case 0x160:
    return "Unconditional trap (TRAPA instruction)";
  case 0x180:
    return "Reserved instruction code exception";
  case 0x1A0:
    return "Illegal slot instruction exception";
  case 0x1E0:
    return "User break point trap";
  case 0x1C0:
    return "NMI";
  case 0x200:
  case 0x220:
  case 0x240:
  case 0x260:
  case 0x280:
  case 0x2A0:
  case 0x2C0:
  case 0x2E0:
  case 0x300:
  case 0x320:
  case 0x340:
  case 0x360:
  case 0x380:
  case 0x3A0:
  case 0x3C0:
    return "IRLx";
  case 0x400:
    return "TMU0/TUNI0";
  case 0x420:
    return "TMU1/TUNI1";
  case 0x440:
    return "TMU2/TUNI2";
  case 0x460:
    return "TICPI2";
  case 0x480:
    return "RTC/ATI";
  case 0x4A0:
    return "PRI";
  case 0x4C0:
    return "CUI";
  case 0x4E0:
    return "SCI/ERI";
  case 0x500:
    return "RXI";
  case 0x520:
    return "TXI";
  case 0x540:
    return "TEI";
  case 0x560:
    return "WDT/ITI";
  case 0x580:
    return "REF/RCMI";
  case 0x5A0:
    return "ROVI";
  default:
    return "unknown";
  }
}


void sci_interrupt(void);
__attribute__((interrupt_handler))
__attribute__((section(".interrupt_handler")))
void interrupt_handler (void) {
  int evt = *INTEVT; /* bits 11-0 */

  switch (evt) {
  case 0x4e0:
  case 0x500:
    sci_interrupt();
    break;
  default:
    my_puts("\nx_x default interrupt_handler x_x \n");
    my_puts("INTEVT: ");
    ehex(evt);
    my_puts(" (");
    my_puts(exceptstr(evt));
    my_puts(")\n\r");

    warmstart(0);
    break;
  }
/*   asm(" mov.l canary2, %0" : "=r"(evt)); */
/*   asm(" mov.l canary2, r0"); */
/*   asm(" mov.l canary2, r1"); */
/*   asm(" mov.l canary2, r2"); */
/*   asm(" mov.l canary2, r3"); */
/*   asm(" mov.l canary2, r4"); */
/*   asm(" mov.l canary2, r5"); */
/*   asm(" mov.l canary2, r6"); */
/*   asm(" mov.l canary2, r7"); */
/*   asm(" bra 1f"); */
/*   asm(" nop"); */
/*   asm(".align 2"); */
/*   asm(" canary2: .long 0xcafebab3"); */
/*   asm("1:"); */

  return;
}

__attribute__((interrupt_handler))
__attribute__((section(".exception_handler")))
void exception_handler (void) {

  my_puts("\n,----[ ");

  ehex(*EXPEVT);
  my_puts(" - ");
  my_puts(exceptstr(*EXPEVT));

  my_puts(" ]\n| ");

  my_puts("spc=");
  unsigned short *spc;
  asm (" stc spc, %0" : "=r"(spc));
  ehex(spc);
/*   my_puts(" ("); */
/*   ehex(*spc); */
/*   my_puts(")\n"); */

  my_puts(" ssr=");
  unsigned int ssr;
  asm (" stc ssr, %0" : "=r"(ssr));
  ehex(ssr);

  my_puts(" sr=");
  unsigned int sr;
  asm (" stc sr, %0" : "=r"(sr));
  ehex(sr);
/*   sr&=~(1<<28); */
/*   asm(" ldc %0, sr" : /\* no outputs *\/ : "r"(sr)); */

  register unsigned int *r15 asm("r15");

  my_puts(" r15=");
  ehex(r15);

  my_puts("\n|");

  int i;

#define dumpbank(r)				\
  asm(" stc " #r  "_bank, %0": "=r"(i));	\
  my_puts(" " #r "="); ehex(i)

  dumpbank(r0);
  dumpbank(r1);
  dumpbank(r2);
  dumpbank(r3);
  dumpbank(r4);
  dumpbank(r5);
  dumpbank(r6);
  dumpbank(r7);

  my_puts("\n`----\n");
  warmstart(1);
}

__attribute__((interrupt_handler))
__attribute__((section(".tlb_handler")))
void tlb_handler (void) {
  my_puts("x_x tlb_handler x_x\n\r");

  my_puts("SPC: ");
  unsigned short *spc;
  asm (" stc spc, %0" : "=r"(spc));
  ehex(spc);
  my_puts(" (");
  ehex(*spc);
  my_puts(")\n");

  my_puts("EXPEVT: ");
  ehex(*EXPEVT);
  my_puts(" (");
  my_puts(exceptstr(*EXPEVT));
  my_puts(")\n");

  warmstart(0);
}

void set_vbr(void *addr) {
  asm("ldc %0, vbr" : /* no outputs */ : "r"(addr));
}

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

extern void vector_base;

static void sei() {
  int status;
  asm (" stc sr, %0" : "=r"(status));
  status |= 0x10000000;
  asm(" ldc %0, sr" : /* no outputs */ : "r"(status));
}

static void initio()
{

  set_vbr(&vector_base);

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
  *SCSCR |= (1<<6); /* RIE */

  *IPRB = 0xf << 4; /* unmask by setting priority */

  ring.in = ring.out = 0;
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

static void ehex(unsigned int i) {
  static const char *hexchars="0123456789abcdefghijklmnopqrstuvwxyz";
  if (i / 16)
    ehex(i / 16);
  putchar(hexchars[i % 16]);
}

int getchar(void) {
  int data;
  led_dsl(1);
  while (ring.in == ring.out) {
  }
  data = ring.buf[ring.out];
  RING_NEXT(ring.out);

  if (!terminal.raw)
    if (data == '\r')
      data = '\n';
  if (!terminal.quiet)
    putchar(data);

  led_dsl(0);

  return data;
}

static int debug;

void sci_interrupt(void) {
  char status;
  int data;
  status = *SCSSR;

  asm (" stc sr, %0" : "=r"(data));
  debug = data;

  if ((ORER|FER|PER) & status) {
    *SCSSR &= ~(ORER|FER|PER);

    if (status & ORER) {
      putchar('!');
    } else {
      my_puts(" <BREAK>\r\n");
      warmstart(1);
    }
  }
  if (RDRF & status)
    {
      data = *SCRDR;
      *SCSSR &= ~RDRF;
      if (!terminal.raw) {
	if (data == 3) {
	  my_puts(" <BREAK>\r\n");
	  warmstart(1);
	}
      }
      ring.buf[ring.in] = data;
      RING_NEXT(ring.in);
    }

/*   asm(" mov.l canary, %0" : "=r"(status)); */
/*   asm(" mov.l canary, %0" : "=r"(data)); */
/*   asm(" mov.l canary, r0"); */
/*   asm(" mov.l canary, r1"); */
/*   asm(" mov.l canary, r2"); */
/*   asm(" mov.l canary, r3"); */
/*   asm(" mov.l canary, r4"); */
/*   asm(" mov.l canary, r5"); */
/*   asm(" mov.l canary, r6"); */
/*   asm(" mov.l canary, r7"); */
/*   asm(" bra 1f"); */
/*   asm(" nop"); */
/*   asm(".align 2"); */
/*   asm(" canary: .long 0xdeadbeef"); */
/*   asm("1:"); */

  return;
}

#endif
