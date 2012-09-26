#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide my_getchar() and putchar() */
#include <stdio.h>

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{
}

#endif
