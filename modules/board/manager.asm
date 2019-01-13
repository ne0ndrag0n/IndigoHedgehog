  ifnd H_GAMEBOARD_MANAGER
H_GAMEBOARD_MANAGER = 1

; GameboardManager
; ss ss - Current score
; xx yy - Upper left corner of board
; ww hh - Board size (in 4x4 tiles)
; (board)
; (inputmanager)

GM_CURRENT_SCORE = 0
GM_UPPER_LEFT_CORNER = 2
GM_BOARD_SIZE = 4

; xx yy - Upper left corner of board (cell coordinates)
; ww hh - Board size (cell coordinates)
GameboardManager_Create:
  rts

  endif
