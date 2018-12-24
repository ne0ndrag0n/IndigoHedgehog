 ifnd H_HELPERS_STACK
H_HELPERS_STACK = 1

 macro PopStack
  move.l sp, d1
  addi.l #\1, d1
  move.l d1, sp
 endm

 endif
