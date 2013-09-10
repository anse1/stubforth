
MEMORY {
       ROM : ORIGIN = 0x10000, LENGTH = 2M
       RAM : ORIGIN = 0x0c000000 , LENGTH = 4M
}

SECTIONS
{
         .text :
           {
             *(.text)
           } > ROM
         .rodata :
           {
             *(.rodata)
             *(.rodata.str1.4)
             rodata_end = .;
	     _etext = . ;
           } > ROM
         .data : AT(_etext)
           {
             *(.data)
           } > RAM
	 _data_start = ADDR(.data);
         _data_load_start = LOADADDR(.data);
         _data_end = _data_start + SIZEOF(.data);
         .bss : 
           {
             *(.bss);
           } > RAM
	 _bstart = ADDR(.bss);
	 _bend =  ADDR(.bss) + SIZEOF(.bss);

     _stack = 0x0c3c0000;
       }
