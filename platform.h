#ifndef PLATFORM_H
#define PLATFORM_H

#include "symbols.h"
#include "stubforth.h"

#include <stdio.h>

#include <dlfcn.h>

struct vocabulary {
  cell *dp;
  word *head;
};

#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <time.h>

static void initio()
{
}

#endif
