#ifndef TYPES_H
#define TYPES_H

#define PARAM_SIZE 10000
#define RETURN_SIZE 10000
#define NAME_SIZE 4

#define HASH_PRIME 8209
#define HASH(s) hash(s, HASH_PRIME)
/* __attribute__((pure,always_inline)) */

/* static unsigned int hash(const char *s, unsigned int prime) */
/* { */
/*   unsigned int hash = 0; */
/*   while (*s) */

/*     hash = hash * prime + *s++; */
/*   return hash; */
/* } */

union cell {
  void *a;
  void **aa;
  int i;
  char *s;
};
typedef union cell cell;

struct word {
  const char *name;
  int execute_only : 1;
  int compile_only : 1;
  int immediate : 1;
  int smudge : 1;
  struct word *link;
  void *code;
  cell data[];
} __attribute__((packed));

struct vmstate {
  volatile int break_condition : 1;
  int compiling : 1;
  unsigned int base : 5;
  int errno : 14;
  cell *dp;
} __attribute__((packed));

#define IS_WORD(c) (c > ' ')

#define CFA2WORD(x,w) ((word *) ((char *)x) - ((char *)(&w->code) - (char *)w))

extern struct word *dictionary;
extern struct vmstate vmstate;

typedef struct word word;

#endif
