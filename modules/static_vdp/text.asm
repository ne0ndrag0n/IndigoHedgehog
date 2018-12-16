 ifnd H_STATIC_VDP_TEXT
H_STATIC_VDP_TEXT = 1

; Coordinates: xx yy
; String address: ss ss ss ss
DrawText:
  ; DrawText works with VDP_PLANE_A exclusively
  move.w  #VDP_PLANE_A, -(sp)             ; Push plane addr
  move.w  6(sp), -(sp)                    ; Copy coordinates
  jsr WriteVDPNametableLocation
  move.l  d1, (sp)+                       ; Pop coords after writing VDP word

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
