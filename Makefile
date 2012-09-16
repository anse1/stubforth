
GCC = gcc
CFLAGS = -O2  -g -Wall -Wcast-align
SYNC = -s

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

%.size: % size.sh
	. ./size.sh $<
	strip $<
	ls -l $<

%.c: %.c.m4 Makefile *.m4
	m4 $(SYNC) $< > $@

check: stub4th
	expect test.tcl

clean:
	rm -f *grind.out.* stub4th
	rm -f .rev.h *.o *.s stub4th.c

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

dict: user.4th stub4th
	dd if=/dev/zero of=$@ bs=1k count=128
	./stub4th dict < $<

run: dict
	./stub4th dict

wordlist: stub4th user.4th
	(cat user.4th ; echo words)|./stub4th|sort|(while read x; do echo -n "$$x ";done; echo)| fold -s > $@
