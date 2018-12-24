 ifnd H_STATIC_VDP_UTIL
H_STATIC_VDP_UTIL = 1
 include 'modules/helpers/stack.asm'

; xx yy - Tile index
; pp pp - Plane nametable VRAM address
; 00 ss - Status, in bits: 0000 0000 for vram write, 0000 0001 for vram read, 1000 0000 for DMA
; Returns: Computed nametable address
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

  move.w  8(sp), -(sp)                  ; Copy status
  move.l  d0, -(sp)                     ; push vram address onto stack
  bsr.s   ComputeVdpDestinationAddress
  PopStack 6

  move.l  d0, (VDP_CONTROL)             ; Write VDP control word containing VRAM address
  rts

; 00 00 pp pp - Destination VRAM address
; 00 ss - Status, in bits: 0000 0000 for vram write, 0000 0001 for vram read, 1000 0000 for DMA
; Returns: Computed nametable address
ComputeVdpDestinationAddress:
  move.w  8(sp), d1                     ; Check for type of operation - read or write
  btst    #0, d1
  beq.s   ComputeVdpDestinationAddress_VramWrite

  move.l  #VDP_VRAM_READ,  d0
  bra.s   ComputeVdpDestinationAddress_CheckDMA

ComputeVdpDestinationAddress_VramWrite:
  move.l  #VDP_VRAM_WRITE, d0           ; Start preparing VDP control word

ComputeVdpDestinationAddress_CheckDMA:
  btst    #7, d1                        ; Check if DMA is being applied
  beq.s   ComputeVdpDestinationAddress_WriteAddress

  move.l  #VDP_DMA_ADDRESS, d1          ; OR the DMA bits
  or.l    d1, d0

ComputeVdpDestinationAddress_WriteAddress:
  move.l  4(sp), d1
  andi.w  #$3FFF, d1                    ; address & $3FFF
  lsl.l   #$07, d1
  lsl.l   #$07, d1
  lsl.l   #$02, d1                      ; << 16
  or.l    d1, d0                        ; VDP_VRAM_WRITE | ( ( address & $3FFF ) << 16 )

  move.l  4(sp), d1
  andi.w  #$C000, d1                    ; address & $C000
  lsr.w   #$07, d1
  lsr.w   #$07, d1                      ; >> 14
  or.l    d1, d0                        ; ... | ( ( address & $C000 ) >> 14 )
  rts

 endif
