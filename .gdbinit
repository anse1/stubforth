## Register boundaries
set $RCC_BASE=(int *)0x40023800
# 0xA0000FFF FSMC control register 
set $FSMC_BASE=(int *) 0xA0000000
# 0X50060BFF        RNG
set $RNG_BASE=(int *) 0x50060800
# 0X500607FF       HASH
set $HASH_BASE=(int *) 0x50060400
# 0X500603FF       CRYP
set $CRYP_BASE=(int *) 0x50060000
# 0X500503FF       DCMI
set $DCMI_BASE=(int *) 0x50050000
# 0X5003FFFF    USB OTG FS
set $USB_BASE=(int *) 0x50000000
# 0x4007FFFF    USB OTG HS
set $USB_BASE=(int *) 0x40040000
# set 0x40029000 - 0x400293FF
# 0x40028C00 - 0x40028FFF
# 0x40028BFF  ETHERNET MAC
set $ETHERNET_BASE=(int *) 0x40028800
# 0x40028400 - 0x400287FF
# 0x40028000 - 0x400283FF
# 0x400267FF       DMA2
set $DMA2_BASE=(int *) 0x40026400
# 0x400263FF       DMA1
set $DMA1_BASE=(int *) 0x40026000
# 0x40024FFF     BKPSRAM
set $BKPSRAM_BASE=(int *) 0x40024000
# 0x40023FFF Flash interface
set $Flash_BASE=(int *) 0x40023C00
# 0x40023BFF        RCC
set $RCC_BASE=(int *) 0x40023800
# 0x400233FF        CRC
set $CRC_BASE=(int *) 0x40023000
# 0x400223FF       GPIOI
set $GPIOI_BASE=(int *) 0x40022000
# 0x40021FFF       GPIOH
set $GPIOH_BASE=(int *) 0x40021C00
# 0x40021BFF      GPIOG
set $GPIOG_BASE=(int *) 0x40021800
# 0x400217FF       GPIOF
set $GPIOF_BASE=(int *) 0x40021400
# 0x400213FF       GPIOE
set $GPIOE_BASE=(int *) 0x40021000
# 0x40020FFF       GPIOD
set $GPIOD_BASE=(int *) 0x40020c00
# 0x40020BFF       GPIOC
set $GPIOC_BASE=(int *) 0x40020800
# 0x400207FF       GPIOB
set $GPIOB_BASE=(int *) 0x40020400
# 0x400203FF       GPIOA
set $GPIOA_BASE=(int *) 0x40020000
# 0x40014BFF        TIM11
set $TIM11_BASE=(int *) 0x40014800
# 0x400147FF        TIM10
set $TIM10_BASE=(int *) 0x40014400
# 0x400143FF        TIM9
set $TIM9_BASE=(int *) 0x40014000
# 0x40013FFF         EXTI
set $EXTI_BASE=(int *) 0x40013C00
# 0x40013BFF      SYSCFG
set $SYSCFG_BASE=(int *) 0x40013800
# 0x400133FF         SPI1
set $SPI1_BASE=(int *) 0x40013000
# 0x40012FFF        SDIO
set $SDIO_BASE=(int *) 0x40012C00
# 0x400123FF ADC1 - ADC2 - ADC3
set $ADC1_BASE=(int *) 0x40012000
# 0x400117FF      USART6
set $USART6_BASE=(int *) 0x40011400
# 0x400113FF      USART1
set $USART1_BASE=(int *) 0x40011000
# 0x400107FF        TIM8
set $TIM8_BASE=(int *) 0x40010400
# 0x400103FF        TIM1
set $TIM1_BASE=(int *) 0x40010000
# 0x400077FF         DAC
set $DAC_BASE=(int *) 0x40007400
# 0x400073FF         PWR
set $PWR_BASE=(int *) 0x40007000
# 0x40006BFF        CAN2
set $CAN2_BASE=(int *) 0x40006800
# 0x400067FF        CAN1
set $CAN1_BASE=(int *) 0x40006400
# 0x40005FFF         I2C3
set $I2C3_BASE=(int *) 0x40005C00
# 0x40005BFF         I2C2
set $I2C2_BASE=(int *) 0x40005800
# 0x400057FF         I2C1
set $I2C1_BASE=(int *) 0x40005400
# 0x400053FF       UART5
set $UART5_BASE=(int *) 0x40005000
# 0x40004FFF       UART4
set $UART4_BASE=(int *) 0x40004C00
# 0x40004BFF      USART3
set $USART3_BASE=(int *) 0x40004800
# 0x400047FF      USART2
set $USART2_BASE=(int *) 0x40004400
# 0x400043FF       I2S3ext
set $I2S3ext_BASE=(int *) 0x40004000
# 0x40003FFF     SPI3 / I2S3
set $SPI3_BASE=(int *) 0x40003C00
# 0x40003BFF     SPI2 / I2S2
set $SPI2_BASE=(int *) 0x40003800
# 0x400037FF       I2S2ext
set $I2S2ext_BASE=(int *) 0x40003400
# 0x400033FF        IWDG
set $IWDG_BASE=(int *) 0x40003000
# 0x40002FFF       WWDG
set $WWDG_BASE=(int *) 0x40002C00
# 0x40002BFF RTC & BKP Registers
set $RTC_BASE=(int *) 0x40002800
# 0x400023FF        TIM14
set $TIM14_BASE=(int *) 0x40002000
# 0x40001FFF        TIM13
set $TIM13_BASE=(int *) 0x40001C00
# 0x40001BFF        TIM12
set $TIM12_BASE=(int *) 0x40001800
# 0x400017FF         TIM7
set $TIM7_BASE=(int *) 0x40001400
# 0x400013FF         TIM6
set $TIM6_BASE=(int *) 0x40001000
# 0x40000FFF         TIM5
set $TIM5_BASE=(int *) 0x40000C00
# 0x40000BFF         TIM4
set $TIM4_BASE=(int *) 0x40000800
# 0x400007FF         TIM3
set $TIM3_BASE=(int *) 0x40000400
# 0x400003FF         TIM2
set $TIM2_BASE=(int *) 0x40000000

