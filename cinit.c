/* copy & paste from GNU ld documentation. */

extern char etext, data, edata, bstart, bend;

void _cinit(void) {
     char *src = &etext;
     char *dst = &data;

     /* ROM has data at end of text; copy it.  */
     while (dst < &edata)
       *dst++ = *src++;

     /* Zero bss.  */
     for (dst = &bstart; dst< &bend; dst++)
       *dst = 0;
}

