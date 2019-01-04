  ifnd H_INPUT_MANAGER
H_INPUT_MANAGER = 1
  include 'modules/math/mod.asm'
  include 'modules/timer/mod.asm'

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

  macro DeleteInputManager
    jsr InputManager_Destroy
  endm

  macro InputManagerUpdate
    move.l  \1, -(sp)
    jsr InputManager_UpdateState
    PopStack 4
  endm

  macro InputManagerRegister
    move.l  \6, -(sp)
    move.w  \5, -(sp)
    move.w  \4, -(sp)
    move.w  \3, -(sp)
    move.w  \2, -(sp)
    move.l  \1, -(sp)
    jsr InputManager_RegisterTarget
    PopStack 16
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
  move.w  #0,  IM_ORIGIN(a0)
  move.w  #-1, IM_DESTINATION(a0)
  move.w  #0, IM_STEP(a0)
  move.w  #IM_TARGETS, IM_NUM_TARGETS(a0) ; 300 slots open for input manager targets

  move.w  4(fp), -(sp)
  bsr.s   InputManager_SetupCursor
  PopStack 2

  move.l  a0, d0               ; d0 returns the address of the inputmanager
  rts

; sp shall be address of the inputmanager
InputManager_Destroy:
  move.l  (sp)+, a0
  Deallocate #( ( IM_TARGETS * IM_TARGET_SIZE ) + IM_MEMBERS_SIZE )
  move.l  a0, -(sp)
  rts

; a0 shall be address of inputmanager
; aa ii - Tile attribute of the corner piece without (flip attributes)
InputManager_SetupCursor:
  SetupFramePointer

  move.w  4(fp), d0         ; Remove flip bits - We're doing this ourselves.
  andi.w  #$E7FF, d0
  move.w  d0, 4(fp)

  ; Upper left
  move.l  a0, -(sp)
  VdpNewSprite  #0, #0, #( SPRITE_VERTICAL_SIZE_1 | SPRITE_HORIZONTAL_SIZE_1 ), 4(fp)
  move.l  (sp)+, a0

  move.w  d0, IM_UL_SPRITE(a0)

  ; Upper right
  move.w  4(fp), d0
  ori.w   #SPRITE_HFLIP, d0
  move.l  a0, -(sp)
  VdpNewSprite #0, #0, #( SPRITE_VERTICAL_SIZE_1 | SPRITE_HORIZONTAL_SIZE_1 ), d0
  move.l  (sp)+, a0

  move.w  d0, IM_UR_SPRITE(a0)

  ; Lower right
  move.w  4(fp), d0
  ori.w   #SPRITE_VFLIP, d0
  ori.w   #SPRITE_HFLIP, d0
  move.l  a0, -(sp)
  VdpNewSprite #0, #0, #( SPRITE_VERTICAL_SIZE_1 | SPRITE_HORIZONTAL_SIZE_1 ), d0
  move.l  (sp)+, a0

  move.w  d0, IM_LR_SPRITE(a0)

  ; Lower left
  move.w  4(fp), d0
  ori.w   #SPRITE_VFLIP, d0
  move.l  a0, -(sp)
  VdpNewSprite #0, #0, #( SPRITE_VERTICAL_SIZE_1 | SPRITE_HORIZONTAL_SIZE_1 ), d0
  move.l  (sp)+, a0

  move.w  d0, IM_LL_SPRITE(a0)

  RestoreFramePointer
  rts

