
all: stub4th

config.h: .rev.h

.rev.h: .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo -n '"' >> $@

stub4th.o:  stub4th.c  *.h Makefile *.m4 config.h
	gcc -O3 -m32  -g -Wall -o $@ -c $<

stub4th:  stub4th.o
	gcc -O3 -m32  -g -Wall -o $@ $<

%.size: %
	nm -t d --size-sort --print-size $<

%.c: %.c.m4 Makefile
	m4 -s $< > $@

check: stub4th
	echo hi | ./$<
	@echo
