primary(drops, drop\")
 try_deallocate(sp[-1].s, &vmstate->dp);
 sp--;

primary(compare)
 sp[-2].i = strcmp(sp[-2].s, sp[-1].s);
 sp--;


