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

dnl Cortex-M system control block

mmio4(E000E008, ACTLR, Auxiliary Control Register, ACTLR on page 4-5, , 00000000)
mmio4(E000E010, SYST_CSR, SysTick Control and Status Register, , 00000000)
dnl Bits R/W Name Function
dnl [16] RO COUNTFLAG Returns 1 if timer counted to 0 since last time this register
dnl                  was read. COUNTFLAG is set by a count transition from 1
dnl                 => 0. COUNTFLAG is cleared on read or by a write to the
dnl                Current Value register.
dnl [2] R/W CLKSOURCE 0: clock source is (optional) external reference clock
dnl                  1: core clock used for SysTick
dnl                 If no external clock provided, this bit will read as 1 and
dnl                ignore writes.
dnl [1] R/W TICKINT If 1, counting down to 0 will cause the SysTick exception to
dnl                be pended. Clearing the SysTick Current Value register by a
dnl               register write in software will not cause SysTick to be
dnl              pended.
dnl [0] R/W ENABLE 0: the counter is disabled
dnl               1: the counter will operate in a multi-shot manner.
mmio4(E000E014, SYST_RVR, SysTick Reload Value Register)
mmio4(E000E018, SYST_CVR, SysTick Current Value Register)
mmio4(E000E01C, SYST_CALIB, SysTick Calibration Value Register)
dnl Bits R/W Name Function
dnl [31] RO NOREF If reads as 1, the Reference clock is not provided – the
dnl                CLKSOURCE bit of the SysTick Control and Status register will
dnl               be forced to 1 and cannot be cleared to 0.
dnl [30] RO SKEW If reads as 1, the calibration value for 10ms is inexact (due to clock
dnl             frequency).
dnl [29:24]
dnl [23:0]
dnl ARM DDI 0403C
dnl Restricted Access
dnl Reserved
dnl RO
dnl TENMS
dnl An optional Reload value to be used for 10ms (100Hz) timing,
dnl subject to system clock skew errors. If the value reads as 0, the
dnl calibration value is not known.
mmio4(E000ED00, CPUID, CPUID Base Register, CPUID on page 4-5, , 412FC231)
mmio4(E000ED04, ICSR, Interrupt Control and State Register, , 00000000)
mmio4(E000ED08, VTOR, Vector Table Offset Register, , 00000000)
mmio4(E000ED0C, AIRCR, Application Interrupt and Reset Control Register, , 00000000a)
mmio4(E000ED10, SCR, System Control Register, , 00000000)
mmio4(E000ED14, CCR, Configuration and Control Register., , 00000200)
mmio4(E000ED18, SHPR1, System Handler Priority Register 1, , 00000000)
mmio4(E000ED1C, SHPR2, System Handler Priority Register 2, , 00000000)
mmio4(E000ED20, SHPR3, System Handler Priority Register 3, , 00000000)
mmio4(E000ED24, SHCSR, System Handler Control and State Register, , 00000000)
mmio4(E000ED28, CFSR, Configurable Fault Status Registers, , 00000000)
mmio4(E000ED2C, HFSR, HardFault Status Register, , 00000000)
mmio4(E000ED30, DFSR, Debug Fault Status Register, , 00000000)
mmio4(E000ED34, MMFAR, MemManage Fault Address Registerb)
mmio4(E000ED38, BFAR, BusFault Address Registerb)
mmio4(E000ED3C, AFSR, Auxiliary Fault Status Register, AFSR on page 4-6, , 00000000)
mmio4(E000ED40, ID_PFR0, Processor Feature Register 0, , 00000030)
mmio4(E000ED44, ID_PFR1, Processor Feature Register 1, , 00000200)
mmio4(E000ED48, ID_DFR0, Debug Features Register 0c, , 00100000)
mmio4(E000ED4C, ID_AFR0, Auxiliary Features Register 0, , 00000000)
mmio4(E000ED50, ID_MMFR0, Memory Model Feature Register 0, , 00100030)
mmio4(E000ED54, ID_MMFR1, Memory Model Feature Register 1, , 00000000)
mmio4(E000ED58, ID_MMFR2, Memory Model Feature Register 2, , 01000000)
mmio4(E000ED5C, ID_MMFR3, Memory Model Feature Register 3, , 00000000)
mmio4(E000ED60, ID_ISAR0, Instruction Set Attributes Register 0, , 01100110)
mmio4(E000ED64, ID_ISAR1, Instruction Set Attributes Register 1, , 02111000)
mmio4(E000ED68, ID_ISAR2, Instruction Set Attributes Register 2, , 21112231)
mmio4(E000ED6C, ID_ISAR3, Instruction Set Attributes Register 3, , 01111110)
mmio4(E000ED70, ID_ISAR4, Instruction Set Attributes Register 4, , 01310132)
mmio4(E000ED88, CPACR, Coprocessor Access Control Register, , 00000000)
mmio4(E000EF00, STIR, Software Triggered Interrupt Register, , 00000000)

