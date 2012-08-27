#include <stdio.h>

#define QUIET

int main(int argc, char *argv[])
{
  FILE *f = fopen(argv[1], "r");
  int c;
  int e;
  int count = 0;

  while ((c = fgetc(f)) > -1) {
    putchar(c);
    if ((e = getchar()) != c) {
      fprintf(stderr, "bogus echo: 0x%x, expected: 0x%x\n", e, c);
      fprintf(stderr, "offset in input: 0x%x\n", count);
      return 1;
    }
#ifndef QUIET
    if ((e = getchar()) != c) {
      fprintf(stderr, "bogus 2nd echo: 0x%x, expected: 0x%x\n", e, c);
      fprintf(stderr, "offset in input: 0x%x\n", count);
      return 2;
    }
#endif

    if((count%1024) == 0) {
      fprintf(stderr, "written: 0x%x\n", count);
      fflush(stderr);
    }
    count++;
  }
  fprintf(stderr, "total: 0x%x\n", count);
  return 0;
}
