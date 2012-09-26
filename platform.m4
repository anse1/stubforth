/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

dnl s -- s
primary(getenv)
sp[-1].s = getenv(sp[-1].s);

dnl s -- ior
primary(chdir)
sp[-1].i = chdir(sp[-1].s);
sp[-1].i = (sp[-1].i == -1) ? errno : 0;

dnl fileid -- ior
primary(fchdir);
sp[-1].i = fchdir(sp[-1].i);
sp[-1].i = (sp[-1].i == -1) ? errno : 0;

