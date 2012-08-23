
all: stub4th

config.h: gitrev.h

gitrev.h: .
	echo -n \#define GIT_REVISION \"  > gitrev.h
	echo -n $$(git describe --always --dirty) >> gitrev.h
	echo -n '"' >> gitrev.h

stub4th:  stub4th.c  *.h Makefile *.m4 config.h
	gcc -O3 -m32  -g -Wall -o $@ -c $<

stub4th:  stub4th.o
	gcc -O3 -m32  -g -Wall -o $@ $<
	echo "1 2 3 4 5 + * ." | ./$@

%.size: %
	nm -t d --size-sort --print-size $<

%.c: %.c.m4 Makefile
	m4 -s $< > $@

