changecom(/*,*/)
#include "platform.h"
#include "types.h"
#include "config.h"

cell return_stack[1000];
cell param_stack[1000];
cell dictionary_stack[1000];

struct vmstate vmstate;

word *forth;
dnl m4 definitions

define(dict_head, 0);
define(div_word, 1);
define(div_init, 2);
define(div_start, 3);

dnl $1 - ANS94 error code
define(`cthrow', `
do {
  vmstate->errno = $1;
  vmstate->errstr = ifelse(`$2',`',0,"$2");
  return vmstate->errno;
} while (0)')

define(primary, `
dnl Cons a primary word
dnl $1 - C identifier
dnl $2 - forth word (default: $1)
dnl $3... - flags
undivert(div_word)
$1:
divert(div_word)
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

define(`l', `ifelse(`$#', `0', ``$0'', `patsubst(`$*', `[ ,]+', `,')')')

dnl Cons a secondary word
dnl $1 - C identifier
dnl $2 - forth word (default: $1)
dnl $3 - flags
dnl $4... - cell data

define(secondary, `
undivert(div_word)
define(`self', `&w_$1.data')
define(translit($1,a-z,A-Z), &w_$1.code)
static word w_$1 = {
  .name = "ifelse(`$2',`',`$1',`$2')",
  .link = dict_head,
  .code = &&enter,
   ifelse(`$3',`',`',`$3,')
  .data = { init_union(shift(shift(shift($@)))) , {EXIT}}
};
  undefine(`self')
  define(`dict_head', &w_$1)
')

dnl Cons a constant
define(constant, `
undivert(div_word)
static word w_$1 = {
  .name = "$1",
  .link = dict_head,
  .code = &&docon,
  .data = { init_union(shift($@)) }
};

  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')

dnl Cons a headerless thread.
dnl $1 - C identifier
dnl $2... - cell data
define(thread, `
define(`self', `&t_$1')
define(translit($1,a-z,A-Z), t_$1)
static cell t_$1[] = { init_union(shift($@)) };
undefine(`self')
')

dnl C helpers
static int strcmp(const char *a, const char *b) {
  while (*a && *a == *b)
     a++, b++;
  return (*a == *b) ? 0 : (*a > *b) ? 1 : -1;
}

dnl increase p until it has cell alignment
void *aligned(void *vp) {
  char *p = vp;
  while ((vmint)p & (__alignof__(cell)-1))
    p++;
  return (cell *)p;
}

dnl pop string from stack if it is at the top
static void try_deallocate(char *s, cell **sp) {
  char *p = s;
  while(*p++);
  p = aligned(p);
  if (*(char **)sp == p)
     *sp = (cell *)s;
}

static void my_puts(const char *s) {
  while (*s)
    putchar(*s++);
}

word *find(word *p, const char *key)
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
  char *startword;

  initio();
  stub4th_init();

  if(!vmstate.dp) {
      vmstate.dp = dictionary_stack;
      vmstate.dictionary = forth;
      startword = "boot";
  } else {
      startword = "quit";
  }


  while(1) {
    vmstate.compiling = 0;
    vmstate.raw = 0;
    vmstate.quiet = 0;
    vmstate.errno = 0;
    vmstate.base = 10;
    vmstate.errstr = 0;
    vmstate.sp = param_stack;
    vmstate.rp = return_stack;

    result = vm(&vmstate, &find(forth, startword)->code);

    if (!result)
       return 0;
    else {
      my_puts("abort: ");
      vmstate.sp = param_stack;
      vmstate.rp = return_stack;
      vmstate.base = 10;
      (vmstate.sp++)->i = result;
      vm(&vmstate, &find(forth, ".")->code);
      if (vmstate.errstr)
        my_puts(vmstate.errstr);
      my_puts("\n");
    }
  }
}

dnl VM

/* The VM is reentrant and may, e.g., be reentered from interrupt
handlers.  It is also reentered on CATCH to implement non-local
control flow within forth.  The entire VM must be contained in a
single function since we make use of GCC's Labels as Values
extension. */

int vm(struct vmstate *vmstate, void **xt)
{

  /* The VM registers */
  cell *ip, *sp, *rp, *w;
  cell t;

  if (!vmstate)
     goto init;

  /* remember the initial values so we can detect underflow */
  cell *sp_base, *rp_base, *dp_base;

  sp_base = sp = vmstate->sp;
  rp_base = rp = vmstate->rp;
  dp_base = vmstate->dp;

goto start;

primary(abort)
  vmstate->sp = sp;
  vmstate->rp = rp;
  cthrow(-1, abort);

dnl inner interpreter
enter:
  (rp++)->a = ip;
  ip = w + 1;
  /* fall through */

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
  vmstate->sp = sp;
  vmstate->rp = rp;
  return 0;

dnl non-colon secondary words

docon:
  *(sp++) = *(w + 1);
  goto next;

dovar:
  (sp++)->a = (w + 1);
  goto next;

dnl push &data[1] and enter the thread at *data[0].
dodoes:
  (sp++)->a = w + 2;
  w = *(cell **)(w + 1) - 1;
  goto enter;

dnl stack manipulation

primary(spload, sp@)
  sp->a = sp-1;
  sp++;

primary(drop)
  sp--;

primary(swap)
  t = sp[-1];
  sp[-1] = sp[-2];
  sp[-2] = t;

primary(dup)
  *sp = sp[-1];
  sp++;

primary(qdup, ?dup)
if (sp[-1].i) {
    *sp = sp[-1];
    sp++;
}

dnl 1 2 3 -- 2 3 1
primary(rot)
  t = sp[-1];
  sp[-1] = sp[-3];
  sp[-3] = sp[-2];
  sp[-2] = t;

primary(over)
  *sp = sp[-2];
  sp++;

primary(s0)
  (sp++)->a = sp_base;

primary(qstack, ?stack)
  if (sp < sp_base)
    cthrow(-4, stack underflow);
  if (rp < rp_base)
    cthrow(-6, return stack underflow);

primary(lit,, compile_only)
  *sp++ = *ip++;

primary(zero, 0)
  (sp++)->i = 0;

primary(one, 1)
  (sp++)->i = 1;

primary(depth)
  sp->i = sp - sp_base;
  sp++;

primary(twodup, 2dup)
  sp[0] = sp[-2];
  sp[1] = sp[-1];
  sp += 2;

primary(twodrop, 2drop)
  sp -= 2;

primary(twoover, 2over)
  sp[0] = sp[-4];
  sp[1] = sp[-3];
  sp += 2;

primary(twoswap, 2swap)
  t = sp[-1];
  sp[-1] = sp[-3];
  sp[-3] = t;
  t = sp[-2];
  sp[-2] = sp[-4];
  sp[-4] = t;

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

primary(r0)
  (sp++)->a = rp_base;

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
unop(minus, -, negate)
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

dnl dividend divisor -- remainder quotient
primary(divmod, /mod)
{
  vmint quot, rem;
  quot = sp[-2].i / sp[-1].i;
  rem = sp[-2].i % sp[-1].i;
  sp[-2].i = rem;
  sp[-1].i = quot;
}

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

dnl i --
primary(throw)
{
   vmstate->sp = sp;
   vmstate->rp = rp;
   cthrow(sp[-1].i, throw);
}

dnl cfa -- i
primary(catch)
{
  void **xt = sp[-1].a;
  int result;
  struct vmstate new = *vmstate;
  sp--;
  new.sp = sp;
  new.rp = rp;
  result = vm(&new, xt);
  if (!result) {
     /* local return, adopt state of the child VM */
     *vmstate = new;
     sp = new.sp;
     rp = new.rp;
  }
  (sp++)->i = result;
}

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

constant(cell, .i=sizeof(cell))

primary(cells)
  sp[-1].i *= sizeof(sp[0]);

dnl ( n|u a-addr -- )
primary(plusstore, +!)
 *(vmint *)sp[-1].a += sp[-2].i;
 sp -= 2;

dnl I/O

dnl c --
primary(emit)
  putchar((--sp)->i);

dnl secondary(cr,,, LIT, .i=13, EMIT)
secondary(lf,,, LIT, .i=10, EMIT)
secondary(bl,,, LIT, .i=32, EMIT)
dnl secondary(crlf,,, CR, LF)

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
dnl : p base c@ /mod dup if recurse else drop then hexchars + c@ emit  ;

constant(hexchars, .s="0123456789abcdefghijklmnopqrstuvwxyz")

thread(dot1,
 &&enter, BASE, CLOAD, DIVMOD,
 QDUP, ZBRANCH, self[8], self,
 HEXCHARS, ADD, CLOAD, EMIT, EXIT)

secondary(dot, .,,
 DUP, ZERO, LT, ZBRANCH, self[9],
 MINUS, LIT, .i=45, EMIT,
 DOT1, BL)

primary(blockcomment, `(', immediate)
  while(getchar() != ')');

primary(linecomment, `\\', immediate)
  while(getchar() != '\n');

secondary(q, ?,, LOAD, DOT)
secondary(cq, c?,, CLOAD, DOT)

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
     sp--;
     try_deallocate(sp[0].a, &vmstate->dp);
     (sp++)->a = &p->code;
     (sp++)->i = 1;
   }
   else (sp++)->i = 0;
}

dnl (void **) --- (cell *)
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

dnl (word *) --- (char **)
primary(toname, >name)
{
  sp[-1].a = &((word *)sp[-1].a)->name;
}

dnl (word *) --- (void **)
primary(tocode, >code)
{
  sp[-1].a = &((word *)sp[-1].a)->code;
}

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
  vmstate->dp = aligned(s);
}

dnl ( addr -- a-addr )
primary(aligned)
{
  char *s = sp[-1].a;
  sp[-1].a = aligned(s);
}

dnl ( addr -- a-addr )
primary(align)
{
  vmstate->dp = aligned(vmstate->dp);
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
      try_deallocate(sp[-1].s, &vmstate->dp);
      cthrow(-24, invalid numeric argument);
   }
   t.i *= vmstate->base;
   t.i += c;
   s++;
  }
  try_deallocate(sp[-1].s, &vmstate->dp);
  if (negate)
    t.i = -t.i;
  sp[-1] = t;
}

primary(dostr)
{
  char *s = (void *)ip;
  (sp++)->s = s;
  while(*s++)
    ;
  ip = aligned(s);
}

secondary(ccomma, `c,',,
  HERE, CSTORE, HERE, PLUS1, DP, STORE)

secondary(quote, `\"',,
  HERE,
  KEY, DUP, LIT, .i=34, SUB, ZBRANCH, self[11], CCOMMA, BRANCH, self[1],
  DROP, ZERO, CCOMMA, ALIGN)

secondary(squote, `s\"', .immediate=1,
   LIT, DOSTR, COMMA, QUOTE, DROP, ALIGN)

secondary(dotquote, `.\"', .immediate=1,
   SQUOTE, LIT, TYPE, COMMA)

primary(drops, drop\")
 try_deallocate(sp[-1].s, &vmstate->dp);
 sp--;

primary(compare)
 sp[-2].i = strcmp(sp[-2].s, sp[-1].s);
 sp--;

dnl compiler
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
  vmstate->dp = aligned(vmstate->dp);
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

secondary(create,,, WORD, CONS, LIT, &&dovar, COMMA, SMUDGE, SUSPEND)
secondary(colon, :,, WORD, CONS, LIT, &&enter, COMMA)
secondary(``constant'',,, WORD, CONS, LIT, &&docon, COMMA, COMMA, SMUDGE, SUSPEND)
secondary(``variable'',,, CREATE, ZERO, COMMA)

dnl start consing a dodoes word
secondary(builds, <builds,,
  WORD, CONS, LIT, &&dodoes, COMMA, ZERO, COMMA, SMUDGE, SUSPEND)

dnl set the dodoes address to the thread following does>
secondary(does, does>,, RFROM, CONTEXT, LOAD, TOCODE, TOBODY, STORE)

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
secondary(until,, .immediate=1, LIT, ZBRANCH, COMMA, COMMA)

dnl ( -- a )
secondary(while,, .immediate=1,
 LIT, ZBRANCH, COMMA, HERE, ZERO, COMMA /* jump after repeat */)

dnl ( a a -- )
secondary(repeat,, .immediate=1,
 SWAP,
 /* deal with unconditional jump first */
 LIT, BRANCH, COMMA, COMMA,
 /* patch the while jump */
 HERE, SWAP, STORE)


dnl ( -- a )
secondary(if,, .immediate=1,
 LIT, ZBRANCH, COMMA, HERE, ZERO, COMMA
)

dnl ( a -- a )
secondary(else,, .immediate=1,
 LIT, BRANCH, COMMA, HERE, ZERO, COMMA,
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

secondary(qword, ?word,,
  l(WORD FIND NULLP ZBRANCH self[8] LIT .i=-13 THROW ))

secondary(tick, ', .immediate=1,
    QWORD,
    STATE, NULLP, ZBRANCH, self[6], EXIT, LIT, LIT, COMMA, COMMA
)

secondary(postpone,, .immediate=1, l(
   QWORD,
   IMMEDIATEP ZBRANCH self[6] COMMA EXIT
   LIT LIT COMMA COMMA LIT COMMA COMMA
))
dnl convenience

dnl non-core
include(core-ext.m4)
include(tools.m4)
include(string.m4)
dnl include(floating.m4)

dnl platform

sinclude(platform.m4)

undivert(div_word)

dnl startup

start:
    if (!vmstate->dictionary) {
	vmstate->dictionary = dict_head;
    }
    thread(top, BYE)
    ip = TOP;
    (sp++)->a = xt;
    undivert(div_start)
    goto execute;

init:
  forth = dict_head;
  undivert(div_init)
  return 0;
}

__attribute__((constructor))
void stub4th_init ()
{
   /* Initialize forth with the static list head. */
   vm(0,0);
}

/*
Local Variables:
mode: m4
mode: outline-minor
End:
*/
