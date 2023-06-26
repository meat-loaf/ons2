includefrom "list.def"

!growvine_sprnum = $29

%alloc_sprite(!growvine_sprnum, "growing_vine", growing_vine_init, growing_vine_main, 1, 0, \
	$00, $00, $3B, $82, $29, $40)
%alloc_sprite_sharedgfx_entry_2(!growvine_sprnum,$04,$06)

!growvine_block_spawn_timer = !sprite_misc_1540
!growvine_ani_timer         = !sprite_misc_1570
; TODO props shuffling can probably be a dumb ambient sprite
;      instead.

%set_free_start("bank1_growvine")
growing_vine_init:
	; todo: spawn ambient sprite with timer at
	;       sprites position
.exit:
	rtl
growing_vine_main:
	lda !sprite_level_props
	pha
	lda !growvine_block_spawn_timer,x
	cmp #$20
	bcc .still_in_block
	lda #$10
	sta !sprite_level_props
.still_in_block:
	jsr.w sub_spr_gfx_2
	pla
	sta !sprite_level_props
	lda !sprites_locked
	bne growing_vine_init_exit
	jsr.w _spr_set_ani_frame
	lda #$F0
	sta !sprite_speed_y,x
	jsr.w _spr_upd_y_no_grav
	lda !growvine_block_spawn_timer,x
	cmp #$20
	bcs .check_spawn_vine
	jsr.w _spr_obj_interact
	lda !sprite_blocked_status,x
	bne .deleet
	lda !sprite_y_high,x
	bpl .check_spawn_vine
.deleet:
	; offscr erase sprite
	jsr.w $01AC80|!bank
	rtl

.check_spawn_vine
	lda !sprite_y_low,x
	and #$0F
	bne growing_vine_init_exit
	lda !sprite_x_low,x
	sta !block_xpos
	lda !sprite_x_high,x
	sta !block_xpos+1

	lda !sprite_y_low,x
	sta !block_ypos
	lda !sprite_y_high,x
	sta !block_ypos+1
	lda #$03
	sta !block_to_generate
	jsl write_item_memory
	jml generate_block
growvine_done:
%set_free_finish("bank1_growvine", growvine_done)
