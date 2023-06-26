!dyn_gfx_files_max = 10

%set_free_start("bank3_sprites")
; a generic 32x32 sprite routine
; inputs:
;   15f6,x: oam props
;   157c,x: horizontal direction, controls flipping
;     note: if both the x-flip setting and 157c are set,
;             the sprite will not be x-flipped
;   1602,x: animation frame. Made for spritesets, so first frame is $00,
;             second is $08, third is $20, fourth is $28
;     note: dynamic sprites should populate this as the slot index they
;             are using, and have a 'spriteset offset' of $C0 to properly
;             set up the tiles

!first_32x32_sprnum = $B9

!spr_horz_dir  = !sprite_misc_157c
!spr_ani_frame = !sprite_misc_1602

spr_gfx_32x32:
;	stz $0E
;	stz $0F
.alt:
	jsl get_draw_info
.no_getdrawinfo:
	ldy !sprite_num,x
	lda .tile_off_x_base-!first_32x32_sprnum,y
	clc
	adc $00
	sta $00
	lda .tile_off_y_base-!first_32x32_sprnum,y
	clc
	adc $01
	sta $01


	ldy !spr_ani_frame,x
	lda .tile_index,y
	sta $02

	ldy #$00
	lda !spr_horz_dir,x
	bne .no_x_flip
	ldy #$40
.no_x_flip:
	tya
	eor !sprite_oam_properties,x
	ora !sprite_level_props
	sta $03

	ldy !sprite_oam_index,x

	rol #3
	and #$03
	asl #2
	tax

	lda #$03
	sta $04
.draw_loop:
	lda $00
	clc
	adc .tile_offsets_x,x
	sta $0300|!addr,y

	lda $01
	clc
	adc .tile_offsets_y,x
	sta $0301|!addr,y

	lda $02
	sta $0302|!addr,y
	inc
	inc
	sta $02

	lda $03
	sta $0303|!addr,y

	iny #4
	inx
	dec $04
	bpl .draw_loop
.ret:
	ldx !current_sprite_process
	lda #$03
	ldy #$02
	jsl finish_oam_write
	rts

; per-sprite tables, x/y offset applied to each sprite tile
; most 32x32 sprites are drawn with slightly different offsets
; (see mega mole, where sprite position is at the bottom-left, or
;   the porcu-puffer, where its sprite position is at its center,
;   or the castle block which has the posotion at the top-left)
;   TODO with clipping updates many of these may be able to be unified,
;   and the per-sprite offset may not be needed
.tile_off_x_base:
	db $00,$F8,$00,$00,$F2,$F8,$00,$00,$00,$00,$08
.tile_off_y_base:
	db $00,$F7,$00,$00,$00,$F0,$F0,$00,$00,$00,$F8
; indexed by yx flip
.tile_off_start:
	db $00
	db $04
	db $08
	db $0C
.tile_index:
	db $00,$08,$20,$28
.tile_offsets_x:
	db $00,$10,$00,$10
	db $10,$00,$10,$00
	db $00,$10,$00,$10
	db $10,$00,$10,$00
.tile_offsets_y:
	db $00,$00,$10,$10
	db $00,$00,$10,$10
	db $10,$10,$00,$00
	db $10,$10,$00,$00

spr_dyn_gfx_rt:
	; do this first to abort remainder if we're not going to draw anyway
	jsr.w _get_draw_info_bank3
	jsr spr_dyn_allocate_slot
	bcs spr_gfx_32x32_ret
	jmp spr_gfx_32x32_no_getdrawinfo

spr_dyn_allocate_slot_long:
	jsr spr_dyn_allocate_slot
	rtl

; call as follows:
; $0E: frame number to upload to scratch
; $0F: id of graphics to pull frame from
;  * note: X is restored to the current sprite index by the routine
; output:
;  carry: clear if slot available, set if not
; clobbers:
;  $0660-$0662

!spr_dyn_alloc_slot_arg_frame_num = $0E
!spr_dyn_alloc_slot_arg_gfx_id    = $0F
!dyn_spr_slot_tbl                 = !sprite_misc_1602
spr_dyn_allocate_slot:
	; preserve calling value
	lda !dyn_slots
	cmp #!dyn_max_slots
	bcc .slots_avail
	ldx !current_sprite_process
	sec
	rts

.slots_avail:
	lda !spr_dyn_alloc_slot_arg_gfx_id
	asl
	adc !spr_dyn_alloc_slot_arg_gfx_id
	tax

	; setup rom gfx address
	lda.l .gfx,x
	sta !dyn_slot_ptr+0
	lda.l .gfx+1,x
	sta !dyn_slot_ptr+1
	lda.l .gfx+2,x
	sta !dyn_slot_ptr+2
	; a = frame index
	lda !spr_dyn_alloc_slot_arg_frame_num
	; lsb to carry
	lsr
	; preserve carry
	php
	; clear carry (clamp frame to even values)
	clc
	; multiply by 4 (multiply even-valued frame by 2)
	asl #2
	; restore carry - add 1 if frame value is odd
	plp
	adc !dyn_slot_ptr+1
	sta !dyn_slot_ptr+1

	; setup ram buffer address
	clc
	ldx !dyn_slots
	lda.l .buffer_offs_hi,x
	inx
	stx !dyn_slots
	adc.b #(!dynamic_buffer>>8)&$FF
	sta !dyn_slot_dest+1
	lda.b #!dynamic_buffer
	sta !dyn_slot_dest

	rep #$10
	stz $4300
	lda #$80
	sta $4301

	; setup wram write addr
	ldx !dyn_slot_dest
	stx $2181
	lda.b #(!dynamic_buffer>>16)&$FF
	sta $2183

	ldx !dyn_slot_ptr
	stx $4302
	; bank
	lda !dyn_slot_ptr+2
	sta $4304
	ldx #$0100
	stx $4305

	; initiate transfer
	lda #$01
	sta $420B

	; second line transfer - only need to setup addr offsets and reset size
	lda !dyn_slot_dest+1
	adc #$02
	sta $2182

	lda !dyn_slot_ptr+1
	adc #$02
	sta $4303

	ldx #$0100
	stx $4305

	; initiate transfer
	lda #$01
	sta $420B

	sep #$10
	ldx !current_sprite_process
	lda !dyn_slots
	dec
	sta !dyn_spr_slot_tbl,x
	clc
	rts
; slots are 2 16x64 strips
.buffer_offs_hi:
	db $00,$01
	db $04,$05
.gfx:
	skip 3*!dyn_gfx_files_max
; pointers set up by macro after sprite list is loaded
; sprites get a '!dyn_spr_<filename>_gfx_id' define with
; the appropriate index
!spr_dyn_gfx_tbl = spr_dyn_allocate_slot_gfx

bank3_sharedgfx_done:
%set_free_finish("bank3_sprites", bank3_sharedgfx_done)