; aa aa aa aa - Address of the inputmanager
InputManager_ResetCursor:
  move.w  #0, IM_ORIGIN(a0)     ; Reset origin to item number 0

  MoveTargetPointer #0, a1      ; Get target pointer of registered location 0

  ; Upper left
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_UL_SPRITE(a0), TARGET_LOCATION_X(a1)
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_UL_SPRITE(a0), TARGET_LOCATION_Y(a1)
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  ; Upper right
  move.w  TARGET_LOCATION_X(a1), d0
  add.w   TARGET_WIDTH(a1), d0
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_UR_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_UR_SPRITE(a0), TARGET_LOCATION_Y(a1)
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  ; Lower right
  move.w  TARGET_LOCATION_X(a1), d0
  add.w   TARGET_WIDTH(a1), d0
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_LR_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.w  TARGET_LOCATION_Y(a1), d0
  add.w   TARGET_HEIGHT(a1), d0
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_LR_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  ; Lower left
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_LL_SPRITE(a0), TARGET_LOCATION_X(a1)
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.w  TARGET_LOCATION_Y(a1), d0
  add.w   TARGET_HEIGHT(a1), d0
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_LL_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0
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

  move.l  a0, -(sp)
  jsr InputManager_ResetCursor
  PopStack 4
  rts

; a0 shall be address of inputmanager
InputManager_UpdateInterpolation:
  move.l  a2, -(sp)
  move.l  d2, -(sp)

  move.w  #100, d2                ; Invert proportion
  sub.w   IM_STEP(a0), d2

  MoveTargetPointer IM_ORIGIN(a0), a1
  MoveTargetPointer IM_DESTINATION(a0), a2

  ; Upper left
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp TARGET_LOCATION_X(a2), TARGET_LOCATION_X(a1), d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_UL_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp TARGET_LOCATION_Y(a2), TARGET_LOCATION_Y(a1), d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_UL_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  ; Upper right
  move.w  TARGET_LOCATION_X(a2), d0
  add.w   TARGET_WIDTH(a2), d0
  move.w  TARGET_LOCATION_X(a1), d1
  add.w   TARGET_WIDTH(a1), d1

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp d0, d1, d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_UR_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp TARGET_LOCATION_Y(a2), TARGET_LOCATION_Y(a1), d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_UR_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  ; Lower right
  move.w  TARGET_LOCATION_X(a2), d0
  add.w   TARGET_WIDTH(a2), d0
  move.w  TARGET_LOCATION_X(a1), d1
  add.w   TARGET_WIDTH(a1), d1

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp d0, d1, d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_LR_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.w  TARGET_LOCATION_Y(a2), d0
  add.w   TARGET_HEIGHT(a2), d0
  move.w  TARGET_LOCATION_Y(a1), d1
  add.w   TARGET_HEIGHT(a1), d1

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp d0, d1, d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_LR_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  ; Lower left
  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp TARGET_LOCATION_X(a2), TARGET_LOCATION_X(a1), d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionX IM_LL_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.w  TARGET_LOCATION_Y(a2), d0
  add.w   TARGET_HEIGHT(a2), d0
  move.w  TARGET_LOCATION_Y(a1), d1
  add.w   TARGET_HEIGHT(a1), d1

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  MathLerp d0, d1, d2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  addi.w  #1, d0          ; Hack

  move.l  a0, -(sp)
  move.l  a1, -(sp)
  VdpSetSpritePositionY IM_LL_SPRITE(a0), d0
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  move.w  IM_STEP(a0), d0              ; Decrement percent remaining
  subi.w  #1, d0
  move.w  d0, IM_STEP(a0)

  tst.w   d0                           ; If percent remaining is 0, set origin to destination
  bne.s   InputManager_UpdateInterpolation_Exit

  move.w  IM_DESTINATION(a0), IM_ORIGIN(a0)

InputManager_UpdateInterpolation_Exit:
  move.l  (sp)+, d2
  move.l  (sp)+, a2
  rts

