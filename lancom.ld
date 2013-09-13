
MEMORY {
       ROM : ORIGIN = 0x10000, LENGTH = 2M
       RAM : ORIGIN = 0x0c000000 , LENGTH = 4M
}

SECTIONS
{
         .text :
           {
             *(.text)
             *(.rodata)
             *(.rodata.str1.4)
           } > ROM

	  .vectors : 
	    {	  
	     _vector_base = .;
	     . = _vector_base + 0x100;
	     *(.exception_handler)
	     . = _vector_base + 0x600;
	     *(.interrupt_handler)
	    _etext = . ;

	     } > ROM

	   _vector_base = ADDR(.vectors);
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
