 ifnd H_STATIC_VDP_TEXT
H_STATIC_VDP_TEXT = 1

; Coordinates: xx yy
; String address: ss ss ss ss
DrawText:
  move.l  #$0, d0                         ; clear d0 and d1
  move.l  #$0, d1

  move.b  5(sp), d0                       ; move yy byte into d0

  mulu.w  #(VDP_PLANE_CELLS_H), d0        ; multiply yy by VDP_PLANE_CELLS_H

  move.b  4(sp),d1                        ; add xx to previous operation
  add.w   d1, d0

  mulu.w  #$0002, d0                      ; Multiply d0 by 2
                                          ; d0 now contains the cell number
                                          ; 2( VDP_PLANE_CELLS_H * yy + xx )
                                          ; This will give you the WORD value of the nametable location that needs to be written to vram
  add.w #VDP_PLANE_A, d0                  ; d0 now contains the actual address to write

  move.l d0, -(sp)                        ; Start preparing the control word we need to write to VDP
  move.l #VDP_VRAM_WRITE, d0
  move.l (sp), d1                         ; address & $3FFF
  andi.l #$3FFF, d1
  lsl.l  #$07,   d1                       ; << 16
  lsl.l  #$07,   d1
  lsl.l  #$02,   d1
  or.l   d1, d0                           ; "or" it on top of the address
  move.l (sp), d1                         ; address & $C000
  andi.l #$C000, d1
  lsr.l #$07, d1                          ; >> 14
  lsr.l #$07, d1
  or.l  d1, d0                            ; "or" it on top of d0
  move.l d0, (VDP_CONTROL)                ; Write the desired address to the VDP control port
  move.l #$0, (sp)
  move.l (sp)+, d0                        ; Take the value off the stack

  move.l 6(a7), a0                        ; Load string address into a0

  ; Write ascii value in terms of index
StringLoop:
  move.b  (a0)+, d0                      ; Check if string is null-terminated and break if zero
  tst.b   d0                            ; d0 contains the character which may be printed
  beq.s   StringLoop_End

  subi.b  #$20, d0                      ; Subtract 32 from ascii value (because text is located at top of rom)
  move.w  d0, (VDP_DATA)                ; Write data

  jmp StringLoop
StringLoop_End:
  rts

 endif
