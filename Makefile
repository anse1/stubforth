TTY=/dev/ttyACM0

CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
CFLAGS =    -O2 -g -Wall -mcpu=cortex-m4 -mthumb 
SYNC = -s
LIBGCC = $(shell $(CC) -print-libgcc-file-name)

LDFLAGS= -Wl,-Tcortexm.ld -nostdlib $(LIBGCC)

all: stubforth.elf

config.h: .rev.h

.rev.h: .git/* .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo -n '"' >> $@

stubforth.o:  stubforth.c  *.h Makefile *.m4 config.h
	$(CC) $(CFLAGS) -o $@ -c $<

stubforth.s:  stubforth.c  *.h Makefile *.m4 config.h
	$(CC) $(CFLAGS) -o $@ -S $<

start.o: start.S
	$(CC) $(CFLAGS) -c $< -o $@

size: stubforth.elf.size

stubforth.elf:  start.o stubforth.o source.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+

%.size: % size.sh
	. ./size.sh $<
	ls -l $<
	size $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

check: stubforth.elf
	expect test.tcl $(TTY)

clean:
	rm -f TAGS
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c
	rm -f *.vcg *.elf
	rm -f *.vcg
	rm -f builtin.4th

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

BINFMT = arm
ELFFMT = elf32-littlearm

builtin.4th: user.4th cortexm.4th discoveryf4.4th
	cat $+ > $@
	dd if=/dev/zero of=$@ bs=1 count=1 oflag=append conv=notrunc

source.o : builtin.4th
	$(OBJCOPY) -I binary -B $(BINFMT) -O $(ELFFMT) \
	 --rename-section .data=.rodata.4th,alloc,load,readonly,data,contents \
	 $< $@
