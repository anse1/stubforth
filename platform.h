#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide getchar() and putchar() */
#include <stdio.h>
#include <unistd.h>
#include <time.h>

struct vocabulary {
  cell *dp;
  word *head;
};

static void initio()
{
}

#endif
