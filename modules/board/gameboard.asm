  ifnd  H_GAME_BOARD
H_GAME_BOARD = 1

MainGameBoardSetup:
  VdpErasePlane #VDP_PLANE_A
  VdpErasePlane #VDP_PLANE_B

MainGameBoardLoop:
  bra.w MainGameBoardLoop

  endif
