
/* stm32f405: 0x10000000 64kB ccm data ram */

SECTIONS {
   . = 0x10000000;
   .ccm : { *(.ccm) }
   _ccm_end = .;
  _stack_base = 0x10010000;
}
