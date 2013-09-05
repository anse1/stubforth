#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <assert.h>
#include <stdio.h>
#include <errno.h>
#include <stdint.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include <unistd.h>

#include <arpa/inet.h>

#define UPX_DATE 0x45
#define UPX_START 0x32
#define UPX_LENGTH 0x36
#define UPX_ENTRY 0x3a
#define UPX_DESCRIPTOR_SUM 0x00
#define UPX_CHECKSUM_BLOCK_SUM 0x80

#define WORDP_AT(x) ((uint16_t *)(((uint8_t *)map)+x))
#define LONGP_AT(x) ((uint32_t *)(((uint8_t *)map)+x))
#define BYTEP_AT(x) ((uint8_t *)(((uint8_t *)map)+x))

#define WORD_AT(x) ntohs(*WORDP_AT(x))
#define LONG_AT(x) ntohl(*LONGP_AT(x))
#define BYTE_AT(x) map[x]

#define error(msg)					\
  do { perror(msg); exit(EXIT_FAILURE); } while (0)


int sum8(unsigned char *map, int count) {
  int sum = 0;
  for(int i=0; i<count; i++) {
    sum += map[i];
  }
  return sum & 0xffff;
}

int main (int argc, char *argv[]) {
  int fd = open(argv[1], O_RDWR);

  if (fd == -1)
    fd = open(argv[1], O_RDONLY);

  if (fd == -1)
    error("open");

  off_t size = lseek(fd, 0, SEEK_END);

  if (size == (off_t) -1)
    error("lseek");

  char *map = mmap(NULL, 1<<24, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);

  if (!map)
    error("mmap");

  printf("    rom descriptor\n"
	 "\tstart\tlength\tentry\tascii\n"
	 "\t%x\t%d\t%x\t%s \n"
	 , LONG_AT(UPX_START), LONG_AT(UPX_LENGTH), LONG_AT(UPX_ENTRY), &map[UPX_DATE]);

  printf("    checksum of rom descriptor: %04x <- %04x.\n", 0xffff - sum8(&map[2], 126), WORD_AT(0));
  *WORDP_AT(UPX_DESCRIPTOR_SUM) = htons(0xffff - sum8(&map[2], 126));

  for (int chk_block=0x80;chk_block < size;chk_block += 0x80 + 63*1024) {
    int offset = chk_block;
    int from_file = WORD_AT(offset);
    offset +=2;
    int computed = 0xffff - sum8(&map[offset], 126);

    assert(computed == from_file);

    printf("    checksum block found at offset %06x: %04x <- %04x.\n", offset, computed, from_file);

      for(int sum=0; sum<63; sum++) {
	int data_offset = sum * 0x400 + chk_block + 0x80;

	if (data_offset >= size) {
	  puts("EOF");
	  exit(0);
	}
	int from_file = WORD_AT(chk_block + 2 + sum*2);
	int computed = 0xffff - sum8(&map[data_offset], 1024);

	if (computed != from_file) {
	  printf("\tchecksum of block %03d at data offset %06x: %04x <- %04x.\n", sum, data_offset, computed, from_file);
	  *WORDP_AT(chk_block + 2 + sum*2) = htons(computed);
	  *WORDP_AT(chk_block) = htons(0xffff - sum8(&map[2+chk_block], 126));
	}

    }
  }
  return 0;
}

