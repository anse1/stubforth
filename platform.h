#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"
#include "cortexm.h"
#include "stm32f4.h"
/* The platform needs to provide my_getchar() and putchar() */

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void putchar(int c);
static void my_puts(const char *s);

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

__attribute__((interrupt))
void sys_tick(void)
{
  tick++;
}

__attribute__((interrupt))
void default_handler(void)
{
  int xpsr;
  my_puts("x_x default handler x_x\n");

  my_puts("  xpsr: ");
  asm ("mrs %0, xpsr": "=r" (xpsr)) ;
  dumphex(xpsr);
  putchar('\n');
  while(1)
    ;
}

volatile struct {
  char buf[1024];
  int in;
  int out;
} ring;

__attribute__((interrupt))
void uart_handler(void)
{
  int status = *usart2_sr;

  if (status & (1<<5)) {
    ring.buf[ring.in] = *usart2_dr;
    ring.in = (ring.in + 1) % sizeof(ring.buf);
  }
  if (status & (1<<8)) {
    my_puts(" <BREAK>\n");
    *usart2_sr &= ~(1<<8);
    /* Patch stack frame to return to _cstart instead. */
    asm("mov r2, sp");
    asm("add r2, #(8*4)");
    asm("movw r3, #:lower16:_cstart");
    asm("movt r3, #:upper16:_cstart");
    asm("str r3, [r2]");
    return;
  }
}

extern void _start;

void *vectors[128] __attribute__((aligned(256))) = {
   [0] = 0x20000000,
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
   [21] = default_handler,
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
   [38+16] = uart_handler,
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
  *VTOR=vectors;
  *rcc_apb1enr |= 1<<17;
  *rcc_apb1lpenr |= 1<<17;
  *usart2_cr1 |= 1<<13;
  *usart2_cr1 |= 1<<3;
  *usart2_cr1 |= 1<<2;
  *gpioa_moder |= (2<<(2*2));
  *gpioa_moder |= (2<<(2*3));
  *gpioa_afrl |= 7 << 3*4 ;
  *gpioa_afrl |= 7 << 2*4 ;


/* # HSE=AHB1=AHB2: 8MHz */
  *rcc_cfgr = 5;
/* # 8MHz/16/4.3125 = 0.115942028986MHz */
  *usart2_brr = 0x45;

  *usart2_cr1 |= (1<<5);
  *usart2_cr2 |= (1<<6);
  *(volatile int *)0xE000E104 = 0x40;

  asm volatile ("cpsie i");
}

static void putchar(int c)
{
  if (c=='\n')
    putchar('\r');
  while (! (*usart2_sr & 1<<7))
    ;
  *usart2_dr = c;
}


static int getchar()
{
  unsigned char c;
  while (ring.in == ring.out)
    asm("nop");
  c = ring.buf[ring.out];
  ring.out = (ring.out + 1) % sizeof(ring.buf);
  if (c=='\r')
    c = '\n';
  if (!vmstate.quiet)
    putchar(c);
  return c;
}

void _exit(int i)
{
     while(1)
          ;
}


#endif
