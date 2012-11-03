#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"
#include "stm32.h"
/* The platform needs to provide my_getchar() and putchar() */

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void putchar(int c);

__attribute__((interrupt))
void default_handler(void)
{
  char * s = "default handler fired\n";
  while (*s)
    putchar(*s++);
}

int main();

void *vectors[128] __attribute__((aligned(128))) = {
  [0] = 0x20000000,
  [1] = main,
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
  [54] = default_handler,
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
  *usart2_sr=0;
}

static void putchar(int c)
{
  while (! (*usart2_sr & 1<<7))
    ;
  *usart2_dr = c;
  if (c=='\n')
    putchar('\r');
}


static int getchar()
{
  unsigned char c;
  while (! (*usart2_sr & 1<<5))
    ;
  c =  *usart2_dr;
  if (c=='\r')
    c = '\n';
  putchar(c);
  return c;
}

void _exit(int i)
{
     while(1)
          ;
}


#endif
