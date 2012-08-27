.section .text,"ax",@progbits
.global  _start
_start:	
	lea 0x40000,%sp

	/* Save bootloader state. */
	moveml %d0-%d6/%a0, %sp@-

	/* C runtime init. */
	lea __bss_start, %a0
	lea _end, %a1
1:	
	clrl %a0@+
	cmpl %a0, %a1
	bgt 1b

	jsr main

	/* Resume bootstrapping. */
	moveml %sp@+, %d0-%d6/%a0
	jmp 0xffffff44 
