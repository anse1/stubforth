changecom(/*,*/)
.( Loading symbols.4th...) lf
hex
define(mmio1, `$1 constant $2')
define(mmio2, `$1 constant $2')
define(mmio4, `$1 constant $2')
define(const, `$1 constant $2')

include(symbols.m4)