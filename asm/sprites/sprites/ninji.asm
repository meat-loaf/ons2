includefrom "list.def"

!ninji_jump_speed_ix = !sprite_misc_c2
!ninji_face = !sprite_misc_157c

!ninji_rand_jump_height = !sprite_misc_151c
!ninji_jump_kind        = !sprite_misc_1528

!ninji_jump_wait_timer = !sprite_misc_1540
!ninji_ani_frame  = !sprite_misc_1602

!ninji_exbyte_rand_jump_height   = $01
!ninji_exbyte_jump_instant       = $02
!ninji_exbyte_jump_short_timer   = $04

!ninji_exbyte_jump_kind = !ninji_exbyte_jump_instant|!ninji_exbyte_jump_short_timer

%alloc_sprite_spriteset_1(!ninji_sprnum, "ninji", ninji_init, ninji_main, 1, \
	$114, \
	$10, $80, $09, $00, $10, $00, \
	ninji_main_tiles,
	!spr_norm_gfx_single_rt_id)

%set_free_start("bank1_spr0to13")
ninji_init:
	lda !spr_extra_byte_1,x
	and #!ninji_exbyte_rand_jump_height
	sta !ninji_rand_jump_height,x

	lda !spr_extra_byte_1,x
	and #!ninji_exbyte_jump_kind
	lsr
	sta !ninji_jump_kind,x
	
	jsl get_rand
	ldy !ninji_rand_jump_height,x
	and .randoff,y
	
	sta !ninji_jump_speed_ix,x
	rtl
.randoff:
	db $03,$07

ninji_main:
	jsl sub_horz_pos
	tya
	sta !ninji_face,x
	lda #$00
	jsl sub_off_screen
	jsr _sprspr_mario_spr_rt
	jsr _spr_upd_pos
	lda !sprite_status,x
	cmp #$08
	bcc .exit

	%spr_obj_blocked(!sprite_blocked_above|!sprite_blocked_below)
	beq .not_jumping
	stz !sprite_speed_y,x
	lda !ninji_jump_wait_timer,x
	bne .not_jumping
	ldy !ninji_jump_kind,x
	lda .jump_timer,y
	sta !ninji_jump_wait_timer,x

	lda !ninji_rand_jump_height,x
	beq .nilla_jump
	jsl get_rand
	bra .store_speed_ix

.nilla_jump:
	lda !ninji_jump_speed_ix,x
	inc
.store_speed_ix:
	ldy !ninji_rand_jump_height,x
	and ninji_init_randoff,y

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
.exit:
	rtl
.y_speeds:
	db $D0,$C0,$B0,$D0
	; random only
	db $B8,$D0,$C0,$B0
.tiles:
	db $02, $00
.jump_timer:
	db $60, $00, $30, $00
.done:
%set_free_finish("bank1_spr0to13", ninji_main_done)
