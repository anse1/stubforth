80000 syst_rvr !
7 syst_csr !
: ms 10 / >r tick @ begin wfi tick @ over - r@ > until r> 2drop ;

