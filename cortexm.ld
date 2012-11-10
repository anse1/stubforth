
/* 0x00000000 flash */
/* 0x10000000 ccm data ram (stm32f4), stellarisware rom (lm4f120) */
/* 0x20000000 sram */
/* 0x40000000 dev */
/* 0x60000000 xram */
/* 0xa0000000 xdev */

SECTIONS
{
  . = 0x20000000;
  .text : { *(.text) }
  .data : { *(.data) }
  .bss : { *(.bss) }
}
