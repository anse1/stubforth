: pid 39 syscall ;
: brk 12 syscall ;

0 brk constant heap
heap 1000000 +
brk
heap dp !

.( pid: )  pid . lf

: mmap 9 syscall ;
: open 2 syscall ;
: bye 0 60 syscall ;
