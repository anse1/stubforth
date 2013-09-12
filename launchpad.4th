hex

.( Loading launchpad.4th...) lf

: red 8 << tmtbmatchr timer0 + ! ;
: green 8 << tmtbmatchr timer1 + ! ;
: blue 8 << tmtamatchr timer1 + ! ;

: col
	dup 10 >> ff and red
	dup 8 >> ff and green
	ff and blue
;

decimal

400000 syst_rvr !

: ms 10 / >r tick @ begin wfi tick @ over - r@ > until r> 2drop ;
: heartbeat begin 900 ms [ hex ] 300000 col [ decimal ] 100 ms [ hex ] 000000 col again ;

