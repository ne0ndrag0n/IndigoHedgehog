 ifnd H_STATIC_VDP_PATTERN
H_STATIC_VDP_PATTERN = 1

; ii ii - desired index of tile (later turned into destination address)
; nn nn - Number of 8x8 tiles to copy
; aa aa aa aa - Address of source data
LoadPatternDma:
  move.w  4(sp), d0         ; Multiply tile index by 32 ($20) - 8 words times 4 bytes each, per cell
  mulu.w  #$0020, d0
  move.w  d0, 4(sp)         ; 4(sp) now equals the vram destination address

  move.w  6(sp), d0         ; tiles * 16 = number of words to transfer
  mulu.w  #16, d0
  move.w  d0, 6(sp)         ; 6(sp) now equals the number of words to write

  lsr.w   #7, d0            ; >> 8
  lsr.w   #1, d0

  VDPSetRegisterRuntime 20, d0

  move.w  6(sp), d0         ; Take only the bottom bits for register 19
  andi.w  #$00FF, d0

  VDPSetRegisterRuntime 19, d0

  move.l  8(sp), -(sp)      ; Copy source address
  jsr WriteDmaSourceAddress
  PopStack 4

  move.w  #$0080, -(sp)     ; Push settings
  move.w  6(sp), -(sp)      ; Copy vram destination address
  move.w  #0, -(sp)         ; Longword with upper as zeros
  jsr ComputeVdpDestinationAddress
  PopStack 6

  move.l  d0, (VDP_CONTROL) ; Do the DMA (Damn Memory Access)!
  rts

 endif