# RCC registers

set $rcc_cr       = $RCC_BASE + 0/sizeof(*$RCC_BASE)
set $rcc_pllcfgr  = $RCC_BASE + 4/sizeof(*$RCC_BASE)
set $rcc_cfgr     = $RCC_BASE + 8/sizeof(*$RCC_BASE)
set $rcc_cir      = $RCC_BASE + 12/sizeof(*$RCC_BASE)
set $rcc_ahb1rstr = $RCC_BASE + 0x10/sizeof(*$RCC_BASE)
set $rcc_ahb2rstr = $RCC_BASE + 0x14/sizeof(*$RCC_BASE)
set $rcc_ahb3rstr = $RCC_BASE + 0x18/sizeof(*$RCC_BASE)
set $rcc_apb1rstr = $RCC_BASE + 0x20/sizeof(*$RCC_BASE)
set $rcc_apb2rstr = $RCC_BASE + 0x24/sizeof(*$RCC_BASE)
set $rcc_ahb1enr  = $RCC_BASE + 0x30/sizeof(*$RCC_BASE)
set $rcc_ahb2enr  = $RCC_BASE + 0x34/sizeof(*$RCC_BASE)
set $rcc_ahb3enr  = $RCC_BASE + 0x38/sizeof(*$RCC_BASE)
set $rcc_apb1enr  = $RCC_BASE + 0x40/sizeof(*$RCC_BASE)
set $rcc_apb1lpenr  = $RCC_BASE + 0x60/sizeof(*$RCC_BASE)
set $rcc_apb2enr  = $RCC_BASE + 0x44/sizeof(*$RCC_BASE)
set $rcc_ahb1lpenr  = $RCC_BASE + 0x50/sizeof(*$RCC_BASE)

set $rcc_bdcr = $RCC_BASE + 0x70/sizeof(*$RCC_BASE)
set $rcc_csr = $RCC_BASE + 0x74/sizeof(*$RCC_BASE)
set $rcc_sscgr = $RCC_BASE + 0x80/sizeof(*$RCC_BASE)
set $rcc_plli2scfgr  = $RCC_BASE + 0x84/sizeof(*$RCC_BASE)

