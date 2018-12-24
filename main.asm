  include 'modules/helpers/stack.asm'

  ORG $00000000

  include 'constants/system.asm'
  include 'bootstrap/vectors.asm'
  include 'bootstrap/headers.asm'
  include 'bootstrap/init.asm'

  jsr LoadDemoPalettes
  jsr LoadDemoPatterns

  move.l #( String_Bread ), -(sp)
  move.w #$0005, -(sp)
  jsr DrawText
  PopStack 6

  move.w  #$0020, -(sp)                   ; 0 priority, palette 2, no flips
  move.w  #VDP_PLANE_A, -(sp)             ; Draw to plane A
  move.w  #$0060, -(sp)                   ; Bread gets loaded at numeric index 0x0060
  move.w  #$0605, -(sp)                   ; Bread is a 6x5 tile image
  move.w  #$0505, -(sp)                   ; We're moving bread *under* the text now
  jsr BlitPattern
  PopStack 10

  ; Test writing to sprite attribute table
  ; sprite located at 128, 128, tile index 1
  ; 0080 0000 0001 0080
  move.w  #$0000, -(sp)
  move.w  #VDP_SPRITES, -(sp)
  move.w  #$0000, -(sp)
  jsr WriteVDPNametableLocation
  PopStack 6

  move.w  #$0080, (VDP_DATA)
  move.w  #$0000, (VDP_DATA)
  move.w  #$0001, (VDP_DATA)
  move.w  #$0080, (VDP_DATA)

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
