#ifndef TYPES_H
#define TYPES_H

#include <stdint.h>

typedef intptr_t vmint;

union cell {
  void *a;
  void **aa;
  vmint i;
  char *s;
};
typedef union cell cell;

struct word {
  const char *name;
  int compile_only : 1; /* Not verified */
  int immediate : 1;
  int smudge : 1;
  struct word *link;
  void *code;
  cell data[];
};
typedef struct word word;

struct vmstate {
  cell *dp; /* Points above top of data stack. */
  cell *rp; /* Invalid during execution of a VM. */
  cell *sp; /* Invalid during execution of a VM. */
  struct word *dictionary;
  char base; /* This ought to be cell-sized according to standards. */
  int errno : 14; /* Set when vm() returns because of a THROW */

  int compiling : 1; /* Used by state-aware words INTERPRET and TICK */

  /* I/O configuration */
  int raw : 1;  /* Avoid translating lf to crlf, etc.  Set this if you
		   want to process binary data. */
  int quiet : 1; /* Don't echo incoming characters as they are
		    consumed by the VM. */
  const char *errstr;
};

struct vocabulary {
  cell *dp;
  word *head;
};

#define IS_WORD(c) (c > ' ')

#define offsetof(TYPE, MEMBER)  __builtin_offsetof (TYPE, MEMBER)

#define CFA2WORD(cfa)  ((word *)(((char *)cfa) - offsetof(word, code)))

extern struct vmstate vmstate;

extern struct word *forth; /* points to the head of head of the static
                              dictionary.  */
int vm(struct vmstate *vmstate, void **xt);

#endif
