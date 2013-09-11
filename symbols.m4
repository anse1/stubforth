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

dnl stm32f4 symbols

mmio4(40023800, RCC_BASE)
mmio4(A0000000, FSMC_BASE)
mmio4(50060800, RNG_BASE)
mmio4(50060400, HASH_BASE)
mmio4(50060000, CRYP_BASE)
mmio4(50050000, DCMI_BASE)
mmio4(50000000, USB_BASE)
mmio4(40040000, USB_BASE2)
mmio4(40028800, ETHERNET_BASE)
mmio4(40026400, DMA2_BASE)
mmio4(40026000, DMA1_BASE)
mmio4(40024000, BKPSRAM_BASE)
mmio4(40023C00, Flash_BASE)
mmio4(40023000, CRC_BASE)
mmio4(40022000, GPIOI_BASE)
mmio4(40021C00, GPIOH_BASE)
mmio4(40021800, GPIOG_BASE)
mmio4(40021400, GPIOF_BASE)
mmio4(40021000, GPIOE_BASE)
mmio4(40020c00, GPIOD_BASE)
mmio4(40020800, GPIOC_BASE)
mmio4(40020400, GPIOB_BASE)
mmio4(40020000, GPIOA_BASE)
mmio4(40014800, TIM11_BASE)
mmio4(40014400, TIM10_BASE)
mmio4(40014000, TIM9_BASE)
mmio4(40013C00, EXTI_BASE)
mmio4(40013800, SYSCFG_BASE)
mmio4(40013000, SPI1_BASE)
mmio4(40012C00, SDIO_BASE)
mmio4(40012000, ADC1_BASE)
mmio4(40011400, USART6_BASE)
mmio4(40011000, USART1_BASE)
mmio4(40010400, TIM8_BASE)
mmio4(40010000, TIM1_BASE)
mmio4(40007400, DAC_BASE)
mmio4(40007000, PWR_BASE)
mmio4(40006800, CAN2_BASE)
mmio4(40006400, CAN1_BASE)
mmio4(40005C00, I2C3_BASE)
mmio4(40005800, I2C2_BASE)
mmio4(40005400, I2C1_BASE)
mmio4(40005000, UART5_BASE)
mmio4(40004C00, UART4_BASE)
mmio4(40004800, USART3_BASE)
mmio4(40004400, USART2_BASE)
mmio4(40004000, I2S3ext_BASE)
mmio4(40003C00, SPI3_BASE)
mmio4(40003800, SPI2_BASE)
mmio4(40003400, I2S2ext_BASE)
mmio4(40003000, IWDG_BASE)
mmio4(40002C00, WWDG_BASE)
mmio4(40002800, RTC_BASE)
mmio4(40002000, TIM14_BASE)
mmio4(40001C00, TIM13_BASE)
mmio4(40001800, TIM12_BASE)
mmio4(40001400, TIM7_BASE)
mmio4(40001000, TIM6_BASE)
mmio4(40000C00, TIM5_BASE)
mmio4(40000800, TIM4_BASE)
mmio4(40000400, TIM3_BASE)
mmio4(40000000, TIM2_BASE)

