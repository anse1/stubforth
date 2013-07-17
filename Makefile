TARGET = m68k-elf
GCC = $(TARGET)-gcc
CC= $(GCC) $(CFLAGS)
#CFLAGS =  -Wall -m68000 -O2 -Wcast-align -I $(HOME)/src/c/vivo/  -fno-reorder-functions         
CFLAGS =  -ffreestanding -Wall -m68000 -O1 -Wcast-align -I $(HOME)/src/c/vivo/ 
LD = $(TARGET)-ld
OBJCOPY = $(TARGET)-objcopy

TTY = /dev/ttyUSB0

VPATH = $(HOME)/src/c/vivo/:$(HOME)/ext/linux-2.6/arch/m68k/lib/
SYNC = -s

all: stubforth

config.h: .rev.h

.rev.h: .git/* .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo -n '"' >> $@

stubforth.o:  stubforth.c  *.h Makefile *.m4 config.h platform.h
	$(GCC) $(CFLAGS) -o $@ -c $<

stubforth.s:  stubforth.c  *.h Makefile *.m4 config.h platform.h
	$(GCC) $(CFLAGS) -o $@ -S $<

stubforth:  stubforth.o
	$(GCC) $(CFLAGS) -o $@ $<

%.size: % size.sh
	. ./size.sh $<
	strip $<
	ls -l $<
	size $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

%.h: %.h.m4
	m4 -s $< > $@

check: stubforth.elf
	./test.tcl $(TTY)

clean:
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c
	rm -f *.vcg
	rm -f *.o *.s *.elf *.srec *.brec *.bin
	rm -f flashload chainload.? bblock.?.fprog block.?.fprog

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

# LIBGCC = modsi3.o mulsi3.o divsi3.o udivsi3.o umodsi3.o
LIBGCC = /usr/local/lib/gcc/m68k-elf/4.7.2/m68000/libgcc.a

stubforth.elf : stubforth.o start.o $(LIBGCC)
	$(LD) -T vivo.ld $+ -o $@

flash.elf : flash.o stubforth.o $(LIBGCC)
	$(LD) -T vivo.ld $+ -o $@

dummy.elf : flash.o dummy.o $(LIBGCC)
	$(LD) -T vivo.ld $+ -o $@

flashload: flashload.c
	gcc -g -Wall flashload.c -o flashload

dummy.prog : dummy.bin flashload
	stty -F $(TTY) raw
	echo flash dup dup funlock ferase fstrap > $(TTY)
	./flashload $< < $(TTY) > $(TTY)
	sendbreak > $(TTY)

boot:
	make init
	make stubforth.prog
	make user

user:
	make user.prog
	make dragon.prog
	make flash.prog
	make chainload.4th
	make vivo.prog
	make display.prog
	make touch.prog
	make mset.prog

block.0.bin : flash.bin
	cp flash.bin block.0.bin

bblock.%.bin:
	rm -f $@
	for f in $+; do echo ".( loading $$f…) lf " ; cat $$f ; done > tmp-$@
	stat -c %s tmp-$@
	[[ 8192 -ge $$(stat -c %s tmp-$@) ]]
	mv tmp-$@ $@

chainload.4th:
	:

chainload.%:
	echo $(@:chainload.%=%) fbblock chainload > $@
	touch -r chainload.4th $@

bblock.0.bin: user.4th dragon.4th flash.4th chainload.4th chainload.1
bblock.1.bin: vivo.4th display.4th chainload.2
bblock.2.bin: touch.4th chainload.3
bblock.3.bin: mset.4th # chainload.4

sourceblocks: bblock.0.fprog bblock.1.fprog bblock.2.fprog bblock.3.fprog
blocks: block.0.fprog sourceblocks

bblock.%.fprog: bblock.%.bin flashload
	stat -c %s $<
	[[ 8192 -ge $$(stat -c %s $<) ]]
	stty -F $(TTY) raw
	echo $(<:bblock.%.bin=%) fbblock dup dup funlock ferase fstrap > $(TTY)
	./flashload < $(TTY) > $(TTY) $<
	sendbreak > $(TTY)
	touch $@

block.%.fprog: block.%.bin flashload
	stat -c %s $<
	[[ 65536 -ge $$(stat -c %s $<) ]]
	stty -F $(TTY) raw
	echo $(<:block.%.bin=%) fblock dup dup funlock ferase fstrap > $(TTY)
	./flashload < $(TTY) > $(TTY) $<
	sendbreak > $(TTY)
	touch $@

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

%.o : %.4th
	$(OBJCOPY) -I binary -B arm -O elf32-littlearm \
	 --rename-section .data=.rodata,alloc,load,readonly,data,contents \
	 $< $@
