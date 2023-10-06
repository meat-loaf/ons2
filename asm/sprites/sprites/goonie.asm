!sprnum_goonie_run = $a0
!sprnum_goonie_fly = $a1

%alloc_sprite_spriteset_2(!sprnum_goonie_run, "runnin_goonie", goonie_init, goonie_run_main, 3, \
	$10C, $10D, \
	$90, $80, $03, $19, $10, $80,
	goonie_body_gfx_ptrs,
	!gen_spr_gfx)

%alloc_sprite_spriteset_2(!sprnum_goonie_fly, "flyin_goonie", goonie_fly_init, goonie_fly_main, 8, \
	$10C, $10D, \
	$90&$E0, $8C, $03, $99, $90, $81,
	goonie_winged_gfx_ptrs,
	!gen_spr_gfx)

%alloc_sprite_spriteset_2($A2, "flyin_goonie_test", goonie_fly_init, goonie_fly_test, 8, \
	$10C, $10D, \
	$90&$E0, $8C, $03, $99, $90, $81,
	goonie_winged_gfx_ptrs,
	!gen_spr_gfx)


!glide_time = $63
!fly_time = $FF

!run_goonie_spd_grnd = $20
!slope_speed_chg     = $04

!goonie_face_dir = !sprite_misc_157c
!goonie_ani_frame = !sprite_misc_1602


!goonie_f_phase             = !sprite_misc_c2
!goonie_f_body_frame        = !sprite_misc_151c
!goonie_f_moved_x_px        = !sprite_misc_1528
!goonie_f_body_frame_ctr    = !sprite_misc_1534
!goonie_f_weight_timer      = !sprite_misc_1540
!goonie_f_ani_timer         = !sprite_misc_1558
!goonie_f_phase_timer       = !sprite_misc_163e
;!goonie_f_body_ani_frame    = !sprite_misc_160e
!goonie_f_ridden            = !sprite_misc_1626

%set_free_start("bank7")

!test_max_ani_frames = $25
;
goonie_fly_test:
	lda #$00
	jsl sub_off_screen
	;lda.b #!test_max_ani_frames
	;sta !goonie_ani_frame,x
	;bra .exit

	lda !sprite_misc_1540,x
	bne .exit
	lda !spr_extra_byte_1,x
	sta !sprite_misc_1540,x
	lda !goonie_ani_frame,x
	inc
	cmp.b #!test_max_ani_frames+1
	bcc .ani_frame_ok
	lda #$00
.ani_frame_ok:
	sta !goonie_ani_frame,x
.exit:
	jsl spr_invis_blk_rt_l
	rtl

goonie_fly_init:
	lda #!glide_time
	sta !goonie_f_phase_timer,x
	lda #$24
	sta !goonie_ani_frame,x
	inc !goonie_f_phase,x
; just 'face mario'...use shared somewhere maybe?
; todo use parabeetle init for facing configurations
goonie_init:
	jsl sub_horz_pos
	tya
	sta !goonie_face_dir,x
.done
	rtl

goonie_run_main:
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne goonie_init_done
	jsl sub_off_screen

	lda !sprite_slope,x
	clc
	adc #$04
	asl
	ora !goonie_face_dir,x
	tay
	lda .speeds,y
	sta !sprite_speed_x,x

	lda !sprite_blocked_status,x
	and #(!sprite_blocked_left|!sprite_blocked_right)
	beq .not_hitting_wall
	lda !goonie_face_dir,x
	eor #$01
	sta !goonie_face_dir,x
.not_hitting_wall:
	ldy !goonie_ani_frame,x
	lda .next_ani_frame,y
	sta !goonie_ani_frame,x
	jsl update_sprite_pos
	jsl spr_spr_interact
	jml mario_spr_interact_l
; speeds are moving right, then left
; it would be nice to not need a big table but whatever. look at this later
.speeds:
	; very steep slope left
	db !run_goonie_spd_grnd-(!slope_speed_chg*4), invert(!run_goonie_spd_grnd+((!slope_speed_chg/2)*4))
	; steep slope left
	db !run_goonie_spd_grnd-(!slope_speed_chg*3), invert(!run_goonie_spd_grnd+((!slope_speed_chg/2)*3))
	; normal slope left
	db !run_goonie_spd_grnd-(!slope_speed_chg*2), invert(!run_goonie_spd_grnd+((!slope_speed_chg/2)*2))
	; gradual slope left
	db !run_goonie_spd_grnd-(!slope_speed_chg*1), invert(!run_goonie_spd_grnd+((!slope_speed_chg/2)*1))
	; flat ground
	db !run_goonie_spd_grnd, invert(!run_goonie_spd_grnd)
	; gradual slope right
	db !run_goonie_spd_grnd+((!slope_speed_chg/2)*1), invert(!run_goonie_spd_grnd-(!slope_speed_chg*1))
	; normal slope right
	db !run_goonie_spd_grnd+((!slope_speed_chg/2)*2), invert(!run_goonie_spd_grnd-(!slope_speed_chg*2))
	; steep slope right
	db !run_goonie_spd_grnd+((!slope_speed_chg/2)*3), invert(!run_goonie_spd_grnd-(!slope_speed_chg*3))
	; very steep slope right
	db !run_goonie_spd_grnd+((!slope_speed_chg/2)*4), invert(!run_goonie_spd_grnd-(!slope_speed_chg*4))

