primary(drops, drop\")
 try_deallocate(sp[-1].s, &vmstate->dp);
 sp--;

primary(compare)
 sp[-2].i = strcmp(sp[-2].s, sp[-1].s);
 sp--;

dnl -- char **
primary(errstr)
  (sp++)->a = &vmstate->errstr;

secondary(abortquote, abort\", .immediate=1, l(
  SQUOTE ERRSTR LITERAL
  LIT STORE COMMA
  LIT .i=-2 LITERAL
  LIT THROW COMMA
))
