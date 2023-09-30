
!banzai_bill_sprnum = $9F

%alloc_sprite_spriteset_2(!banzai_bill_sprnum, "banzai_bill", banzai_bill_init, banzai_bill_main, 16, \
	$105, $106, \
	$10, $B6, $32, $01, $19, $04,
	banzai_bill_gfx_ptrs,
	!gen_spr_gfx)

!banzai_bill_rot         = !sprite_misc_151c
!banzai_behavior_chase   = !sprite_misc_1528
!banzai_bill_turn_timer  = !sprite_misc_1564
!banzai_smoke_timer      = !sprite_misc_1558
!banzai_palflash_timer   = !sprite_misc_15ac
!banzai_bill_face_dir    = !sprite_misc_157c

!banzai_palflash_time  = $02
!banzai_bill_turn_time  = $08+1
!turn_accel             = $02
!smoke_frame_spawn_time = $06
;!banzai_bill_speed      = $E8
!banzai_bill_speed      = $CA
!banzai_bill_speed_y    = $FC

%set_free_start("bank1_koopakids")
banzai_bill_init:
	lda !spr_extra_bits,x
	sta !banzai_behavior_chase,x
	beq .tweaker_ok
	lda !sprite_tweaker_1656,x
	and #~($10)
	sta !sprite_tweaker_1656,x
.tweaker_ok:

	lda #!banzai_palflash_time
	sta !banzai_palflash_timer,x
	lda #!smoke_frame_spawn_time
	sta !banzai_smoke_timer,x

	jsl sub_horz_pos
	lda .face,y
	sta !banzai_bill_face_dir,x
	lda banzai_bill_speeds,y
	sta !sprite_speed_x,x
.exit:
	rtl
.face:
	db $00, $01

banzai_bill_speeds:
.x:
	db invert(!banzai_bill_speed), !banzai_bill_speed
.y:
	db invert(!banzai_bill_speed_y), !banzai_bill_speed_y
banzai_bill_accel_vals:
.x:
	db !turn_accel, invert(!turn_accel)
.y:
	db $02, invert($02)

banzai_bill_main:
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne banzai_bill_init_exit

	lda !banzai_behavior_chase,x
	beq .no_chase

	lda !banzai_palflash_timer,x
	bne .no_flash_yet
	lda !sprite_oam_properties,x
	eor #$0A
	sta !sprite_oam_properties,x
	lda #!banzai_palflash_time
	sta !banzai_palflash_timer,x

	lda !banzai_bill_turn_timer,x
	bne .no_chase

.no_flash_yet:
	jsl sub_vert_pos
	lda $0F
;	and #$FC
;	beq .nuke_y_speed
	beq .horz_speed
	tya
	lda !sprite_speed_y,x
	cmp banzai_bill_speeds_y,y
	beq .horz_speed
	lda banzai_bill_accel_vals,y
	clc
	adc !sprite_speed_y,x
;.nuke_y_speed:
	sta !sprite_speed_y,x

.horz_speed
	jsl sub_horz_pos
	tya
	cmp !banzai_bill_face_dir,x
	beq .apply_accel
	sta !banzai_bill_face_dir,x
	lda #!banzai_bill_turn_time
	sta !banzai_bill_turn_timer,x
	bra .no_chase

.apply_accel:
	ldy !banzai_bill_face_dir,x
	lda banzai_bill_speeds,y
	cmp !sprite_speed_x,x
	beq .no_chase
	lda banzai_bill_accel_vals,y
	clc
	adc !sprite_speed_x,x
	sta !sprite_speed_x,x

.no_chase:
	lda !banzai_smoke_timer,x
	bne .no_smoke
	lda #$03
	sta $00

	lda #!smoke_frame_spawn_time
	sta !banzai_smoke_timer,x

	lda #$10
	sta !ambient_get_slot_timer

	lda !sprite_y_low,x
	sta $01
	lda !sprite_y_high,x
	sta $02

	lda !banzai_bill_face_dir,x
	asl
	tay
	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$30
	clc
	adc .smoke_face_offset,y
	sta !ambient_get_slot_xpos
	lda $01
.spawn_smoke_loop:
	sta !ambient_get_slot_ypos
	lda #$0001
	jsl ambient_get_slot_axy_prepped
	bcs .no_smoke
	dec $00
	bmi .no_smoke
	rep #$30
	lda !ambient_get_slot_ypos
	clc
	adc #$0010
	bra .spawn_smoke_loop
.no_smoke:
	lda #$01
	jsl sub_off_screen
	jsl spr_upd_yx_no_grav_l
	jml mario_spr_interact_l
.smoke_face_offset:
	dw $FFFC, $003C

%start_sprite_pose_entry_list("banzai_bill")
	%start_sprite_pose_entry("banzai_bill_gfx", 64, 64)
		; row 1
		%sprite_pose_tile_entry($E8, $E8, $08, $00, 2, 1)
		%sprite_pose_tile_entry($F8, $E8, $0A, $00, 2, 1)
		%sprite_pose_tile_entry($08, $E8, $0C, $00, 2, 1)
		%sprite_pose_tile_entry($18, $E8, $0E, $00, 2, 1)
		; row 2
		%sprite_pose_tile_entry($E8, $F8, $20, $00, 2, 1)
		%sprite_pose_tile_entry($F8, $F8, $22, $00, 2, 1)
		%sprite_pose_tile_entry($08, $F8, $2C, $00, 2, 1)
		%sprite_pose_tile_entry($18, $F8, $2E, $00, 2, 1)
		; row 3
		%sprite_pose_tile_entry($E8, $08, $24, $00, 2, 1)
		%sprite_pose_tile_entry($F8, $08, $26, $00, 2, 1)
		%sprite_pose_tile_entry($08, $08, $2C, $00, 2, 1)
		%sprite_pose_tile_entry($18, $08, $2E, $00, 2, 1)
		; row 4
		%sprite_pose_tile_entry($E8, $18, $28, $00, 2, 1)
		%sprite_pose_tile_entry($F8, $18, $2A, $00, 2, 1)
		%sprite_pose_tile_entry($08, $18, $0C, $80, 2, 1)
		%sprite_pose_tile_entry($18, $18, $0E, $80, 2, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()
banzai_bill_done:
%set_free_finish("bank1_koopakids", banzai_bill_done)
