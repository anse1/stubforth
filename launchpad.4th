
2 8 << \ src
3 6 << or \ div
2 4 << or \ mode
tactl !

ffff taccr0 !

fc00 taccr1 !

ec70 taccr1 !

ec70 ec70 fc20 + + 3 / taccr1 !

ec70 fc20 + 2 / taccr1 !

: s 4 << ec88 + taccr1 ! ;

6 4 << \ output mode 6
tacctl1 !

\ p1.6/ta0.1 out1 output
1 6 << p1sel +!

