includefrom "list.def"

%alloc_sprite_dynamic_free(!woozyguy_sprnum, "woozyguy", woozyguy_init, woozyguy_main, 4, \
	$30, $80, $01, $01, $00, $00,\
	dyn_woozie_guy_gfx_ptrs, \
	!spr_norm_gfx_dyn_rt_id)

!woozy_phase         = !sprite_misc_c2
!woozy_phase_counter = !sprite_misc_1534
!woozy_face_dir      = !sprite_misc_157c
!woozy_ani_frame_id  = !sprite_misc_160e

!jump_interval = $20
!squish_interval = $08

!jump_y_speed = $30

%set_free_start("bank3_sprites")
woozyguy_init:
	%dyn_slot_setup("woozyguy")
	lda #!jump_interval
	sta !woozy_phase_counter,x

	lda !sprite_x_low,x
	lsr #4
	and #$03
	inc #2
	clc
	asl
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	jsl sub_horz_pos
	tya
	sta !woozy_face_dir,x
.exit
	rtl

woozyguy_main:
	lda #$00
	jsl sub_off_screen
	lda !sprite_blocked_status,x
	and #$08
	beq .not_touching_ceiling
	stz !sprite_speed_y,x
.not_touching_ceiling:
	lda !sprite_blocked_status,x
	and #$03
	beq .not_touching_wall
	lda !woozy_face_dir,x
	eor #$01
	sta !woozy_face_dir,x
.not_touching_wall:

	lda !woozy_phase,x
	txy
	asl
	tax
	jsr (.behaviors,x)
	jsl mario_spr_interact_l
	jsl update_sprite_pos
	jml spr_spr_interact

.behaviors:
	dw ..wait
	dw ..squish
	dw ..jump
	dw ..rotating
	dw ..squish
..wait:
	tyx
	stz !woozy_ani_frame_id,x
	lda !sprite_blocked_status,x
	and #$04
	beq ...done
	dec !woozy_phase_counter,x
	bne ...done
	inc !woozy_phase,x
	lda #!squish_interval
	sta !woozy_phase_counter,x
...done:
	rts

..squish:
	tyx
	dec !woozy_phase_counter,x
	beq ...done
	lda #!squish_interval
	sec
	sbc !woozy_phase_counter,x
	bit #$04
	beq ...no_inv
	eor #$07
...no_inv:
	asl
	adc #$10
	sta !woozy_ani_frame_id,x
	rts
...done:
	ldy !woozy_phase,x
	lda ...next_phase-1,y
	sta !woozy_phase,x
	lda #!jump_interval
	sta !woozy_phase_counter,x
	rts
...next_phase:
	db $02,$00,$00,$00

..jump:
	tyx
	ldy !woozy_face_dir,x
	lda ..x_speed,y
	sta !sprite_speed_x,x
	lda #(~!jump_y_speed)-1
	sta !sprite_speed_y,x
	inc !woozy_phase,x
	rts

; todo setting props better would be nice, if possible
;      this is kind of ugly
..rotating:
	tyx
	; gfx - TODO handle flipping
	dec !woozy_phase_counter,x
	lda !woozy_phase_counter,x
	bit #$10
	beq ..nofr
	pha
	lda #$C0
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	pla
	bra ..cont
..nofr:
	pha
	lda !sprite_oam_properties,x
	and #(~$C0)
	sta !sprite_oam_properties,x
	pla
..cont:
	and #$0F
	sta !woozy_ani_frame_id,x

	ldy !woozy_face_dir,x
	lda ..x_speed,y
	sta !sprite_speed_x,x
	lda !sprite_blocked_status,x
	and #$04
	beq ...done
	lda !sprite_oam_properties,x
	and #(~$C0)
	sta !sprite_oam_properties,x

	lda #!squish_interval
	sta !woozy_phase_counter,x
	inc !woozy_phase,x
	stz !woozy_ani_frame_id,x
	stz !sprite_speed_x,x
...done:
	rts

..x_speed:
	db $10,$F0

%start_sprite_pose_entry_list("dyn_woozie_guy")
	%start_sprite_pose_entry("dyn_woozie_guy_impl", 16, 16)
		%sprite_pose_tile_entry($F8, $F8, $80, $00, 2, 1)
		%sprite_pose_tile_entry($08, $F8, $82, $00, 2, 1)
		%sprite_pose_tile_entry($F8, $08, $84, $00, 2, 1)
		%sprite_pose_tile_entry($08, $08, $86, $00, 2, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()

woozyguy_done:
%set_free_finish("bank3_sprites", woozyguy_done)
