.syntax unified
.global _start, _cstart	
.thumb

_start:
_bss_init:
	movw r0, #:lower16:_bss_start
        movt r0, #:upper16:_bss_start
	movw r1, #:lower16:_bss_end
        movt r1, #:upper16:_bss_end

	movw r2, #0
1:
	str r2, [r0]
	add r0, #4
	cmp r0, r1
	ble 1b

_maybe_copy_data:
	movw r0, #:lower16:_data_start
        movt r0, #:upper16:_data_start
	movw r1, #:lower16:_data_load_start
        movt r1, #:upper16:_data_load_start
	movw r2, #:lower16:_data_end
        movt r2, #:upper16:_data_end

	cmp r0, r1
	beq skipit
1:	
	ldr r3, [r1]
	str r3, [r0]
	add r0, #4
	add r1, #4
	cmp r0, r2
	bne 1b

skipit:
	
	
_cstart:
	movw r3, #:lower16:_stack_base
        movt r3, #:upper16:_stack_base
	mov sp, r3
	b main
