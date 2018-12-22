  macro DisableInterrupts
    move.w	#$2700,sr		; disable interrupts
  endm

  macro EnableInterrupts
    move.w	#$2000, sr	;re-enable interrupts
  endm

 macro RequestZ80Bus
    move.w #$0100, (Z80_BUS)
 endm

 macro ResetZ80
    move.w #$0100, (Z80_RESET)
 endm

 macro ReturnZ80Bus
    move.w	#0, (Z80_BUS)
 endm

 macro ControllerDelay
    rept 4
      nop
    endr
  endm
