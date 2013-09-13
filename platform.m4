/* This file is included in the VM's scope after all platform
   independent words have been defined.
   "boot" will be looked up by name on boot, so it is possible to
   redefine it here to initialize hardware, extend the dictionary from
   ROM, etc. */

extern const char binary_builtin_4th_start[];

constant(builtin4th,, .s=binary_builtin_4th_start)

secondary(boot2, boot,, LIT, .s=binary_builtin_4th_start, REDIRECT, STORE, HI, QUIT)

primary(led_pwr)
  sp--;
  led_pwr(sp[0].i);

primary(led_dsl)
  sp--;
  led_dsl(sp[0].i);

primary(led_chan1)
  sp--;
  led_chan1(sp[0].i);

primary(led_chan2)
  sp--;
  led_chan2(sp[0].i);

primary(vbrload, vbr@)
{
    void *vbr;
    asm("stc vbr, %0" : "=r"(vbr): /* no inputs */);
    sp[0].a=vbr;
    sp++;
}

primary(srload, sr@)
{
    void *sr;
    asm("stc sr, %0" : "=r"(sr): /* no inputs */);
    sp[0].a=sr;
    sp++;
}

primary(srstore, sr!)
{
    void *sr = sp[-1].a;
    asm("ldc %0, sr" : /* no outputs */ : "r"(sr));
    sp--;
}

primary(wload, w@)
  sp[-1].i = *((short *)sp[-1].a);
primary(wstore, w!)
  *((short *)sp[-1].a) = sp[-1].i;

secondary(wq, w?,, WLOAD, DOT)

primary(keyq, key?)
  sp[0].i = (ring.in != ring.out);
  sp++;

primary(sleep)
  asm("sleep");