.next_ani_frame:
	db $01, $02, $03, $04, $05, $00

goonie_fly_main:
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	beq .run
	rtl
.run:
	jsl sub_off_screen

	lda !goonie_ani_frame,x
	lsr #2
	tay
	lda .speeds_y,y
	ldy !goonie_f_weight_timer,x
	beq .not_weighed_down_y
	cmp #$00
	bmi .y_neg_weighed
	clc
.y_neg_weighed:
	ror
	clc
	adc !goonie_f_weight_timer,x
.not_weighed_down_y:
	sta !sprite_speed_y,x

	ldy !goonie_face_dir,x
	lda .speeds_x,y
	ldy !goonie_f_weight_timer,x
	beq .not_weighed_down_x
	cmp #$00
	clc
	bpl .carry_ok_x
	sec
.carry_ok_x:
	ror
.not_weighed_down_x:
	sta !sprite_speed_x,x

	; position stuff
	jsr fly_goonie_upd_ani_frames
	; note the original code ran these two with the sprite pos
	; shifted down 4px. why? why does it even call these when it
	; just wants to be solid?
;	jsl mario_spr_interact_l
;	jsl spr_spr_interact

	jsl spr_upd_yx_no_grav_l
	; there wsa also some code to kill the sprite if it got to high?


	lda !sprite_movement
	sta !goonie_f_moved_x_px,x

	lda !goonie_f_ridden,x
	sta $45
	jsl spr_invis_blk_rt_l
	tdc
	rol
	sta !goonie_f_ridden,x
	beq .not_riding
	; force flying phase
	sta !goonie_f_phase,x

	; doubletime
	jsr fly_goonie_upd_ani_frames
	lda $45
	bne .riding_last_frame
	; TODO original did this every frame while riding, here is likely fine
	lda !goonie_ani_frame,x
	cmp #$24
	bne .wasnt_gliding
	stz !goonie_ani_frame,x
.wasnt_gliding:
	lda #$18
	sta !goonie_f_weight_timer,x

.riding_last_frame:
	jsr fly_goonie_upd_ani_frames

	clc
	lda !sprite_speed_x,x
	bpl .pos_x_speed
	sec
.pos_x_speed:
	ror
	sta !sprite_speed_x,x

	lda #!fly_time
	sta !goonie_f_phase_timer,x
	lda !player_blocked_status
	and #!sprite_blocked_above
	beq .not_riding
	stz !sprite_speed_y,x

.not_riding:
	lda !goonie_f_phase,x
	bne .no_glide
	lda #$24
	sta !goonie_ani_frame,x
.no_glide:
	lda !goonie_f_phase_timer,x
	bne .no_phase_change
	lda !goonie_f_phase,x
	eor #$01
	tay
	sta !goonie_f_phase,x
	lda .phase_timers,y
	sta !goonie_f_phase_timer,x
	stz !goonie_ani_frame,x
.no_phase_change:
	rtl

.speeds_y:
	db $F8,$00,$00,$00,$00,$F8,$F0,$F0,$F8,$10
.speeds_x
	db $0C, invert($0C)
.phase_timers:
	db !glide_time
	db !fly_time

fly_goonie_upd_ani_frames:
	lda !goonie_ani_frame,x
	cmp #$24
	beq .exit
	lda !goonie_f_ani_timer,x
	bne .exit
	lda #$04
	sta !goonie_f_ani_timer,x

	lda !goonie_ani_frame,x
	inc
	cmp #$24
	bne .no_ani_frame_loop
	tdc
.no_ani_frame_loop:
	sta !goonie_ani_frame,x

	lda !goonie_f_body_frame_ctr,x
	inc
	cmp #$0c
	bne .no_body_ani_frame_loop
	tdc
.no_body_ani_frame_loop:
	sta !goonie_f_body_frame_ctr,x
	tay
	lda .body_frame_offs,y
	sta !goonie_f_body_frame,x
.exit:
	rts
.body_frame_offs:
	db $00, $00, $00, $00
	db $02, $02, $02, $02
	db $02, $03, $03, $03

