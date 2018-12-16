 ifnd H_STATIC_VDP_NAMETABLE
H_STATIC_VDP_NAMETABLE = 1

; Example bread is 6x5 located at index 0x0060

; xx yy - Location on plane
; ww hh - Width and height of pattern
; rr rr - Root pattern index (8x8 numeric index, not address)
; pp pp - Root plane address
; aa - Tile attribute (priority (1), palette (2), vflip (1), hflip (1))
BlitPattern:
  rts

 endif
