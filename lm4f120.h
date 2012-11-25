#ifndef LM4F120_H
#define LM4F120_H

#define UART0_BASE (char *)0x4000C000
#define UART1_BASE (char *)0x4000D000
#define UART2_BASE (char *)0x4000E000
#define UART3_BASE (char *)0x4000F000
#define UART4_BASE (char *)0x40010000
#define UART5_BASE (char *)0x40011000
#define UART6_BASE (char *)0x40012000
#define UART7_BASE (char *)0x40013000

#define UARTDR ((volatile int *)(UART0_BASE + 0x000))
#define UARTRSR ((volatile int *)(UART0_BASE + 0x004))
#define UARTFR ((volatile int *)(UART0_BASE + 0x018))
#define UARTILPR ((volatile int *)(UART0_BASE + 0x020))
#define UARTIBRD ((volatile int *)(UART0_BASE + 0x024))
#define UARTFBRD ((volatile int *)(UART0_BASE + 0x028))
#define UARTLCRH ((volatile int *)(UART0_BASE + 0x02C))
#define UARTCTL ((volatile int *)(UART0_BASE + 0x030))
#define UARTIFLS ((volatile int *)(UART0_BASE + 0x034))
#define UARTIM ((volatile int *)(UART0_BASE + 0x038))
#define UARTRIS ((volatile int *)(UART0_BASE + 0x03C))
#define UARTMIS ((volatile int *)(UART0_BASE + 0x040))
#define UARTICR ((volatile int *)(UART0_BASE + 0x044))
#define UARTDMACTL ((volatile int *)(UART0_BASE + 0x048))
#define UARTLCTL ((volatile int *)(UART0_BASE + 0x090))
#define UARTLSS ((volatile int *)(UART0_BASE + 0x094))
#define UARTLTIM ((volatile int *)(UART0_BASE + 0x098))
#define UART9BITADDR ((volatile int *)(UART0_BASE + 0x0A4))
#define UART9BITAMASK ((volatile int *)(UART0_BASE + 0x0A8))
#define UARTPP ((volatile int *)(UART0_BASE + 0xFC0))
#define UARTCC ((volatile int *)(UART0_BASE + 0xFC8))
#define UARTPeriphID4 ((volatile int *)(UART0_BASE + 0xFD0))
#define UARTPeriphID5 ((volatile int *)(UART0_BASE + 0xFD4))
#define UARTPeriphID6 ((volatile int *)(UART0_BASE + 0xFD8))
#define UARTPeriphID7 ((volatile int *)(UART0_BASE + 0xFDC))
#define UARTPeriphID0 ((volatile int *)(UART0_BASE + 0xFE0))
#define UARTPeriphID1 ((volatile int *)(UART0_BASE + 0xFE4))
#define UARTPeriphID2 ((volatile int *)(UART0_BASE + 0xFE8))
#define UARTPeriphID3 ((volatile int *)(UART0_BASE + 0xFEC))
#define UARTPCellID0 ((volatile int *)(UART0_BASE + 0xFF0))
#define UARTPCellID1 ((volatile int *)(UART0_BASE + 0xFF4))
#define UARTPCellID2 ((volatile int *)(UART0_BASE + 0xFF8))
#define UARTPCellID3 ((volatile int *)(UART0_BASE + 0xFFC))


#endif
