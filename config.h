#ifndef CONFIG_H
#define CONFIG_H

#include ".rev.h"

#define FORTHNAME "stubforth"

#define PAD_SIZE 32 /* The size of the PAD (core-ext.m4) alloca'd on
		       first use in a VM instance. */

#define RETURN_STACK_SIZE 32
#define PARAM_STACK_SIZE 48
#define DICTIONARY_SIZE 144

#include <stdint.h>

typedef intptr_t vmint;
typedef uintptr_t uvmint;
typedef int64_t dvmint;

#endif
