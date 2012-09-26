constant(ro, r/o, .i=O_RDONLY)
constant(rw, r/w, .i=O_RDWR)

primary(close_file, close-file)
sp[-1].i = close(sp[-1].i);

primary(create_file, create-file)
sp[-2].i = creat(sp[-2].s, sp[-1].i);
sp[-1].i = (sp[-2].i == -1) ? errno : 0;

