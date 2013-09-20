dnl Platform symbol definitions used to generate initialization code
dnl as well as generally making the symbols available to Forh, C and
dnl assembly code.
dnl
dnl produces forth/C/asm symbols and initialization code
dnl
dnl     mmioN(address, name, comment, init, default)
dnl         |   |       |       |      |     ^--value on reset
dnl         |   |       |       |      ^--initialization value for platform
dnl         |   |       |       ^--arbitrary text
dnl         |   |       ^--valid identifier for asm, C and forth
dnl         |   ^--hexadecimal number
dnl         ^-- size in Bytes
dnl
dnl Used when perpherals exist multiple times
dnl     indirect(offset, name, comment)
dnl
dnl other constants
dnl     const(address, name, comment)
dnl


dnl                                Table 5-1. Basic Clock Module+ Registers
mmio1(056, DCOCTL, DCO control register)
mmio1(057, BCSCTL1, Basic clock system control 1)
mmio1(058, BCSCTL2, Basic clock system control 2)
mmio1(053, BCSCTL3, Basic clock system control 3)
mmio1(000, IE1, SFR interrupt enable register 1)
mmio1(002, IFG1, SFR interrupt flag register 1)

mmio1(060, UCA0CTL0, USCI_A0 control register 0)
mmio1(061, UCA0CTL1, USCI_A0 control register 1)
mmio1(062, UCA0BR0, USCI_A0 Baud rate control register 0)
mmio1(063, UCA0BR1, USCI_A0 baud rate control register 1)
mmio1(064, UCA0MCTL, USCI_A0 modulation control register)
mmio1(065, UCA0STAT, USCI_A0 status register)
mmio1(066, UCA0RXBUF, USCI_A0 receive buffer register)
mmio1(067, UCA0TXBUF, USCI_A0 transmit buffer register)
mmio1(05D, UCA0ABCTL, USCI_A0 Auto baud control register)
mmio1(05E, UCA0IRTCTL, USCI_A0 IrDA transmit control register)
mmio1(05F, UCA0IRRCTL, USCI_A0 IrDA receive control register)
mmio1(001, IE2, SFR interrupt enable register 2)
mmio1(003, IFG2, SFR interrupt flag register 2)

mmio2(0120, WDTCTL, Watchdog timer+ control register)
mmio1(0000, IE1, SFR interrupt enable register 1)
mmio1(0002, IFG1, SFR interrupt flag register 1)

mmio1(020, P1IN, Input)
mmio1(021, P1OUT, Output)
mmio1(022, P1DIR, Direction)
mmio1(023, P1IFG, Interrupt Flag)
mmio1(024, P1IES, Interrupt Edge Select)
mmio1(025, P1IE, Interrupt Enable)
mmio1(026, P1SEL, Port Select)
mmio1(041, P1SEL2, Port Select 2)
mmio1(027, P1REN, Resistor Enable)
mmio1(028, P2IN, Input)
mmio1(029, P2OUT, Output)
mmio1(02A, P2DIR, Direction)
mmio1(02B, P2IFG, Interrupt Flag)
mmio1(02C, P2IES, Interrupt Edge Select)
mmio1(02D, P2IE, Interrupt Enable)
mmio1(02E, P2SEL, Port Select)
mmio1(042, P2SEL2, Port Select 2)
mmio1(02F, P2REN, Resistor Enable)
