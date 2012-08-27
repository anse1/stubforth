#ifndef TYPES_H
#define TYPES_H

union cell {
  void *a;
  void **aa;
  long i;
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
  volatile int break_condition : 1;
  int compiling : 1;
  char base;
  int errno : 14;
  char *errstr;
};

#define IS_WORD(c) (c > ' ')

#define CFA2WORD(w,cfa)							\
  do { word bogus;							\
    w = (word *) ((cfa) - ((char *)&bogus.code - (char *)&bogus)) ;} while (0)

extern struct word *dictionary;
extern struct vmstate vmstate;

typedef struct word word;

#endif
