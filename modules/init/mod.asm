 ifnd H_INIT_MOD
H_INIT_MOD = 1

 include 'modules/init/patterns.asm'
 include 'modules/init/palettes.asm'

InitSubsystems:
  jsr LoadPalettes
  jsr LoadPatterns

  ; TODO: Below, all this stuff gets moved into other modules

  ;move.l #( String_Bread ), -(sp)
  ;move.w #$0005, -(sp)
  ;jsr DrawText
  ;PopStack 6

  ;move.w  #$0020, -(sp)                   ; 0 priority, palette 2, no flips
  ;move.w  #VDP_PLANE_A, -(sp)             ; Draw to plane A
  ;move.w  #$0060, -(sp)                   ; Bread gets loaded at numeric index 0x0060
  ;move.w  #$0605, -(sp)                   ; Bread is a 6x5 tile image
  ;move.w  #$0505, -(sp)                   ; We're moving bread *under* the text now
  ;jsr BlitPattern
  ;PopStack 10

  move.w  #$0040, -(sp)
  move.w  #VDP_PLANE_A, -(sp)
  move.w  #$007E, -(sp)
  move.w  #$281C, -(sp)
  move.w  #$0000, -(sp)
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
  rts

 endif
