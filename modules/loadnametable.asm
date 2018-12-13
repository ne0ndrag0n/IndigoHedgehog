DisplayBread:
  ; Program bread into the nametable
  ; This can be done better using DMA and a constant nametable format
  ; Or by writing a proper method past "MVP"

  ; Plane A nametable starts at VRAM 0x2000
  ;#( $2000 | $0000 )

  move.l  #( VDP_VRAM_WRITE | $20000000 ), (VDP_CONTROL)
  move.w  #$2060, (VDP_DATA)
  move.w  #$2061, (VDP_DATA)
  move.w  #$2062, (VDP_DATA)
  move.w  #$2063, (VDP_DATA)
  move.w  #$2064, (VDP_DATA)
  move.w  #$2065, (VDP_DATA)

  move.l  #( VDP_VRAM_WRITE | $20800000 ), (VDP_CONTROL)
  move.w  #$2066, (VDP_DATA)
  move.w  #$2067, (VDP_DATA)
  move.w  #$2068, (VDP_DATA)
  move.w  #$2069, (VDP_DATA)
  move.w  #$206A, (VDP_DATA)
  move.w  #$206B, (VDP_DATA)

  move.l  #( VDP_VRAM_WRITE | $21000000 ), (VDP_CONTROL)
  move.w  #$206C, (VDP_DATA)
  move.w  #$206D, (VDP_DATA)
  move.w  #$206E, (VDP_DATA)
  move.w  #$206F, (VDP_DATA)
  move.w  #$2070, (VDP_DATA)
  move.w  #$2071, (VDP_DATA)

  move.l  #( VDP_VRAM_WRITE | $21800000 ), (VDP_CONTROL)
  move.w  #$2072, (VDP_DATA)
  move.w  #$2073, (VDP_DATA)
  move.w  #$2074, (VDP_DATA)
  move.w  #$2075, (VDP_DATA)
  move.w  #$2076, (VDP_DATA)
  move.w  #$2077, (VDP_DATA)

  move.l  #( VDP_VRAM_WRITE | $22000000 ), (VDP_CONTROL)
  move.w  #$2078, (VDP_DATA)
  move.w  #$2079, (VDP_DATA)
  move.w  #$207A, (VDP_DATA)
  move.w  #$207B, (VDP_DATA)
  move.w  #$207C, (VDP_DATA)
  move.w  #$207D, (VDP_DATA)

  rts
