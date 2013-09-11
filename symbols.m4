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
define(m4_RCC_BASE, 40023800)
mmio4(A0000000, FSMC_BASE)
define(m4_FSMC_BASE, A0000000)
mmio4(50060800, RNG_BASE)
define(m4_RNG_BASE, 50060800)
mmio4(50060400, HASH_BASE)
define(m4_HASH_BASE, 50060400)
mmio4(50060000, CRYP_BASE)
define(m4_CRYP_BASE, 50060000)
mmio4(50050000, DCMI_BASE)
define(m4_DCMI_BASE, 50050000)
mmio4(50000000, USB_BASE)
define(m4_USB_BASE, 50000000)
mmio4(40040000, USB_BASE2)
define(m4_USB_BASE2, 40040000)
mmio4(40028800, ETHERNET_BASE)
define(m4_ETHERNET_BASE, 40028800)
mmio4(40026400, DMA2_BASE)
define(m4_DMA2_BASE, 40026400)
mmio4(40026000, DMA1_BASE)
define(m4_DMA1_BASE, 40026000)
mmio4(40024000, BKPSRAM_BASE)
define(m4_BKPSRAM_BASE, 40024000)
mmio4(40023C00, Flash_BASE)
define(m4_Flash_BASE, 40023C00)
mmio4(40023000, CRC_BASE)
define(m4_CRC_BASE, 40023000)
mmio4(40022000, GPIOI_BASE)
define(m4_GPIOI_BASE, 40022000)
mmio4(40021C00, GPIOH_BASE)
define(m4_GPIOH_BASE, 40021C00)
mmio4(40021800, GPIOG_BASE)
define(m4_GPIOG_BASE, 40021800)
mmio4(40021400, GPIOF_BASE)
define(m4_GPIOF_BASE, 40021400)
mmio4(40021000, GPIOE_BASE)
define(m4_GPIOE_BASE, 40021000)
mmio4(40020c00, GPIOD_BASE)
define(m4_GPIOD_BASE, 40020c00)
mmio4(40020800, GPIOC_BASE)
define(m4_GPIOC_BASE, 40020800)
mmio4(40020400, GPIOB_BASE)
define(m4_GPIOB_BASE, 40020400)
mmio4(40020000, GPIOA_BASE)
define(m4_GPIOA_BASE, 40020000)
mmio4(40014800, TIM11_BASE)
define(m4_TIM11_BASE, 40014800)
mmio4(40014400, TIM10_BASE)
define(m4_TIM10_BASE, 40014400)
mmio4(40014000, TIM9_BASE)
define(m4_TIM9_BASE, 40014000)
mmio4(40013C00, EXTI_BASE)
define(m4_EXTI_BASE, 40013C00)
mmio4(40013800, SYSCFG_BASE)
define(m4_SYSCFG_BASE, 40013800)
mmio4(40013000, SPI1_BASE)
define(m4_SPI1_BASE, 40013000)
mmio4(40012C00, SDIO_BASE)
define(m4_SDIO_BASE, 40012C00)
mmio4(40012000, ADC1_BASE)
define(m4_ADC1_BASE, 40012000)
mmio4(40011400, USART6_BASE)
define(m4_USART6_BASE, 40011400)
mmio4(40011000, USART1_BASE)
define(m4_USART1_BASE, 40011000)
mmio4(40010400, TIM8_BASE)
define(m4_TIM8_BASE, 40010400)
mmio4(40010000, TIM1_BASE)
define(m4_TIM1_BASE, 40010000)
mmio4(40007400, DAC_BASE)
define(m4_DAC_BASE, 40007400)
mmio4(40007000, PWR_BASE)
define(m4_PWR_BASE, 40007000)
mmio4(40006800, CAN2_BASE)
define(m4_CAN2_BASE, 40006800)
mmio4(40006400, CAN1_BASE)
define(m4_CAN1_BASE, 40006400)
mmio4(40005C00, I2C3_BASE)
define(m4_I2C3_BASE, 40005C00)
mmio4(40005800, I2C2_BASE)
define(m4_I2C2_BASE, 40005800)
mmio4(40005400, I2C1_BASE)
define(m4_I2C1_BASE, 40005400)
mmio4(40005000, UART5_BASE)
define(m4_UART5_BASE, 40005000)
mmio4(40004C00, UART4_BASE)
define(m4_UART4_BASE, 40004C00)
mmio4(40004800, USART3_BASE)
define(m4_USART3_BASE, 40004800)
mmio4(40004400, USART2_BASE)
define(m4_USART2_BASE, 40004400)
mmio4(40004000, I2S3ext_BASE)
define(m4_I2S3ext_BASE, 40004000)
mmio4(40003C00, SPI3_BASE)
define(m4_SPI3_BASE, 40003C00)
mmio4(40003800, SPI2_BASE)
define(m4_SPI2_BASE, 40003800)
mmio4(40003400, I2S2ext_BASE)
define(m4_I2S2ext_BASE, 40003400)
mmio4(40003000, IWDG_BASE)
define(m4_IWDG_BASE, 40003000)
mmio4(40002C00, WWDG_BASE)
define(m4_WWDG_BASE, 40002C00)
mmio4(40002800, RTC_BASE)
define(m4_RTC_BASE, 40002800)
mmio4(40002000, TIM14_BASE)
define(m4_TIM14_BASE, 40002000)
mmio4(40001C00, TIM13_BASE)
define(m4_TIM13_BASE, 40001C00)
mmio4(40001800, TIM12_BASE)
define(m4_TIM12_BASE, 40001800)
mmio4(40001400, TIM7_BASE)
define(m4_TIM7_BASE, 40001400)
mmio4(40001000, TIM6_BASE)
define(m4_TIM6_BASE, 40001000)
mmio4(40000C00, TIM5_BASE)
define(m4_TIM5_BASE, 40000C00)
mmio4(40000800, TIM4_BASE)
define(m4_TIM4_BASE, 40000800)
mmio4(40000400, TIM3_BASE)
define(m4_TIM3_BASE, 40000400)
mmio4(40000000, TIM2_BASE)

