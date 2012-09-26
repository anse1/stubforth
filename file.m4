#include <fcntl.h>

constant(r/o, O_RDONLY)
constant(r/w, O_RDWR)

primary(close_file, close-file)
sp[-1] = close(sp[-1]);

primary(create_file, create-file)
sp[-2].i = creat(sp[-2].s, sp[-1].i);
sp[-1].i = (sp[-2].i == -1) ? errno : 0;

