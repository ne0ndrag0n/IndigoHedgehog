  ifnd H_TITLESCREEN
H_TITLESCREEN = 1
  include 'modules/inputmanager/mod.asm'

LoadTitlescreen:
  VdpLoadPaletteDma #VDP_PAL_0, #VGAPalette
  VdpLoadPaletteDma #VDP_PAL_1, #Bread
  VdpLoadPaletteDma #VDP_PAL_2, #SpacePal
  VdpLoadPaletteDma #VDP_PAL_3, #LogoPalette

  VdpLoadPatternDma #TS_FONT_LOCATION,    #96,   #Font
  VdpLoadPatternDma #TS_BREAD_LOCATION,   #30,   #BreadPattern
  VdpLoadPatternDma #TS_SPACE_LOCATION,   #1120, #SpacePattern
  VdpLoadPatternDma #TS_LOGO_LOCATION,    #36,   #LogoPattern
  VdpLoadPatternDma #TS_BUTTON_LOCATION,  #1,    #Button

  VdpBlitPattern #$0000, #$281C, #TS_SPACE_LOCATION, #VDP_PLANE_B, #$0040 ; Draw the background
  VdpBlitPattern #$0305, #$0C03, #TS_LOGO_LOCATION,  #VDP_PLANE_A, #$0060 ; Draw the logo

  ; Draw text items
  VdpDrawText #$1911, #String_1PGame
  VdpDrawText #$1913, #String_HeadToHead
  VdpDrawText #$1915, #String_Online
  VdpDrawText #$1917, #String_Settings

  NewInputManager #TS_BUTTON_LOCATION
  move.l  d0, -(sp)

  move.l  (sp), a0
  InputManagerRegister a0, #$C3, #$83, #$3B, #$0B, #Selected1PGame
  move.l  (sp), a0
  InputManagerRegister a0, #$C3, #$93, #$63, #$0B, #Selected2PGame
  move.l  (sp), a0
  InputManagerRegister a0, #$C3, #$A3, #$63, #$0B, #SelectedNetplay
  move.l  (sp), a0
  InputManagerRegister a0, #$C3, #$B3, #$43, #$0B, #SelectedSettings

  lea BgmDoomsday, a0
  jsr Echo_PlayBGM

TitlescreenMain:
  InputManagerUpdate (sp)
  bra.s TitlescreenMain

Selected1PGame:
  lea SfxBeep, a0
  jsr Echo_PlaySFX
  TimerHiResWaitTicks #16384    ; debounce
  rts

Selected2PGame:
  rts

SelectedNetplay:
  rts

SelectedSettings:
  rts

ExitTitlescreen:
  PopStack 4
  bra.s ExitTitlescreen

  endif