dnl NVIC

mmio4(E000E004, ICTR, Controller Type Register)
mmio4(E000E100, NVIC_ISER, Interrupt Set-Enable Registers)
mmio4(E000E180, NVIC_ICER, Interrupt Clear-Enable Registers)
mmio4(E000E200, NVIC_ISPR, Interrupt Set-Pending Registers)
mmio4(E000E280, NVIC_ICPR, Interrupt Clear-Pending Registers)
mmio4(E000E300, NVIC_IABR, Interrupt Active Bit Register)
mmio4(E000E400, NVIC_IPR, Interrupt Priority Register)

dnl Silicon implementor symbols follow

indirect(4000C000, UART0)
indirect(4000D000, UART1)
indirect(4000E000, UART2)

mmio4(000, UARTDR,`          R/W 0x0000.0000 UART Data                         698')
mmio4(004, UARTRSR,`/UARTECR R/W 0x0000.0000 UART Receive Status/Error Clear   700')
mmio4(018, UARTFR,`          RO  0x0000.0090 UART Flag                         703')
mmio4(020, UARTILPR,`        R/W 0x0000.0000 UART IrDA Low-Power Register      706')
mmio4(024, UARTIBRD,`        R/W 0x0000.0000 UART Integer Baud-Rate Divisor    707')
mmio4(028, UARTFBRD,`        R/W 0x0000.0000 UART Fractional Baud-Rate Divisor 708')
mmio4(02C, UARTLCRH,`        R/W 0x0000.0000 UART Line Control                 709')
mmio4(030, UARTCTL,`         R/W 0x0000.0300 UART Control                      711')
mmio4(034, UARTIFLS,`        R/W 0x0000.0012 UART Interrupt FIFO Level Select  715')
mmio4(038, UARTIM,`          R/W 0x0000.0000 UART Interrupt Mask               717')
mmio4(03C, UARTRIS,`         RO  0x0000.0000 UART Raw Interrupt Status         721')
mmio4(040, UARTMIS,`         RO  0x0000.0000 UART Masked Interrupt Status      725')
mmio4(044, UARTICR,`         W1C 0x0000.0000 UART Interrupt Clear              729')
mmio4(048, UARTDMACTL,`      R/W 0x0000.0000 UART DMA Control                  731')
mmio4(090, UARTLCTL,`        R/W 0x0000.0000 UART LIN Control                  732')
mmio4(094, UARTLSS,`         RO  0x0000.0000 UART LIN Snap Shot                733')
mmio4(098, UARTLTIM,`        RO  0x0000.0000 UART LIN Timer                    734')

define(sysctrl, `format(%x, eval(0x400fe000 + $1))')

mmio4(sysctrl(0x008), DC0, `         RO   0x017F.007F Device Capabilities 0                           248')
mmio4(sysctrl(0x010), DC1, `         RO         -     Device Capabilities 1                           249')
mmio4(sysctrl(0x014), DC2, `         RO   0x570F.5337 Device Capabilities 2                           252')
mmio4(sysctrl(0x018), DC3, `         RO   0xBFFF.FFFF Device Capabilities 3                           254')
mmio4(sysctrl(0x01C), DC4, `         RO   0x5004.F1FF Device Capabilities 4                           257')
mmio4(sysctrl(0x020), DC5, `         RO   0x0F30.00FF Device Capabilities 5                           259')
mmio4(sysctrl(0x024), DC6, `         RO   0x0000.0013 Device Capabilities 6                           261')
mmio4(sysctrl(0x028), DC7, `         RO   0xFFFF.FFFF Device Capabilities 7                           262')
mmio4(sysctrl(0x02C), DC8, `         RO   0xFFFF.FFFF Device Capabilities 8 ADC Channels              266')
mmio4(sysctrl(0x030), PBORCTL, `     R/W  0x0000.7FFD Brown-Out Reset Control                         220')
mmio4(sysctrl(0x040), SRCR0, `       R/W   0x00000000 Software Reset Control 0                        301')
mmio4(sysctrl(0x044), SRCR1, `       R/W   0x00000000 Software Reset Control 1                        303')
mmio4(sysctrl(0x048), SRCR2, `       R/W   0x00000000 Software Reset Control 2                        306')
mmio4(sysctrl(0x050), RIS, `         RO   0x0000.0000 Raw Interrupt Status                            221')
mmio4(sysctrl(0x054), IMC, `         R/W  0x0000.0000 Interrupt Mask Control                          223')
mmio4(sysctrl(0x058), MISC, `       R/W1C 0x0000.0000 Masked Interrupt Status and Clear               225')
mmio4(sysctrl(0x05C), RESC, `        R/W        -     Reset Cause                                     227')
mmio4(sysctrl(0x060), RCC, `         R/W  0x078E.3AD1 Run-Mode Clock Configuration                    229')
mmio4(sysctrl(0x064), PLLCFG, `      RO         -     XTAL to PLL Translation                         234')
mmio4(sysctrl(0x06C), GPIOHBCTL, `   R/W  0x0000.0000 GPIO High-Performance Bus Control               235')
mmio4(sysctrl(0x070), RCC2, `        R/W  0x07C0.6810 Run-Mode Clock Configuration 2                  237')
mmio4(sysctrl(0x07C), MOSCCTL, `     R/W  0x0000.0000 Main Oscillator Control                         240')
mmio4(sysctrl(0x100), RCGC0, `       R/W   0x00000040 Run Mode Clock Gating Control Register 0        272')
mmio4(sysctrl(0x104), RCGC1, `       R/W   0x00000000 Run Mode Clock Gating Control Register 1        280')
mmio4(sysctrl(0x108), RCGC2, `       R/W   0x00000000 Run Mode Clock Gating Control Register 2        292')
mmio4(sysctrl(0x110), SCGC0, `       R/W   0x00000040 Sleep Mode Clock Gating Control Register 0      275')
mmio4(sysctrl(0x114), SCGC1, `       R/W   0x00000000 Sleep Mode Clock Gating Control Register 1      284')
mmio4(sysctrl(0x118), SCGC2, `       R/W   0x00000000 Sleep Mode Clock Gating Control Register 2      295')
mmio4(sysctrl(0x120), DCGC0, `       R/W   0x00000040 Deep Sleep Mode Clock Gating Control Register 0 278')
mmio4(sysctrl(0x124), DCGC1, `       R/W   0x00000000 Deep-Sleep Mode Clock Gating Control Register 1 288')
mmio4(sysctrl(0x128), DCGC2, `       R/W   0x00000000 Deep Sleep Mode Clock Gating Control Register 2 298')
mmio4(sysctrl(0x144), DSLPCLKCFG, `  R/W  0x0780.0000 Deep Sleep Clock Configuration                  241')
mmio4(sysctrl(0x150),  PIOSCCAL, `   R/W  0x0000.0000 Precision Internal Oscillator Calibration      243')
mmio4(sysctrl(0x170),  I2SMCLKCFG, ` R/W  0x0000.0000 I2S MCLK Configuration                         244')
mmio4(sysctrl(0x190),  DC9, `         RO  0x00FF.00FF Device Capabilities 9 ADC Digital Comparators  269')
mmio4(sysctrl(0x1A0),  NVMSTAT, `     RO  0x0000.0001 Non-Volatile Memory Information                271')

dnl AHB: new
dnl APB: legacy

dnl mutually exclusive, controlled by GPIOHBCTL

indirect(40004000, GPIOA_APB)
indirect(40058000, GPIOA_AHB)
indirect(40005000, GPIOB_APB)
indirect(40059000, GPIOB_AHB)
indirect(40006000, GPIOC_APB)
indirect(4005A000, GPIOC_AHB)
indirect(40007000, GPIOD_APB)
indirect(4005B000, GPIOD_AHB)
indirect(40024000, GPIOE_APB)
indirect(4005C000, GPIOE_AHB)
indirect(40025000, GPIOF_APB)
indirect(4005D000, GPIOF_AHB)

mmio4(000, GPIODATA, `  R/W 0x0000.0000 GPIO Data')
mmio4(400, GPIODIR, `   R/W 0x0000.0000 GPIO Direction')
mmio4(404, GPIOIS, `    R/W 0x0000.0000 GPIO Interrupt Sense')
mmio4(408, GPIOIBE, `   R/W 0x0000.0000 GPIO Interrupt Both Edges')
mmio4(40C, GPIOIEV, `   R/W 0x0000.0000 GPIO Interrupt Event')
mmio4(410, GPIOIM, `    R/W 0x0000.0000 GPIO Interrupt Mask')
mmio4(414, GPIORIS, `   RO  0x0000.0000 GPIO Raw Interrupt Status')
mmio4(418, GPIOMIS, `   RO  0x0000.0000 GPIO Masked Interrupt Status')
mmio4(41C, GPIOICR, `   W1C 0x0000.0000 GPIO Interrupt Clear')
mmio4(420, GPIOAFSEL, ` R/W      -      GPIO Alternate Function Select')
mmio4(500, GPIODR2R, `  R/W 0x0000.00FF GPIO 2-mA Drive Select')
mmio4(504, GPIODR4R, `  R/W 0x0000.0000 GPIO 4-mA Drive Select')
mmio4(508, GPIODR8R, `  R/W 0x0000.0000 GPIO 8-mA Drive Select')
mmio4(50C, GPIOODR, `   R/W 0x0000.0000 GPIO Open Drain Select')
mmio4(510, GPIOPUR, `   R/W      -      GPIO Pull-Up Select')
mmio4(514, GPIOPDR, `    R/W  0x0000.0000 GPIO Pull-Down Select')
mmio4(518, GPIOSLR, `    R/W  0x0000.0000 GPIO Slew Rate Control Select')
mmio4(51C, GPIODEN, `    R/W       -      GPIO Digital Enable')
mmio4(520, GPIOLOCK, `   R/W  0x0000.0001 GPIO Lock')
mmio4(524, GPIOCR, `       -       -      GPIO Commit')
mmio4(528, GPIOAMSEL, `  R/W  0x0000.0000 GPIO Analog Mode Select')
mmio4(52C, GPIOPCTL, `   R/W       -      GPIO Port Control')
mmio4(530, GPIOADCCTL, ` R/W  0x0000.0000 GPIO ADC Control')
mmio4(534, GPIODMACTL, ` R/W  0x0000.0000 GPIO DMA Control')

