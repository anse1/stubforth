
	.global _main

	bsr _init
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
_init:
  	mov #0x55, r4  ! <- 0c006f84
	sts pr, r5 
	bsr putchar
	nop  ! delay
	mov r5, r4
	bsr putchar
	shlr8 r5 ! delay
	mov r5, r4
	bsr putchar
	shlr8 r5 ! delay
	mov r5, r4
	bsr putchar
	shlr8 r5 ! delay
	mov r5, r4
	bsr putchar
	nop ! delay
	bsr _init   
	nop   ! delay
	

putchar:
  	extu.b	r4,r4	! <- 0c006fa4
  	mov.w	.sr,r2
1:
	mov.b	@r2,r1			  
  	cmp/pz	r1			  
  	bt	1b
  	mov.w	.dr,r1
  	mov.b	r4,@r1			  
  	add	#2,r1			  
  	mov.b	@r1,r0			  
  	and	#127,r0			  
  	mov.b	r0,@r1			  
  	rts
	nop

.dr:
	.short 0xfe86
.sr:
	.short 0xfe88
	.align 2
