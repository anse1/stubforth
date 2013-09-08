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
dnl     const(address, name, comment)
dnl
mmio2(ffffff80, FRQCR, Frequency control, 112)
mmio1(ffffff6c, PCR, PCMCIA control, a2)
mmio1(ffffff60, BCR1, Bus control 1, 13)
dnl ¬le, burst, a5pcm, a6pcm
mmio2(ffffff62, BCR2, Bus control 2, 1bd8)
dnl        01 10 11 11 01 10 00
dnl area:  66 55 44 33 22 11  ^--porten
dnl         8 16 32 32  8 16
dnl
dnl
mmio2(ffffff64, WCR1, Wait state control 1, b40c)
mmio2(ffffff66, WCR2, Wait state control 2, f91e)
mmio2(ffffff68, MCR,  Individual memory control, 4175)

dnl 0 tpc1
dnl 1 tpc0
dnl 0 rcd1
dnl 0 rcd0
dnl 0 trwl1
dnl 0 trwl0
dnl 0 tras1
dnl 1 tras0

dnl 0 -
dnl 1 BE
dnl 1 SZ
dnl 1 AMX1
dnl 0 AMX0
dnl 1 RFSH
dnl 0 RMODE
dnl 1 EDO MODE

mmio2(ffffff70, RTCNT,   Refresh timer counter, a500)
mmio2(ffffff72, RTCOR,   Refresh time constant, a50d)
mmio2(ffffff6e, RTCSR,   Refresh timer control/status, a518)

mmio2(ffffff74, RFCR,  refresh count register)
mmio2(ffffff6a, DCR,  DRAM control register)

mmio4(ffffffd0, TRA,  TRAPA exception register)
mmio4(ffffffd4, EXPEVT,  Exception event)
mmio4(ffffffd8, INTEVT,  Interrupt event)

mmio1(fffffe80, SCSMR, Serial mode)
mmio1(fffffe82, SCBRR, Bit rate)
mmio1(fffffe84, SCSCR, Serial control)
mmio1(fffffe86, SCTDR, Transmit data)
mmio1(fffffe88, SCSSR, Serial status)
mmio1(fffffe8a, SCRDR, Receive data)
mmio1(fffffe7c, SCSPTR, Serial port)

const(fffffe9c, TCR0, Timer control register 0)
const(ffffffec, CCR, Cache control register)

const(b8000000, CPLD_BASE, reaches the the big CPLD)

mmio1(b800000c, SWITCHES, JP1/SW1 input via big CPLD)

mmio1(b8000014, LED34, Front-Panel LEDs CHAN1/CHAN2 via big CPLD)
const(c0, LED4_MASK, 0->off 1->green 2->red 3->off)
const(30, LED3_MASK, 0->off 1->green 2->red 3->off)

mmio1(b8000010, LED18, Front-Panel LEDs PWR/CHAN via big CPLD)
const(c0, LED1_MASK, 0->on 1->off)
const(60, LED8_MASK, 0->off 1->green 2->red 3->off)

const(80, TDRE)
const(40, RDRF)
const(4, TEND)
