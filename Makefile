-include config.mak

TTY ?= /dev/ttyACM0

GCC ?= arm-none-eabi-gcc
OBJCOPY ?= arm-none-eabi-objcopy
CFLAGS ?= -O2 -g -Wall -mcpu=cortex-m4 -mthumb 
SYNC ?= -s
LIBGCC ?= $(shell $(GCC) -print-libgcc-file-name)
LDFLAGS ?= -Wl,-Tcortexm.ld -nostdlib $(LIBGCC)

GCC ?= gcc
CFLAGS ?= -O2  -g -Wall -Wcast-align
SYNC ?= -s

all: stubforth.elf

config.h: .rev.h

.rev.h: .git/* .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo  '"' >> $@
	echo -n \#define COMPILER \"  >> $@
	echo -n "$$($(GCC) --version|sed q)" >> $@
	echo  '"' >> $@

stubforth.o:  stubforth.c  *.h Makefile *.m4 config.h symbols.h platform.h
	$(GCC) $(CFLAGS) -o $@ -c $<

stubforth.s:  stubforth.c  *.h Makefile *.m4 config.h symbols.h platform.h
	$(GCC) $(CFLAGS) -o $@ -S $<

start.o: start.S
	$(GCC) $(CFLAGS) -c $< -o $@

size: stubforth.elf.size

stubforth.elf:  start.o stubforth.o source.o cortexm.ld
	$(GCC) $(CFLAGS) $(LDFLAGS) -o $@ $+ $(LIBGCC)

%.size: % size.sh
	. ./size.sh $<
	ls -l $<
	size $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

check: stubforth.elf
	expect test.tcl $(TTY)

clean:
	rm -f symbols.h symbols.4th symbols.gdb
	rm -f TAGS
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c
	rm -f *.vcg *.elf
	rm -f *.vcg
	rm -f builtin.4th

symbols.%: symto%.m4 symbols.m4
	m4 $< > $@

dev:	symbols.gdb TAGS

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

BINFMT = arm
ELFFMT = elf32-littlearm

builtin.4th: user.4th symbols.4th cortexm.4th launchpad.4th
	echo ".( Loading $@...) lf" > $@
	cat $+ >> $@
	echo ".( Ready.) lf" >> $@
	dd if=/dev/zero of=$@ bs=1 count=1 oflag=append conv=notrunc

source.o : builtin.4th
	$(OBJCOPY) -I binary -B $(BINFMT) -O $(ELFFMT) \
	 --rename-section .data=.rodata.4th,alloc,load,readonly,data,contents \
	 $< $@
