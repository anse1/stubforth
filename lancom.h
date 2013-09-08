#ifndef LANCOM_H
#define LANCOM_H

#define LED34 ((volatile unsigned char *)0xb8000014)
#define LED4_MASK 0xc0 /* 0->off 1->green 2->red 3->off */
#define LED3_MASK 0x30 /* 0->off 1->green 2->red 3->off */

#define LED18 ((volatile unsigned char *)0xb8000010)
#define LED1_MASK 0x80 /* 0->on 1->off */
#define LED8_MASK 0x60 /* 0->off 1->green 2->red 3->off */

#define CPLD8 ((volatile unsigned char *)0xb8000008)
#define CPLD4 ((volatile unsigned char *)0xb8000004)
#define CPLD0 ((volatile unsigned char *)0xb8000000)

#endif
