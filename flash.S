.section .text,"ax",@progbits
.global  _start
_start:
 	movew #0x2410, 0xFFFFF200 /* pllcr: full speed */
	movew #0x2700, %sr /* orig */
	moveb #0x14,  0xfffff000 /* orig, SCR */
	moveb #0,      0xFFFFFB0B /* watchdog */
        moveb #8, 0xFFFFFD0D /* disable hardmap */
	moveb #0xF5,   0xFFFFF42B /* pfsel */
	moveb #0xfb,   0xfffff40b /* pbsel */
        movew #8, 0xfffffd0c /* orig, ICEMCR */
        movew #7, 0xfffffd0e /* orig, ICEMSR */
 	moveb #0x18,   0xFFFFF300 /* ivr */
	movel #0x007FFFFF, 0xFFFFF304 /* imr */
	/* enable UART */

	movew #0x00bf, 0xfffff420 /* PEDIR + PEDATA */
	movew #0xff0f, 0xfffff422 /* PEPUEN + PESEL */
	movew #0xe100, 0xFFFFF900 /* ustcnt: enable tx, rx */
	movew #0x0138, 0xFFFFF902 /* ubaud: 57600 */
	moveb #'f',   0xFFFFF907

	moveb #'F',   0xFFFFF907
	
	movew #0x0400, 0xFFFFF100 /* csgba: flash 8M-10M */
	movew #0x0189, 0xFFFFF110 /* csa */
	movew #0x0087, 0xFFFFF114 /* csc */
	movew #0x0000, 0xFFFFF104 /* csgbc: sram 0-256k */
	movew #0x0000, 0xFFFFF116 /* csd */
 	moveb #0x18,   0xFFFFF300 /* ivr */
 	moveb #0x1C,  	0xfffff000 /* orig, SCR */

/*	moveb #0x7B,   0xFFFFF42B /* pbpuen */

	moveb #'M',   0xFFFFF907

	jsr uwait

	moveb #'c',   0xFFFFF907
	/* copy flash to SRAM from 0 till __bss_start */
	lea 0, %a0
	movel #__bss_start, %d0
	lea _flash, %a1
1:	
	moveb (%a1)+, (%a0)+
	moveb #'.', 0xFFFFF907
	cmpl %d0, %a0
	jcs 1b

	jsr uwait

	moveb #'C', 0xFFFFF907

        /* jump into the copy */
	jmp 1f:l
1:	
	nop
	moveb #'s', 0xFFFFF907
	
	/* bss init. */
	lea __bss_start, %a0
	lea _end, %a1
1:	
	clrl %a0@+
	cmpl %a0, %a1
	bgt 1b

	moveb #'S', 0xFFFFF907

	jsr uwait

	moveb #'\r', 0xFFFFF907
	moveb #'\n', 0xFFFFF907


.global _cinit
_cinit:
	lea _stack_base,%sp
	jsr main
	stop #0x2700

uwait:
1:	
      	movew 0xfffff906, %d1
      	btst #13,%d1
	beqs 1b
	rts

