includefrom "list.def"

!rex_exbyte_slides = $80
!rex_exbyte_spring = $01

%alloc_sprite_spriteset_1(!rex_sprnum, "rex", rex_init, rex_main, 2, $115, \
	$30, $2A, $00, $01, $00, $00, \
	rex_gfx_ptrs, \
	!spr_norm_gfx_generic_rt_id)

;%alloc_sprite_spriteset_1(!slidin_rex_sprnum, "slidin_rex", slidin_rex_init, slidin_rex_main, 3, $115, \
;	$30, $2A, $00, $01, $00, $00, \
;	rex_gfx_ptrs, \
;	!spr_norm_gfx_generic_rt_id)

;!rex_sprnum

!rex_sliding   = !sprite_misc_c2
!rex_hp        = !sprite_misc_1528
!rex_face_dir  = !sprite_misc_157c
!rex_ani_timer = !sprite_misc_1570
!rex_ani_frame = !sprite_misc_1602
!rex_pop_timer = !sprite_misc_163e

%set_free_start("bank3_sprites")
rex_init:
	ldy #$00
	lda !spr_extra_byte_1,x
	bpl .not_sliding
	inc !rex_sliding,x
	lda #$05
	sta !rex_ani_frame,x
	iny
.not_sliding:
	lda .hps,y
	sta !rex_hp,x
	jsl sub_horz_pos
	tya
	sta !rex_face_dir,x
.set_props:
	lda !spr_extra_byte_1,x
	and #$7F
	tay
	lda .props,y
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	rtl
.props:
	db $06,$08
.hps:
	db $01, $02

rex_main:
	lda #$00
	jsl sub_off_screen
	lda !rex_sliding,x
	beq .normal
	jmp .sliding
.normal:
	%spr_touching_wall()
	beq .no_wall
	lda !rex_face_dir,x
	eor #$01
	sta !rex_face_dir,x
.no_wall:
	%spr_on_ground()
	beq .airborne
	stz !sprite_speed_y,x
.airborne:

	lda !rex_pop_timer,x
	dec
	bne .dont_pop
	inc !rex_hp,x
	lda.b #invert($38)
	sta !sprite_speed_y,x
	lda !rex_ani_frame,x
	dec #2
	sta !rex_ani_frame,x
	bra .interact
.dont_pop:
	jsr rex_set_ani_frame
	ldy !rex_face_dir,x
	lda !rex_hp,x
	bne .slowe
	iny
	iny
.slowe:
	lda .x_speeds,y
	sta !sprite_speed_x,x
.interact:
	jsl update_sprite_pos
	jsl sprspr_mariospr_l
	lda !sprite_status,x
	cmp #$04
	bne .check_skoosh
	jml boost_mario_speed_l

.check_skoosh:
	cmp #$03
	bne .cont
	dec !rex_hp,x
	bmi .die
	lda #$08
	sta !sprite_status,x
	lda !spr_extra_byte_1,x
	dec
	bne ..done
	lda #$31
	sta !rex_pop_timer,x
..done:
	rtl

.die:
	lda #$04
	sta !rex_ani_frame,x
.cont:
	rtl
.x_speeds:
	db $08, invert($08)
	db $10, invert($10)

.sliding:
	rtl

rex_set_ani_frame:
	inc !rex_ani_timer,x
	lda !rex_ani_timer,x
	lsr #2

	ldy !rex_hp,x
	beq .fast
	lsr
	and #$01
	sta !rex_ani_frame,x
	rts
.fast:
	and #$01
	inc #2
	sta !rex_ani_frame,x
	rts

%start_sprite_pose_entry_list("rex")
	%start_sprite_pose_entry("rex_w_1", 16, 16)
		%sprite_pose_tile_entry($FC, $F0, $00, $00, 2, 1)
		%sprite_pose_tile_entry($00, $00, $02, $00, 2, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("rex_w_2", 16, 16)
		%sprite_pose_tile_entry($FC, $F1, $00, $00, 2, 1)
		%sprite_pose_tile_entry($00, $00, $04, $00, 2, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("rex_ws_1", 16, 16)
		%sprite_pose_tile_entry($00, $00, $06, $00, 2, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("rex_ws_2", 16, 16)
		%sprite_pose_tile_entry($00, $00, $08, $00, 2, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("rex_skoosh", 16, 16)
		%sprite_pose_tile_entry($FC, $04, $0F, $00, 0, 1)
		%sprite_pose_tile_entry($04, $04, $1F, $00, 0, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("rex_slide", 16, 16)
		%sprite_pose_tile_entry($00, $F3, $00, $00, 2, 1)
		%sprite_pose_tile_entry($00, $00, $0B, $00, 2, 1)
		%sprite_pose_tile_entry($F8, $00, $0A, $00, 2, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()
rex_done:
%set_free_finish("bank3_sprites", rex_done)
