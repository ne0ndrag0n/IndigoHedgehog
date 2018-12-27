  ifnd H_SPRITES_MANAGER
H_SPRITES_MANAGER = 1

SPRITE_VERTICAL_SIZE_1=$0000
SPRITE_VERTICAL_SIZE_2=$0100
SPRITE_VERTICAL_SIZE_3=$0200
SPRITE_VERTICAL_SIZE_4=$0300

SPRITE_HORIZONTAL_SIZE_1=$0000
SPRITE_HORIZONTAL_SIZE_2=$0400
SPRITE_HORIZONTAL_SIZE_3=$0800
SPRITE_HORIZONTAL_SIZE_4=$0C00

SPRITE_PRIORITY=$8000
SPRITE_PAL_0=$0000
SPRITE_PAL_1=$2000
SPRITE_PAL_2=$4000
SPRITE_PAL_3=$6000

SPRITE_VFLIP=$1000
SPRITE_HFLIP=$0800

  macro VdpNewSprite
    move.w  \4, -(sp)
    move.w  \3, -(sp)
    move.w  \2, -(sp)
    move.w  \1, -(sp)
    jsr NewSprite
    PopStack 8
  endm

; xx xx - Location of sprite, x
; yy yy - Location of sprite, y
; 00 hv - Horizontal and vertical size
; aa ii - Index of sprite pattern w/attributes
; Returns: numeric index of sprite just created in sprite attribute table - or -1 if we couldn't make one.
NewSprite:
  jsr FindNearestOpenSprite

  cmpi.w  #-1, d0
  bne.s   NewSprite_Allocate

  rts                         ; d0 is -1, so return that if we can't allocate a sprite

NewSprite_Allocate:
  move.l  d0, d1              ; Save the original return value

  mulu.w  #8, d0              ; 8 * index
  addi.w  #VDP_SPRITES, d0    ; + VDP_SPRITES

  move.l  d1, -(sp)
  move.w  #0, -(sp)           ; Vram write
  move.w  d0, -(sp)           ; VDP destination
  move.w  #0, -(sp)
  jsr ComputeVdpDestinationAddress
  PopStack 6
  move.l  (sp)+, d1

  move.l  d0, (VDP_CONTROL)   ; Set VDP to write to this address

  move.w  6(sp), d0           ; Load yy yy
  addi.w  #$80, d0            ; All locations must be + 128
  move.w  d0, (VDP_DATA)      ; Write vertical position and autoincrement

  move.w  8(sp), d0           ; Load hv size attributes
  andi.w  #$FF80, d0          ; Don't keep any potential link field provided - This is the item at the end of the list
  move.w  d0, (VDP_DATA)      ; Write hv size attributes and link and autoincrement

  move.w  10(sp), (VDP_DATA)  ; Load tile attribute data - No postprocessing required and autoincrement

  move.w  4(sp), d0           ; Load xx xx
  addi.w  #$80, d0            ; All locations must be + 128
  move.w  d0, (VDP_DATA)      ; Write horizontal position and autoincrement

  move.l  d2, -(sp)           ; Save d2 as we're about to screw with it

  move.l  d1, d2              ; Go get original return value
  lsr.l   #7, d2              ; Original end of list index is at upper word so >> 16
  lsr.l   #7, d2
  lsr.l   #2, d2
  mulu.w  #8, d2              ; index * 8
  addi.w  #VDP_SPRITES, d2    ; + VDP_SPRITES
  addi.w  #2, d2              ; + 2, to get at the link attribute

  move.l  d2, -(sp)
  move.l  d1, -(sp)
  move.w  d2, -(sp)           ; Read existing vram word at previous end of list
  jsr ReadVramWord
  PopStack 2
  move.l  (sp)+, d1
  move.l  (sp)+, d2

  andi.w  #$FF80, d0          ; Clear the link attribute for good measure
  or.w    d1, d0              ; OR the latest sprite attribute table index, onto the word we just fetched

  move.l  d1, -(sp)           ; We still need d1 for the return value!

  move.w  d0, -(sp)           ; Write those contents to VRAM
  move.w  d2, -(sp)           ; At the same address we read from
  jsr WriteVramWord
  PopStack 4

  move.l  (sp)+, d1           ; Restore d1
  move.w  d1, d0              ; Return the index of the item we created

  move.l  (sp)+, d2           ; Slip d2 back
  rts

