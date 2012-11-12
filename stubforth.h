#ifndef STUBFORTH_H
#define STUBFORTH_H

#include <stdint.h>

typedef intptr_t vmint;

union cell {
  void *a;
  void **aa;
  vmint i;
  char *s;
};
typedef union cell cell;

/* GCC supports static initialization of flexible arrays, but we work
   around it for portability's sake and because it produces bogus
   sizes in the ELF meta-info. */

#define staticword(len)				\
  const char *name;				\
  int compile_only : 1;				\
  int immediate : 1;				\
  int smudge : 1;				\
  struct word *link;				\
  void *code;					\
  cell data[len];				\

struct word {
  staticword(0)
};

struct vmstate {
  cell *dp; /* Points above top of data stack. */
  cell *rp; /* Invalid during execution of a VM. */
  cell *sp; /* Invalid during execution of a VM. */
  struct word *dictionary;
  char base; /* This ought to be cell-sized according to standards. */

  int compiling : 1; /* Used by state-aware word INTERPRET */

};

struct terminal {
  int raw : 1;  /* Avoid translating lf to crlf, etc.  Set this if you
		   want to process binary data. */
  int quiet : 1; /* Don't echo incoming characters as they are
		    consumed by the VM. */
};
extern struct terminal terminal;

#define IS_WORD(c) (c > ' ')

#define offsetof(TYPE, MEMBER)  __builtin_offsetof (TYPE, MEMBER)

#define CFA2WORD(cfa)  ((word *)(((char *)cfa) - offsetof(word, code)))

extern struct vmstate vmstate;

typedef struct word word;

extern struct word *forth; /* points to the head of head of the static
                              dictionary.  */
cell vm(struct vmstate *vmstate, void **xt);
void stubforth_init(void);
word *find(word *p, const char *key);
void my_puts(const char *s);

#endif
