 ifnd H_INIT_PATTERNS
H_INIT_PATTERNS = 1

LoadPatterns:
  move.l  #Font, -(sp)
  move.w  #96, -(sp)
  move.w  #0, -(sp)
  jsr LoadPatternDma
  PopStack 8

  move.l  #BreadPattern, -(sp)
  move.w  #30, -(sp)
  move.w  #$0060, -(sp)
  jsr LoadPatternDma
  PopStack 8

  ; 40 x 28
  move.l  #SpacePattern, -(sp)
  move.w  #1120, -(sp)
  move.w  #$007E, -(sp)
  jsr LoadPatternDma
  PopStack 8
  rts

 endif
