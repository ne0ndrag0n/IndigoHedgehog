  ifnd H_MATH_COMPDIST
H_MATH_COMPDIST = 1

  macro MathCompareDistance
    move.w  \1, -(sp)
    move.w  \2, -(sp)
    move.w  \3, -(sp)
    move.w  \4, -(sp)
    jsr CompareDistance
    PopStack 8
  endm

; y2 y2
; x2 x2
; y1 y1
; x1 x1
; Returns: 1 if x1, y1 > x2, y2, 0 otherwise
CompareDistance:
  SetupFramePointer

  ;those square roots are often heavy to compute, and what's more, you don't need to compute them at all. Do this instead:
  ;dd1 = x1^2 + y1^2
  ;dd2 = x2^2 + y2^2
  ;return dd1 > dd2
  move.w  10(fp), d0     ; x1^2
  muls.w  10(fp), d0

  move.w  8(fp), d1      ; y1^2
  muls.w  8(fp), d1

  add.w   d1, d0         ; x1^2 + y1^2

  move.w  d0, -(sp)      ; save it

  move.w  6(fp), d0      ; x2^2
  muls.w  6(fp), d0

  move.w  4(fp), d1      ; y2^2
  muls.w  4(fp), d1

  add.w   d1, d0         ; d0 = x2^2 + y2^2

  move.w  (sp)+, d1      ; d1 = x1^2 + y1^2

  cmp.w   d0, d1
  bgt.w   CompareDistance_IsGT

  RestoreFramePointer
  move.b  #0, d0
  rts

CompareDistance_IsGT:
  RestoreFramePointer
  move.b  #1, d0
  rts

  endif
