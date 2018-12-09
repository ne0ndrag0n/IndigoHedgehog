  macro VDPSetRegister
    move.w ( ( ( $80 + \1 ) << 8 ) | \2 ), (VDP_CONTROL)
  endm

LoadPalette:
  ; Set DMA to read 16 words
  VDPSetRegister 20, $00
  VDPSetRegister 19, $10

  ; Set DMA location to VGAPalette
  VDPSetRegister 23, ( ( VGAPalette / 2 ) & $007F0000 ) >> 16
  VDPSetRegister 22, ( ( VGAPalette / 2 ) & $0000FF00 ) >> 8
  VDPSetRegister 21, ( VGAPalette / 2 ) & $000000FF

  ; Initiate DMA from above location to CRAM by performing a CRAM write
  move.l  #( VDP_CRAM_WRITE | $00000080 ), (VDP_CONTROL)

  jmp Main
