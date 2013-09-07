
	.global _main
	.global _cinit

_init:
  	mov.l .leds, r6
	mov.b r7, @r6
	mov #0x50, r7
	mov.l .stack,r15
	stc.l	spc,@-r15
	stc.l	ssr,@-r15
	sts.l	pr,@-r15

	mov #0, r0
	mov #0xA0, r7
	mov.l .cinit, r1
	jsr @r1
	nop

	mov.b r7, @r6
	mov #0x10, r7
	mov #0xA0, r7
	mov #0, r0
	mov.l .main, r1
	jsr @r1
	nop
	mov.l .leds, r6
1:	
	mov #0x20, r7
	mov.b r7, @r6
	mov #0x10, r7
	bra 1b
	mov.b r7, @r6
	
	.align 2
.leds:
	.long 0xb8000014
.stack:
	.long _stack
.main:
	.long _main
.cinit:
	.long _cinit