; Returns: The nearest open "slot" in the sprite attribute table. -1 if we're out of sprites.
; Longword - High word contains the index of the last zero item. Low word contains the next item ready to use.
FindNearestOpenSprite:
  move.w  #VDP_SPRITES, -(sp)   ; First thing we want to do is check for the default position
  jsr ReadVramWord              ; That's all four words in the first entry being 0
  PopStack 2

  tst.w   d0
  bne.s   FindNearestOpenSprite_Continue

  move.w  #VDP_SPRITES + 2, -(sp)
  jsr ReadVramWord
  PopStack 2

  tst.w   d0
  bne.s   FindNearestOpenSprite_Continue

  move.w  #VDP_SPRITES + 4, -(sp)
  jsr ReadVramWord
  PopStack 2

  tst.w  d0
  bne.s  FindNearestOpenSprite_Continue

  move.w  #VDP_SPRITES + 6, -(sp)
  jsr ReadVramWord
  PopStack 2

  tst.w   d0
  bne.s   FindNearestOpenSprite_Continue

  move.l  #0, d0
  rts

FindNearestOpenSprite_Continue:
  move.l  d2, -(sp)           ; Save d2 so we can use it

  move.w  #1, d1              ; Our search begins by checking to see if sprite index 1 is unused
  move.w  #0, d2              ; Current index into the sprite table

FindNearestOpenSprite_TryAgain:
  ; *( VDP_SPRITES + ( 8 * index ) + 2 ) & $007F = link value for an item in the sprite attribute table
  move.w  d2, d0              ; 8 * index
  mulu.w  #8, d0
  addi.w  #VDP_SPRITES, d0    ; + VDP_SPRITES
  addi.w  #2, d0              ; + 2

  move.w  d1, -(sp)           ; Save d1 as ReadVramWord may corrupt it

  move.w  d0, -(sp)           ; d0 turns from pointer to value
  jsr ReadVramWord
  PopStack 2

  move.w  (sp)+, d1           ; Restore d1

  andi.w  #$007F, d0          ; Only the bottom 7 bits (the index)

  ; If we find the item here, it can't be used. Increment d1, reset d2 to zero, and do all this shit over again.
  ;   If d1 equals 128 there's no room to add a sprite!
  ; Else if we didn't find the item here, go to the next index and check that.
  ;   If the next index is zero, this is the end of the list. The item was never found, so it's safe to use - return d1.

  cmp.w   d0, d1              ; Did we find the target index?
  bne.s   FindNearestOpenSprite_ItemNotFound

  addi.w  #1, d1

  cmpi.w  #128, d1            ; There is no sprite index 128. If you got here, you ran out of sprites.
  bne.s   FindNearestOpenSprite_Reset

  move.w  #-1, d0             ; -1 means you're flat out of sprites
  bra.s   FindNearestOpenSprite_End

FindNearestOpenSprite_Reset:
  move.w  #0, d2
  bra.s   FindNearestOpenSprite_TryAgain

FindNearestOpenSprite_ItemNotFound:
  tst.w   d0                  ; Was this the last item in the list?
  bne.s   FindNearestOpenSprite_JumpToNext

  move.w  d2, d0              ; d1 survived without being found in the linked list of sprites
  lsl.l   #7, d0              ; Return the current d2 index in the upper word - we'll need it to reassign the link
  lsl.l   #7, d0
  lsl.l   #2, d0
  or.w    d1, d0              ; Return d1 in the lower word
  bra.s   FindNearestOpenSprite_End

FindNearestOpenSprite_JumpToNext:
  move.w  d0, d2              ; Jump on over to the next item in the list
  bra.s   FindNearestOpenSprite_TryAgain

FindNearestOpenSprite_End:
  move.l  (sp)+, d2           ; Restore whatever d2 was
  rts

  endif