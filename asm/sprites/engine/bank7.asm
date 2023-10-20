includeonce

; todo
;  * make tweaker tables relocatable, we support > c8 sprites
;  * move spriteset changes here? it modifies
;      the load sprite tables routine
; * do something about the goal tape junk here, move it? move all the 
;   goal tape code here?

%set_free_start("bank7")
; TODO currently some ids at the end of the range
;      aren't for normal sprites, and thus don't have
;      tweaker bits, not all entries are currently used
spr_tweaker_1656_tbl:
	skip $100
spr_tweaker_1662_tbl:
	skip $100
spr_tweaker_166E_tbl:
	skip $100
spr_tweaker_167A_tbl:
	skip $100
spr_tweaker_1686_tbl:
	skip $100
spr_tweaker_190F_tbl:
	skip $100
spr_gfxptr_rt_id_tbl:
	skip $100
;spr_gfxptr_lo_tbl:
;	skip $100
;spr_gfxptr_hi_tbl:
;	skip $100
spr_gfx_lo_tbl:
	skip $100
spr_gfx_hi_tbl:
	skip $100

zero_sprite_tables:
	stz.w !sprite_in_water,x
	stz.w !sprite_behind_scenery,x
	stz.b !sprite_misc_c2,x
	stz.w !sprite_misc_151c,x
	stz.w !sprite_misc_1528,x
	stz.w !sprite_misc_1534,x
	stz.w !sprite_misc_157c,x
	stz.w !sprite_blocked_status,x
	stz.w !sprite_off_screen,x
	stz.w !sprite_misc_1602,x
	stz.w !sprite_misc_1540,x
	stz.w !sprite_misc_154c,x
	stz.w !sprite_misc_1558,x
	stz.w !sprite_misc_1564,x
	stz.w !sprite_cape_disable_time,x
	stz.w !sprite_misc_1626,x
	stz.w !sprite_misc_1570,x
	stz.b !sprite_speed_x,x
	stz.w !sprite_pos_x_frac,x
	stz.b !sprite_speed_y,x
	stz.w !sprite_obj_interact,x
	stz.w !sprite_pos_y_frac,x
	stz.w !sprite_being_eaten,x
	stz.w !sprite_misc_163e,x
	stz.w !sprite_misc_187b,x
	stz.w !sprite_misc_160e,x
	stz.w !sprite_misc_1594,x
	stz.w !sprite_misc_1504,x
;	stz.w !sprite_misc_1fd6,x
	stz.w !sprite_dyn_gfx_id,x
	stz.w !spr_spriteset_off,x
	lda.b #$01
	sta.w !sprite_off_screen_horz,x
	rtl

init_sprite_tables:
	jsl zero_sprite_tables
	; fallthrough
load_sprite_tables:
	phy
	phx
	lda !sprite_num,x
	txy
	tax
	lda.l spr_gfxptr_rt_id_tbl,x
	sta !spr_gfx_rt_id,y
	lda.l spr_gfx_lo_tbl,x
	sta !spr_gfx_tbl_lo,y
	lda.l spr_gfx_hi_tbl,x
	sta !spr_gfx_tbl_hi,y
	lda.l !sprite_main_table_bk,x
	sta !spr_gfx_tbl_bk,y
	lda.l spr_tweaker_1656_tbl,x
	sta !sprite_tweaker_1656,y
	lda.l spr_tweaker_1662_tbl,x
	sta !sprite_tweaker_1662,y
	lda.l spr_tweaker_166E_tbl,x
	sta !sprite_tweaker_166e,y
	lda.l spr_tweaker_167A_tbl,x
	sta !sprite_tweaker_167a,y
	lda.l spr_tweaker_1686_tbl,x
	sta !sprite_tweaker_1686,y
	lda.l spr_tweaker_190F_tbl,x
	sta !sprite_tweaker_190f,y

	; TODO all this sucks
	;lda.l spr_tweaker_166E_tbl,x
	lda !sprite_tweaker_166e,y
	and #$0f
	lsr
	sta !sprite_oam_properties,y
	lda #$c0
	sta !spr_spriteset_off,y
	bcs .dynspr

	lda.l !level_ss_sprite_offs,x
	cmp #$ff
	bne .have_set
	inc
	clc
