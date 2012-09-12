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
