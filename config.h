#ifndef CONFIG_H
#define CONFIG_H

#include ".rev.h"

#define FORTHNAME "stubforth"

#define PAD_SIZE 1024 /* The size of the PAD (core-ext.m4) alloca'd on
		       first use in a VM instance. */

#define RETURN_STACK_SIZE 1024
#define PARAM_STACK_SIZE 1024
#define DICTIONARY_SIZE 1024

#define NEUTRAL ZERO /* The NEUTRAL word is used to get a value on the
			stack used as placeholder, e.g., when
			compiling a forward jump. */

#endif
