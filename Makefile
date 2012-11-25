
GCC = gcc
CFLAGS = -O2  -g -Wall -Wcast-align
SYNC = -s
OBJCOPY = objcopy
all: stubforth

config.h: .rev.h

.rev.h: .git/* .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo -n '"' >> $@

stubforth.o:  stubforth.c  *.h Makefile *.m4 config.h
	$(GCC) $(CFLAGS) -o $@ -c $<

stubforth.s:  stubforth.c  *.h Makefile *.m4 config.h
	$(GCC) $(CFLAGS) -o $@ -S $<

stubforth:  stubforth.o source.o
	$(GCC) $(CFLAGS) -o $@ $+

%.size: % size.sh
	. ./size.sh $<
	strip $<
	ls -l $<
	size $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

check: stubforth
	expect test.tcl

clean:
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c
	rm -f *.vcg
	rm -f builtin.4th

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

builtin.4th: user.4th
	cat $+ > $@
	dd if=/dev/zero of=$@ bs=1 count=1 oflag=append conv=notrunc

BINFMT = i386:x86-64
ELFFMT = elf64-x86-64
source.o : builtin.4th
	$(OBJCOPY) -I binary -B $(BINFMT) -O $(ELFFMT) \
	 --rename-section .data=.rodata.4th,alloc,load,readonly,data,contents \
	 $< $@
