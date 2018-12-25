  ifnd H_HELPERS_CONTEXT
H_HELPERS_CONTEXT = 1

  macro ContextSave
    move.w  sr, -(sp)
    move.l  d0, -(sp)
    move.l  d1, -(sp)
    move.l  d2, -(sp)
    move.l  d3, -(sp)
    move.l  d4, -(sp)
    move.l  d5, -(sp)
    move.l  d6, -(sp)
    move.l  d7, -(sp)
    move.l  a0, -(sp)
    move.l  a1, -(sp)
    move.l  a2, -(sp)
    move.l  a3, -(sp)
    move.l  a4, -(sp)
    move.l  a5, -(sp)
    move.l  a6, -(sp)
  endm

  macro ContextRestore
    move.l  (sp)+, a6
    move.l  (sp)+, a5
    move.l  (sp)+, a4
    move.l  (sp)+, a3
    move.l  (sp)+, a2
    move.l  (sp)+, a1
    move.l  (sp)+, a0
    move.l  (sp)+, d7
    move.l  (sp)+, d6
    move.l  (sp)+, d5
    move.l  (sp)+, d4
    move.l  (sp)+, d3
    move.l  (sp)+, d2
    move.l  (sp)+, d1
    move.l  (sp)+, d0
    move.w  (sp)+, sr
  endm

  endif
