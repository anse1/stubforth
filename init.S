
	.global _main
_init:
2:	
  	mov #0x55, r4
  	extu.b	r4,r4			  
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
  	bra 1b
	nop

.dr:
	.short 0xfe86
.sr:
	.short 0xfe88
	.align 2
