  include 'constants/system.asm'
  include 'bootstrap/vectors.asm'
  include 'bootstrap/headers.asm'
  include 'bootstrap/init.asm'

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
  include 'vdp/clear.asm'
  include 'patterns/demo.asm'
  include 'palettes/vga.asm'
  include 'modules/mod.asm'

RomEnd:
  ORG $3FFFFF
  dc.b %11111111
  end 0