; a0 shall be address of inputmanager
; 00 ss - Status (in JOYPAD_* direction)
; Returns: -1 if none in this direction, index of closest target otherwise.
InputManager_FindNearestInDirection:
  move.l  sp, fp                                    ; Frame pointer is easier to work with

  move.l  #0, d0
  move.w  #IM_TARGETS, d0                           ; Targets - num_targets = Items in list
  sub.w   IM_NUM_TARGETS(a0), d0                    ; As num_targets is actually the number of remaining items
  tst.w   d0
  beq.w   InputManager_FindNearestInDirection_ReturnNone

  move.w  d0, -(sp)                                 ; Contains the number of registered items in a0
                                                    ; -2(fp) - tt tt rr rr rr rr 00 ss
                                                    ;          ^sp   ^fp

  move.w  #0, -(sp)                                 ; Contains the number of found items
                                                    ; -4(fp)

  move.w  #0, -(sp)                                 ; Contains the current closest target index
                                                    ; -6(fp)

  move.w  #$FFFF, -(sp)                             ; Contains the last known difference measured between origin and potential destination
                                                    ; -8(fp)

  move.l  a2, -(sp)                                 ; Save a2
  move.l  a3, -(sp)                                 ; Save a3
  move.l  a4, -(sp)                                 ; Save a4

  lsl.w   #1, d0                                    ; *2, Each index is word size
  Allocate d0, a1                                   ; (a1) - Top of the candidates list

  move.w  4(fp), d0                                 ; Start figuring out what direction was pressed

  move.b  d0, d1
  ori.b   #JOYPAD_UP, d1
  cmp.b   d0, d1
  beq.s   InputManager_FindNearestInDirection_Up

  move.b  d0, d1
  ori.b   #JOYPAD_DOWN, d1
  cmp.b   d0, d1
  beq.s   InputManager_FindNearestInDirection_Down

  move.b  d0, d1
  ori.b   #JOYPAD_LEFT, d1
  cmp.b   d0, d1
  beq.s   InputManager_FindNearestInDirection_Left

  move.b  d0, d1                                      ; It's damn well gonna be one of these four!
  ori.b   #JOYPAD_RIGHT, d1
  cmp.b   d0, d1
  beq.s   InputManager_FindNearestInDirection_Right

InputManager_FindNearestInDirection_Up:
  move.l  #InputManager_FindNearestInDirection_FindUp, a4
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_Down:
  move.l  #InputManager_FindNearestInDirection_FindDown, a4
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_Left:
  move.l  #InputManager_FindNearestInDirection_FindLeft, a4
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_Right:
  move.l  #InputManager_FindNearestInDirection_FindRight, a4
  bra.s   InputManager_FindNearestInDirection_BeginSearch

InputManager_FindNearestInDirection_FindUp:
  move.w  TARGET_LOCATION_Y(a3), d1
  cmp.w   TARGET_LOCATION_Y(a2), d1       ; origin < value
  blt.s   InputManager_FindNearestInDirection_AddItem
  rts

InputManager_FindNearestInDirection_FindDown:
  move.w  TARGET_LOCATION_Y(a3), d1
  cmp.w   TARGET_LOCATION_Y(a2), d1       ; origin > value
  bgt.s   InputManager_FindNearestInDirection_AddItem
  rts

InputManager_FindNearestInDirection_FindLeft:
  move.w  TARGET_LOCATION_X(a3), d1
  cmp.w   TARGET_LOCATION_X(a2), d1       ; origin < value
  blt.s   InputManager_FindNearestInDirection_AddItem
  rts

InputManager_FindNearestInDirection_FindRight:
  move.w  TARGET_LOCATION_X(a3), d1
  cmp.w   TARGET_LOCATION_X(a2), d1       ; origin > value
  bgt.s   InputManager_FindNearestInDirection_AddItem
  rts

InputManager_FindNearestInDirection_AddItem:
  cmp.w   IM_ORIGIN(a0), d0     ; Skip and don't add if d0 is the same item as origin
  bne.s   InputManager_FindNearestInDirection_Add
  rts

InputManager_FindNearestInDirection_Add:
  move.l  a1, -(sp)        ; Save the original pointer to array of matching indices

  move.l  #0, d1           ; Increment a1 to where we need to put the new item
  move.w  -4(fp), d1
  lsl.w   #1, d1
  add.l   a1, d1
  move.l  d1, a1

  move.w  d0, (a1)          ; Write to the array of matching indices

  move.l  (sp)+, a1         ; Restore pointer to array of matching indices

  move.w  -4(fp), d1        ; Increment number of found items
  addi.w  #1, d1
  move.w  d1, -4(fp)
  rts

