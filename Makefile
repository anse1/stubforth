-include config.mak

GCC ?= msp430-gcc
CFLAGS ?= -O2  -g -Wall -Wcast-align -Os -mmcu=msp430g2553
SYNC ?= -s
OBJCOPY = msp430-objcopy

all: stubforth

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

stubforth:  stubforth.o builtin.o
	$(GCC) $(CFLAGS) -Wl,platform.x  -o $@ $+

prog: stubforth 
	mspdebug rf2500 erase "load $<"
	touch .prog

%.size: % size.sh
	size $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

check: stubforth
	expect test.tcl

clean:
	rm -f symbols.h symbols.4th symbols.gdb builtin.4th
	rm -f TAGS
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c
	rm -f *.vcg

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

builtin.4th: launchpad.4th
	echo "lf .( Loading $@...) lf" > $@
	for f in $+; do echo " .( Loading $$f...) lf "; cat $$f ; done >> $@
	echo ".( Ready.) lf" >> $@
	dd if=/dev/zero of=$@ bs=1 count=1 oflag=append conv=notrunc

source.o : builtin.4th

%.o : %.4th
	$(OBJCOPY) -I binary -B msp430:430  -O elf32-msp430 \
	 --rename-section .data=.rodata.4th,alloc,load,readonly,data,contents \
	 $< $@
