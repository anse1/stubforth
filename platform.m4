/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

primary(sync)
{
  v->head = vmstate->dictionary;
  v->dp = vmstate->dp;
}

primary(epoch)
{
 (sp++)->i = time(0);
}

primary(ms)
 usleep(1000*sp[-1].i);
