  ifnd H_MATH_COMPDIST
H_MATH_COMPDIST = 1

; ii ii (after first computation)
; rr rr rr rr
; y2 y2
; x2 x2
; y1 y1
; x1 x1
; Returns: -1 if x1, y1 < x2, y2...0 if equal....1 if x1, y1 > x2, y2
CompareDistance:
  ;those square roots are often heavy to compute, and what's more, you don't need to compute them at all. Do this instead:
  ;dd1 = x1^2 + y1^2
  ;dd2 = x2^2 + y2^2
  ;return dd1 > dd2
  move.w  10(sp), d0     ; x1^2
  muls.w  10(sp), d0

  move.w  8(sp), d1      ; y1^2
  muls.w  8(sp), d1

  add.w   d1, d0         ; x1^2 + y1^2

  move.w  d0, -(sp)      ; save it

  move.w  12(sp), d0     ; x2^2
  muls.w  12(sp), d0

  move.w  10(sp), d1     ; y2^2
  muls.w  10(sp), d1

  add.w   d1, d0         ; d0 = x2^2 + y2^2

  move.w  (sp)+, d1      ; d1 = x1^2 + y1^2

  cmp.w   d1, d0

  blt.w   CompareDistance_IsLT ; It's sure as shit gonna be one of these three
  beq.w   CompareDistance_IsEQ
  bgt.w   CompareDistance_IsGT

CompareDistance_IsLT:
  move.b  #-1, d0
  rts

CompareDistance_IsEQ:
  move.b  #0, d0
  rts

CompareDistance_IsGT:
  move.b  #1, d0
  rts

  endif
