constant(ro, r/o, .i=O_RDONLY)
constant(rw, r/w, .i=O_RDWR)
constant(wo, w/o, .i=O_WRONLY)

dnl fileid --
primary(close_file)
sp[-1].i = close(sp[-1].i);
if (sp[-2].i == -1)
   cthrow(errno);
sp--;

dnl s ignored -- fileid
primary(create_file)
sp[-2].i = creat(sp[-2].s, 0777);
if (sp[-2].i == -1)
   cthrow(errno);
sp--;

dnl s --
primary(delete_file)
sp[-1].i = unlink(sp[-1].s);
if (sp[-1].i == -1)
   cthrow(errno);
sp--;

dnl fileid -- i
primary(file_size)
{
  struct stat buf;
  sp[-1].i = fstat(sp[-1].i, &buf);
  sp++;
  if (sp[-2].i == -1)
    cthrow(errno);
  sp[-2].i = buf.st_size;
  sp--;
}
dnl s fam -- fileid
primary(open_file)
  sp[-2].i = open(sp[-2].s, sp[-1].i);
if (sp[-2].i == -1)
   cthrow(errno);
sp--;

dnl c-addr u1 fileid -- u2
primary(read_file)
sp[-3].i = read(sp[-1].i, sp[-3].s, sp[-2].i);
if (sp[-3].i == -1)
   cthrow(errno);
sp--;

sp--;

dnl i fileid --
primary(reposition_file)
sp[-2].i = lseek(sp[-1].i, sp[-2].i, SEEK_SET);
sp--;

dnl c-addr u fileid --
primary(write_file)
sp[-3].i = write(sp[-1].i, sp[-3].s, sp[-2].i);
if (sp[-3].i == -1)
   cthrow(errno);
sp--;

dnl fileid --
primary(flush_file)
sp[-1].i = fdatasync(sp[-1].i);
if (sp[-1].i == -1)
   cthrow(errno);
sp--;

dnl s1 s2 --
primary(rename_file)
sp[-2].i = rename(sp[-2].s, sp[-1].s);
if (sp[-2].i == -1)
   cthrow(errno);
sp--;
sp--;
