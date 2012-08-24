#include "platform.h"
#include "types.h"
#include "config.h"

cell return_stack[1000];
cell param_stack[1000];
cell dictionary_stack[1000];

word *dictionary;

struct vmstate vmstate = { .dp = dictionary_stack };

define(dict_head, 0);

dnl $1 - ANS94 error code
define(`cthrow', `
{
  vmstate.errno = $1;
  vmstate.errstr = "$2";
  goto abort;
}')

define(`chkalign', `
  if ((int)vmstate.dp & (__alignof__(cell)-1))
    cthrow(-23,address alignment)
')

define(primary, `
dnl Cons a primary word
dnl $1 - C identifier
dnl $2 - forth word (default: $1)
dnl $3... - flags
undivert(1)
$1:
dnl puts("p$1\n");
divert(1)
  goto next;
  static word w_$1 = {
    .name = "ifelse(`$2',`',`$1',`$2')",
    .link = dict_head,
    .code = &&$1
    dnl optional flags
    ifelse(`$3',`',`',`, .$3=1')
    ifelse(`$4',`',`',`, .$4=1')
    ifelse(`$5',`',`',`, .$5=1')
    ifelse(`$6',`',`',`, .$6=1')
  };
divert
  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')

define(`init_union', `ifelse(`$1',,,`{ $1 } ifelse(`$2',,,`,') init_union(shift($@))') ')

dnl Cons a secondary word
dnl $1 - C identifier
dnl $2 - forth word (default: $1)
dnl $3 - flags
dnl $4... - cell data

define(secondary, `
undivert(1)
static word w_$1 = {
  .name = "ifelse($2,`',`$1',`$2')",
  .link = dict_head,
  .code = &&enter,
   ifelse(`$3',`',`',`$3,')
  .data = { init_union(shift(shift(shift($@)))) , {EXIT}}
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

static word *find(word *p, const char *key)
{
   while(p) {
      if(! p->smudge && (0 == strcmp(p->name, key)))
         break;
      p = p->link;
   }
   return p;
}

int main()
{
  cell *ip, *sp, *rp, *w;
  cell t;

  initio();

  vmstate.base = 10;

goto cold;

primary(abort)
  my_puts("abort");
  if (vmstate.errno)
    my_puts(": ");
    my_puts(vmstate.errstr);
  my_puts("\n");
  vmstate.errno = 0;
  goto quit;

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
  ip = (--rp)->a;
  w = ip->a;

primary(bye)
  return 0;


dnl non-colon secondary words

docon:
  *(sp++) = *(w + 1);
  goto next;

dnl $1 - name
dnl $2 - value

define(constant, `
undivert(1)
static word w_$1 = {
  .name = "$1",
  .link = dict_head,
  .code = &&docon,
  .data = {{ $2 }}
};

  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')

constant(cell, .i=sizeof(cell))
constant(dp, .a=(&vmstate.dp))
constant(s0, .a=param_stack)
constant(r0, .a=return_stack)

primary(spat, sp@)
  sp->a = sp-1;
  sp++;


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

primary(qstack, ?stack)
  if (sp > &param_stack[sizeof(param_stack)])
    cthrow(-3, stack overflow)
  if (sp < param_stack)
    cthrow(-4, stack underflow)
  if (rp > &return_stack[sizeof(return_stack)])
    cthrow(-5, stack overflow)
  if (rp < return_stack)
    cthrow(-6, return stack underflow)
  if (vmstate.dp > &dictionary_stack[sizeof(dictionary_stack)])
    cthrow(-8, dictionary overflow)


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
binop(or, |, or)
binop(xor, ^, xor)
binop(and, &, and)
binop(mod, %, mod)
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
unop(invert, -, invert)
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

dnl i --
primary(zbranch, 0branch, compile_only)
   if ((--sp)->i)
      ip++;
   else
      ip += ip->i;

dnl dnl i --
dnl primary(zexit, 0exit, compile_only)
dnl    if (!(--sp)->i)
dnl      goto exit;

dnl I/O

dnl c --
primary(emit)
  putchar((--sp)->i);

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
  for (j=8 * sizeof(t.i) - 4; j>=0; j-=4) {
    putchar(hex[0xf & (t.i>>j)]);
  }
  putchar(' ');
}


dnl MEM
primary(store, !)
  chkalign(sp[-1].aa)
  *(sp[-1].aa) = sp[-2].a;
  sp -= 2;

primary(load, @)
  chkalign(sp[-1].aa)
  sp[-1].a = *(sp[-1].aa);

primary(cstore, c!)
  *sp[-1].s = sp[-2].i;
  sp -= 2;

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

primary(word)
dnl ( -- s ) read a word, return zstring, allocated on dictionary stack
{
   int c;
   char *s = (char *)vmstate.dp;
   do {
      c = getchar();
      if (c < 0) return 0;
   } while (!IS_WORD(c));
   do {
      if (c < 0) return 0;
      *s++ = c;
      c = getchar();
   } while (IS_WORD(c));
  *s++ = 0;
  (sp++)->s = (char *)vmstate.dp;

  /* fix alignment */
  while ((int)s & (__alignof__(cell)-1)) s++;
  vmstate.dp = (cell *)s;
}

primary(number)
dnl ( s -- n )
dnl Convert string to number. On failure, abort.
{
  t.i = 0;
  char *s = sp[-1].s;
  int c;
  while ((c = *s)) {
   if (c <= '9')
      c -= '0';
   else
    {
      c |= 1 << 5; /* upcase */
      c = c - 'a' + 10;
    }
   if (c < 0 || c >= vmstate.base) {
      cthrow(-24, invalid numeric argument);
   }
   t.i *= vmstate.base;
   t.i += c;
   s++;
  }
  vmstate.dp = (cell *)sp[-1].s; /* TODO: sanity check */
  sp[-1] = t;
}


dnl dictionary

primary(allot)
dnl n -- increase dictionary pointer
  vmstate.dp += (--sp)->i;

primary(comma, `,')
  *vmstate.dp++ = *--sp;

primary(here)
dnl ( -- a ) push dictionary pointer onto parameter stack
  (sp++)->a = vmstate.dp;

primary(type)
dnl ( s -- ) send zstring
{
  char *s = (--sp)->s;
  my_puts(s);
}

primary(forget)
dnl ( a -- ) set dictionary pointer to a
  vmstate.dp = (--sp)->a;

primary(find)
dnl s -- cfa tf (found) -- s ff (not found)
dnl s is deallocated when found
{
   char *key = sp[-1].s;
   word *p = find(dictionary, key);
   if (p)
   {
     vmstate.dp = (cell *) key; /* TODO: sanity check */
     sp--;
     (sp++)->a = &p->code;
     (sp++)->i = 1;
   }
     else (sp++)->i = 0;
}


dnl compiler
primary(lit,, compile_only)
  *sp++ = *ip++;

primary(state)
  (sp++)->i = vmstate.compiling;
  dictionary->smudge = 0;

dnl ( cfa -- cfa i )
dnl check immediate flag of word around cfa
primary(immediatep)
{
  word bogus;
  word *w = (word *) ((sp[-1].s) - ((char *)&bogus.code - (char *)&bogus));
  (sp++)->i = w->immediate;
}

primary(recurse,, immediate, compile_only)
  (vmstate.dp++)->a = &dictionary->code;

dnl ( -- )
dnl set immediate flag most recently defined word
primary(immediate,,compile_only)
  dictionary->immediate = 1;

dnl ( s -- )
dnl cons the header of a dictionary entry for s, switch state
primary(cons)
{
  word *new = (word *)vmstate.dp;
  new->name = (--sp)->s;
  new->link = dictionary;
  new->smudge = 1;
  vmstate.compiling = 1;
  dictionary = new;
  new->code = &&enter;
  vmstate.dp = (cell *) &new->data;
}

primary(semi, ;, immediate)
{
  vmstate.compiling = 0;
  (vmstate.dp++)->a = EXIT;
}

dnl from fig.txt, unclassified
secondary(cr,,, LIT, .i=13, EMIT)
secondary(lf,,, LIT, .i=10, EMIT)
secondary(crlf,,, CR, LF)
secondary(bl,,, LIT, .i=32, EMIT)

dnl secondary(repl, WORD,, FIND, ZBRANCH, .i=4, EXECUTE, BRANCH, .i=2, NUMBER, BRANCH, .i=-9)

secondary(tick, ',, WORD, FIND, ZBRANCH, .i=2, EXIT, ABORT)
secondary(tobody, >body,, CELL, ADD)

dnl secondary(interpret,,, FIND, ZBRANCH, .i=3, EXECUTE, EXIT, NUMBER)

dnl (s -- )
dnl interpret or compile s
secondary(interpret,,,
FIND,
ZBRANCH, .i=11,
IMMEDIATEP, NULLP, STATE, AND, ZBRANCH, .i=3,
COMMA, EXIT,
EXECUTE, EXIT,
NUMBER,
STATE, NULLP, ZBRANCH, .i=2, EXIT,
LIT, LIT, COMMA, COMMA)

secondary(quit,,, WORD, INTERPRET, QSTACK, BRANCH, .i=-4)

dnl secondary(quit, WORD,, FIND, ZBRANCH, .i=4, STATE, ZBRANCH, .i=4, COMMA, BRANCH, .i=-9, EXECUTE, BRANCH, .i=-6, NUMBER, BRANCH, .i=-9)

secondary(colon, :,, WORD, CONS)

dnl ( -- a )
secondary(begin,, .immediate=1,
 DP, LOAD)
dnl ( a -- )
secondary(again,, .immediate=1,
 LIT, BRANCH, COMMA, DP, LOAD, SUB, CELL, DIV, COMMA)
dnl ( a -- )
secondary(until,, .immediate=1,
 LIT, ZBRANCH, COMMA, DP, LOAD, SUB, CELL, DIV, COMMA)

dnl ( -- &zbranch-arg )
secondary(if,, .immediate=1,
 LIT, ZBRANCH, COMMA, /* place branch cfa */
 DP, LOAD,            /* push address of branch arg */
 DP, COMMA            /* place dummy arg */
)

dnl ( &zbranch-arg -- &branch-arg )
secondary(else,, .immediate=1,
 LIT, BRANCH, COMMA, /* place branch cfa */
 DP, LOAD, /* push address of dummy target */
 DP, COMMA, /* place dummy target */
 SWAP, DUP,
 DP, LOAD, SWAP, SUB, CELL, DIV, /* compute distance */
 SWAP, STORE /* patch */
)

dnl ( &branch-arg -- )
secondary(then,, .immediate=1,
 DUP,  /* address to patch */
 DP, LOAD, /* next cell */
 SWAP, SUB, CELL, DIV,  /* compute distance */
 SWAP, STORE /* patch */
)

secondary(q, ?,, LOAD, PRINT)

secondary(hi,,, LIT, .s= FORTHNAME " " REVISION "\n", TYPE)
secondary(cold,,, HI, QUIT, BYE)


dnl convenience
dnl DUMP

undivert(1)

quit:
  sp = param_stack;
  rp = return_stack;
  vmstate.compiling = 0;
  (sp++)->a = QUIT;
  goto execute;

cold:
  dictionary = dict_head;
  sp = param_stack;
  rp = return_stack;
  ip = 0;
  (sp++)->a = COLD;
  goto execute;

  return 0;
}
