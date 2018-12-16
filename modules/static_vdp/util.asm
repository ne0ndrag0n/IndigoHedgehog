 ifnd H_STATIC_VDP_UTIL
H_STATIC_VDP_UTIL = 1

; xx yy - Tile index
; pp pp - Plane nametable VRAM address
WriteVDPNametableLocation:
  move.l  #$0, d0                       ; clear d0 and d1
  move.l  #$0, d1

  ; 2( VDP_PLANE_CELLS_H * yy ) + xx

  move.b  5(sp), d0                     ; move yy into d0

  mulu.w  #(VDP_PLANE_CELLS_H), d0      ; yy * VDP_PLANE_CELLS_H

  move.b  4(sp), d1
  add.w   d1, d0                        ; + xx

  mulu.w  #$0002, d0                    ; times 2
                                        ; d0 now contains cell number

  add.w   6(sp), d0                     ; d0 now contains address

  move.l  d0, -(sp)                     ; push vram address onto stack
  move.l  #VDP_VRAM_WRITE, d0           ; Start preparing VDP control word
  move.l  (sp), d1
  andi.l  #$3FFF, d1                    ; address & $3FFF
  lsl.l   #$07, d1
  lsl.l   #$07, d1
  lsl.l   #$02, d1                      ; << 16
  or.l    d1, d0                        ; VDP_VRAM_WRITE | ( ( address & $3FFF ) << 16 )

  move.l  (sp), d1
  andi.l  #$C000, d1                    ; address & $C000
  lsr.l   #$07, d1
  lsr.l   #$07, d1                      ; >> 14
  or.l    d1, d0                        ; VDP_VRAM_WRITE | ( ( address & $C000 ) >> 14 )

  move.l  d0, (VDP_CONTROL)             ; Write VDP control word containing VRAM address
  move.l  #$0, (sp)
  move.l (sp)+, d0                      ; Pop value from stack cleanly

  rts

 endif
