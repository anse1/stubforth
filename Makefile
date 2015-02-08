-include config.mak

GCC ?= gcc
CFLAGS ?= -O2  -g -Wall -Wcast-align
SYNC ?= -s
LDFLAGS ?= -ldl

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

stubforth:  stubforth.o
	$(GCC) $(CFLAGS) -o $@ $< $(LDFLAGS)

%.size: % size.sh
	. ./size.sh $<
	strip $<
	ls -l $<
	size $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

check: stubforth $(HOME)/.stubforth
	expect test.tcl

clean:
	rm -f symbols.h symbols.4th symbols.gdb
	rm -f TAGS
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c
	rm -f *.vcg
	rm -f $(HOME)/.stubforth

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

dict: $(HOME)/.stubforth

$(HOME)/.stubforth: user.4th platform.4th stubforth
	dd if=/dev/zero of=$(HOME)/.stubforth bs=1k count=128
	( cat user.4th platform.4th; echo sync bye ) | ./stubforth

run: $(HOME)/.stubforth
	./stubforth

install: stubforth
	cp $< $(HOME)/bin/
