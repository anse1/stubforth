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
