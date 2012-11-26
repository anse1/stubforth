decimal
80000 syst_rvr !
7 syst_csr !
: ms 10 / >r tick @ begin wfi tick @ over - r@ > until r> 2drop ;

hex
A0000000 constant fsmc
50060800 constant rng
50060400 constant hash
50060000 constant cryp
50050000 constant dcmi
50000000 constant usb
40040000 constant usb
40028800 constant ethernet
40026400 constant dma2
40026000 constant dma1
40024000 constant bkpsram
40023C00 constant flash
40023800 constant rcc
40023000 constant crc
40022000 constant gpioi
40021C00 constant gpioh
40021800 constant gpiog
40021400 constant gpiof
40021000 constant gpioe
40020c00 constant gpiod
40020800 constant gpioc
40020400 constant gpiob
40020000 constant gpioa
40014800 constant tim11
40014400 constant tim10
40014000 constant tim9
40013C00 constant exti
40013800 constant syscfg
40013000 constant spi1
40012C00 constant sdio
40012000 constant adc1
40011400 constant usart6
40011000 constant usart1
40010400 constant tim8
40010000 constant tim1
40007400 constant dac
40007000 constant pwr
40006800 constant can2
40006400 constant can1
40005C00 constant i2c3
40005800 constant i2c2
40005400 constant i2c1
40005000 constant uart5
40004C00 constant uart4
40004800 constant usart3
40004400 constant usart2
40004000 constant i2s3ext
40003C00 constant spi3
40003800 constant spi2
40003400 constant i2s2ext
40003000 constant iwdg
40002C00 constant wwdg
40002800 constant rtc
40002000 constant tim14
40001C00 constant tim13
40001800 constant tim12
40001400 constant tim7
40001000 constant tim6
40000C00 constant tim5
40000800 constant tim4
40000400 constant tim3
40000000 constant tim2

rcc 0 + constant rcc_cr
rcc 4 + constant rcc_pllcfgr
rcc 8 + constant rcc_cfgr
rcc 12 + constant rcc_cir
rcc 10 + constant rcc_ahb1rstr
rcc 14 + constant rcc_ahb2rstr
rcc 18 + constant rcc_ahb3rstr
rcc 20 + constant rcc_apb1rstr
rcc 24 + constant rcc_apb2rstr
rcc 30 + constant rcc_ahb1enr
rcc 34 + constant rcc_ahb2enr
rcc 38 + constant rcc_ahb3enr
rcc 40 + constant rcc_apb1enr
rcc 44 + constant rcc_apb2enr
rcc 50 + constant rcc_ahb1lpenr
rcc 70 + constant rcc_bdcr
rcc 74 + constant rcc_csr
rcc 80 + constant rcc_sscgr
rcc 84 + constant rcc_plli2scfgr

: moder  0 + ;
: otyper  4 + ;
: ospeedr  8 + ;
: pupdr  12 + ;
: idr  10 + ;
: odr  14 + ;
: bsrr  18 + ;
: lckr  1c + ;
: afrl  20 + ;
: afrh  24 + ;

\ 4 leds @ gpiod:12  

rcc_ahb1enr @ 1 3 << or rcc_ahb1enr !

55 c 2 * << gpiod moder !
f c << gpiod odr !

: ledon c <<  gpiod odr @ or gpiod odr ! ;
: ledoff c << ~ gpiod odr @ and gpiod odr ! ;

decimal
: heartbeat begin 900 ms 4 ledon 100 ms 4 ledoff again ;

hex
: unused 10010000 here - ;
