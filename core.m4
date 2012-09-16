dnl dividend divisor -- remainder quotient
primary(divmod, /mod)
{
  vmint quot, rem;
  quot = sp[-2].i / sp[-1].i;
  rem = sp[-2].i % sp[-1].i;
  sp[-2].i = rem;
  sp[-1].i = quot;
}

