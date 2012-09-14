#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"
#include <syscall.h>

/* 1. User-level applications use as integer registers for passing the sequence */
/*    %rdi, %rsi, %rdx, %rcx, %r8 and %r9. The kernel interface uses %rdi, */
/*    %rsi, %rdx, %r10, %r8 and %r9. */

static int getchar() {
   volatile register int callno	asm ("%rax") = __NR_read;
   volatile register int fd	asm ("%rdi") = 0;
   volatile unsigned char c;
   volatile register char * buf	asm ("%rsi") = &c;
   volatile register int count	asm ("%rdx") = 1;
   asm("syscall"
      : "=r" (callno)
      : "0" (callno), "r"(fd), "r"(buf), "r"(count)
      : "rcx", "r11", "memory"
      );
  return (callno != 1) ? callno : c;
}

static int putchar(int i) {
  volatile register int callno	asm ("%rax") = __NR_write;
  volatile register int fd	asm ("%rdi") = 1;
  volatile char c = i;
  volatile register char * buf	asm ("%rsi") = &c;
  volatile register int count	asm ("%rdx") = 1;

    asm("syscall"
	: "=r" (callno), "=m"(c)
	: "r" (callno), "r"(fd), "r"(buf), "r"(count)
	: "rcx", "r11"
	);
  return callno;
}

static void initio()
{
}



#endif
