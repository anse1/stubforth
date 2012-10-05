
typedef float vmfloat;

vmfloat float_stack[30];
vmfloat *fp;

divert(div_start)
fp = float_stack;
divert

dnl I/O
primary(itof, i>f)
*fp++ = sp[-1].i;
sp--;

primary(ftoi, f>i)
sp->i = *--fp;
sp++;

dnl stack manipulation
primary(fover)
fp[0] = fp[-2];
fp++;

primary(fswap)
{
  vmfloat f;
  f = fp[-1];
  fp[-1] = fp[-2];
  fp[-2] = f;
}

primary(frot)
{
  vmfloat f;
  f = fp[-3];
  fp[-3] = fp[-2];
  fp[-2] = fp[-1];
  fp[-1] = f;
}

dnl ops
define(fbinop, `
primary(`$1',`$2')
fp[-2] = fp[-2] $3 fp[-1];
fp--;
')

fbinop(fmul, f*, *)
fbinop(fadd, f+, +)
fbinop(fsub, f-, -)
fbinop(fdiv, f/, /)

fbinop(flt, f<, <)
fbinop(fgt, f>, >)
fbinop(feq, f=, =)

primary(fzlt, f0<)
sp->i = fp[-1] < 0;
sp++, fp--;

primary(fnegagte)
fp[-1] = -fp[-1];
