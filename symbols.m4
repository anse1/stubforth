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
dnl other constants
dnl     const(address, name, comment)
dnl

dnl Cortex-M system control block

mmio4(E000E008, ACTLR, Auxiliary Control Register, ACTLR on page 4-5, , 00000000)
mmio4(E000E010, STCSR, SysTick Control and Status Register, , 00000000)
mmio4(E000E014, STRVR, SysTick Reload Value Register)
mmio4(E000E018, STCVR, SysTick Current Value Register)
mmio4(E000E01C, STCR, SysTick Calibration Value Register)
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
mmio4(E000ED54, ID_, Memory Model Feature Register 1, , 00000000)
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
mmio4(E000E100, NVIC_ISER0, Interrupt Set-Enable Registers)
mmio4(E000E180, NVIC_ICER0, Interrupt Clear-Enable Registers)
mmio4(E000E200, NVIC_ISPR0, Interrupt Set-Pending Registers)
mmio4(E000E280, NVIC_ICPR0, Interrupt Clear-Pending Registers)
mmio4(E000E300, NVIC_IABR0, Interrupt Active Bit Register)
mmio4(E000E400, NVIC_IPR0, Interrupt Priority Register)

dnl Silicon implementor symbols follow
