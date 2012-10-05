
float float_stack[30];
float *fp;

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

primary(f_zero_less_than, f0<)
sp->i = fp[-1] < 0;
sp++, fp--;

