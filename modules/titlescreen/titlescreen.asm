  ifnd H_TITLESCREEN
H_TITLESCREEN = 1

LoadTitlescreen:
  jsr LoadPalettes
  jsr LoadPatterns

  ; Draws the background
  move.w  #$0040, -(sp)
  move.w  #VDP_PLANE_B, -(sp)
  move.w  #$007E, -(sp)
  move.w  #$281C, -(sp)
  move.w  #$0000, -(sp)
  jsr BlitPattern
  PopStack 10

  ; Draws the logo
  move.w  #$0060, -(sp)
  move.w  #VDP_PLANE_A, -(sp)
  move.w  #$04DE, -(sp)
  move.w  #$0C03, -(sp)
  move.w  #$0305, -(sp)
  jsr BlitPattern
  PopStack 10

  ; Test writing to sprite attribute table
  ; sprite located at 128, 128, tile index 1
  ; 0080 0000 0001 0080
  ;move.w  #$0000, -(sp)
  ;move.w  #VDP_SPRITES, -(sp)
  ;move.w  #$0000, -(sp)
  ;jsr WriteVDPNametableLocation
  ;PopStack 6

  ;move.w  #$0080, (VDP_DATA)
  ;move.w  #$0000, (VDP_DATA)
  ;move.w  #$005D, (VDP_DATA)
  ;move.w  #$0080, (VDP_DATA)

  ; Draw text items
  move.l #( String_1PGame ), -(sp)
  move.w #$1911, -(sp)
  jsr DrawText
  PopStack 6

  move.l #( String_HeadToHead ), -(sp)
  move.w #$1913, -(sp)
  jsr DrawText
  PopStack 6

  move.l #( String_Online ), -(sp)
  move.w #$1915, -(sp)
  jsr DrawText
  PopStack 6

  move.l #( String_Settings ), -(sp)
  move.w #$1917, -(sp)
  jsr DrawText
  PopStack 6

TitlescreenMain:
  bra.s TitlescreenMain

  endif
