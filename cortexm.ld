MEMORY {
       rom : ORIGIN = 0x0, LENGTH = 256k
       ram : ORIGIN = 0x20000000, LENGTH = 32k
}

/* 0x00000000 flash */
/* 0x10000000 ccm data ram (stm32f4), stellarisware rom (lm4f120) */
/* 0x20000000 sram */
/* 0x40000000 dev */
/* 0x60000000 xram */
/* 0xa0000000 xdev */

SECTIONS
{
  .text : { *(.text) } >ram
  .data : { *(.data) } >ram
  .bss : { *(.bss) } > ram
  _bss_start = ADDR(.bss);
  _bss_end = ADDR(.bss) + SIZEOF(.bss);
  _stack_base = ORIGIN(ram) + LENGTH(ram) - 4;
}