.have_set:
	asl
	sta !spr_spriteset_off,y

.dynspr:
	plx
	ply
	rol !sprite_oam_properties,x
.exit:
	rtl

; generic gfx callbacks
chuck_head_shake_callback:
	lda !sprite_misc_1570,x
	cmp #$05
	bne .exit
	sty $00
	ldy !sprite_misc_151c,x
	lda.w chuck_head_shake_props,y
	ldy $00
	sta $00
	lda $0303-$0C|!addr,y
	and #(~$C0)
	ora $00
	sta $0303-$0C|!addr,y
	lda $0302-$0C|!addr,y
	dec #2
	sta $0302-$0C|!addr,y
.exit
	rtl

; TODO something about this is not exactly correct. inspect
;      actual use of this table (see LookSideToSide behavior ptr in chuck)
chuck_sit_callback:
	lda !sprite_misc_1534,x
	lsr
	bcs .right
	lda $0303-$0C|!addr,y
	and #(~$40)
	ora #$40
	sta $0303-$0C|!addr,y
	rtl
.right:
	lda $0303-$0C|!addr,y
	and #(~$40)
	sta $0303-$0C|!addr,y
	rtl

; todo more elegant...need tables. need to offset in x-dir if right facing
winged_koopa_callback:
	lda !sprite_misc_1602,x
	cmp #$03
	bne .grounded
	lda #$4E
	bra .set_tile

.grounded:
	lda #$5D
.set_tile:
	sta $0302-$0C|!addr,y
	lda $0303-$0C|!addr,y
	and #$FE
	sta $0303-$0C|!addr,y
.exit:
	rtl

!gfx_x_pos         = $00
!gfx_y_pos         = $02

!spr_props_no_flip = $04

; two bytes together (packed)
!spr_tile_off      = $06

!tile_flip_y_off   = $08
!tile_flip_x_off   = $09

; two bytes
!spr_props_flip    = $0A

!curr_pose_ptr     = $0c
!curr_pose_ptr_off = $0e
!oam_off           = $0f

!tile_yx           = $45
!tile_hitable      = $48
!tile_off          = $49

!spr_tile_off_2    = $8A
!spr_finish_cb     = $D5
; 'default' entry point, mainly intended for sprite states outside of 8
!gen_spr_gfx = spr_gfx_2
spr_gfx_2:
	lda !spr_gfx_tbl_hi,x
	sta !curr_pose_ptr+1
	lda !spr_gfx_tbl_lo,x
	sta !curr_pose_ptr
	lda !sprite_misc_1602,x
	asl
	tay
	rep #$20
	lda (!curr_pose_ptr),y
	sta !curr_pose_ptr
	sep #$20

	; table header - offset to center + pointer
	; to first tile
	lda (!curr_pose_ptr)
	sta $45
	stz $46
	ldy #$01
	lda (!curr_pose_ptr),y
	sta $47
	stz $48

	; potential callback
	iny
	lda (!curr_pose_ptr),y
	sta !spr_finish_cb
	iny
	lda (!curr_pose_ptr),y
	sta !spr_finish_cb+1

	iny
	lda (!curr_pose_ptr),y
	xba
	iny
	lda (!curr_pose_ptr),y
	sta !curr_pose_ptr+1
	xba
	sta !curr_pose_ptr

	ldy #$00
	lda !sprite_misc_157c,x
	bne .no_x_flip_facedir
	ldy #$40
.no_x_flip_facedir:
	sty $01
	
	stz !tile_off+1
	stz !spr_tile_off+1
	stz !spr_tile_off_2+1
	stz !spr_props_no_flip
	stz !spr_props_flip

	lda !spr_spriteset_off,x
	sta !spr_tile_off
	lda !sprite_misc_151c,x
	sta !spr_tile_off_2

	lda !sprite_oam_properties,x
	sta $00
	and #$3F
	sta !spr_props_no_flip+1
	ldy #$02
	lda $00
	and #$C0
	eor $01
	ora $64
	sta !spr_props_flip+1
	bpl .no_y_flip
	ldy #$04
.no_y_flip:
	sty !tile_flip_y_off
	ldy #$06
	; still has props
	and #$40
	beq .no_x_flip
	ldy #$08
