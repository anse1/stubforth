#include "platform.h"
#include "types.h"

cell param_stack[1000];
cell return_stack[1000];
cell dictionary_stack[1000];

word *dictionary;

define(dict_head, 0);

define(primary, `
dnl Cons a primary word
dnl $1 - C identifier
dnl $2 - token string (default: $1)
dnl $3... - flags
undivert(1)
$1:
divert(1)
  goto next;
  static word w_$1 = {
    .name = "ifelse(`$2',`',`$1',`$2')",
    .link = dict_head,
    .code = &&$1
    ifelse(`$3',`',`',`, .$3=1')
    ifelse(`$4',`',`',`, .$4=1')
    ifelse(`$5',`',`',`, .$5=1')
    ifelse(`$6',`',`',`, .$6=1')
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
  .data = { shift($@) , EXIT}
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


dnl inner interpreter
primary(execute)
  w = *--sp;
  goto **(void **)w;

primary(exit)
  ip = *--rp; w = *ip;

primary(bye)
  return 0;


dnl stack manipulation

primary(pick)
  sp[-1] = sp[-2 - (INT)sp[-1]];

primary(drop)
  sp--;

primary(swap)
  t = sp[-1];
  sp[-1] = sp[-2];
  sp[-2] = t;

primary(dup)
  *sp = sp[-1];
  sp++;

primary(rot)
  t = sp[-1];
  sp[-1] = sp[-3];
  sp[-3] = sp[-2];
  sp[-2] = t;


dnl return stack

primary(r)
  *sp++ = rp[-1];

primary(rfrom, r>)
  *sp++ = *--rp;

primary(rto, >r)
  *rp++ = *--sp;


dnl Arithmetic/Logic

define(binop, `
primary(`$1', ifelse(`$3',`',`$2',`$3'))
    t = *--sp;
    ((INT *)sp)[-1] = ((INT *)sp)[-1] $2 (INT)t;
')

binop(mul, *)
binop(plus, +)
binop(minus, -)
binop(div, /)
binop(or, |)
binop(xor, ^)
binop(and, &)
binop(mod, %)
binop(shl, <<)
binop(shr, >>)

binop(eq, ==, =)
binop(gt, >)
binop(lt, <)

define(unop, `
primary(`$1', ifelse(`$3',`',`$2',`$3'))
    ((INT *)sp)[-1] = $2 ((INT *)sp)[-1];
')

unop(toggle, ~)
unop(negate, -)

primary(max)
  sp--;
  if ((INT)sp[0] > (INT)sp[-1])
     sp[-1] = sp[0];

primary(min)
  sp--;
  if ((INT)sp[0] < (INT)sp[-1])
     sp[-1] = sp[0];


dnl control
dnl primary(branch,,compile_only)
dnl   ip = *--sp;
dnl
dnl I/O
primary(emit)
  putchar((INT)*--sp);
  fflush(stdout);

primary(key)
  *sp++ = (cell)(INT)getchar();


dnl MEM
primary(store, !)
  p = *--sp;
  *p = *--sp;

primary(cstore, c!)
  p = *--sp;
  *(char *)p = (INT)*--sp;

primary(load, @)
  sp[-1] = **(cell **)sp[-1];

primary(cload, c@)
  ((INT *) sp)[-1] = **(char **)sp[-1];

primary(fill)
{
  unsigned char c = (INT)*--sp;
  INT n = (INT)*--sp;
  p = *--sp;
  while(n--)
    ((char *)p)[n] = c;
}


dnl dictionary
primary(allot)
  dp += (INT) *--sp;

primary(comma, `,')
  *dp++ = *--sp;

primary(here)
  *sp++ = dp;


dnl compiler
primary(lit, compile_only)
  *sp++ = *ip++;

secondary(cold, LIT, (cell)0x55, LIT, (cell) 64, SWAP, EMIT, EMIT, BYE)


dnl from fig.txt, unclassified
secondary(cr, LIT, (cell)13, EMIT)
secondary(bl, LIT, (cell)32, EMIT)


dnl convenience
dnl DUMP

undivert(1)

dictionary = dict_head;

boot:
  ip = COLD;
  *sp++ = COLD;
  goto execute;

  return 0;
}
