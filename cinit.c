/* copy & paste from GNU ld documentation. */

extern char data_start[], data_load_start[], data_end[], bstart[], bend[];

void cinit(void) {
     char *src = data_load_start;
     char *dst = data_start;

     /* ROM has data at end of text; copy it.  */
     while (dst < data_end)
       *dst++ = *src++;

     /* Zero bss.  */
     for (dst = bstart; dst< bend; dst++)
       *dst = 0;
}