.no_x_flip:
	sty !tile_flip_x_off

	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$20
	sec
	sbc !layer_1_xpos_curr
	clc
	adc $45
;	adc !gen_gfx_tile_offs+$0
	sta !gfx_x_pos
	; stolen from original suboffscreen...
	; not much of a better way to do it i don't think
	; since we still need to pack 8-bit tables. we need
	; to drop to 8-bit a for y calcs anyway

	clc
	adc #$0040
	cmp #$0180
	sep #$20
;	lda #$00
	tdc
	rol
	sta !sprite_off_screen_horz,x
	beq .continue
	rtl
.continue:

	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	; carry is always clear here anywhay from rol above but whatever
	rep #$21
	adc #$0010
	sec
	sbc !layer_1_ypos_curr
	clc
;	adc !gen_gfx_tile_offs+$2
	adc $47
	sta !gfx_y_pos

	lda !sprite_oam_index,x
	tax

.handle_pose:
	ldy #$00
	lda (!curr_pose_ptr),y
	sta !tile_hitable

	ldy !tile_flip_y_off
	lda (!curr_pose_ptr),y
	clc
	adc !gfx_y_pos
	sec
	sbc #$0010
	sbc !tile_off

	cmp #$FFF0
	bcs ..y_onscr
	cmp #$00F0
	bcc ..y_onscr
..y_offscr:
	lda #$00F0
..y_onscr:
	sta !tile_yx

	ldy !tile_flip_x_off
	lda (!curr_pose_ptr),y
	clc
	adc !gfx_x_pos
	sec
	sbc !tile_off

	cmp #$0100
	sta !tile_yx+1
	; corrupts tile offset, but it's not needed now
	rol !tile_hitable

	ldy #$0a
	lda (!curr_pose_ptr),y
	bit #$0100
	beq ..no_ram_props
	and #(~$0100)
	ora !spr_props_no_flip
	clc
..no_ram_props:
	bit #$0080
	beq .no_ext_tile_off
	and #(~$0080)
	adc !spr_tile_off_2
.no_ext_tile_off:
	adc !spr_tile_off
	eor !spr_props_flip
	sta $0302|!addr,x
	lda !tile_yx
	xba
	sta $0300|!addr,x
	txa
	lsr #2
	tax
	lda !tile_hitable
	; turns out this is necessary. no sty addr,x to make it cheaper
	sep #$20
	sta $0460|!addr,x
	; since we drop to 8 bit mode we can save a cycle here
	; not loading the otherwise unneded high byte
	lda.l oam_small_to_next_big,x
	rep #$20
	tax
	ldy #$0c
	lda (!curr_pose_ptr),y
	beq ..done
	sta !curr_pose_ptr
	bra .handle_pose

..done:
	txy
	ldx !current_sprite_process

	lda !spr_finish_cb
	sep #$20
	beq .exit
	jmp.w (!spr_finish_cb)

.exit:
	rtl

oam_small_to_next_big:
!ix #= 1
while !ix <= $64
	db !ix*4
	!ix #= !ix+1
endif

; carry clear if successful: buffer index in y
; carry set if no slots left; y will be negative
;get_dyn_pose:
;	txy
;	ldx !dyn_pose_buffer_avail
;	lda.l .free_indices,x
;	bmi .none
;	tsb !dyn_pose_buffer_avail
;	tax
;	lda.l .buff_index_to_offset,x
;.none:
;	tyx
;	tay
;
;	rtl
;
;.free_indices:
;	db $00, $01, $00, $02, $00, $01, $00, $03
;	db $00, $01, $00, $02, $00, $01, $00, $04
;	db $00, $01, $00, $02, $00, $01, $00, $03
;	db $00, $01, $00, $02, $00, $01, $00, $05
;	db $00, $01, $00, $02, $00, $01, $00, $03
;	db $00, $01, $00, $02, $00, $01, $00, $04
;	db $00, $01, $00, $02, $00, $01, $00, $03
;	db $00, $01, $00, $02, $00, $01, $00, $06|$80
;.buff_index_to_offset:
;	db !gen_gfx_tile_tblsz*0
;	db !gen_gfx_tile_tblsz*1
;	db !gen_gfx_tile_tblsz*2
;	db !gen_gfx_tile_tblsz*3
;	db !gen_gfx_tile_tblsz*4
;	db !gen_gfx_tile_tblsz*5
;

