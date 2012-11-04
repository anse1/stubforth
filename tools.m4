thread(dumpstack,
 &&enter, DEPTH, ZBRANCH, self[9], RTO, self, RFROM, DUP, DOT, EXIT)

secondary(dots, .s,,
 QSTACK, LIT, .i=35, EMIT, DEPTH, DOT, DUMPSTACK, LF)

secondary(forget,,, l(
 QWORD TOWORD DUP
 TOLINK LOAD CONTEXT STORE
 TONAME LOAD DP STORE
))
