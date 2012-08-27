.section .text,"ax",@progbits
.global  _start
_start:

	moveb #0,      0xFFFFFB0A /* watchdog */
	movew #0x2700, %sr /* orig */
	moveb #0x1C,  	0xfffff000 /* orig, SCR */
	moveb #0xF5,   0xFFFFF42B /* pfsel */
;; 	moveb #-11,   0xfffff40b /* pbsel */
        movew #8, 0xfffffd0c /* orig, ICEMCR */
        movew #7, 0xfffffd0e /* orig, ICEMSR */

	moveb #0x7B,   0xFFFFF42B /* pbpuen */

	/* enable UART early so we can debug */

	movew #0x00bf, 0xfffff420 /* PEDIR + PEDATA */
	movew #0xff0f, 0xfffff422 /* PEPUEN + PESEL */
	movew #0x2410, 0xFFFFF200 /* pllcr: full speed */
	movew #0xe100, 0xFFFFF900 /* ustcnt: enable tx, rx */
	movew #0x0138, 0xFFFFF902 /* ubaud: 57600 */
	moveb #'F',   0xFFFFF907
	moveb #0x18,   0xFFFFF300 /* ivr */

	jmp 1f + 0x800000
1:	

	moveb #'G',   0xFFFFF907
	
	movew #0x0400, 0xFFFFF100 /* csgba: flash 8M-10M */
	movew #0x0089, 0xFFFFF110 /* csa */
	movew #0x0087, 0xFFFFF114 /* csc */
	movew #0x0000, 0xFFFFF104 /* csgbc: sram 0-256k */
	movew #0x0000, 0xFFFFF116 /* csd */

	moveb #'H',   0xFFFFF907
	
	/* copy flash to sram till __bss_start */
	lea 0, %a0
	lea __bss_start, %a1
	lea 0x800000, %a2
1:	
	movb %a2@+, %a0@+
	cmpl %a0, %a1
	bgt 1b

	moveb #'D', 0xFFFFF907

	jmp 1f - 0x800000
1:	
	moveb #'S', 0xFFFFF907
	
	/* bss init. */
	lea __bss_start, %a0
	lea _end, %a1
1:	
	clrl %a0@+
	cmpl %a0, %a1
	bgt 1b

	moveb #'M', 0xFFFFF907

.global _cinit
_cinit:	
	lea _stack_base,%sp
	jsr main

