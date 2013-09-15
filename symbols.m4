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
mmio2(ffffff80, FRQCR, Frequency control, 112)
mmio2(ffffff6c, PCR, PCMCIA control, a2)
mmio2(ffffff60, BCR1, Bus control 1, 13)
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
const(04, TEND)
const(08, PER)
const(10, FER)
const(20, ORER)
const(40, RDRF)
const(80, TDRE)
mmio1(fffffe8a, SCRDR, Receive data)
mmio1(fffffe7c, SCSPTR, Serial port)

const(ffffffec, CCR, Cache control register)

const(b8000000, CPLD_BASE, reaches the the big CPLD)

mmio4(b8000004, CPLD_UNK1, Used by loader as argument for function c3f8480)

mmio4(b8000008, CPLD_UNK2, Loader writes to at c3f0636)

mmio1(b800000c, SWITCHES, JP1/SW1 input via big CPLD)

mmio1(b8000014, LED34, Front-Panel LEDs CHAN1/CHAN2 via big CPLD)
const(c0, LED4_MASK, 0->off 1->green 2->red 3->off)
const(30, LED3_MASK, 0->off 1->green 2->red 3->off)

mmio1(b8000010, LED18, Front-Panel LEDs PWR/CHAN via big CPLD)
const(c0, LED1_MASK, 0->on 1->off)
const(60, LED8_MASK, 0->off 1->green 2->red 3->off)

mmio1(fffffe90, TOCR, Timer output control      )
mmio1(fffffe92, TSTR, Timer start register      )

mmio2(fffffe9c, TCR0, Timer control register 0  )
mmio4(fffffe94, TCOR0, Timer constant register 0)
mmio4(fffffe98, TCNT0, Timer counter 0           )

mmio2(fffffea8, TCR1, Timer control register 1  )
mmio4(fffffea0, TCOR1, Timer constant register 1)
mmio4(fffffea4, TCNT1, Timer counter 1           )

mmio2(fffffeb4, TCR2, Timer control register 2  )
mmio4(fffffeac, TCOR2, Timer constant register 2)
mmio4(fffffeb0, TCNT2, Timer counter 2           )
mmio4(fffffeb8, TCPR2, Input capture register 2  )

const(10000000, SMSC, SMSC IOBASE)

mmio2(fffffee0, ICR, Interrupt control register)
mmio2(fffffee2, IPRA, Interrupt priority level setting register A)
mmio2(fffffee4, IPRB, Interrupt priority level setting register B)
