.section .text,"ax",@progbits
.global  _start
_start:	
	/* C runtime init. */
	lea __bss_start, %a0
	lea _end, %a1
1:	
	clrl %a0@+
	cmpl %a0, %a1
	bgt 1b
.global _cinit
_cinit:	
	lea _stack_base,%sp
	jsr main

