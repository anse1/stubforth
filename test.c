#include "stubforth.h"
#include "platform.h"


const char *eae = "Each and everyone will die at my hands, choking in warm ponds of blood.\n\r";

char mooo[10] = { 'b', 'u', 'h', '\n', '\r', 0};

const char *tqbf = "The quick brown fox jumps over the lazy dog.\n\r";

int bss = 0;
int data = '@';
int deadbeef = 0xdeadbeef;


int main (void) {
  int i = 0;
  const char *s = "Hello World!\n\r";
  initio();

  while (*s) {
    putchar(*s++);
  }
  putchar(data);
  putchar(bss);
  putchar('\n');
  putchar('\r');

  while (i++ < 100000) {
    *LED18 = 0x50;
    *LED18 = 0xA0;
  }

  s = mooo;
  while (*s) {
    putchar(*s++);
  }

  while(1) {
    putchar(getchar());
  }

  return 0;
}
