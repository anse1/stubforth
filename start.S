.syntax unified
.global _start, _cstart	

_start:
	movw r0, #:lower16:_bss_start
        movt r0, #:upper16:_bss_start
	movw r1, #:lower16:_end
        movt r1, #:upper16:_end

	movw r2, #0
1:
	str r2, [r0]
	add r0, #4
	cmp r0, r1
	ble 1b
_cstart:
	movw r3, #:lower16:_stack_base
        movt r3, #:upper16:_stack_base
	mov sp, r3
	b main
