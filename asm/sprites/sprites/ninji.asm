includefrom "list.def"

!ninji_jump_speed_ix = !sprite_misc_c2
!ninji_face = !sprite_misc_157c

!ninji_jump_wait_timer = !sprite_misc_1540
!ninji_ani_frame  = !sprite_misc_1602

%alloc_sprite_spriteset_1(!ninji_sprnum, "ninji", ninji_init, ninji_main, 1, \
	$114, \
	$10, $80, $09, $00, $10, $00, \
	ninji_main_tiles,
	!spr_norm_gfx_single_rt_id)

%set_free_start("bank1_spr0to13")
ninji_init:
	jsl get_rand
	and #$03
	sta !ninji_jump_speed_ix,x
	rtl

ninji_main:
	jsl sub_horz_pos
	tya
	sta !ninji_face,x
	lda #$00
	jsl sub_off_screen
	jsr _sprspr_mario_spr_rt
	jsr _spr_upd_pos

	%spr_obj_blocked(!sprite_blocked_above|!sprite_blocked_below)
	beq .not_jumping
	stz !sprite_speed_y,x
	lda !ninji_jump_wait_timer,x
	bne .not_jumping
	lda #$60
	sta !ninji_jump_wait_timer,x
	lda !ninji_jump_speed_ix,x
	inc
	and #$03
	sta !ninji_jump_speed_ix,x
	tay
	lda .y_speeds,y
	sta !sprite_speed_y,x
.not_jumping:
	lda #$00
	ldy !sprite_speed_y,x
	bmi .not_moving_up
	inc
.not_moving_up:
	sta !ninji_ani_frame,x
	rtl
.y_speeds:
	db $D0,$C0,$B0,$D0
.tiles:
	db $02, $00
.done:
%set_free_finish("bank1_spr0to13", ninji_main_done)
