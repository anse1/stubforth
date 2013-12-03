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
