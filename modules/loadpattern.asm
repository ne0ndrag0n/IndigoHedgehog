LoadPattern:
  ; Set DMA to read 1536 words (768 longwords, or 96 tiles)
  VDPSetRegister 20, $06
  VDPSetRegister 19, $00

  ; Set DMA location to DemoPattern1
  VDPSetRegister 23, ( ( Font / 2 ) & $007F0000 ) >> 16
  VDPSetRegister 22, ( ( Font / 2 ) & $0000FF00 ) >> 8
  VDPSetRegister 21, ( Font / 2 ) & $000000FF

  ; Initiate DMA from above location to VRAM by performing a VRAM write
  ; Bit CD5 in the address must be one for this to work
  ;move.l  #( ( VDP_VRAM_WRITE ) | $00200000 | $00000080 ), (VDP_CONTROL)
  move.l  #( ( VDP_VRAM_WRITE ) | $00000080 ), (VDP_CONTROL)

  ; Load the bread tiles
  ; 48x40 pixels = 6 x 5 = 30 tiles, 960 bytes, 480 words
  VDPSetRegister 20, $01
  VDPSetRegister 19, $E0

  VDPSetRegister 23, ( ( BreadPattern / 2 ) & $007F0000 ) >> 16
  VDPSetRegister 22, ( ( BreadPattern / 2 ) & $0000FF00 ) >> 8
  VDPSetRegister 21, ( BreadPattern / 2 ) & $000000FF

  move.l  #( ( VDP_VRAM_WRITE ) | $00000080 | $0C000000 ), (VDP_CONTROL)

  rts
