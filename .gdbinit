source symbols.gdb

define cfa2w
 p *(word *) ($arg0 - sizeof(void *) * 3)
end

# platform code follows
