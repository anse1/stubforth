changecom(/*,*/)
.( Loading symbols.4th...) lf

define(`downcase', `translit(`$*', `A-Z', `a-z')')
hex
define(mmio1, `set $`'downcase($2) = ((char *)$1 ')
define(mmio2, `set $`'downcase($2) = ((short *)$1 ')
define(mmio4, `set $`'downcase($2) = ((int *)$1 ')
define(const, `set $`'downcase($2) = $1 ')

include(symbols.m4)

