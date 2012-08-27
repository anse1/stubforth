#include "MC68EZ328.h"

static int putchar(int c)
{
  if (c=='\n')
    putchar('\r');

  while (! (UTX & UTX_TX_AVAIL))
        ;
  UTX_TXDATA = c;

  return 0;
}

static int cprint(int i)
{
  char *hex = "0123456789abcdef";
  int j;
  for (j=8 * sizeof(i) - 4; j>=0; j-=4) {
    putchar(hex[0xf & (i>>j)]);
  }
  putchar('\n');
  return 0;
}

static void my_puts(const char *s) {
  while (*s)
    putchar(*s++);
}

int main() {

  my_puts("\r\nI'm alive!\n");
  return 0;
}
