constant(ro, r/o, .i=O_RDONLY)
constant(rw, r/w, .i=O_RDWR)
constant(wo, w/o, .i=O_WRONLY)

dnl fileid -- ior
primary(close_file)
sp[-1].i = close(sp[-1].i);
sp[-1].i = (sp[-2].i == -1) ? errno : 0;

dnl s ignored -- fileid ior
primary(create_file)
sp[-2].i = creat(sp[-2].s, 0777);
sp[-1].i = (sp[-2].i == -1) ? errno : 0;

dnl s -- ior
primary(delete_file)
sp[-1].i = unlink(sp[-1].s);
sp[-1].i = (sp[-1].i == -1) ? errno : 0;

dnl fileid -- i ior
primary(file_size)
{
  struct stat buf;
  sp[-1].i = fstat(sp[-1].i, &buf);
  sp++;
  if (sp[-2].i == -1)
    sp[-1].i = errno;
  else
    sp[-2].i = buf.st_size;
}
dnl s fam -- fileid ior
primary(open_file)
  sp[-2].i = open(sp[-2].s, sp[-1].i);
  sp[-1].i = (sp[-2].i == -1) ? errno : 0;

dnl c-addr u1 fileid -- u2 ior
primary(read_file)
sp[-3].i = read(sp[-1].i, sp[-3].s, sp[-2].i);
sp[-2].i = (sp[-3].i == -1) ? errno : 0;

sp--;

dnl i fileid -- ior
primary(reposition_file)
sp[-2].i = lseek(sp[-1].i, sp[-2].i, SEEK_SET);
sp--;

dnl c-addr u fileid -- ior
primary(write_file)
sp[-3].i = write(sp[-1].i, sp[-3].s, sp[-2].i);
sp[-3].i = (sp[-3].i == -1) ? errno : 0;

dnl fileid -- ior
primary(flush_file)
sp[-1].i = fdatasync(sp[-1].i);
sp[-1].i = (sp[-1].i == -1) ? errno : 0;
