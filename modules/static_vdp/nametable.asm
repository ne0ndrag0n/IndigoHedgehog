 ifnd H_STATIC_VDP_NAMETABLE
H_STATIC_VDP_NAMETABLE = 1

; Example bread is 6x5 located at index 0x0060

; xx yy - Location on plane
; ww hh - Width and height of pattern
; rr rr - Root pattern index (8x8 numeric index, not address)
; pp pp - Root plane address
; pw - Plane width in cells
; aa - Tile attribute (priority (1), palette (2), vflip (1), hflip (1))
BlitPattern:
  ; for each hh
  ; calculate + set vdp nametable address using [pp pp] and [xx yy] (seems expensive...)
  ;   for each ww
  ;   write index [rr rr] to vdp control word using [aa] attributes (vdp will autoincrement one word)
  ;   increment [rr rr]

BlitPattern_ForEachHH:
  move.b  7(sp), d0                   ; Break if hh is zero
  tst.b   d0
  beq.s   BlitPattern_ForEachHHEnd

  move.b  7(sp), d0                   ; Decrement hh
  subi.b  #$01, d0
  move.b  d0, 7(sp)

  move.w  10(sp), -(sp)               ; Copy pp pp
  move.w  6(sp), -(sp)                ; Copy xx yy
  jsr WriteVDPNametableLocation
  move.l  (sp)+, d0                   ; Pop values

  move.b  6(sp), d1                   ; d1 = ww

BlitPattern_ForEachWW:
  tst.b   d1                          ; Stop when d1 is 0
  beq.s   BlitPattern_ForEachWWEnd

  subi.b #$01, d1                     ; d1--

  move.w  13(sp), d0                  ; d0 = aa << 11
  lsl.w   #$07, d0
  lsl.w   #$04, d0

  or.w    8(sp), d0                   ; d0 = d0 | rr rr

  move.w  d0, (VDP_DATA)              ; Write tile index + settings to plane nametable
                                      ; VDP shall autoincrement by 1 word

  move.w 8(sp), d0                    ; (rr rr)++
  addi.w #$01, d0
  move.w d0, 8(sp)

  bra.s BlitPattern_ForEachWW
BlitPattern_ForEachWWEnd:

  ; TODO: not finished. Increment xx by a whole column? This seems expensive...

  bra.s BlitPattern_ForEachHH
BlitPattern_ForEachHHEnd:
  rts

 endif
