
/* MEMORY { */
/*    ram   : ORIGIN = 0x0, LENGTH =  0x40000 */
/* /\*  flash [RX]  : ORIGIN = 0x800000, LENGTH =  0x200000  *\/ */
/* } */

ENTRY(_start)

SECTIONS 
{
    _flash = 0x800000;
    _flash_end = 0xa00000;
    _ram = 0;
    _ram_end = 0x40000;
    _stack_base = _ram_end;

    . = 0;
    
    .vectors : {
        LONG (_stack_base);
	LONG (_start + _flash);
	*(.vectors)
    }
    . = 0x80;
    .rodata :  { *(.rodata) }
    .data :  { *(.data) }
    .text :  { *(.text) } 
    __bss_start = .;
    .bss :  { *(.bss) }
    _end = .;
}
