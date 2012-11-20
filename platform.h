#ifndef PLATFORM_H
#define PLATFORM_H

#include "stubforth.h"
#include "cortexm.h"
#include "lm4f120.h"

/* The platform needs to provide my_getchar() and putchar() */

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void putchar(int c);
void my_puts(const char *s);

static void dumphex(int c) {
  int nibble=32;
  char hexchars[] = "0123456789abcdefghijklmnopqrstuvwxyz";
  my_puts("0x");
  while(nibble > 0) {
    nibble -=4;
    putchar( hexchars[((c >> nibble) & 0xf)]);
  }
}

volatile long tick;

void sys_tick(void)
{
  tick++;
}

__attribute__((naked))
void default_handler(void)
{
  asm("mov r0, sp");
  asm("b default_handler_1");
}

void default_handler_1(struct exception_frame *frame)
{
  int xpsr;
  my_puts("\nx_x default handler x_x\n");

  my_puts("  xpsr: ");
  asm ("mrs %0, xpsr": "=r" (xpsr)) ;
  dumphex(xpsr);
  my_puts("\n    pc: ");
  dumphex((int)frame->ra);
  while(1)
    ;
}

volatile struct {
  char buf[1024];
  int in;
  int out;
} ring;

void uart_handler_1(struct exception_frame *frame)
{
  int status;

  while (! (*UARTFR & (1<<4) /* RXFE */ )) {
    int data = *UARTDR;
    if (data == 3) goto force_break;
    ring.buf[ring.in] = data;
    ring.in = (ring.in + 1) % sizeof(ring.buf);
  }

  status = *UARTRSR;
  if (status & (1<<2) /* BE */ ) {
  force_break:
    *UARTRSR = 0;
    my_puts(" <BREAK>\n");
    /* Patch ReturnAddress in exception frame to return to _cstart
       instead. */
    frame->ra = &_cstart;
    return;
  }
}

__attribute__((naked))
void uart_handler(void)
{
  asm("mov r0, sp");
  asm("b uart_handler_1");
}

extern void *_start;
extern void *_stack_base;

void *vectors[64] __attribute__((aligned(256))) = {
   [0] = &_stack_base,
   [1] = &_start,
   [2] = default_handler,
   [3] = default_handler,
   [4] = default_handler,
   [5] = default_handler,
   [6] = default_handler,
   [7] = default_handler,
   [8] = default_handler,
   [9] = default_handler,
   [10] = default_handler,
   [11] = default_handler,
   [12] = default_handler,
   [13] = default_handler,
   [14] = default_handler,
   [15] = sys_tick,
   [16] = default_handler,
   [17] = default_handler,
   [18] = default_handler,
   [19] = default_handler,
   [20] = default_handler,
   [21] = uart_handler, /* lm4f120 uart0 */
   [22] = default_handler,
   [23] = default_handler,
   [24] = default_handler,
   [25] = default_handler,
   [26] = default_handler,
   [27] = default_handler,
   [28] = default_handler,
   [29] = default_handler,
   [30] = default_handler,
   [31] = default_handler,
   [32] = default_handler,
   [33] = default_handler,
   [34] = default_handler,
   [35] = default_handler,
   [36] = default_handler,
   [37] = default_handler,
   [38] = default_handler,
   [39] = default_handler,
   [40] = default_handler,
   [41] = default_handler,
   [42] = default_handler,
   [43] = default_handler,
   [44] = default_handler,
   [45] = default_handler,
   [46] = default_handler,
   [47] = default_handler,
   [48] = default_handler,
   [49] = default_handler,
   [50] = default_handler,
   [51] = default_handler,
   [52] = default_handler,
   [53] = default_handler,
   [38+16] = uart_handler, /* stm32f4 usart2 */
   [55] = default_handler,
   [56] = default_handler,
   [57] = default_handler,
   [58] = default_handler,
   [59] = default_handler,
   [60] = default_handler,
   [61] = default_handler,
};

static void initio()
{
  ring.in = ring.out;
  *VTOR=vectors;


  /* interrupt on break and data ready */
  *UARTIM = (1<<4) | (1<<9);
  *UARTLCRH &= ~(1<<4);

  *(volatile int *)0xE000E104 = 0x40;

  asm volatile ("cpsie i");
}

static void putchar(int c)
{
  int status;

  if (!terminal.raw && c=='\n')
    putchar('\r');

  do {
    status = *UARTFR;
  } while (! (status & (1<<7))) /* TXFE */;

  *UARTDR = c;
}


static int getchar()
{
  unsigned char c;
  while (ring.in == ring.out)
    asm("wfi");
  c = ring.buf[ring.out];
  ring.out = (ring.out + 1) % sizeof(ring.buf);
  if (!terminal.raw && c=='\r')
    c = '\n';
  if (!terminal.quiet)
    putchar(c);
  return c;
}

void _exit(int i)
{
     while(1)
          ;
}


#endif
