
undivert(div_word)

do2con:
  *(sp++) = *(++w);
  *(sp++) = *(++w);
  goto next;

secondary(twoconstant, 2constant,, l(
  WORD CONS LIT &&do2con COMMA SWAP COMMA COMMA SMUDGE SUSPEND))

primary(twolit, 2lit)
  *(sp++) = *(++w);
  *(sp++) = *(++w);
goto next;

secondary(twoliteral, 2literal, .immediate=1, l(
  LIT TWOLIT COMMA SWAP COMMA COMMA))

secondary(twovariable, 2variable,, l(
  VARIABLE ZERO COMMA
))
