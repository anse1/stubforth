TARGET = m68k-elf
GCC = $(TARGET)-gcc
CC= $(GCC) $(CFLAGS)
CFLAGS =  -Wall -m68000 -O2
LD = $(TARGET)-ld
OBJCOPY = $(TARGET)-objcopy

TTY = /dev/ttyUSB0

VPATH = $(HOME)/src/c/vivo/:$(HOME)/ext/linux-2.6/arch/m68k/lib/

all: stub4th

config.h: .rev.h

.rev.h: .git/* .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo -n '"' >> $@

stub4th.o:  stub4th.c  *.h Makefile *.m4 config.h
	$(GCC) $(CFLAGS) -o $@ -c $<

stub4th.s:  stub4th.c  *.h Makefile *.m4 config.h
	$(GCC) $(CFLAGS) -o $@ -S $<

stub4th:  stub4th.o
	$(GCC) $(CFLAGS) -o $@ $<

%.c: %.c.m4 Makefile platform.h
	m4 -s $< > $@

check: stub4th.elf
	./test.tcl $(TTY)

clean:
	rm -f .rev.h *.o *.s stub4th.c
	rm -f *.o *.s *.elf *.srec *.brec *.bin


init:
#	stty -F $(TTY) -isig -icanon -echo -opost -onlcr -icrnl -imaxbel
	stty -F $(TTY) 9600
	echo U > $(TTY) # baud rate calibration
	sleep 0.06
	cat init.Brec  > $(TTY)
	sleep 0.06
	echo FFFFF200022410 > $(TTY) # pllcr: sysclk ½ -> full speed
	stty -F $(TTY) 19200
	sleep 0.06
	echo FFFFF902020138 > $(TTY) # ubaud
	stty -F $(TTY) 57600
	sleep 0.06
# 	echo FFFFF902020038 > $(TTY) # ubaud
# 	stty -F $(TTY) 115200
# 	echo FFFFF902020026 > $(TTY) # ubaud
# 	stty -F $(TTY) 38400
	perl -e '($$s,$$m,$$h)=localtime(time); printf("FFFFFB0004%02X%02X00%02X\n",$$h,$$m,$$s)' > $(TTY)

%.brec : %.srec
	srec_cat $< -Output $@ -B-Record

%.srec : %.elf
	$(OBJCOPY) $< -O srec $@

%.bin : %.elf
	$(OBJCOPY) $< -O binary $@

%.prog : %.brec
	cat $< > $(TTY)

%.prog : %.4th
	./infuse.tcl $(TTY) < $<

%.size : %.elf %.bin
	m68k-elf-nm -t d --size-sort --print-size $<
	m68k-elf-strip $<
	ls -l $+

.PHONY : %.prog clean %.size init

stub4th.elf : stub4th.o start.o modsi3.o mulsi3.o divsi3.o udivsi3.o umodsi3.o
	$(LD) -T vivo.ld $+ -o $@

flash.elf : flash.o stub4th.o modsi3.o mulsi3.o divsi3.o udivsi3.o umodsi3.o
	$(LD) -T vivo.ld $+ -o $@

dummy.elf : flash.o dummy.o modsi3.o mulsi3.o divsi3.o udivsi3.o umodsi3.o
	$(LD) -T vivo.ld $+ -o $@

flashload: flashload.c
	gcc -g -Wall flashload.c -o flashload

flash.prog : flash.bin flashload
	echo F > $(TTY)
	stty -F $(TTY) raw
	./flashload $< < $(TTY) > $(TTY)

dummy.prog : dummy.bin flashload
	echo F > $(TTY)
	stty -F $(TTY) raw
	./flashload $< < $(TTY) > $(TTY)

boot:
	make init stub4th.prog dragon.prog vivo.prog
