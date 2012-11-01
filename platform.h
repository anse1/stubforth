#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"
#include "stm32.h"
/* The platform needs to provide my_getchar() and putchar() */

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{
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
