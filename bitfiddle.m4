dnl non-standard words convenient for bit fiddling

primary(orstore, |!)
 *(vmint *)sp[-1].a |= sp[-2].i;
 sp -= 2;

primary(xorstore, ^!)
 *(vmint *)sp[-1].a ^= sp[-2].i;
 sp -= 2;

primary(andstore, &!)
 *(vmint *)sp[-1].a &= sp[-2].i;
 sp -= 2;

primary(notandstore, ~&!)
 *(vmint *)sp[-1].a &= ~(sp[-2].i);
 sp -= 2;
