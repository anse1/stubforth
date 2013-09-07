marker lancom

hex
b8000000 constant cpld
cpld 10 + constant led18
cpld 14 + constant led34

: sw1 cpld c + c@ 40 and if 1 else 0 then ;



ffffffec constant ccr

