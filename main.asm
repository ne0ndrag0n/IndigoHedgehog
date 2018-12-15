  ORG $00000000

  include 'system/interrupts.asm'
  include 'constants/system.asm'
  include 'bootstrap/vectors.asm'
  include 'bootstrap/headers.asm'
  include 'bootstrap/init.asm'

  jsr LoadPalette
  jsr LoadPattern
  jsr DisplayBread

  move.l #( String_Bread ), -(a7)
  move.w #$0005, -(a7)
  jsr DrawText

Main:
  jmp Main

TrapException:
  rte

ExternalInterrupt:
  rte

HBlank:
  rte

VBlank:
  rte

  include 'constants/vdpinit.asm'

  include 'vdp/mod.asm'
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
