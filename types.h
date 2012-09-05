#ifndef TYPES_H
#define TYPES_H

typedef long vmint;  /* for efficient use of data structures,
                        sizeof(vmint) ought to equal sizeof(void *) */
union cell {
  void *a;
  void **aa;
  vmint i;
  char *s;
};
typedef union cell cell;

struct word {
  const char *name;
  int compile_only : 1;
  int immediate : 1;
  int smudge : 1;
  struct word *link;
  void *code;
  cell data[];
};

struct vmstate {
  cell *dp;
  cell *rp;  /* only valid on entry/return of vm() */
  cell *sp;  /* only valid on entry/return of vm() */
  struct word *dictionary;
  char base;
  int compiling : 1;
  int raw : 1;
  int quiet : 1;
  int errno : 14;
};

#define IS_WORD(c) (c > ' ')

#define offsetof(TYPE, MEMBER)  __builtin_offsetof (TYPE, MEMBER)

#define CFA2WORD(cfa)  cfa - offsetof(word, code)

extern struct vmstate vmstate;

typedef struct word word;

int vm(struct vmstate *vmstate, const char *startword);

#endif
