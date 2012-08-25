
/* MEMORY { */
/*    ram   : ORIGIN = 0x0, LENGTH =  0x40000 */
/* /\*  flash [RX]  : ORIGIN = 0x800000, LENGTH =  0x200000  *\/ */
/* } */

ENTRY(_start)

SECTIONS 
{
    . = 0;
   .vectors : { *(.vectors) } = 0
   . = 0x200;
   .text : SUBALIGN(4) { *(.text) } 
   .rodata : SUBALIGN(4) { *(.rodata) }
   .data : SUBALIGN(4) { *(.data) }
    __bss_start = .;
    .bss : SUBALIGN(4) { *(.bss) }
    _end = .;

}

