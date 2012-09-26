
GCC = gcc
CFLAGS = -O2  -g -Wall -Wcast-align
SYNC = -s

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

stubforth:  stubforth.o
	$(GCC) $(CFLAGS) -o $@ $<

%.size: % size.sh
	. ./size.sh $<
	strip $<
	ls -l $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

check: stubforth
	expect test.tcl

clean:
	rm -f *grind.out.* stubforth
	rm -f .rev.h *.o *.s stubforth.c

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

dict: user.4th stubforth
	dd if=/dev/zero of=$@ bs=1k count=128
	./stubforth dict < $<

run: dict
	./stubforth dict

wordlist: stubforth user.4th
	(cat user.4th ; echo words)|./stubforth|sort|(while read x; do echo -n "$$x ";done; echo)| fold -s > $@
