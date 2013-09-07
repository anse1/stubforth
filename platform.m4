/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

extern const char binary_builtin_4th_start[];

constant(builtin4th,, .s=binary_builtin_4th_start)

secondary(boot2, boot,, LIT, .s=binary_builtin_4th_start, REDIRECT, STORE, HI, QUIT)

