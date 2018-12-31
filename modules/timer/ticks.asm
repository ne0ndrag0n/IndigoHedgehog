  ifnd H_TIMER_TICKS
H_TIMER_TICKS = 1

TOTAL_TICKS = $FF0012

  macro TimerWaitMs
    move.w  \1, -(sp)
    jsr WaitMs
    PopStack 2
  endm

  macro TimerWaitTicks
    move.l  \1, -(sp)
    jsr WaitTicks
    PopStack 4
  endm

; Every second, this value is incremented by 60 ($3C)
UpdateTicks:
  move.l  TOTAL_TICKS, d0
  addi.l  #1, d0
  move.l  d0, TOTAL_TICKS
  rts

; ss ss - Amount to wait, in milliseconds
; IMPRECISE
WaitMs:
  ; Every 60 ticks, roughly 1000 ms elapses
  ; 60 ticks       1 tick
  ; -------- = -------------
  ; 1000 ms       16.66 ms
  ; All bets are off if you provide a time less than 17 ms
  move.l  #0, d0            ; (ss ss) / 16 = Number of ticks to wait
  move.w  4(sp), d0
  divu.w  #16, d0
  andi.l  #$0000FFFF, d0    ; Keep only the quotient result

  add.l   TOTAL_TICKS, d0   ; Where we eventually need to end up

WaitMs_Loop:
  cmp.l   TOTAL_TICKS, d0   ; TOTAL_TICKS will be incremented by the vblank interrupt
  bgt.s   WaitMs_Loop       ; If d0 still >= TOTAL_TICKS, keep on waitin'
  rts

; tt tt tt tt - Amount to wait, in ticks
WaitTicks:
  move.l  4(sp), d0
  add.l   TOTAL_TICKS, d0

WaitTicks_Loop:
  cmp.l   TOTAL_TICKS, d0
  bgt.s   WaitTicks_Loop
  rts

  endif
