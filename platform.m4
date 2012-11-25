/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

extern char _binary_user_4th_source_start[];

secondary(boot2,boot,, LIT, .s=_binary_user_4th_source_start, EVALUATE, HI, QUIT)
