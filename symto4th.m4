changecom(/*,*/)
.( Loading symbols.4th...) lf

define(`downcase', `translit(`$*', `A-Z', `a-z')')
hex
define(mmio1, `$1 constant downcase($2)')
define(mmio2, `$1 constant downcase($2)')
define(mmio4, `$1 constant downcase($2)')
define(const, `$1 constant downcase($2)')

define(indirect, `: downcase($2) $1 + ;')

include(symbols.m4)
