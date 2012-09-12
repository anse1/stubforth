#ifndef PLATFORM_H
#define PLATFORM_H

#include "types.h"

/* The platform needs to provide getchar() and putchar() */
#include <stdio.h>
#include <unistd.h>
#include <time.h>

/* flags.break_condition can be set in an ISR to interrupt the
   interpreter. */

static void initio()
{
}

#endif
