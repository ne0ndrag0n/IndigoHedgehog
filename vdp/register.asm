  macro VDPSetRegister
    move.w #( ( ( $80 + \1 ) << 8 ) | \2 ), (VDP_CONTROL)
  endm
