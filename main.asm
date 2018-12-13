  ORG $00000000

  include 'system/interrupts.asm'
  include 'constants/system.asm'
  include 'bootstrap/vectors.asm'
  include 'bootstrap/headers.asm'
  include 'bootstrap/init.asm'

  jmp LoadPalette
LoadPatternMain:
  jmp LoadPattern

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

  ORG $00080000
  include 'palettes/vga.asm'
  include 'patterns/demo.asm'
  include 'patterns/font.asm'

RomEnd:
  ORG $003FFFFF
  dc.b %11111111
  end 0
