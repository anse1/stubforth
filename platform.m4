/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

dnl s -- handle
primary(dlopen)
{
  sp[-1].a = dlopen(sp[-1].s, RTLD_LAZY);
  if (! sp[-1].a)
     cthrow(dlerror());
}

dnl handle s -- (void *)
primary(dlsym)
{
  dlerror();
  sp[-2].a = dlsym(sp[-2].a, sp[-1].s);
  sp--;
  t.s = dlerror();
  if (t.s)
    cthrow(t.s);
}

void *dlopen(const char *filename, int flag);

constant(dataspace_fd,, &dataspace_fd)

primary(sync)
{
  v->head = vmstate->dictionary;
  v->dp = vmstate->dp;
}

secondary(shebang, #!,, LINECOMMENT)

constant(static_argv, argv, &static_argv)
constant(static_argc, argc, &static_argc)
constant(optind,, &optind)
constant(optarg,, &optarg)

dnl s -- s
primary(getenv)
sp[-1].s = getenv(sp[-1].s);

dnl s -- ior
primary(chdir)
sp[-1].i = chdir(sp[-1].s);
if (sp[-1].i == -1)
   cthrow(errno);
sp--;

dnl fileid -- ior
primary(fchdir);
sp[-1].i = fchdir(sp[-1].i);
if (sp[-1].i == -1)
   cthrow(errno);
sp--;

dnl -- i
primary(epoch)
{
 (sp++)->i = time(0);
}

dnl i --
primary(ms)
 usleep(1000*sp[-1].i);

dnl -- +n1 +n2 +n3 +n4 +n5 +n6
primary(timeanddate, time&date)
{
  struct tm *tm;
  time_t t = time(0);
  tm = localtime(&t);
  (sp++)->i = tm->tm_sec;
  (sp++)->i = tm->tm_min;
  (sp++)->i = tm->tm_hour;
  (sp++)->i = tm->tm_mday;
  (sp++)->i = 1 + tm->tm_mon;
  (sp++)->i = 1900 + tm->tm_year;
}
