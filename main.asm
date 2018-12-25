  ORG $00000000

  include 'constants/system.asm'
  include 'bootstrap/vectors.asm'
  include 'bootstrap/headers.asm'
  include 'bootstrap/init.asm'

  jsr LoadTitlescreen

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
  rte

VBlank:
  include 'modules/helpers/context.asm'
  ContextSave

  move.b  $FF0000, d0         ; Test if vblank is in progress
  tst.b   d0
  bne.s   EndVBlank           ; Nonzero means we're already doing a vblank - stop, get out!

  ori.b  #$01, d0             ; Overlay a 1 onto the interrupt status
  move.b d0, $FF0000

  ; vblank stuff goes here
  jsr JoypadVBlank

  move.b  $FF0000, d0         ; Unset status bit
  andi.b  #$FE, d0
  move.b  d0, $FF0000

EndVBlank:
  ContextRestore
  rte

  include 'modules/mod.asm'

  ORG $00001000
  include 'palettes/vga.asm'
  include 'patterns/demo.asm'
  include 'patterns/font.asm'
  include 'patterns/bread.asm'
  include 'patterns/space2.asm'
  include 'patterns/logo.asm'
  include 'constants/en_US.asm'

RomEnd:
  ORG $00010000
  dc.b %11111111
  end 0
