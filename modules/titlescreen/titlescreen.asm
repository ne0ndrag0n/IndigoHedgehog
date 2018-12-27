  ifnd H_TITLESCREEN
H_TITLESCREEN = 1

LoadTitlescreen:
  VdpLoadPaletteDma #VDP_PAL_0, #VGAPalette
  VdpLoadPaletteDma #VDP_PAL_1, #Bread
  VdpLoadPaletteDma #VDP_PAL_2, #SpacePal
  VdpLoadPaletteDma #VDP_PAL_3, #LogoPalette

  VdpLoadPatternDma #TS_FONT_LOCATION,    #96,   #Font
  VdpLoadPatternDma #TS_BREAD_LOCATION,   #30,   #BreadPattern
  VdpLoadPatternDma #TS_SPACE_LOCATION,   #1120, #SpacePattern
  VdpLoadPatternDma #TS_LOGO_LOCATION,    #36,   #LogoPattern
  VdpLoadPatternDma #TS_BUTTON_LOCATION,  #3,    #Button

  VdpBlitPattern #$0000, #$281C, #TS_SPACE_LOCATION, #VDP_PLANE_B, #$0040 ; Draw the background
  VdpBlitPattern #$0305, #$0C03, #TS_LOGO_LOCATION,  #VDP_PLANE_A, #$0060 ; Draw the logo

  ; Test writing to sprite attribute table
  ; sprite located at 128, 128, tile index 1
  ; 0080 0000 0001 0080
  move.w  #$0000, -(sp)
  move.l  #VDP_SPRITES, -(sp)
  jsr ComputeVdpDestinationAddress
  PopStack 4
  move.l  d0, (VDP_CONTROL)

  move.w  #$0080, (VDP_DATA)
  move.w  #$0000, (VDP_DATA)
  move.w  #$005D, (VDP_DATA)
  move.w  #$0080, (VDP_DATA)

  ; Draw text items
  VdpDrawText #$1911, #String_1PGame
  VdpDrawText #$1913, #String_HeadToHead
  VdpDrawText #$1915, #String_Online
  VdpDrawText #$1917, #String_Settings

TitlescreenMain:
  bra.s TitlescreenMain

ExitTitlescreen:
  bra.s ExitTitlescreen

  endif
