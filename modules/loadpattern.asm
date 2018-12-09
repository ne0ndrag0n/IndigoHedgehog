LoadPattern:
  ; Set DMA to read 16 words (8 longwords)
  VDPSetRegister 20, $00
  VDPSetRegister 19, $10

  ; Set DMA location to DemoPattern1
  lea DemoPattern1, a0

  VDPSetRegister 23, ( ( DemoPattern1 / 2 ) & $007F0000 ) >> 16
  VDPSetRegister 22, ( ( DemoPattern1 / 2 ) & $0000FF00 ) >> 8
  VDPSetRegister 21, ( DemoPattern1 / 2 ) & $000000FF

  ; Initiate DMA from above location to VRAM by performing a VRAM write
  ; Bit CD5 in the address must be one for this to work
  move.l  #( ( VDP_VRAM_WRITE ) | $00200000 | $00000080 ), (VDP_CONTROL)

  jmp Main