InputManager_FindNearestInDirection_BeginSearch:
  move.w  #0, d0                        ; d0 is current index
  MoveTargetPointer IM_ORIGIN(a0), a2   ; Store the needle pointer

InputManager_FindNearestInDirection_SearchLoop:
  cmp.w   -2(fp), d0            ; Break if counter exceeds the number of registered items
                                ; Branch if d0 equals -2(fp)
  beq.s   InputManager_FindNearestInDirection_ShortestDistanceLoopPrepare

  MoveTargetPointer d0, a3      ; Store the value to compare to the needle
  jsr (a4)                      ; Top of stack should contain selected routine

  addi.w  #1, d0
  bra.s InputManager_FindNearestInDirection_SearchLoop

InputManager_FindNearestInDirection_ShortestDistanceLoopPrepare:
  tst.w   -4(fp)                        ; If no items were found, -4(fp) being 0, move -1 into -6(fp)
  bne.s   InputManager_FindNearestInDirection_ShortestDistanceLoopPrepareContinue
  move.w  #-1, -6(fp)
  bra.s   InputManager_FindNearestInDirection_ReturnValue

InputManager_FindNearestInDirection_ShortestDistanceLoopPrepareContinue:
  MoveTargetPointer IM_ORIGIN(a0), a2   ; The needle will be the origin pointer

InputManager_FindNearestInDirection_ShortestDistanceLoop:
  tst.w   -4(fp)                ; Break if we exceed the number of found items
  beq.s   InputManager_FindNearestInDirection_ReturnValue

  move.l  a0, -(sp)             ; Save these registers as they can be potentially overwritten
  move.l  a1, -(sp)
  move.l  a2, -(sp)

  MoveTargetPointer (a1), a3    ; Value

  MathGetComparisonDistance TARGET_LOCATION_X(a2), TARGET_LOCATION_Y(a2), TARGET_LOCATION_X(a3), TARGET_LOCATION_Y(a3)

  move.l  (sp)+, a2
  move.l  (sp)+, a1
  move.l  (sp)+, a0

  cmp.w   -8(fp), d0            ; Did this value come up less than the last one we looked at?
  bhs.s   InputManager_FindNearestInDirection_ShortestDistanceLoop_Continue

  move.w  (a1), -6(fp)          ; If so, move current index position to last lowest position
  move.w  d0, -8(fp)            ; And write that distance to last_known_distance -8(fp)

InputManager_FindNearestInDirection_ShortestDistanceLoop_Continue:
  move.w  -4(fp), d1            ; Decrement remaining items to explore
  subi.w  #1, d1
  move.w  d1, -4(fp)

  move.l a1, d1                 ; Increment a1 to the next position in the array
  addi.l #2, d1
  move.l d1, a1

  bra.s InputManager_FindNearestInDirection_ShortestDistanceLoop

InputManager_FindNearestInDirection_ReturnValue:
  move.w  -2(fp), d0            ; Deallocate that huge array
  lsl.w   #1, d0
  Deallocate d0
  move.l  (sp)+, a4             ; Restore a4, we're done with it
  move.l  (sp)+, a3             ; Restore a3, we're done with it
  move.l  (sp)+, a2             ; Restore a2, we're done with it
  move.w  -6(fp), d0            ; The return value is the last lowest position (or -1)
  PopStack 8                    ; Pop all local variables
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

  cmp.w   #-1, d0
  beq.s   InputManager_UpdateState_End

  move.w  d0, IM_DESTINATION(a0)            ; Set destination to returned
  move.w  #100, IM_STEP(a0)                 ; Set step to 100
  rts

InputManager_UpdateState_ButtonPressed:
  MoveTargetPointer IM_ORIGIN(a0), a1       ; Get pointer to the item in the target array
  move.l  TARGET_CALLBACK(a1), a1

  move.w   d0, -(sp)                        ; Push button states
  jsr      (a1)                             ; Call the callback!
  PopStack 2

InputManager_UpdateState_End:
  rts

  endif
