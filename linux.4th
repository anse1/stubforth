decimal
: pid 39 syscall ;
: brk 12 syscall ;

0 brk constant heap
heap 1000000 +
brk
heap dp !

.( pid: )  pid . lf

: mmap ( off fd flags prot len addr -- addr ) 9 syscall ;
: write ( count buf fd -- count ) 1 syscall ;
: open ( mode flags file -- fd ) 2 syscall ;
: read ( count buf fd -- count ) 0 syscall ;
: bye ( int -- ) 60 syscall ;

\ 0 0 " /etc/passwd" open
\ constant fd
\ 
\ variable buf 100 allot 0 ,
\ 100 buf fd read
\ buf type lf
\ 0 bye

octal

0003		constant	 O_ACCMODE
00			constant	 O_RDONLY
01			constant	 O_WRONLY
02			constant	 O_RDWR
0100		constant	 O_CREAT
0200		constant	 O_EXCL
0400		constant	 O_NOCTTY
01000		constant	 O_TRUNC
02000		constant	 O_APPEND
04000		constant	 O_NONBLOCK
04000		constant	 O_NDELAY
010000		constant	 O_SYNC
010000		constant	 O_FSYNC
020000		constant	 O_ASYNC
040000		constant	 O_DIRECT
0200000		constant	 O_DIRECTORY
0400000		constant	 O_NOFOLLOW
01000000	constant	 O_NOATIME
02000000	constant	 O_CLOEXEC
0100000		constant	 O_LARGEFILE


hex

1				 constant PROT_READ
2				 constant PROT_WRITE
4				 constant PROT_EXEC
8				 constant PROT_SEM
0				 constant PROT_NONE
01000000		 constant PROT_GROWSDOWN
02000000		 constant PROT_GROWSUP
01				 constant MAP_SHARED
02				 constant MAP_PRIVATE
0f				 constant MAP_TYPE
10				 constant MAP_FIXED
20				 constant MAP_ANONYMOUS
4000000			 constant MAP_UNINITIALIZED

decimal

: mapro ( filename -- addr )
	>r 0 0 r> open
	dup 0< if ," open failed" throw then
	>r
	( off fd flags prot len addr -- addr )
	0 r> MAP_SHARED PROT_READ
	1 20 << \ size
	0
	mmap
	dup 0= if ," mmap failed" throw then
;