define(compute, `format(%x, eval(`$1'))')

mmio4(         compute(0x`'m4_RCC_BASE + 0), RCC_CR)
mmio4(    compute(0x`'m4_RCC_BASE + 4), RCC_PLLCFGR)
mmio4(       compute(0x`'m4_RCC_BASE + 8), RCC_CFGR)
mmio4(        compute(0x`'m4_RCC_BASE + 12), RCC_CIR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x10), RCC_AHB1RSTR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x14), RCC_AHB2RSTR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x18), RCC_AHB3RSTR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x20), RCC_APB1RSTR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x24), RCC_APB2RSTR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x30), RCC_AHB1ENR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x34), RCC_AHB2ENR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x38), RCC_AHB3ENR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x40), RCC_APB1ENR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x60), RCC_APB1LPENR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x44), RCC_APB2ENR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x50), RCC_AHB1LPENR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x70), RCC_BDCR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x74), RCC_CSR)
mmio4(   compute(0x`'m4_RCC_BASE + 0x80), RCC_SSCGR)
mmio4(    compute(0x`'m4_RCC_BASE + 0x84), RCC_PLLI2SCFGR)

mmio4(     compute(0x`'m4_GPIOA_BASE + 0), GPIOA_MODER)
mmio4(    compute(0x`'m4_GPIOA_BASE + 4), GPIOA_OTYPER)
mmio4(   compute(0x`'m4_GPIOA_BASE + 8), GPIOA_OSPEEDR)
mmio4(     compute(0x`'m4_GPIOA_BASE + 12), GPIOA_PUPDR)
mmio4(       compute(0x`'m4_GPIOA_BASE + 0x10), GPIOA_IDR)
mmio4(       compute(0x`'m4_GPIOA_BASE + 0x14), GPIOA_ODR)
mmio4(      compute(0x`'m4_GPIOA_BASE + 0x18), GPIOA_BSRR)
mmio4(      compute(0x`'m4_GPIOA_BASE + 0x1c), GPIOA_LCKR)
mmio4(      compute(0x`'m4_GPIOA_BASE + 0x20), GPIOA_AFRL)
mmio4(      compute(0x`'m4_GPIOA_BASE + 0x24), GPIOA_AFRH)

mmio4(   compute(0x`'m4_PWR_BASE + 0), PWR_CR)
mmio4(   compute(0x`'m4_PWR_BASE + 4), PWR_CSR)

mmio4(   compute(0x`'m4_EXTI_BASE + 0), EXTI_IMR)
mmio4(   compute(0x`'m4_EXTI_BASE + 4), EXTI_EMR)
mmio4(   compute(0x`'m4_EXTI_BASE + 8), EXTI_RTSR)
mmio4(   compute(0x`'m4_EXTI_BASE + 0xc), EXTI_FTSR)
mmio4(   compute(0x`'m4_EXTI_BASE + 0x10), EXTI_SWIER)
mmio4(   compute(0x`'m4_EXTI_BASE + 0x14), EXTI_PR)

mmio4( compute(0x`'m4_USART2_BASE + 0),  USART2_SR)
mmio4( compute(0x`'m4_USART2_BASE + 1*4),  USART2_DR)
mmio4( compute(0x`'m4_USART2_BASE + 2*4),  USART2_BRR)
mmio4( compute(0x`'m4_USART2_BASE + 3*4),  USART2_CR1)
mmio4( compute(0x`'m4_USART2_BASE + 4*4),  USART2_CR2)
mmio4( compute(0x`'m4_USART2_BASE + 5*4),  USART2_CR3)
mmio4( compute(0x`'m4_USART2_BASE + 6*4),  USART2_GTPR)
