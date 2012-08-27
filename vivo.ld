
/* MEMORY { */
/*    ram   : ORIGIN = 0x0, LENGTH =  0x40000 */
/* /\*  flash [RX]  : ORIGIN = 0x800000, LENGTH =  0x200000  *\/ */
/* } */

ENTRY(_start)

SECTIONS 
{
    . = 0;
    .vectors : { *(.vectors) }
    . = 0x100;
    .rodata :  { *(.rodata) }
    .data :  { *(.data) }
    .text :  { *(.text) } 
    __bss_start = .;
    .bss :  { *(.bss) }
    _end = .;
    _stack_base = 0x40000 - 4;
}
