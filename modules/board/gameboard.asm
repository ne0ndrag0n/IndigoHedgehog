  ifnd  H_GAME_BOARD
H_GAME_BOARD = 1

GB_BG1_LOCATION = $0060
GB_BG2_LOCATION = GB_BG1_LOCATION + 16

MainGameBoardSetup:
  VdpErasePlane #VDP_PLANE_A
  VdpErasePlane #VDP_PLANE_B

  VdpLoadPaletteDma #VDP_PAL_1, #BoardBg1Pal

  VdpLoadPatternDma #GB_BG1_LOCATION, #16, #BoardBg1

  VdpBlitRepeatingPattern #$2000, #$0404, #GB_BG1_LOCATION, #VDP_PLANE_B, #VDP_TILE_ATTR_PAL1, #$0207

  VdpBlitFill #$2101, #$0602, #0, #VDP_PLANE_B, #VDP_TILE_ATTR_PAL0
  VdpDrawText #$2101, #String_Super
  VdpDrawText #$2102, #String_Swirl

  VdpBlitFill #$2119, #$0602, #0, #VDP_PLANE_B, #VDP_TILE_ATTR_PAL0
  VdpDrawText #$2119, #String_Score

  VdpBlitFill #$2116, #$0602, #0, #VDP_PLANE_B, #VDP_TILE_ATTR_PAL0
  VdpDrawText #$2116, #String_ComboBonus

MainGameBoardLoop:
  bra.w MainGameBoardLoop

  endif
