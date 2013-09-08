T=/dev/ttyUSB0
SHGCC = sh-elf-gcc
SHCFLAGS = -O2 -m3  -lgcc -g -Wall -Wcast-align -nostdlib -nostartfiles -ffreestanding -fno-strict-aliasing -mrenesas
SYNC = -s
CFLAGS = -std=c99

all: stubforth

config.h: .rev.h

.rev.h: .git/* .
	echo -n \#define REVISION \"  > $@
	echo -n $$(git describe --always --dirty) >> $@
	echo -n '"' >> $@

stubforth.o:  stubforth.c  *.h Makefile *.m4 config.h
	$(SHGCC) $(SHCFLAGS) -o $@ -c $<


%.o : %.S
	sh-elf-as  --big  -c $< -o $@

%.o : %.c 
	$(SHGCC) $(SHCFLAGS) -o $@ -c $<

%.c : platform.h

% : %.c
% : %.S


test : init.o cinit.o test.o
	sh-elf-gcc $(SHCFLAGS) -Wl,-T lancom.ld $+ -lgcc  -o $@

%.bin: %
	sh-elf-objcopy $<  -O binary $@

%.D : %
	sh-elf-objdump -b binary -m sh3  -D  $<

stubforth.s:  stubforth.c  *.h Makefile *.m4 config.h
	$(SHGCC) $(SHCFLAGS) -o $@ -S $<

stubforth:  init.o cinit.o stubforth.o builtin.o
	sh-elf-gcc $(SHCFLAGS) -Wl,-T lancom.ld $+ -lgcc  -o $@

stubforth: lancom.ld
test: lancom.ld

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
	rm -f test test.o
	rm -f test.o test test.bin
	rm -f builtin.4th
	rm -f stubforth.upx test.upx upx *.padded *.flash
	rm -f *.bin

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

%.o : %.4th
	sh-elf-objcopy -I binary -B sh -O elf32-sh \
	--rename-section .data=.rodata,alloc,load,readonly,data,contents \
	 $< $@

builtin.4th: user.4th lancom.4th
	echo '.( Loading builtin.4th...)' > $@
	cat $+ >> $@
	echo '.( ready.) lf ' >> $@
	echo 0 redirect ! >> $@

%.padded: %.bin
	cp $< $@
	let size=$$(stat --format="%s" $<) ; \
	dd if=/dev/zero bs=1 count=$$(((((size+1023)/1024)*1024)-size)) \
		conv=notrunc oflag=append of=$@

%.upx:  %.padded upx Makefile head.upx
	dd if=head.upx of=$@
	dd bs=1 seek=256 if=$< count=$$(stat --format="%s" $<) of=$@
	./upx $@ $$(stat --format="%s" stubforth.bin)

upx: upx.c
	gcc -std=c99 $< -o $@

%.flash: %.upx
	expect wipe.tcl $T
	./upxload.sh $<
	touch $@
