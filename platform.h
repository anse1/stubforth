#ifndef PLATFORM_H
#define PLATFORM_H

#include "symbols.h"
#include "stubforth.h"
#include "cortexm.h"

/* gah, who built libgcc with exception handling?! */
char __aeabi_unwind_cpp_pr0[0];

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

#define CATHODES 4
char dpybuf[4] = {0xAA, 0x55, 0xAA, 0x55};
static int dpystate;

void ssi0_handler(void)
{
  *(GPIOE_APB(GPIODATA)+0xf) = 1 << dpystate;;
  dpystate = (dpystate + 1) % CATHODES;
  *SSI0(SSIDR) = dpybuf[dpystate];
}

volatile int tick;

void sys_tick(void)
{
  tick++;
}

cell forth_vectors[60];

__attribute__((naked))
void default_handler(void)
{
  asm("mov r0, sp");
  asm("b default_handler_1");
}

void default_handler_1(struct exception_frame *frame)
{
  int xpsr;
  asm ("mrs %0, xpsr": "=r" (xpsr)) ;
  cell forth_vector = forth_vectors[xpsr&0xff];
  if (forth_vector.aa) {
    cell sp[20];
    cell rp[10];
    struct vmstate istate = {
      .sp = sp,
      .rp = rp,
      .dp = 0,
      .dictionary = vmstate.dictionary,
      .base = 16,
      .compiling = 0,
    };
    vm(&istate, forth_vector.aa);
    return;
  }
 
  my_puts("\nx_x default handler x_x\n");
  my_puts("  xpsr: ");
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

__attribute__((naked))
void uart_handler(void)
{
  asm("mov r0, sp");
  asm("b uart_handler_1");
}

void uart_handler_1(struct exception_frame *frame)
{
  int status;

  while (! (*UART0(UARTFR) & (1<<4) /* RXFE */ )) {
    int data = *UART0(UARTDR);
    if (data == 3) goto force_break;
    ring.buf[ring.in] = data;
    ring.in = (ring.in + 1) % sizeof(ring.buf);
  }

  status = *UART0(UARTRSR);
  if (status & (1<<2) /* BE */ ) {
  force_break:
    *UART0(UARTRSR) = 0;
    my_puts(" <BREAK>\n");
    /* Patch ReturnAddress in exception frame to return to _cstart
       instead. */
    frame->ra = &_cstart;
    return;
  }
}

extern void *_start;
extern void *_stack_base;

void *vectors[128]
__attribute__((section(".vectors")))
 = {
   [0] = (void *)&_stack_base,
   [1] = 1 + (char *)&_start,
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
   [23] = ssi0_handler,
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
  *VTOR=(unsigned)vectors;

/* The PLL is configured using direct register writes to the RCC/RCC2 register. If the RCC2 register */
/* is being used, the USERCC2 bit must be set and the appropriate RCC2 bit/field is used. The steps */
/* required to successfully change the PLL-based system clock are: */
/* 1. Bypass the PLL and system clock divider by setting the BYPASS bit and clearing the USESYS */
/*     bit in the RCC register, thereby configuring the microcontroller to run off a "raw" clock source */
/*     and allowing for the new PLL configuration to be validated before switching the system clock */
/*     to the PLL. */

  *RCC |= 1<<11;
  *RCC &= ~(1<<22);


/* 2. Select the crystal value (XTAL) and oscillator source (OSCSRC), and clear the PWRDN bit in */
/*     RCC/RCC2. Setting the XTAL field automatically pulls valid PLL configuration data for the */
/*     appropriate crystal, and clearing the PWRDN bit powers and enables the PLL and its output. */
  *RCC &= ~(0x1f<<6);
  *RCC |= 0x15<<6;

/*   *PLLFREQ0=0x32; */
/*   *PLLFREQ1=0x1; */

  *RCC &= ~(1<<13);

/* 3. Select the desired system divider (SYSDIV) in RCC/RCC2 and set the USESYS bit in RCC. The */
/*     SYSDIV field determines the system frequency for the microcontroller. */
  *RCC &=~(0xf<<23);
  *RCC |=0x4<<23;
  *RCC |= 1<<22;

/* 4. Wait for the PLL to lock by polling the PLLLRIS bit in the Raw Interrupt Status (RIS) register. */
  while(! (*RIS & (1<<6)))
    ;
/* 5. Enable use of the PLL by clearing the BYPASS bit in RCC/RCC2. */
  *RCC &= ~(1<<11);

/*   *RCC=0x24e0540; */
/*   *GPIOHBCTL=0x7e00; */
/*   *RCC2=0x2404000; /\* not used *\/ */
  *MOSCCTL=0x0;
  *DSLPCLKCFG=0x7800000;
  *RCGCTIMER=0x3;
  *RCGCGPIO=0x3f;
  *RCGCHIB=0x1;
  *RCGCUART=0x1;
  *SCGCHIB=0x1;
  *DCGCHIB=0x1;
  *PRTIMER=0x3;
  *PRGPIO=0x21;
  *PRHIB=0x1;
  *PRUART=0x1;


/* 14.4 Initialization and Configuration */
/*      To enable and initialize the UART, the following steps are necessary: */
/*      1. Enable the UART module using the RCGCUART register (see page 314). */

  *RCGCUART=0x1;

/*      2. Enable the clock to the appropriate GPIO module via the RCGCGPIO register (see page 310). */
/*          To find out which GPIO port to enable, refer to Table 21-5 on page 1134. */
  *RCGCGPIO=0x3f;

/*      3. Set the GPIO AFSEL bits for the appropriate pins (see page 624). To determine which GPIOs to */

  *GPIOA_APB(GPIOAFSEL) = 3;

/*          configure, see Table 21-4 on page 1130. */
/*      4. Configure the GPIO current level and/or slew rate as specified for the mode selected (see */
/*          page 626 and page 634). */

/* 5. Configure the PMCn fields in the GPIOPCTL register to assign the UART signals to the appropriate */
/*    pins (see page 641 and Table 21-5 on page 1134). */

 *GPIOA_APB(GPIOPCTL) = 0x222211;

 *GPIOA_APB(GPIODEN) |= 0x3;

 /* LED segment display cathodes */
 *GPIOD_APB(GPIODR2R) |= 0xf;
 *GPIOD_APB(GPIODEN) |= 0xf;
 *GPIOD_APB(GPIODIR) |= 0xf;

 /* LED segment display anodes via HC595 on SPI */
 *RCGCSSI |= 1;

 *GPIOA_APB(GPIOAFSEL) |= 0xf << 2;
 *GPIOA_APB(GPIODIR) |= 0xf << 2;
 *GPIOA_APB(GPIODEN) |= 0xf << 2;

 *SSI0(SSICR1) = 0;
 *SSI0(SSICPSR) = 0xff;
 *SSI0(SSICR0) = 0x4007;
 *SSI0(SSICR1) = 0x12;

 *UART0(UARTIBRD) = 0x15;
 *UART0(UARTFBRD) = 0x2d;
 *UART0(UARTLCRH) = 0x70;
 *UART0(UARTCTL) = 0x301;
 *UART0(UARTIM) = 0x50;
 *UART0(UARTRIS) = 0xf;

  /* interrupt on break and data ready */
 *UART0(UARTIM) = (1<<4) | (1<<9);
 *UART0(UARTLCRH) &= ~(1<<4);

  *(volatile int *)0xE000E104 = 0x40;

  *NVIC_ISER |= (1<<5);

  *NVIC_ISER |= (1<<7); /* SSI0 */

  *SSI0(SSIIM) |= 0x8; /* TXIM */

  asm volatile ("cpsie i");
}

static void putchar(int c)
{
  int status;

  if (!terminal.raw && c=='\n')
    putchar('\r');

  do {
    status = *UART0(UARTFR);
  } while (! (status & (1<<7))) /* TXFE */;

  *UART0(UARTDR) = c;
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

#endif

