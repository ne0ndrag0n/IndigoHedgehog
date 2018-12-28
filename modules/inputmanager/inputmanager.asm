  ifnd H_INPUT_MANAGER
H_INPUT_MANAGER = 1
  include 'modules/math/mod.asm'

  macro MoveTargetPointer
    move.l  #0, d1
    move.w  \1, d1                  ; target index * IM_TARGET_SIZE
    mulu.w  #IM_TARGET_SIZE, d1
    add.w   #IM_MEMBERS_SIZE, d1    ; + IM_MEMBERS_SIZE
    add.l   a0, d1                  ; + a0
    move.l  d1, \2                  ; a1 = pointer to target struct
  endm

  macro NewInputManager
    move.w  \1, -(sp)
    jsr InputManager_Create
    PopStack 2
  endm

  macro InputManagerUpdate
    move.l  \1, -(sp)
    jsr InputManager_UpdateState
    PopStack 4
  endm

; InputManager target data structure:
; [ xx xx yy yy ww ww hh hh aa aa aa aa ]
; xx xx yy yy - Location on-screen of upper left corner
; ww ww hh hh - Width and height
; aa aa aa aa - Callback: jsr'd when non-joypad button is pressed

; InputManager struct:
; ul ul - Corner sprite index
; ur ur - Corner sprite index
; lr lr - Corner sprite index
; ll ll - Corner sprite index
; oo oo - Origin target, if interpolating, current target otherwise
; dd dd - Destination target, if interpolating
; 00 ss - Interpolation step, 0 representing no active interpolation
; nn nn - Number of targets remaining (300 available)

TARGET_LOCATION_X = 0
TARGET_LOCATION_Y = 2
TARGET_WIDTH = 4
TARGET_HEIGHT = 6
TARGET_CALLBACK = 8

IM_TARGETS = 300
IM_TARGET_SIZE = 12

IM_UL_SPRITE = 0
IM_UR_SPRITE = 2
IM_LR_SPRITE = 4
IM_LL_SPRITE = 6
IM_ORIGIN = 8
IM_DESTINATION = 10
IM_STEP = 12
IM_NUM_TARGETS = 14

IM_MEMBERS_SIZE = IM_NUM_TARGETS + 2

; aa ii - Tile attribute of the corner piece without (flip attributes)
; Returns: address of new InputManager
InputManager_Create:
  move.l  sp, fp              ; Create a frame pointer to track original top of stack
                              ; Original top of stack should be return address + all arguments

  PopStack 6                  ; Move the stack pointer down to the bottom

  Allocate #( ( IM_TARGETS * IM_TARGET_SIZE ) + IM_MEMBERS_SIZE ), a0

  move.w  4(fp), -(sp)        ; Replace the attribute argument
  move.l  (fp), -(sp)         ; Replace the return address

  move.w  #-1, IM_UL_SPRITE(a0)
  move.w  #-1, IM_UR_SPRITE(a0)
  move.w  #-1, IM_LR_SPRITE(a0)
  move.w  #-1, IM_LL_SPRITE(a0)
  move.w  #-1, IM_ORIGIN(a0)
  move.w  #-1, IM_DESTINATION(a0)
  move.w  #0, IM_STEP(a0)
  move.w  #IM_TARGETS, IM_NUM_TARGETS(a0) ; 300 slots open for input manager targets

  move.w  4(fp), -(sp)
  bsr.s   InputManager_SetupCursor
  PopStack 2

  move.l  a0, d0               ; d0 returns the address of the inputmanager
  rts

; a0 shall be address of inputmanager
; aa ii - Tile attribute of the corner piece without (flip attributes)
InputManager_SetupCursor:
  move.l  sp, fp            ; Frame pointer is easier to work with

  move.w  4(fp), d0         ; Remove flip bits - We're doing this ourselves.
  andi.w  #$E7FF, d0
  move.w  d0, 4(fp)

  move.l  a0, -(sp)

  VdpNewSprite  #0, #0, #( SPRITE_VERTICAL_SIZE_1 | SPRITE_HORIZONTAL_SIZE_1 ), 4(fp)

  move.l  (sp)+, a0

  move.w  d0, IM_UL_SPRITE(a0)

  ; TODO: The other corner pieces
  rts

