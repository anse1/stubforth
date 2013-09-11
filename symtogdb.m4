changecom(/*,*/)

define(`downcase', `translit(`$*', `A-Z', `a-z')')
define(mmio1, `set $`'downcase($2) = ((char *)0x$1 ')
define(mmio2, `set $`'downcase($2) = ((short *)0x$1 ')
define(mmio4, `set $`'downcase($2) = ((int *)0x$1 ')
define(const, `set $`'downcase($2) = 0x$1 ')

include(symbols.m4)
