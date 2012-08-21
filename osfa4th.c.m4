#include <stdio.h>
#include "types.h"

cell param_stack[10000];
cell return_stack[10000];
cell dictionary_stack[10000];

word *dictionary;

define(dict_head, 0);
define(primary, `
undivert(1)
$1:
divert(1)
  static word w_$1 = {
    .name = "ifelse(`$2',`',`$1',`$2')",
    .link = dict_head,
    .code = &&$1
  };
divert(0)
  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')

define(secondary, `
undivert(1)
static word w_$1 = {
  .name = "$1",
  .link = dict_head,
  .code = &&enter,
  .data = { shift($@) }
};

  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')

int main()
{
  cell *ip, *sp, *rp, *dp, *w;
  cell *p, t;

  sp = param_stack;
  rp = return_stack;
  dp = dictionary_stack;

  goto boot;

enter:
  *rp++ = ip;
  ip = w + 1;

next:
  w = *ip++;
  goto **(void **)w;

primary(execute)
  w = *--sp;
  goto **(void **)w;

primary(exit)
  ip = *--rp; w = *ip;
  goto next;

dnl I/O
primary(emit)
  putchar((INT)*--sp);
  fflush(stdout);
  goto next;

primary(key)
  *sp++ = (cell)(INT)getchar();
  goto next;

dnl MEM
primary(store, !)
  p = *--sp;
  *p = *--sp;
  goto next;

primary(load, @)
  sp[-1] = **(cell **)sp[-1];
  goto next;

primary(lit)
  *sp++ = *ip++;
  goto next;

primary(bye)
  return 0;

dnl Arithmetic

define(binop, `
primary(`$1', `$2')
    t = *--sp;
    ((INT *)sp)[-1] $2= (INT)t;
    goto next;
')

binop(mul, *)
binop(plus, +)
binop(minus, -)
binop(div, /)
binop(or, |)
binop(xor, ^)
binop(and, &)
binop(mod, %)

undefine(`binop')

secondary(cold, LIT, (cell)0x55, LIT, (cell)1, MINUS, EMIT, BYE)

undivert(1)

dictionary = dict_head;

boot:
  ip = COLD;
  *sp++ = COLD;
  goto execute;

  return 0;
}
