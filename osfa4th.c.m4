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
    .code = { .a = &&$1 }
    ifelse(`$3',`',`',`, .$3=1')
    ifelse(`$4',`',`',`, .$4=1')
    ifelse(`$5',`',`',`, .$5=1')
    ifelse(`$6',`',`',`, .$6=1')
  };
divert(0)
  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')

define(`init_union', `ifelse(`$1',,,`{ $1 } ifelse(`$2',,,`,') init_union(shift($@))') ')

define(secondary, `
undivert(1)
static word w_$1 = {
  .name = "$1",
  .link = dict_head,
  .code.a = &&enter,
  .data = { init_union(shift($@)) , {EXIT}}
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
  cell *ip, *sp, *rp, *w, *dp;
  cell t;

  vmstate.base = 10;

primary(abort)
  sp = param_stack;
  rp = return_stack;
  dp = dictionary_stack;
  my_puts("abort\n");
  putchar(10);
  goto boot;

enter:
  (rp++)->a = ip;
  ip = w + 1;
next:
  w = (ip++)->a;
  goto **(void **)w;


dnl inner interpreter
primary(execute)
  w = (--sp)->a;
  goto *(w->aa);

primary(exit)
  ip = (--rp)->a; w = ip->a;

primary(bye)
  return 0;


dnl stack manipulation

primary(pick)
  sp[-1] = sp[-2 - sp[-1].i];

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

primary(over)
  *sp = sp[-2];
  sp++;


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
    sp[-1].i = sp[-1].i $2 t.i;
')

binop(mul, *)
binop(add, +)
binop(sub, -)
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
    sp[-1].i = $2 sp[-1].i;
')

unop(toggle, ~)
unop(negate, -)
unop(nullp, !, 0=)

primary(max)
  sp--;
  if (sp[0].i > sp[-1].i)
     sp[-1] = sp[0];

primary(min)
  sp--;
  if (sp[0].i < sp[-1].i)
     sp[-1] = sp[0];

primary(plus1, 1+)
  sp[-1].i++;


dnl control

dnl --
primary(branch, , compile_only)
   ip += ip->i;

dnl f --
primary(zbranch, 0branch, compile_only)
   if ((--sp)->i)
      ip++;
   else
      ip += ip->i;

dnl I/O

dnl c --
primary(emit)
  putchar((--sp)->i);
  fflush(stdout);

dnl --
primary(hex)
  vmstate.base = 16;

dnl --
primary(decimal)
  vmstate.base = 10;

dnl -- c
primary(key)
  (sp++)->i = getchar();

dnl n --
primary(print, .)
{
  t.i = (--sp)->i;
  char *hex = "0123456789abcdef";
  int j;
  for (j=4 * sizeof(cell) - 4; j>=0; j-=4) {
    putchar(hex[0xf & (t.i>>j)]);
  }
  putchar(32);
  fflush(stdout);
}


dnl MEM
primary(store, !)
  *(sp[-1].aa) = sp[-2].a;
  sp -= 2;

primary(cstore, c!)
  *sp[-1].s = sp[-2].i;
  sp -= 2;

primary(load, @)
  sp[-1].a = *sp[-1].aa;

primary(cload, c@)
  sp[-1].i = *sp[-1].s;

primary(fill)
{
  unsigned char c = (--sp)->i;
  int n = (--sp)->i;
  t = *--sp;
  while(n--)
    t.s[n] = c;
}


dnl strings

primary(number)
dnl addr -- n
dnl convert string at addr to number
dnl on failure, abort
{
  t.i = 0;
  char *s = sp[-1].s;
  int c;
  while ((c = *s)) {
   if (c <= 58)
      c -= 48;
   else
    {
      c |= 1 << 5;
      c -= 87;
    }
   if (c < 0 || c >= vmstate.base) {
      dp = (cell *)s; /* TODO: sanity check */
      goto abort;
   }
   t.i *= vmstate.base;
   t.i += c;
   s++;
  }
  sp[-1] = t;
}

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
  (sp++)->s = (char *)dp;
  dp = (cell *)s;
}


dnl dictionary

primary(allot)
dnl n -- increase dictionary pointer
  dp += (--sp)->i;

primary(comma, `,')
  *dp++ = *--sp;

primary(here)
dnl ( -- a ) push dictionary pointer onto parameter stack
  (sp++)->a = dp;

primary(type)
dnl ( s -- ) send zstring
{
  char *s = (--sp)->s;
  my_puts(s);
}

primary(forget)
dnl ( a -- ) set dictionary pointer to a
  dp = (--sp)->a;

primary(find)
dnl addr -- cfa tf (found) -- addr ff (not found)
dnl find string at address a
dnl string is deallocated when found
{
   word *p = dictionary;
   char *s = sp[-1].s;
   while(p) {
      if(0 == strcmp(p->name, s)) {
         dp = (cell *) s; /* TODO: sanity check */
	 sp--;
         (sp++)->a = &p->code;
         (sp++)->i = 1;
	 goto next;
      }
      p = p->link;
   }
   (sp++)->i = 0;
}


dnl compiler
primary(lit, compile_only)
  *sp++ = *ip++;


dnl from fig.txt, unclassified
secondary(cr, LIT, .i=13, EMIT)
secondary(lf, LIT, .i=10, EMIT)
secondary(crlf, CR, LF)
secondary(bl, LIT, .i=32, EMIT)

secondary(repl, WORD, FIND, ZBRANCH, .i=4, EXECUTE, BRANCH, .i=2, NUMBER, BRANCH, .i=-9)

secondary(test, WORD, TYPE, BRANCH,  .i=-3)
secondary(testdict, WORD, FIND, PRINT, PRINT, BRANCH, .i=-5)

secondary(hi, LIT, .s= "Hello world\n", TYPE)
secondary(cold, HI, REPL, BYE)


dnl convenience
dnl DUMP

undivert(1)

boot:
  dictionary = dict_head;
  ip = 0;
  (sp++)->a = REPL;
  goto execute;

  return 0;
}
