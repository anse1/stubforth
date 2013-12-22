changecom(/*,*/)
.( Loading symbols.4th...) lf

define(`downcase', `translit(`$*', `A-Z', `a-z')')
hex
define(mmio1, `$1 constant downcase($2)')
define(mmio2, `$1 constant downcase($2)')
define(mmio4, `$1 constant downcase($2)')
define(const, `$1 constant downcase($2)')

: immio <builds , does> @ + ;

define(indirect, `$1 immio downcase($2)')

include(symbols.m4)
