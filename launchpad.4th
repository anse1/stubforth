hex

.( Loading launchpad.4th...) lf

: red 8 << tmtbmatchr timer0 + ! ;
: green 8 << tmtbmatchr timer1 + ! ;
: blue 8 << tmtamatchr timer1 + ! ;

: col
	dup 10 >> ff and red
	dup 8 >> ff and green
	ff and blue
;

decimal

400000 syst_rvr !

: ms 10 / >r tick @ begin wfi tick @ over - r@ > until r> 2drop ;
: heartbeat begin 900 ms [ hex ] 300000 col [ decimal ] 100 ms [ hex ] 000000 col again ;

: ms 92 * begin ?dup while 1- repeat ;

\ gpio

hex

: pa gpioa_apb ;
: pb gpiob_apb ;
: pc gpioc_apb ;
: pd gpiod_apb ;
: pe gpioe_apb ;
: pf gpiof_apb ;

\ 1. Enable the clock to the port by setting the appropriate bits in
\ the RCGCGPIO register (see page 310). In addition, the SCGCGPIO and
\ DCGCGPIO registers can be programmed in the same manner to enable
\ clocking in Sleep and Deep-sleep modes.

3f rcgcgpio !

\ 2. Set the direction of the GPIO port pins by programming the
\ GPIODIR register. A write of a '1' indicates output and a write of a
\ '0' indicates input.

e gpiodir pf !
			
\ 3. Configure the GPIOAFSEL register to program each bit as a GPIO or
\ alternate pin. If an alternate pin is chosen for a bit, then the
\ PMCx field must be programmed in the GPIOPCTL register for the
\ specific peripheral required. There are also two registers,
\ GPIOADCCTL and GPIODMACTL, which can be used to program a GPIO pin
\ as a ADC or DMA trigger, respectively.

\ 4. Set the drive strength for each of the pins through the GPIODR2R,
\ GPIODR4R, and GPIODR8R registers.

e gpiodr8r pf !
	

\ 5. Program each pad in the port to have either pull-up, pull-down,
\ or open drain functionality through the GPIOPUR, GPIOPDR, GPIOODR
\ register. Slew rate may also be programmed, if needed, through the
\ GPIOSLR register.

\ 6. To enable GPIO pins as digital I/Os, set the appropriate DEN bit
\ in the GPIODEN register. To enable GPIO pins to their analog
\ function (if available), set the GPIOAMSEL bit in the GPIOAMSEL
\ register.

e gpioden pf !
	
\ 7. Program the GPIOIS, GPIOIBE, GPIOBE, GPIOEV, and GPIOIM registers
\ to configure the type, event, and mask of the interrupts for each
\ port.

\ 8. Optionally, software can lock the configurations of the NMI and
\ JTAG/SWD pins on the GPIO port pins, by setting the LOCK bits in the
\ GPIOLOCK register.

\ pf0 - sw2
\ pf1 - red led
\ pf2 - blue led
\ pf3 - green led
\ pf4 - sw1

11 gpiopur pf !
e gpiodir pf !


	
e gpiodata pf ff 2 << !

