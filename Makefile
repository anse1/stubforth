T=/dev/ttyUSB0
SHGCC = sh-elf-gcc
SHCFLAGS = -O2 -m3 -g -Wall -Wcast-align -ffreestanding -fno-strict-aliasing -mrenesas
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

% : %.c
% : %.S


test : init.o  # test.o
	sh-elf-ld -T lancom.ld $+ -o $@

%.bin: %
	sh-elf-objcopy $<  -O binary $@

%.D : %
	sh-elf-objdump -b binary -m sh3  -D  $<

stubforth.s:  stubforth.c  *.h Makefile *.m4 config.h
	$(SHGCC) $(SHCFLAGS) -o $@ -S $<

stubforth:  stubforth.o
	$(SHGCC) $(SHCFLAGS) -o $@ $<

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

TAGS: .
	ctags-exuberant -e  --langdef=forth --langmap=forth:.4th.m4 \
	--regex-forth='/: *([^ ]+)/\1/' \
	--regex-forth='/(primary|secondary|constant|master)\([^,]+, ([^,\)]+)/\2/' \
	--regex-forth='/(primary|secondary|constant|master)\(([a-z0-9_]+)/\2/' \
	 *.4th *.c.m4 *.m4
	shopt -s nullglob; ctags-exuberant -e -a --language-force=c *.c *.h *.m4

%.o : %.4th
	$(OBJCOPY) -I binary -B arm -O elf32-littlearm \
	 --rename-section .data=.rodata,alloc,load,readonly,data,contents \
	 $< $@

image.upx:  test.bin upx Makefile
	cp ~/ext/lancom/ftp.lancom.de/LANCOM-Archive/LC-DSL-I-10/LC-DSLI10-A-CV-2.11.0007.upx $@ 
	chmod u+w $@
# 	: arrange for test.bin to be loaded at 0x20000
# 	dd if=test.bin of=$@ bs=1 seek=65920  conv=notrunc
	: overwrite code with test.bin
	dd if=test.bin of=$@ bs=1 seek=12496 conv=notrunc
	: fix checksums
	./upx  $@

flash: image.upx
	expect wipe.tcl $T
	./upxload.sh $<
	touch flash
