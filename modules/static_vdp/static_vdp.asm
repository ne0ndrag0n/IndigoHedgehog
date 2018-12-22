 ifnd H_STATIC_VDP
H_STATIC_VDP = 1

  macro VDPDefineRegisterConstant
    dc.w ( ( $80 + \1 ) << 8 ) | \2
  endm

  macro VDPSetRegister
    move.w #( ( ( $80 + \1 ) << 8 ) | \2 ), (VDP_CONTROL)
  endm

; VDP is currently structured to be fully static
VDP_PLANE_A=$C000
VDP_PLANE_B=$E000
VDP_WINDOW=$D000
VDP_PLANE_CELLS_H=64
VDP_PLANE_CELLS_V=32

  if VDP_PLANE_CELLS_H == 32
VDP_CELL_X = $00
  else
  if VDP_PLANE_CELLS_H == 64
VDP_CELL_X = $01
  else
  if VDP_PLANE_CELLS_H == 128
VDP_CELL_X = $11
  else
  fail "VDP_PLANE_CELLS_H must be one of 32, 64, or 128"
  endif
  endif
  endif

  if VDP_PLANE_CELLS_V == 32
VDP_CELL_Y = $00
  else
  if VDP_PLANE_CELLS_V == 64
VDP_CELL_Y = $01
  else
  if VDP_PLANE_CELLS_V == 128
VDP_CELL_Y = $11
  else
  fail "VDP_PLANE_CELLS_V must be one of 32, 64, or 128"
  endif
  endif
  endif

VDPInitData:
  VDPDefineRegisterConstant 0, $04                                ; 04=00000100 -> 9-bit palette, everything else disabled
  VDPDefineRegisterConstant 1, $74                                ; 74=01110100 -> Genesis display mode, DMA & V-int enabled
  VDPDefineRegisterConstant 2, ( VDP_PLANE_A / $400 )             ; 64x32 nametable each requiring two bytes = 4096 bytes, or $2000-$3000
  VDPDefineRegisterConstant 3, ( VDP_WINDOW / $400 )              ; Window nametable begins at $3000
  VDPDefineRegisterConstant 4, ( VDP_PLANE_B / $2000 )            ; 64x32 nametable each requiring two bytes = 4096 bytes, or $4000-$5000
  VDPDefineRegisterConstant 5, $28                                ; Sprite nametable starts at $5000 and goes to whatever
  VDPDefineRegisterConstant 6, $00                                ; 128kb mode stuff is always 0
  VDPDefineRegisterConstant 7, $00                                ; Set background colour to pal 0, col 0
  VDPDefineRegisterConstant 10, $00                               ; Number of lines used to generate hsync interrupt
  VDPDefineRegisterConstant 11, $00                               ; Full-screen scroll with no external interrupts
  VDPDefineRegisterConstant 12, $81                               ; 40-cell across display with no interlace
  VDPDefineRegisterConstant 13, $2f                               ; Horizontal scroll metadata located at $BC00
  VDPDefineRegisterConstant 14, $00                               ; 128kb mode stuff is always 0
  VDPDefineRegisterConstant 15, $02                               ; VDP address register will always increment by 2
  VDPDefineRegisterConstant 16, ( VDP_CELL_Y << 5 | VDP_CELL_X )  ; Nametables are 64 across and 32 down
  VDPDefineRegisterConstant 17, $00                               ; Window plane horizontal position (top left)
  VDPDefineRegisterConstant 18, $00                               ; Window plane vertical position (top left)
  VDPDefineRegisterConstant 19, $FF                               ; DMA length low byte
  VDPDefineRegisterConstant 20, $FF                               ; DMA length high byte
  VDPDefineRegisterConstant 21, $00                               ; DMA address low byte
  VDPDefineRegisterConstant 22, $00                               ; DMA address mid byte
  VDPDefineRegisterConstant 23, $80                               ; DMA address high byte + type
VDPInitDataEnd:

ClearVRAM:
  move.l  #VDP_VRAM_WRITE,(VDP_CONTROL)
  move.w  #$7FFF, d1
ClearVRAMLoop:
  move.w  #$0000, (VDP_DATA)
  dbf     d1, ClearVRAMLoop
  rts

 endif