#GPIO

set $gpioa_moder   = $GPIOA_BASE + 0/sizeof(*$RCC_BASE)
set $gpioa_otyper  = $GPIOA_BASE + 4/sizeof(*$RCC_BASE)
set $gpioa_ospeedr = $GPIOA_BASE + 8/sizeof(*$RCC_BASE)
set $gpioa_pupdr   = $GPIOA_BASE + 12/sizeof(*$RCC_BASE)
set $gpioa_idr     = $GPIOA_BASE + 0x10/sizeof(*$RCC_BASE)
set $gpioa_odr     = $GPIOA_BASE + 0x14/sizeof(*$RCC_BASE)
set $gpioa_bsrr    = $GPIOA_BASE + 0x18/sizeof(*$RCC_BASE)
set $gpioa_lckr    = $GPIOA_BASE + 0x1c/sizeof(*$RCC_BASE)
set $gpioa_afrl    = $GPIOA_BASE + 0x20/sizeof(*$RCC_BASE)
set $gpioa_afrh    = $GPIOA_BASE + 0x24/sizeof(*$RCC_BASE)

set $gpiob_moder   = $GPIOB_BASE + 0/sizeof(*$RCC_BASE)
set $gpiob_otyper  = $GPIOB_BASE + 4/sizeof(*$RCC_BASE)
set $gpiob_ospeedr = $GPIOB_BASE + 8/sizeof(*$RCC_BASE)
set $gpiob_pupdr   = $GPIOB_BASE + 12/sizeof(*$RCC_BASE)
set $gpiob_idr     = $GPIOB_BASE + 0x10/sizeof(*$RCC_BASE)
set $gpiob_odr     = $GPIOB_BASE + 0x14/sizeof(*$RCC_BASE)
set $gpiob_bsrr    = $GPIOB_BASE + 0x18/sizeof(*$RCC_BASE)
set $gpiob_lckr    = $GPIOB_BASE + 0x1c/sizeof(*$RCC_BASE)
set $gpiob_afrl    = $GPIOB_BASE + 0x20/sizeof(*$RCC_BASE)
set $gpiob_afrh    = $GPIOB_BASE + 0x24/sizeof(*$RCC_BASE)

set $gpioc_moder   = $GPIOC_BASE + 0/sizeof(*$RCC_BASE)
set $gpioc_otyper  = $GPIOC_BASE + 4/sizeof(*$RCC_BASE)
set $gpioc_ospeedr = $GPIOC_BASE + 8/sizeof(*$RCC_BASE)
set $gpioc_pupdr   = $GPIOC_BASE + 12/sizeof(*$RCC_BASE)
set $gpioc_idr     = $GPIOC_BASE + 0x10/sizeof(*$RCC_BASE)
set $gpioc_odr     = $GPIOC_BASE + 0x14/sizeof(*$RCC_BASE)
set $gpioc_bsrr    = $GPIOC_BASE + 0x18/sizeof(*$RCC_BASE)
set $gpioc_lckr    = $GPIOC_BASE + 0x1c/sizeof(*$RCC_BASE)
set $gpioc_afrl    = $GPIOC_BASE + 0x20/sizeof(*$RCC_BASE)
set $gpioc_afrh    = $GPIOC_BASE + 0x24/sizeof(*$RCC_BASE)

set $gpiod_moder   = $GPIOD_BASE + 0/sizeof(*$RCC_BASE)
set $gpiod_otyper  = $GPIOD_BASE + 4/sizeof(*$RCC_BASE)
set $gpiod_ospeedr = $GPIOD_BASE + 8/sizeof(*$RCC_BASE)
set $gpiod_pupdr   = $GPIOD_BASE + 12/sizeof(*$RCC_BASE)
set $gpiod_idr     = $GPIOD_BASE + 0x10/sizeof(*$RCC_BASE)
set $gpiod_odr     = $GPIOD_BASE + 0x14/sizeof(*$RCC_BASE)
set $gpiod_bsrr    = $GPIOD_BASE + 0x18/sizeof(*$RCC_BASE)
set $gpiod_lckr    = $GPIOD_BASE + 0x1c/sizeof(*$RCC_BASE)
set $gpiod_afrl    = $GPIOD_BASE + 0x20/sizeof(*$RCC_BASE)
set $gpiod_afrh    = $GPIOD_BASE + 0x24/sizeof(*$RCC_BASE)

