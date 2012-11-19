#ifndef CORTEXM_H
#define CORTEXM_H

/* System control block (SCB) */
#define ICTR	(volatile int *)0xe000e004
#define ACTLR	(volatile int *)0xe000e008
#define CPUID	(volatile int *)0xe000ed00
#define ICSR	(volatile int *)0xe000ed04
#define VTOR	(volatile int *)0xe000ed08
#define AIRCR	(volatile int *)0xe000ed0c
#define SCR	(volatile int *)0xe000ed10
#define CCR	(volatile int *)0xe000ed14
#define SHPR1	(volatile int *)0xe000ed18
#define SHPR2	(volatile int *)0xe000ed1c
#define SHPR3	(volatile int *)0xe000ed20
#define SHCRS	(volatile int *)0xe000ed24
#define CFSR	(volatile int *)0xe000ed28
#define MMSR	(volatile int *)0xe000ed28
#define BFSR	(volatile int *)0xe000ed29
#define UFSR	(volatile int *)0xe000ed2a
#define HFSR	(volatile int *)0xe000ed2c
#define MMAR	(volatile int *)0xe000ed34
#define BFAR	(volatile int *)0xe000ed38
#define AFSR	(volatile int *)0xe000ed3c

#define NVIC_ISER (volatile int *)0xE000E100
#define NVIC_ICER (volatile int *)0xE000E180

#define NVIC_ISPR (volatile int *)0xE000E200
#define NVIC_ICPR (volatile int *)0xE000E280

#define NVIC_IAPR (volatile int *)0xE000E300

#define NVIC_IPR (volatile int *)0xE000E400

#endif

struct exception_frame {
  int r0;
  int r1;
  int r2;
  int r3;
  int r12;
  void *lr;
  void *ra;
  int xpsr;
};

extern void *_cstart;
