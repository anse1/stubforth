primary(pick)
  sp[-1] = sp[-2 - sp[-1].i];

dnl ( a -- )
secondary(again,, .immediate=1, LIT, BRANCH, COMMA, COMMA)

dnl -- 0
secondary(case,, .immediate=1,
 ZERO, LIT, RTO, COMMA)

dnl n -- ofpad n+1
secondary(of,, .immediate=1, l(
 PLUS1
 LIT R COMMA LIT EQ COMMA
 IF  SWAP
))

dnl ofpad n -- endofpad n
secondary(endof,, .immediate=1, l(
 RTO ELSE  RFROM
))

dnl pad1 ... padn n --
secondary(endcase,, .immediate=1, l(
 DUP ZBRANCH self[8]
  MINUS1 SWAP
  THEN
 BRANCH self[0]
 DROP LIT RFROM COMMA LIT DROP COMMA
))

dnl -- pad
secondary(ahead,,.immediate=1, l(
 LIT BRANCH COMMA HERE ZERO COMMA
))
