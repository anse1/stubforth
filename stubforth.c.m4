changecom(/*,*/)
#include "platform.h"
#include "stubforth.h"
#include "config.h"
#include <sys/mman.h>
#include <fcntl.h>

cell return_stack[1000];
cell param_stack[1000];
struct vmstate vmstate;

word *forth;

int dataspace_fd;
struct vocabulary *v;

unsigned char *redirect;
struct terminal terminal;

dnl m4 definitions

define(dict_head, 0)
define(div_word, 1)
define(div_init, 2)
define(div_start, 3)

dnl $1 - ANS94 error code
dnl $2 - ANS94 error string
define(`cthrow', `
do {
   ifelse($#, 2,
     `return t.s="$2", t;',
     `return t.i=$1, t;')
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
    .name = "ifelse(`$2',`',`translit(`$1',_,-)',`$2')",
    .link = (word *) dict_head,
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
static struct { staticword(eval($#-2)) } w_$1 = {
  .name = "ifelse($2,`',`translit($1,_,-)',$2)",
  .link = (word *)dict_head,
  .code = &&enter,
   ifelse(`$3',`',`',`$3,')
  .data = { init_union(shift(shift(shift($@)))) , {EXIT}}
};
  undefine(`self')
  define(`dict_head', &w_$1)
')

dnl Cons a constant
define(constant, `ifelse($#,0,``$0'',`
undivert(div_word)
static struct { staticword(1) } w_$1 = {
  .name = "ifelse($2,`',`translit($1,_,-)',$2)",
  .link = (word *)dict_head,
  .code = &&docon,
  .data = { init_union(shift(shift($@))) }
};

  define(`dict_head', &w_$1)
  define(translit($1,a-z,A-Z), &w_$1.code)
')')

dnl Cons a headerless thread.
dnl $1 - C identifier
dnl $2... - cell data
define(thread, `
define(`self', `&t_$1')
define(translit($1,a-z,A-Z), t_$1)
static cell t_$1[eval($#-1)] = { init_union(shift($@)) };
undefine(`self')
')

dnl C helpers
static int my_getchar() {
  int c;

  if (redirect) {
    c = *redirect++;
    if (!c)
      return (redirect = 0), -1;
    else
      return c;
  }
  return getchar();
}

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

void my_puts(const char *s) {
  while (*s)
    putchar(*s++);
}

const word *find(const word *p, const char *key)
{
   while(p) {
      if(! p->smudge && (0 == strcmp(p->name, key)))
         break;
      p = p->link;
   }
   return p;
}

int static_argc;
char **static_argv;

dnl main
int main(int argc, char *argv[])
{
  cell result;
  char *startword = 0;
  int opt;

  static_argc = argc;
  static_argv = argv;

  initio();
  forth = vm(0,0).a;


  while ((opt = getopt(argc, argv, "w:m:")) != -1) {
    switch (opt) {
    case 'w':
      startword = optarg;
      break;
    case 'm':
       dataspace_fd = open(optarg, O_RDWR);
       if (dataspace_fd < 0) {
         dataspace_fd = open(optarg, O_RDONLY);
         if (dataspace_fd < 0) {
           perror("opening dataspace");
	   return -4;
         }
       }
       break;
    default: /* '?' */
      fprintf(stderr, "Usage: %s [-w startword] [-m dataspace] [script]\n",
		argv[0]);
      return -3;
    }
  }

  if (!dataspace_fd)
  {
    int oldpwd = open(".", O_RDONLY);
    if (!getenv("HOME")) {
      perror("locating ~/.stubforth");
      return -1;
    }
    chdir(getenv("HOME"));
    dataspace_fd = open(".stubforth", O_RDWR);
    if (dataspace_fd < 0) {
        perror("opening dataspace read-write");
    	return -2;
    }
    fchdir(oldpwd);
  }

  v = mmap((void *)0x100000000ULL, 1<<20, PROT_READ|PROT_WRITE, MAP_FIXED|MAP_SHARED, dataspace_fd, 0);
  if (v == MAP_FAILED) {
    perror("mmap");
    return -1;
  }

  vmstate.dp = v->dp ? v->dp :(cell *) (v + 1);

  if(!v->head)
      v->head = forth;

  vmstate.dictionary = v->head;

  if (!startword)
  startword = "boot";

  if (optind < argc) {
     if (startword == (char *)"boot")
        startword = "quit";
     int fd =  open(argv[optind], O_RDONLY);
     if (fd < 0) {
       perror("redirecting");
       return -1;
     }
     redirect = mmap(0, 1 << 20, PROT_READ, MAP_SHARED, fd, 0);

    if (redirect == MAP_FAILED) {
      perror("mmap");
      return -1;
    }
  }

  while(1) {
    vmstate.compiling = 0;
    vmstate.base = 10;
    vmstate.sp = param_stack;
    vmstate.rp = return_stack;

    result = vm(&vmstate, &find(vmstate.dictionary, startword)->code);

    if (!result.s)
       return 0;
    else {
       if (result.i < 4096 && result.i > 0)
         perror("errno");
       else {
         my_puts("abort: ");
	 my_puts(result.s);
         my_puts("\n");
       }
    }
    redirect = 0;
    startword = "quit";

    if (argc > 1)
       return 0;
  }
}

dnl VM

/* The VM is reentrant and may, e.g., be reentered from interrupt
handlers.  It is also reentered on CATCH to implement non-local
control flow within forth.  The entire VM must be contained in a
single function since we make use of GCC's Labels as Values
extension. */

cell vm(struct vmstate *vmstate, void *const*xt)
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
  goto *(w->a);

primary(exit)
  ip = (--rp)->a;
  w = ip->a;

primary(bye)
  vmstate->sp = sp;
  vmstate->rp = rp;
  return t.a = 0, t;

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

dnl return stack

primary(rload, r@)
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
primary(abort)
  vmstate->sp = sp;
  vmstate->rp = rp;
  cthrow(-1, abort);

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
if (sp[-1].a) {
   vmstate->sp = sp;
   vmstate->rp = rp;
   return sp[-1];
} else {
  sp--;
}

dnl cfa -- i
primary(catch)
{
  void **xt = sp[-1].a;
  cell result;
  struct vmstate new = *vmstate;
  sp--;
  new.sp = sp;
  new.rp = rp;
  result = vm(&new, xt);
  if (!result.s) {
     /* local return, adopt state of the child VM */
     *vmstate = new;
     sp = new.sp;
     rp = new.rp;
  }
  *sp++ = result;
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

constant(cell,, .i=sizeof(cell))

primary(cells)
  sp[-1].i *= sizeof(sp[0]);

dnl ( n|u a-addr -- )
primary(plusstore, +!)
 *(vmint *)sp[-1].a += sp[-2].i;
 sp -= 2;

primary(move)
{
 char *s = sp[-3].s;
 char *d = sp[-2].s;
 vmint count = sp[-1].i;
 while (count--)
   *d++ = *s++;
 sp -= 3;
}

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
{
  t.i = my_getchar();
  if (t.i < 0) cthrow(-39, unexpected end of file);
  *sp++ = t;
}

dnl n --
dnl : p base c@ /mod dup if recurse else drop then hexchars + c@ emit  ;

constant(hexchars,, .s="0123456789abcdefghijklmnopqrstuvwxyz")

thread(dot1,
 &&enter, BASE, CLOAD, DIVMOD,
 QDUP, ZBRANCH, self[8], self,
 HEXCHARS, ADD, CLOAD, EMIT, EXIT)

secondary(dot, .,,
 DUP, ZERO, LT, ZBRANCH, self[9],
 MINUS, LIT, .i=45, EMIT,
 DOT1, BL)

primary(blockcomment, `(', immediate)
while((t.i = my_getchar()) != ')') {
  if (t.i < 0) cthrow(-39, unexpected end of file);
}

secondary(q, ?,, LOAD, DOT)
secondary(cq, c?,, CLOAD, DOT)

primary(type)
dnl ( s -- ) send zstring
{
  char *s = (--sp)->s;
  my_puts(s);
}

dnl dictionary
primary(context)
   (sp++)->a = &vmstate->dictionary;

primary(dp)
   (sp++)->a = &vmstate->dp;

primary(allot)
dnl n -- increase dictionary pointer
  vmstate->dp = (void *)((char *)vmstate->dp + (--sp)->i);

primary(comma, `,')
  *vmstate->dp++ = *--sp;

primary(here)
dnl ( -- a ) push dictionary pointer onto parameter stack
  (sp++)->a = vmstate->dp;

primary(find)
dnl s -- cfa tf (found) -- s ff (not found)
dnl s is deallocated when found
{
   char *key = sp[-1].s;
   const word *p = find(vmstate->dictionary, key);
   if (p)
   {
     sp--;
     try_deallocate(sp[0].a, &vmstate->dp);
     (sp++)->a = (void *)&p->code;
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
      c = my_getchar();
      if (c < 0) cthrow(0);
   } while (!IS_WORD(c));
   do {
      *s++ = c;
      c = my_getchar();
      if (c < 0) cthrow(-39, unexpected end of file);
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

secondary(commaquote, ``,\"'', .immediate=1,
   LIT, DOSTR, COMMA, QUOTE, DROP, ALIGN)

secondary(dotquote, `.\"', .immediate=1,
   COMMAQUOTE, LIT, TYPE, COMMA)

dnl compiler
secondary(literal,, .immediate=1, l(
   LIT LIT COMMA COMMA
))

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
secondary(constant,,, WORD, CONS, LIT, &&docon, COMMA, COMMA, SMUDGE, SUSPEND)
secondary(variable,,, CREATE, ZERO, COMMA)

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
LITERAL)

secondary(quit,,, WORD, INTERPRET, QSTACK, BRANCH, self[0])

constant(redirect,, &redirect);

dnl ( -- a )
secondary(if,, .immediate=1,
 LIT, ZBRANCH, COMMA, HERE, ZERO, COMMA
)

dnl ( a -- )
secondary(then,, .immediate=1,
 HERE, SWAP, STORE
)

dnl -- pad
secondary(ahead,, .immediate=1, l(
 LIT BRANCH COMMA HERE ZERO COMMA
))

dnl ( a -- a )
secondary(else,, .immediate=1,
 AHEAD, SWAP, THEN
)

dnl ( -- a )
secondary(begin,, .immediate=1, HERE)
dnl ( a -- )
secondary(until,, .immediate=1, LIT, ZBRANCH, COMMA, COMMA)

dnl ( -- a )
secondary(while,, .immediate=1, IF)

dnl ( a a -- )
secondary(repeat,, .immediate=1,
 SWAP,
 /* deal with unconditional jump first */
 LIT, BRANCH, COMMA, COMMA,
 /* patch the while jump */
 THEN)

secondary(hi,,, LIT, .s= FORTHNAME " " REVISION "\n", TYPE)

secondary(boot,,, HI, QUIT)

primary(cold)
  vmstate->dictionary = 0;
  goto start;

primary(raw)
 terminal.raw = 1;

primary(cooked)
 terminal.raw = 0;

primary(echo)
 terminal.quiet = 0;

primary(quiet)
 terminal.quiet = 1;

secondary(qword, ?word,,
  WORD, FIND, NULLP, ZBRANCH, self[8], LIT, .s="undefined word", THROW )

secondary(tick, ',, QWORD)

secondary(brackettick, ['], .immediate=1, l(
    QWORD LITERAL
))

secondary(postpone,, .immediate=1, l(
   QWORD
   IMMEDIATEP ZBRANCH self[6] COMMA EXIT
   LITERAL LIT COMMA COMMA
))

dnl convenience

dnl non-core
include(core.m4)
include(core-ext.m4)
include(tools.m4)
include(string.m4)
include(ffi.m4)
include(file.m4)
include(floating.m4)

dnl platform

sinclude(platform.m4)

undivert(div_word)

dnl startup

start:
{
    thread(top, BYE)
    ip = TOP;
    (sp++)->a = (void *)xt;
    undivert(div_start)
    goto execute;
}

init:
    undivert(div_init)
    return t.a=(word *)dict_head, t;
}

/*
Local Variables:
mode: m4
mode: outline-minor
End:
*/
