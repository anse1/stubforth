: pid 39 syscall ;
: brk 12 syscall ;

0 brk constant heap
heap 1000000 +
brk
heap dp !

.( pid: )  pid . lf

: mmap 9 syscall ;
: write 1 syscall ;
: open 2 syscall ;
: read 0 syscall ;
: bye 60 syscall ;

\ 0 0 " /etc/passwd" open
\ constant fd
\ 
\ variable buf 100 allot 0 ,
\ 100 buf fd read
\ buf type lf
\ 0 bye

\ char *filename -- char *contents

octal

0003		constant  O_ACCMODE
00			constant  O_RDONLY
01			constant  O_WRONLY
02			constant  O_RDWR
0100		constant  O_CREAT
0200		constant  O_EXCL
0400		constant  O_NOCTTY
01000		constant  O_TRUNC
02000		constant  O_APPEND
04000		constant  O_NONBLOCK
04000		constant  O_NDELAY
010000		constant  O_SYNC
010000		constant  O_FSYNC
020000		constant  O_ASYNC
040000		constant  O_DIRECT
0200000		constant  O_DIRECTORY
0400000		constant  O_NOFOLLOW
01000000	constant  O_NOATIME
02000000	constant  O_CLOEXEC
0100000		constant  O_LARGEFILE