; aa aa aa aa - Address of the inputmanager
; xx xx yy yy - Target location
; ww ww hh hh - Width and height
; cc cc cc cc - Callback
InputManager_RegisterTarget:
  move.l  4(sp), a0

  move.w  #IM_TARGETS, d0                 ; Next target index is at IM_TARGETS - available_targets
  sub.w   IM_NUM_TARGETS(a0), d0

  MoveTargetPointer d0, a1

  move.l  8(sp), (a1)
  move.l  12(sp), 4(a1)
  move.l  16(sp), 8(a1)

  move.w  IM_NUM_TARGETS(a0), d0          ; Decrement available targets
  subi.w  #1, d0
  move.w  d0, IM_NUM_TARGETS(a0)
  rts

; a0 shall be address of inputmanager
; d2 d2 d2 d2
; a2 a2 a2 a2
; rr rr rr rr
InputManager_UpdateInterpolation:
  move.l  a2, -(sp)
  move.l  d2, -(sp)

  move.w  #100, d2                ; Invert proportion
  sub.w   IM_STEP(a0), d2

  MoveTargetPointer IM_ORIGIN(a0), a1
  MoveTargetPointer IM_DESTINATION(a0), a2

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp (a1), (a2), d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_UL_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp 2(a1), 2(a2), d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_UL_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  ; TODO: For now and for testing, we're only going to do the top left corner
  ; TODO: But here will go calculations for new widths and heights, etc

  move.w  IM_STEP(a0), d0              ; Decrement percent remaining
  subi.w  #1, d0
  move.w  d0, IM_STEP(a0)

  move.l  (sp)+, d2
  move.l  (sp)+, a2
  rts

; a0 shall be address of inputmanager
; 00 ss - Status (in JOYPAD_* direction)
; Returns: -1 if none in this direction, index of closest target otherwise.
InputManager_FindNearestInDirection:
  ; TODO: This is the fun one. Set up a parallel IM_NUM_TARGETS bucket to match up to IM_NUM_TARGETS - 1 items in a given direction.
  ; Then, use the math library to determine the closest item. This item will be set as IM_DESTINATION, and IM_STEP shall be set to 100.
  move.l  sp, fp                                    ; Frame pointer is easier to work with

  move.w  #IM_TARGETS, d0                           ; Targets - num_targets = Items in list
  sub.w   IM_NUM_TARGETS(a0), d0                    ; As num_targets is actually the number of remaining items
  tst.w   d0
  beq.w   InputManager_FindNearestInDirection_ReturnNone

  move.w  d0, -(sp)                                 ; Contains the number of registered items
                                                    ; -2(fp) - tt tt rr rr rr rr 00 ss
                                                    ;          ^sp   ^fp

  move.w  #0, -(sp)                                 ; Contains the number of found items
                                                    ; -4(fp)


  move.l  a2, -(sp)                                 ; Save a2

  lsl.w   #1, d0                                    ; *2, Each index is word size
  Allocate d0, a1                                   ; (a1) - Top of the candidates list

  move.w  4(fp), d0                                 ; Start figuring out what direction was pressed

  move.b  d0, d1
  ori.b   #JOYPAD_UP, d1
  beq.s   InputManager_FindNearestInDirection_Up

  move.b  d0, d1
  ori.b   #JOYPAD_DOWN, d1
  beq.s   InputManager_FindNearestInDirection_Down

  move.b  d0, d1
  ori.b   #JOYPAD_LEFT, d1
  beq.s   InputManager_FindNearestInDirection_Left

  move.b  d0, d1                                      ; It's damn well gonna be one of these four!
  ori.b   #JOYPAD_RIGHT, d1
  beq.s   InputManager_FindNearestInDirection_Right

