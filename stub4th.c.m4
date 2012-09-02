changecom(/*,*/)
#include "platform.h"
#include "types.h"
#include "config.h"

cell return_stack[1000];
cell param_stack[1000];
cell dictionary_stack[10000];

struct vmstate vmstate;

dnl m4 definitions

define(dict_head, 0);

dnl $1 - ANS94 error code
define(`cthrow', `
{
  vmstate->errno = $1;
  vmstate->errstr = ifelse(`$2',`',0,"$2");
  goto abort;
}')

define(primary, `
dnl Cons a primary word
dnl $1 - C identifier
dnl $2 - forth word (default: $1)
dnl $3... - flags
undivert(1)
$1:
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
define(`self', `&w_$1.data')
static word w_$1 = {
  .name = "ifelse($2,`',`$1',`$2')",
  .link = dict_head,
  .code = &&enter,
   ifelse(`$3',`',`',`$3,')
  .data = { init_union(shift(shift(shift($@)))) , {EXIT}}
};
  undefine(`self')
  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')

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

dnl C helpers
static int strcmp(const char *a, const char *b) {
  while (*a && *a == *b)
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

dnl main
int main()
{
  int result;

  initio();

  vmstate.param_stack = param_stack;
  vmstate.return_stack = return_stack;
  vmstate.dictionary_stack = dictionary_stack;

  while(1) {
    vmstate.compiling = 0;
    vmstate.raw = 0;
    vmstate.quiet = 0;
    vmstate.errno = 0;

    if (vmstate.dictionary) {
       result = vm(&vmstate, "quit");
    } else {
       vmstate.base  = 10;
       result = vm(&vmstate, "boot");
    }
    if (!result)
       return 0;
  }
}

dnl VM
dnl The entire VM must be contained in a single function since we make use of GCC's
dnl Labels as Values extension.

dnl The vm is reentrant and may be called e.g., from interrupt handlers.
int vm(struct vmstate *vmstate, const char *startword)
{

  cell *ip, *sp, *rp, *w;
  cell t;



goto start;

primary(abort)
  my_puts("abort");
  if (vmstate->errno) {
    my_puts(": ");
    my_puts(vmstate->errstr);
  }
  my_puts("\n");
  return vmstate->errno;

dnl inner interpreter
enter:
  (rp++)->a = ip;
  ip = w + 1;

next:
  w = (ip++)->a;
  goto **(void **)w;

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

dovar:
  (sp++)->a = (w + 1);
  goto next;

dnl $1 - name
dnl $2 - value

constant(cell, .i=sizeof(cell))
constant(s0, .a=param_stack)
constant(r0, .a=return_stack)
dnl constant(d0, .a=dictionary_stack)

dnl stack manipulation

primary(spload, sp@)
  sp->a = sp-1;
  sp++;

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
    cthrow(-5, return stack overflow)
  if (rp < return_stack)
    cthrow(-6, return stack underflow)
  if (vmstate->dp > &dictionary_stack[sizeof(dictionary_stack)])
    cthrow(-8, dictionary overflow)

dnl return stack

primary(r)
  *sp++ = rp[-1];

primary(rfrom, r>)
  *sp++ = *--rp;

primary(rto, >r)
  *rp++ = *--sp;

primary(rpload, rp@)
  sp->a = rp-1;
  sp++;

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
unop(minus, -, minus)
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

primary(minus1, 1-)
  sp[-1].i--;

dnl control primitives

dnl --
primary(branch, , compile_only)
   ip = ip->a;

dnl i --
primary(zbranch, 0branch, compile_only)
   if ((--sp)->i)
      ip++;
   else
      ip = ip->a;
dnl I/O

dnl c --
primary(emit)
  putchar((--sp)->i);

dnl --
primary(hex)
  vmstate->base = 16;

dnl --
primary(decimal)
  vmstate->base = 10;

dnl -- &c
primary(base)
   (sp++)->a = &vmstate->base;

dnl -- c
primary(key)
  (sp++)->i = getchar();

dnl n --
primary(print, .)
{
  t.i = (--sp)->i;
  char *hex = "0123456789abcdef";
  int j;
  int skip = 1;
  for (j=8 * sizeof(t.i) - 4; j>=0; j-=4) {
    char c = hex[0xf & (t.i>>j)];
    if (c == '0' && skip)
      continue;
    skip = 0;
    putchar(c);
  }
  if (skip)
    putchar('0');
  putchar(' ');
}

primary(blockcomment, `(', immediate)
  while(getchar() != ')');

primary(linecomment, `\\', immediate)
  while(getchar() != '\n');

dnl MEM
primary(store, !)
  *(sp[-1].aa) = sp[-2].a;
  sp -= 2;

primary(load, @)
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

secondary(q, ?,, LOAD, PRINT)

dnl strings

primary(word)
dnl ( -- s ) read a word, return zstring, allocated on dictionary stack
{
   int c;
   char *s = (char *)vmstate->dp;
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
  (sp++)->s = (char *)vmstate->dp;

  /* fix alignment */
  while ((typeof(t.i))s & (__alignof__(cell)-1)) s++;
  vmstate->dp = (cell *)s;
}

dnl ( addr -- a-addr )
primary(aligned)
{
  char *s = sp[-1].a;
  while ((typeof(t.i))s & (__alignof__(cell)-1)) s++;
  sp[-1].a = s;
}

primary(number)
dnl ( s -- n )
dnl Convert string to number according to base variable.
dnl On failure, abort.
{
  t.i = 0;
  char *s = sp[-1].s;
  int c;
  int negate = 0;
  while ((c = *s)) {
   if (c == '-')
      { negate ^= 1; s++; continue; }
   else if (c <= '9')
      c -= '0';
   else
    {
      c |= 1 << 5; /* upcase */
      c = c - 'a' + 10;
    }
   if (c < 0 || c >= vmstate->base) {
      vmstate->dp = (cell *)sp[-1].s; /* TODO: sanity check */
      cthrow(-24, invalid numeric argument);
   }
   t.i *= vmstate->base;
   t.i += c;
   s++;
  }
  vmstate->dp = (cell *)sp[-1].s; /* TODO: sanity check */
  if (negate)
    t.i = -t.i;
  sp[-1] = t;
}

dnl dictionary

primary(context)
   (sp++)->a = &vmstate->dictionary;

primary(dp)
   (sp++)->a = &vmstate->dp;

primary(allot)
dnl n -- increase dictionary pointer
  vmstate->dp += (--sp)->i;

primary(comma, `,')
  *vmstate->dp++ = *--sp;

primary(here)
dnl ( -- a ) push dictionary pointer onto parameter stack
  (sp++)->a = vmstate->dp;

primary(type)
dnl ( s -- ) send zstring
{
  char *s = (--sp)->s;
  my_puts(s);
}

primary(find)
dnl s -- cfa tf (found) -- s ff (not found)
dnl s is deallocated when found
{
   char *key = sp[-1].s;
   word *p = find(vmstate->dictionary, key);
   if (p)
   {
     vmstate->dp = (cell *) key; /* TODO: sanity check */
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
  (sp++)->i = vmstate->compiling;

dnl ( cfa -- cfa i )
dnl check immediate flag of word around cfa
primary(immediatep)
{
  word *w = CFA2WORD(sp[-1].a);
  (sp++)->i = w->immediate;
}

primary(recurse,, immediate, compile_only)
  (vmstate->dp++)->a = &vmstate->dictionary->code;

dnl ( -- )
dnl toggle immediate flag of most recently defined word
primary(immediate,,)
  vmstate->dictionary->immediate ^= 1;

dnl ( -- )
dnl toggle smudge flag of most recently defined word
primary(smudge,,)
  vmstate->dictionary->smudge ^= 1;

dnl ( s -- )
dnl cons the header of a dictionary entry for s, switch state
primary(cons)
{
  word *new = (word *)vmstate->dp;
  new->name = (--sp)->s;
  new->link = vmstate->dictionary;
  new->smudge = 1;
  new->immediate = 0;
  new->compile_only = 0;
  vmstate->compiling = 1;
  vmstate->dictionary = new;
  vmstate->dp = (cell *) &new->code;
}

primary(suspend, [, immediate)
  vmstate->compiling = 0;

primary(resume, ], immediate)
  vmstate->compiling = 1;

secondary(semi, ;, .immediate=1,
  LIT, EXIT, COMMA, SMUDGE, SUSPEND)

secondary(create,,, WORD, CONS, COMMA)
secondary(colon, :,, LIT, &&enter, CREATE)
secondary(``constant'',,, LIT, &&docon, CREATE, COMMA, SMUDGE, SUSPEND)
secondary(``variable'',,, LIT, &&dovar, CREATE, COMMA, SMUDGE, SUSPEND)

dnl (char *) ---
dnl interpret or compile s
secondary(interpret,,,
FIND,
ZBRANCH, self[13],
IMMEDIATEP, NULLP, STATE, AND, ZBRANCH, self[11],
COMMA, EXIT,
EXECUTE, EXIT,
NUMBER,
STATE, NULLP, ZBRANCH, self[19], EXIT,
LIT, LIT, COMMA, COMMA)

secondary(quit,,, WORD, INTERPRET, QSTACK, BRANCH, self[0])

dnl ( -- a )
secondary(begin,, .immediate=1, HERE)
dnl ( a -- )
secondary(again,, .immediate=1, LIT, BRANCH, COMMA, COMMA)
dnl ( a -- )
secondary(until,, .immediate=1, LIT, ZBRANCH, COMMA, COMMA)

dnl ( -- a )
secondary(while,, .immediate=1,
 LIT, ZBRANCH, COMMA, HERE, DP, COMMA /* jump after repeat */)

dnl ( a a -- )
secondary(repeat,, .immediate=1,
 SWAP,
 /* deal with unconditional jump first */
 LIT, BRANCH, COMMA, COMMA,
 /* patch the while jump */
 HERE, SWAP, STORE)


dnl ( -- a )
secondary(if,, .immediate=1,
 LIT, ZBRANCH, COMMA, HERE, DP, COMMA
)

dnl ( a -- a )
secondary(else,, .immediate=1,
 LIT, BRANCH, COMMA, HERE, DP, COMMA,
 SWAP, HERE, SWAP, STORE
)

dnl ( a -- )
secondary(then,, .immediate=1,
 HERE, SWAP, STORE
)

secondary(hi,,, LIT, .s= FORTHNAME " " REVISION "\n", TYPE)

secondary(boot,,, HI, QUIT)

primary(cold)
  vmstate->dictionary = 0;
  goto start;

primary(raw)
 vmstate->raw = 1;

primary(cooked)
 vmstate->raw = 0;

primary(echo)
 vmstate->quiet = 0;

primary(quiet)
 vmstate->quiet = 1;

dnl from fig.txt, unclassified
dnl secondary(cr,,, LIT, .i=13, EMIT)
secondary(lf,,, LIT, .i=10, EMIT)
dnl secondary(crlf,,, CR, LF)
dnl secondary(bl,,, LIT, .i=32, EMIT)

secondary(tick, ', .immediate=1,
    WORD, FIND, NULLP, ZBRANCH, self[6], ABORT,
    STATE, NULLP, ZBRANCH, self[11], EXIT, LIT, LIT, COMMA, COMMA
)

secondary(tobody, >body,, CELL, ADD)

dnl (void **) --- (word *)
primary(toword, >word)
{
  sp[-1].a = CFA2WORD(sp[-1].a);
}
dnl (word *) --- (word **)
primary(tolink, >link)
{
  sp[-1].a = &((word *)sp[-1].a)->link;
}

dnl convenience

dnl platform

sinclude(platform.m4)

undivert(1)

dnl startup

start:
    sp = vmstate->param_stack;
    rp = vmstate->return_stack;
    if (!vmstate->dictionary) {
        vmstate->dp = vmstate->dictionary_stack;
	vmstate->dictionary = dict_head;
    }
    ip = 0;

    {
      word *w = find(vmstate->dictionary, startword);
      if (!w) {
        putchar('"');
        my_puts(startword);
	my_puts("\" ");
        cthrow(-13, undefined word);
      }
      (sp++)->a = &w->code;
      goto execute;
    }
}
/*
Local Variables:
mode: m4
mode: outline-minor
End:
*/
