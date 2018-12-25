  ifnd H_INIT_PALETTES
H_INIT_PALETTES = 1

LoadPalettes:
  move.l  #VGAPalette, -(sp)
  move.w  #VDP_PAL_0, -(sp)
  jsr LoadPaletteDma
  PopStack 6

  move.l  #Bread, -(sp)
  move.w  #VDP_PAL_1, -(sp)
  jsr LoadPaletteDma
  PopStack 6

  move.l  #SpacePal, -(sp)
  move.w  #VDP_PAL_2, -(sp)
  jsr LoadPaletteDma
  PopStack 6

  move.l  #LogoPalette, -(sp)
  move.w  #VDP_PAL_3, -(sp)
  jsr LoadPaletteDma
  PopStack 6
  rts

  endif