InputManager_FindNearestInDirection_Up:
  move.l  #InputManager_FindNearestInDirection_FindUp, -(sp)
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_Down:
  move.l  #InputManager_FindNearestInDirection_FindDown, -(sp)
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_Left:
  move.l  #InputManager_FindNearestInDirection_FindLeft, -(sp)
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_Right:
  move.l  #InputManager_FindNearestInDirection_FindRight, -(sp)
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_FindUp:     ; d1 has y < origin
  nop

InputManager_FindNearestInDirection_FindDown:   ; d1 has y > origin
  nop

InputManager_FindNearestInDirection_FindLeft:   ; d1 has x < origin
  nop

InputManager_FindNearestInDirection_FindRight:  ; d1 has x > origin
  nop

; TODO
InputManager_FindNearestInDirection_BeginSearch:
  move.w  #0, d0                ; d0 is current index

InputManager_FindNearestInDirection_SearchLoop:
  MoveTargetPointer d0, a2      ; a2 contains needle we're comparing to
  ; TODO
  jsr (sp)                      ; Top of stack should contain selected routine
  nop

  PopStack 4                    ; Get rid of the comparator
  move.l  (sp)+, a2             ; Restore a2, we're done with it
  move.w  -2(fp), d0            ; Deallocate that huge array
  lsl.w   #1, d0
  Deallocate d0
  PopStack 4                    ; Then deallocate the two items we allocated before that
  rts

InputManager_FindNearestInDirection_ReturnNone:
  move.w  #-1, d0
  rts

; aa aa aa aa - Address of the inputmanager
InputManager_UpdateState:
  move.l  4(sp), a0           ; Load SELF pointer

  move.w  IM_NUM_TARGETS(a0), d0          ; Nothing to do if there are no targets
  cmp.w   #IM_TARGETS, d0
  bne.s   InputManager_UpdateState_CheckInterpolation

  bra.w   InputManager_UpdateState_End

InputManager_UpdateState_CheckInterpolation:
  move.w  IM_STEP(a0), d0
  tst.w   d0
  beq.s   InputManager_UpdateState_CheckInputs    ; If interpolation step is 0 then nothing needs to be done

  bsr.w   InputManager_UpdateInterpolation        ; Otherwise, call the function which updates sprite position on screen

  bra.w   InputManager_UpdateState_End

InputManager_UpdateState_CheckInputs:
  move.w  #0, d0                                 ; Check for a,b,c,start where the item currently is
  move.b  JOYPAD_STATE_1, d0

  move.b  d0, d1                                 ; x OR y, if x contains y, equals x
  ori.b   #JOYPAD_A, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_ButtonPressed

  move.b  d0, d1
  ori.b   #JOYPAD_B, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_ButtonPressed

  move.b  d0, d1
  ori.b   #JOYPAD_C, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_ButtonPressed

  move.b  d0, d1
  ori.b   #JOYPAD_START, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_ButtonPressed

InputManager_UpdateState_CheckDPad:
  move.b  d0, d1                            ; Check for dpad motion, find the items in that direction, and set destination for next go-around
  ori.b   #JOYPAD_UP, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_PrepareCall

  move.b  d0, d1
  ori.b   #JOYPAD_DOWN, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_PrepareCall

  move.b  d0, d1
  ori.b   #JOYPAD_LEFT, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_PrepareCall

  move.b  d0, d1
  ori.b   #JOYPAD_RIGHT, d1
  cmp.b   d0, d1
  beq.s   InputManager_UpdateState_PrepareCall

  bra.s   InputManager_UpdateState_End          ; If we make it here, no relevant buttons were pressed

InputManager_UpdateState_PrepareCall:
  move.w  d0, -(sp)
  bsr.w   InputManager_FindNearestInDirection
  PopStack 2

  bra.s   InputManager_UpdateState_End

InputManager_UpdateState_ButtonPressed:
  MoveTargetPointer IM_ORIGIN(a0), a1       ; Get pointer to the item in the target array

  move.w   d0, -(sp)                        ; Push button states
  jsr      8(a1)                            ; Call the callback!
  PopStack 2

InputManager_UpdateState_End:
  rts

  endif