set $gpioe_moder   = $GPIOE_BASE + 0/sizeof(*$RCC_BASE)
set $gpioe_otyper  = $GPIOE_BASE + 4/sizeof(*$RCC_BASE)
set $gpioe_ospeedr = $GPIOE_BASE + 8/sizeof(*$RCC_BASE)
set $gpioe_pupdr   = $GPIOE_BASE + 12/sizeof(*$RCC_BASE)
set $gpioe_idr     = $GPIOE_BASE + 0x10/sizeof(*$RCC_BASE)
set $gpioe_odr     = $GPIOE_BASE + 0x14/sizeof(*$RCC_BASE)
set $gpioe_bsrr    = $GPIOE_BASE + 0x18/sizeof(*$RCC_BASE)
set $gpioe_lckr    = $GPIOE_BASE + 0x1c/sizeof(*$RCC_BASE)
set $gpioe_afrl    = $GPIOE_BASE + 0x20/sizeof(*$RCC_BASE)
set $gpioe_afrh    = $GPIOE_BASE + 0x24/sizeof(*$RCC_BASE)

set $pwr_cr = $PWR_BASE + 0/sizeof(*$PWR_BASE)
set $pwr_csr = $PWR_BASE + 4/sizeof(*$PWR_BASE)

set $exti_imr = $EXTI_BASE + 0/sizeof(*$EXTI_BASE)
set $exti_emr = $EXTI_BASE + 4/sizeof(*$EXTI_BASE)
set $exti_rtsr = $EXTI_BASE + 8/sizeof(*$EXTI_BASE)
set $exti_ftsr = $EXTI_BASE + 0xc/sizeof(*$EXTI_BASE)
set $exti_swier = $EXTI_BASE + 0x10/sizeof(*$EXTI_BASE)
set $exti_pr = $EXTI_BASE + 0x14/sizeof(*$EXTI_BASE)

set $usart2_sr = $USART2_BASE + 0
set $usart2_dr = $USART2_BASE + 1
set $usart2_brr = $USART2_BASE + 2
set $usart2_cr1 = $USART2_BASE + 3
set $usart2_cr2 = $USART2_BASE + 4
set $usart2_cr3 = $USART2_BASE + 5
set $usart2_gtpr = $USART2_BASE + 6

define init
  set *$rcc_apb1enr |= 1<<17
  set *$rcc_apb1lpenr |= 1<<17
  set *$usart2_cr1 |= 1<<13
  set *$usart2_cr1 |= 1<<3
  set *$usart2_cr1 |= 1<<2
  set *$gpioa_moder |= (2<<(2*2))
  set *$gpioa_moder |= (2<<(2*3))

# Bits 31:16 Reserved, must be kept at reset value
#  Bits 15:4 DIV_Mantissa[11:0]: mantissa of USARTDIV
#               These 12 bits define the mantissa of the USART Divider (USARTDIV)
#    Bits 3:0 DIV_Fraction[3:0]: fraction of USARTDIV
#               These 4 bits define the fraction of the USART Divider (USARTDIV). When OVER8=1, the
#               DIV_Fraction3 bit is not considered and must be kept cleared.

# UART2 is AF7 for pa2 and pa3
  set *$gpioa_afrl |= 7 << 3*4 
  set *$gpioa_afrl |= 7 << 2*4 

# HSE=AHB1=AHB2: 8MHz
  set *$rcc_cfgr = 5
# 8MHz/16/4.3125 = 0.115942028986MHz
  set *$usart2_brr = 0x45



end

define u2sr
  set $t = *$usart2_sr
  echo "txe: "
  p $t & (1<<7) 
  echo "tc: "
  p $t & (1<<6) 
  echo "rxne: "
  p $t & (1<<5) 
end

target extended :4242
load
set $pc=main
set $sp=0x10010000
set vmstate.dp=0
