thread(dumpstack,
 &&enter, DEPTH, ZBRANCH, self[9], RTO, self, RFROM, DUP, DOT, EXIT)

secondary(dots, .s,,
 QSTACK, LIT, .i=35, EMIT, DEPTH, DOT, DUMPSTACK, LF)

secondary(forget,,, l(
 QWORD TOWORD DUP
 TOLINK LOAD CONTEXT STORE
 TONAME LOAD DP STORE
))

secondary(restart,, .immediate=1, l(
  LIT BRANCH COMMA
  CONTEXT LOAD TOCODE TOBODY COMMA
))

secondary(words,,, l(
  CONTEXT LOAD DUP TOCODE
  TOWORD TONAME LOAD TYPE BL
  TOLINK LOAD QDUP NULLP
  ZBRANCH self[2]
))
