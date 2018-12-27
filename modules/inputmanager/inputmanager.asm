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

; InputManager target data structure:
; [ xx xx yy yy ww ww hh hh aa aa aa aa ]
; xx xx yy yy - Location on-screen of upper left corner
; ww ww hh hh - Width and height
; aa aa aa aa - Callback: jsr'd when non-joypad button is pressed

; InputManager struct:
; [ xx xx yy yy ww ww hh hh aa ll nn nn [ target, target, ... ] ]
; 0 xx xx yy yy - Upper left corner of cursor
; 4 ww ww hh hh - Width and height of cursor box
; 8 i1 i2 i3 i4 - Sprite attribute table index of each corner, clockwise from left
; 12 oo oo - Origin target, if interpolating, current target otherwise
; 14 dd dd - Destination target, if interpolating
; 16 00 ss - Interpolation step, 0 representing no active interpolation
; 18 nn nn - Number of targets remaining (300 available)

IM_TARGETS = 300
IM_TARGET_SIZE = 12
IM_MEMBERS_SIZE = 20

; Returns: address of new InputManager
InputManager_Create:
  move.l  (sp), a1            ; Save the return address for after we're done preallocating

  move.l  sp, d0
  subi.l  #( ( IM_TARGETS * IM_TARGET_SIZE ) + IM_MEMBERS_SIZE ), d0
  move.l  d0, sp

  move.l  #0, (sp)             ; Set x and y coords of current cursor to 0
  move.l  #0, 4(sp)            ; Set width and height of current cursor to 0
  move.l  #0, 8(sp)            ; Set attribute and location of rotatable corner piece to 0
  move.w  #0, 12(sp)           ; Origin target 0
  move.w  #0, 14(sp)           ; Destination target 0
  move.w  #0, 16(sp)           ; Inactive interpolation (0)
  move.w  #IM_TARGETS, 18(sp)  ; 300 slots open for input manager targets

  move.l  sp, d0               ; d0 returns the address of the inputmanager

  move.l  a1, -(sp)           ; Push return address back onto the stack
  rts

; aa aa aa aa - Address of the inputmanager
; xx xx yy yy - Target location
; ww ww hh hh - Width and height
; cc cc cc cc - Callback
InputManager_RegisterTarget:
  move.l  4(sp), a0           ; a0 is going to be where much of the magic happens

  move.w  18(a0), d0          ; Decrement available targets
  subi.w  #1, d0
  move.w  d0, 18(a0)

  ; IM_MEMBERS_SIZE + IM_TARGET_SIZE( IM_TARGETS - Remaining - 1 ) = Offset the new target is placed at
  move.l  #0, d0              ; Store in d0
  move.w  #IM_TARGETS, d0
  sub.w   18(a0), d0
  subi.w  #1, d0
  mulu.w  #IM_TARGET_SIZE, d0
  addi.w  #IM_MEMBERS_SIZE, d0

  add.l   a0, d0              ; Address + offset (or offset + address)

  move.l  8(sp), (a0)+        ; Write xx xx and yy yy
  move.l  12(sp), (a0)+       ; Write ww ww and hh hh
  move.l  16(sp), (a0)        ; Write callback
  rts

; a0 shall be address of inputmanager
; d2 d2 d2 d2
; a2 a2 a2 a2
; rr rr rr rr
InputManager_UpdateInterpolation:
  move.l  a2, -(sp)
  move.l  d2, -(sp)

  move.w  #100, d2                ; Invert proportion
  sub.w   16(a0), d2

  ; xx xx, yy yy - UL
  ; xx xx + ww ww, yy yy - UR
  ; xx xx, yy yy + hh hh - LL
  ; xx xx + ww ww, yy yy + hh hh - LR
  ; lerp uses origin target, destination target, proportion at 16(a0)
  ; each target address is accessible with the formula:
  ;     a0 + IM_MEMBERS_SIZE + (IM_TARGET_SIZE * target index)

  MoveTargetPointer 12(a0), a1
  MoveTargetPointer 14(a0), a2

  MathLerp (a1), (a2), d2

  move.w  d0, (a0)                ; Write new xx xx position to inputmanager

  MathLerp 2(a1), 2(a2), d2

  move.w  d0, 2(a0)               ; Write new yy yy position to inputmanager

  ; TODO: For now and for testing, we're only going to do the top left corner
  ; TODO: But here will go calculations for new widths and heights, etc

  move.w  16(a0), d0              ; Decrement percent remaining
  subi.w  #1, d0
  move.w  d0, 16(a0)

  move.l  (sp)+, d2
  move.l  (sp)+, a2
  rts

; aa aa aa aa - Address of the inputmanager
InputManager_UpdateState:
  move.l  4(sp), a0           ; Load SELF pointer

  move.w  18(a0), d0          ; Nothing to do if there are no targets
  cmp.w   #IM_TARGETS, d0
  bne.s   InputManager_UpdateState_CheckInterpolation
  rts

InputManager_UpdateState_CheckInterpolation:
  move.w  16(a0), d0
  tst.w   d0
  beq.s   InputManager_UpdateState_CheckInputs    ; If interpolation step is 0 then nothing needs to be done

  bsr.w   InputManager_UpdateInterpolation        ; Otherwise, call the function which updates sprite position on screen
  rts

InputManager_UpdateState_CheckInputs:
  ; TODO: Check for a,b,c,start where the item currently is
  ; TODO: Check for dpad motion, find the items in that direction, and set destination for next go-around
  rts

  endif