%start_sprite_pose_entry_list("goonie_body")
	%start_sprite_pose_entry("goonie_body_1", 16, 16)
		%sprite_pose_tile_entry($F8,$FF,$06,$00,$02, 1)
		%sprite_pose_tile_entry($03,$07,$00,$00,$02, 1)
		%sprite_pose_tile_entry($04,$FB,$08,$00,$00, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("goonie_body_1")
	%start_sprite_pose_entry("goonie_body_2", 16, 16)
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($03,$08,$02,$00,$02, 1)
		%sprite_pose_tile_entry($04,$FC,$0A,$00,$00, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("goonie_body_2")
	%start_sprite_pose_entry("goonie_body_3", 16, 16)
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($03,$08,$04,$00,$02, 1)
		%sprite_pose_tile_entry($04,$FC,$0C,$00,$00, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("goonie_body_3")
%finish_sprite_pose_entry_list()

%start_sprite_pose_entry_list("goonie_winged")
	%start_sprite_pose_entry("goonie_wing_flap_up_1", 16, 10)

		%sprite_pose_tile_entry($0C,$F6,$28,$00,$02, 1)
		%sprite_pose_tile_entry($0D,$ED,$2D,$00,$00, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($FA,$F6,$28,$40,$02, 1)
		%sprite_pose_tile_entry($F9,$ED,$2D,$40,$00, 1)
	%finish_sprite_pose_entry()

	%start_sprite_pose_entry("goonie_wing_flap_up_2", 16, 10)
		%sprite_pose_tile_entry($0B,$EF,$25,$00,$02, 1)
		%sprite_pose_tile_entry($09,$E4,$2D,$00,$00, 1)
		%sprite_pose_tile_entry($07,$FB,$27,$00,$00, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($0B-$10,$EF,$25,$40,$02, 1)
		%sprite_pose_tile_entry($09-$0C,$E4,$2D,$40,$00, 1)
		%sprite_pose_tile_entry($07-$08,$FB,$27,$40,$00, 1)
	%finish_sprite_pose_entry()
	; flap down 1

	%sprite_pose_entry_mirror("goonie_wing_flap_up_1")

	%start_sprite_pose_entry("goonie_wing_flap_down_2", 16, 10)
		%sprite_pose_tile_entry($0E,$00,$2A,$00,$02, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($F8,$00,$2A,$40,$02, 1)
	%finish_sprite_pose_entry()

	%start_sprite_pose_entry("goonie_wing_flap_down_3", 16, 10)
		%sprite_pose_tile_entry($0D,$08,$2C,$00,$02, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($0D-$14,$08,$2C,$40,$02, 1)
	%finish_sprite_pose_entry()

	%start_sprite_pose_entry("goonie_wing_flap_down_4", 16, 10)
		%sprite_pose_tile_entry($08,$04,$37,$00,$00, 1)
		%sprite_pose_tile_entry($0C,$10,$2E,$00,$02, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($08-$0A,$04,$37,$40,$00, 1)
		%sprite_pose_tile_entry($0C-$12,$10,$2E,$40,$02, 1)
	%finish_sprite_pose_entry()

	%start_sprite_pose_entry("goonie_wing_flap_up_3", 16, 10)
		%sprite_pose_tile_entry($0C,$0A,$28,$80,$02, 1)
		%sprite_pose_tile_entry($0D,$13,$2D,$80,$00, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($0C-$12,$0A,$28,$C0,$02, 1)
		%sprite_pose_tile_entry($0D-$14,$13,$2D,$C0,$00, 1)
	%finish_sprite_pose_entry()

	%start_sprite_pose_entry("goonie_wing_flap_up_4", 16, 10)
		%sprite_pose_tile_entry($0E,$00,$2A,$80,$02, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($F8,$00,$2A,$C0,$02, 1)
	%finish_sprite_pose_entry()


	%start_sprite_pose_entry("goonie_wing_flap_up_5", 16, 10)
		%sprite_pose_tile_entry($0D,$08-$10,$2C,$80,$02, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($0D-$14,$08-$10,$2C,$C0,$02, 1)
	%finish_sprite_pose_entry()

	%start_sprite_pose_entry("goonie_wing_flap_up_6", 16, 10)
		%sprite_pose_tile_entry($08,$04-$08,$37,$80,$00, 1)
		%sprite_pose_tile_entry($0C,$10-$20,$2E,$80,$02, 1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($08-$0A,$04-$08,$37,$C0,$00, 1)
		%sprite_pose_tile_entry($0C-$12,$10-$20,$2E,$C0,$02, 1)
	%finish_sprite_pose_entry()

	%sprite_pose_entry_mirror("goonie_wing_flap_up_2")

	%sprite_pose_entry_mirror("goonie_wing_flap_up_1")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_2")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_3")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_4")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_3")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_4")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_5")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_6")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_2")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_1")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_2")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_3")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_4")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_3")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_4")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_5")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_6")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_2")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_1")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_2")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_3")
	%sprite_pose_entry_mirror("goonie_wing_flap_down_4")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_3")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_4")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_5")
	%sprite_pose_entry_mirror("goonie_wing_flap_up_6")

	%start_sprite_pose_entry("goonie_wing_glide", 16, 10)
		%sprite_pose_tile_entry($0B,$00,$34,$00,$00,1)
		%sprite_pose_tile_entry($13,$00,$22,$00,$02,1)
		%sprite_pose_tile_entry($1F,$FC,$24,$00,$00,1)
		;body
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$08|$80,$00,$02, 1)

		%sprite_pose_tile_entry($FC,$00,$34,$40,$00,1)
		%sprite_pose_tile_entry($F0,$00,$22,$40,$02,1)
		%sprite_pose_tile_entry($E4,$FC,$24,$40,$00,1)
	%finish_sprite_pose_entry()

%finish_sprite_pose_entry_list()

goonies_done:
%set_free_finish("bank7", goonies_done)
