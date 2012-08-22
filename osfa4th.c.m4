#include "platform.h"
#include "types.h"

cell param_stack[1000];
cell return_stack[1000];
cell dictionary_stack[1000];

word *dictionary;

struct vmstate vmstate;

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

static int strcmp(const char *a, const char *b) {
  while (*a && *b && *a == *b)
     a++, b++;
  return (*a == *b) ? 0 : (*a > *b) ? 1 : -1;
}

static void my_puts(const char *s) {
  while (*s)
    putchar(*s++);
}

int main()
{
  cell *ip, *sp, *rp, *dp, *w;
  cell *p, t;

  vmstate.base = 10;

primary(abort)
  sp = param_stack;
  rp = return_stack;
  dp = dictionary_stack;
  my_puts("abort\n");
  putchar(10);
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

primary(plus1, 1+)
  ((INT *)sp)[-1]++;


dnl control

dnl --
primary(branch, , compile_only)
   ip += (INT)*ip;

dnl f --
primary(zbranch, 0branch, compile_only)
   if (*--sp)
      ip++;
   else
      ip += (INT)*ip;

dnl I/O

dnl c --
primary(emit)
  putchar((INT)*--sp);
  fflush(stdout);

dnl --
primary(hex)
  vmstate.base = 16;

dnl --
primary(decimal)
  vmstate.base = 10;

dnl -- c
primary(key)
  *sp++ = (cell)(INT)getchar();

dnl n --
primary(print, .)
{
  INT i = (INT) *--sp;
  char *hex = "0123456789abcdef";
  int j;
  for (j=4 * sizeof(cell) - 4; j>=0; j-=4) {
    putchar(hex[0xf & (i>>j)]);
  }
  putchar(32);
  fflush(stdout);
}


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
dnl ( n -- ) increase dictionary pointer
  dp += (INT) *--sp;

primary(comma, `,')
  *dp++ = *--sp;

primary(here)
dnl ( -- a ) push dictionary pointer onto parameter stack
  *sp++ = dp;

primary(word)
dnl ( -- a ) read a word, return zstring allocated on dictionary stack
{
   int c;
   char *s = (char *)dp;
   do {
      c = getchar();
      *s++ = c;
   } while (IS_WORD(c));
  s[-1] = 0;
  *sp++ = dp;
  dp = (cell *)s;
}

primary(type)
dnl ( a -- ) send string at address a
{
  char *s = (char *) (*--sp);
  puts(s);
}

primary(free)
dnl ( a -- ) set dictionary pointer to a
  dp = *--sp;


dnl compiler
primary(lit, compile_only)
  *sp++ = *ip++;

primary(find)
dnl addr -- cfa tf (found) -- addr ff (not found)
dnl find string at address a
{
   word *p = dictionary;
   char *s = sp[-1];
   while(p) {
      if(0 == strcmp(p->name, s)) {
          sp--;
         *sp++ = &p->code;
         *sp++ = (cell)1;
	 goto next;
      }
      p = p->link;
   }
   *sp++ = 0;
}

primary(number)
dnl addr -- n
dnl convert string at addr to number
dnl on failure, abort
{
  INT n = 0;
  char *s = sp[-1];
  int c;
  while ((c = *s)) {
   if (c <= 58)
      c -= 48;
   else
      c -= 87;
   if (c < 0 || c >= vmstate.base)
      goto abort;
   n *= vmstate.base;
   n += c;
   s++;
  }
  sp[-1] = (cell)n;
}


dnl from fig.txt, unclassified
secondary(cr, LIT, (cell)13, EMIT)
secondary(lf, LIT, (cell)10, EMIT)
secondary(crlf, CR, LF)
secondary(bl, LIT, (cell)32, EMIT)

secondary(quit, WORD, FIND, ZBRANCH, (cell)4, EXECUTE, BRANCH, (cell)2, NUMBER, BRANCH, (cell)-9)

secondary(test, WORD, TYPE, BRANCH, (cell) -3)
secondary(testdict, WORD, FIND, PRINT, PRINT, BRANCH, (cell) -5)

secondary(cold, LIT, (cell) "Hello world\n", TYPE, QUIT, BYE)


dnl convenience
dnl DUMP

undivert(1)

boot:
  dictionary = dict_head;
  ip = QUIT;
  *sp++ = QUIT;
  goto execute;

  return 0;
}
