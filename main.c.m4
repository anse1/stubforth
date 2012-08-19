changequote([,])dnl
include(lispbrk.m4)dnl

#include "types.h"
#include "stdio.h"

cell param_stack[[PARAM_SIZE]];
cell return_stack[[RETURN_SIZE]];


int main(int argc, char *argv[[]])
{
  cell *rsp = return_stack;
  cell *psp = param_stack;
  cell tos;
  cell *ip;
  cell *w;
  cell *up;

  struct word * dp;


 next:
  w = *ip++;
  goto *w;

  static struct word w_next = {
    .length = 4,
    .name = { 'n', 'e', 'x', 't' },
    .link = 0,
    .cfa = &&next,
  };


 exit:
  ip = *--rsp;
  goto next;

  static struct word w_exit = {
    .length = 4,
    .name = { 'e', 'x', 'i', 't' },
    .link = &w_next,
    .cfa = &&exit,
  };


 enter:
  *rsp++ = ip;
  ip = w + 1;
  goto next;

  static struct word w_enter = {
    .length = 5,
    .name = { 'e', 'n', 't', 'e' },
    .link = &w_exit,
    .cfa = &&enter,
  };

 execute:
  w = *--psp;
  goto *w;

  static struct word w_execute = {
    .length = 5,
    .name = { 'e', 'x', 'e', 'c' },
    .link = &w_enter,
    .cfa = &&execute,
  };

  dp = &w_execute;

  return 0;
}