; draw a single sprite tile at the sprite's position.
; inputs:
; the tile is always 16x16 (TODO flag?)
spr_gfx_single:
	; pull the tile to draw
	lda !spr_gfx_tbl_lo,x
	sta $0A
	lda !spr_gfx_tbl_hi,x
	sta $0B
	ldy !sprite_misc_1602,x
	lda ($0A),y
	
.have_tile:
	clc
	adc !spr_spriteset_off,x
	sta $03
	tdc
	rol
	sta $04

	ldy #$00
	lda !sprite_misc_157c,x
	bne .no_x_flip_facedir
	ldy #$40
.no_x_flip_facedir:
	tya
	eor !sprite_oam_properties,x
	ora $64
	tsb $04

	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$20
	sec
	sbc !layer_1_xpos_curr
	sta $00
	clc
	adc #$0040
	cmp #$0180
	sep #$20
	tdc
	rol
	sta !sprite_off_screen_horz,x
	bne .abort

	lda #$02
	ldy $01
	beq .x_ok
	ora #$01
.x_ok:
	sta $05

	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	rep #$20
	sec
	sbc !layer_1_ypos_curr
	; the generic routine offsets y-pos to skip this comparison,
	; but this is faster for a single tile
	cmp #$FFF0
	bcs .y_ok
	cmp #$00F0
	bcc .y_ok
	lda #$00F0
.y_ok:
	sta $01

	ldy !sprite_oam_index,x
	lda $00
	sta $0300|!addr,y
	lda $03
	sta $0302|!addr,y
	sep #$20
	tya
	lsr #2
	tay
	lda $05
	sta $0460|!addr,y
.abort:
	rtl

gen_spr_gfx_dyn:
	jsr spr_dyn_allocate_slot
	bcs spr_gfx_single_abort
	jmp spr_gfx_2

; call as follows:
; $0E: frame number to upload to scratch
; $0F: id of graphics to pull frame from
;  * note: X is restored to the current sprite index by the routine
; output:
;  carry: clear if slot available, set if not
; clobbers:
;  $0660-$0662
!dyn_gfx_files_max = 10
!dyn_spr_slot_tbl = !sprite_misc_151c
!dyn_spr_frame_id = !sprite_misc_160e
!spr_dyn_gfx_tbl  = spr_dyn_allocate_slot_gfx
spr_dyn_allocate_slot:
	lda !dyn_slots
	cmp #!dyn_max_slots
	bcc .slots_avail
	ldx !current_sprite_process
	sec
	rts

.slots_avail:
	txy
	lda !sprite_dyn_gfx_id,y
;	lda !spr_dyn_alloc_slot_arg_gfx_id
	asl
	adc !sprite_dyn_gfx_id,y
;	adc !spr_dyn_alloc_slot_arg_gfx_id
	tax

	; setup rom gfx address
	lda.l .gfx,x
	sta !dyn_slot_ptr+0
	lda.l .gfx+1,x
	sta !dyn_slot_ptr+1
	lda.l .gfx+2,x
	sta !dyn_slot_ptr+2
	; a = frame index
;	lda !spr_dyn_alloc_slot_arg_frame_num
	lda !dyn_spr_frame_id,y
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
	;stz $4300
	;lda #$80
	;sta $4301
	ldx #$8000
	stx $4300

	; setup wram write addr
	ldx !dyn_slot_dest
	stx $2181
	lda.b #bank(!dynamic_buffer)
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
	ldy !current_sprite_process
	lda !dyn_slots
	dec
	tax
	lda.l .slot_to_off,x
	sta !dyn_spr_slot_tbl,y
	tyx
	clc
	rts
; slots are 2 16x64 strips
.buffer_offs_hi:
	db $00,$01
	db $04,$05
.slot_to_off:
	db $00,$08,$20,$28
.gfx:
	skip 3*!dyn_gfx_files_max

bank7_stuff_done:
%set_free_finish("bank7", bank7_stuff_done)
