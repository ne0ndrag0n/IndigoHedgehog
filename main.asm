  ORG $00000000

  include 'system/interrupts.asm'
  include 'constants/system.asm'
  include 'bootstrap/vectors.asm'
  include 'bootstrap/headers.asm'
  include 'bootstrap/init.asm'

  jsr LoadPalette
  jsr LoadPattern

  move.l #( String_Bread ), -(sp)
  move.w #$0005, -(sp)
  jsr DrawText
  move.l  sp, d0                          ; Clean up stack
  addi.l  #6, d0
  move.l  d0, sp

  move.w  #$0020, -(sp)                   ; 0 priority, palette 2, no flips
  move.w  #VDP_PLANE_A, -(sp)             ; Draw to plane A
  move.w  #$0060, -(sp)                   ; Bread gets loaded at numeric index 0x0060
  move.w  #$0605, -(sp)                   ; Bread is a 6x5 tile image
  move.w  #$0505, -(sp)                   ; We're moving bread *under* the text now
  jsr BlitPattern
  move.l  sp, d0                          ; Clean up stack
  addi.l  #10, d0
  move.l  d0, sp

Main:
  jmp Main

BusError:
  rte

AddressError:
  rte

IllegalInstr:
  rte

TrapException:
  rte

ExternalInterrupt:
  rte

HBlank:
  nop
  rte

VBlank:
  nop
  nop
  rte

  include 'modules/mod.asm'

  ORG $00001000
  include 'palettes/vga.asm'
  include 'patterns/demo.asm'
  include 'patterns/font.asm'
  include 'patterns/bread.asm'
  include 'constants/en_US.asm'

RomEnd:
  ORG $00003000
  dc.b %11111111
  end 0
