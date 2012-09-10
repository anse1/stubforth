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
 LIT R COMMA LIT EQ COMMA LIT ZBRANCH COMMA
 HERE SWAP LIT ZERO COMMA
))

dnl ofpad n -- endofpad n
secondary(endof,, .immediate=1, l(
 RTO
 LIT BRANCH COMMA HERE LIT ZERO COMMA
 SWAP HERE SWAP STORE
 RFROM
))

dnl pad1 ... padn n --
secondary(endcase,, .immediate=1, l(
 DUP ZBRANCH self[10]
  MINUS1 SWAP
  HERE SWAP STORE
 BRANCH self[0]
 DROP
 LIT RFROM COMMA LIT DROP COMMA
))
