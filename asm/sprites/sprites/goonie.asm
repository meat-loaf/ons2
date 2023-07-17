!sprnum_goonie_run = $a0
!sprnum_goonie_fly = $a1

; TODO really only needs exgfx 10C, investigate slot allocation
%alloc_sprite_spriteset_2(!sprnum_goonie_run, "runnin_goonie", goonie_init, goonie_run_main, 3, \
	$10C, $10D, \
	$90, $80, $03, $19, $10, $80)

%alloc_sprite_spriteset_2(!sprnum_goonie_fly, "flyin_goonie", goonie_fly_init, goonie_fly_main, 6, \
	$10C, $10D, \
	$90&$E0, $8C, $03, $99, $90, $81)

!glide_time = $63
!fly_time = $FF

!run_goonie_spd_grnd = $20
!slope_speed_chg     = $04

!goonie_face_dir = !sprite_misc_157c
!goonie_ani_frame = !sprite_misc_1602

!goonie_f_moved_x_px = !sprite_misc_1528

!goonie_f_phase             = !sprite_misc_c2
!goonie_f_body_frame        = !sprite_misc_151c
!goonie_f_weight_timer      = !sprite_misc_1540
!goonie_f_phase_timer        = !sprite_misc_163e
!goonie_f_body_ani_frame    = !sprite_misc_160e
!goonie_f_ridden            = !sprite_misc_1626

%set_free_start("bank7")
goonie_fly_init:
	lda #!glide_time
	sta !goonie_f_phase_timer,x
	;inc !goonie_f_phase,x
; just 'face mario'...use shared somewhere maybe?
; todo use parabeetle init for facing configurations
goonie_init:
	jsl sub_horz_pos
	tya
	sta !goonie_face_dir,x
.done
	rtl

goonie_run_main:
	lda !goonie_ani_frame,x
	rep #$20
	asl
	tay
	lda goonie_body_pose_ptrs,y
	sta !gen_gfx_pose_list
	stz !gen_gfx_pose_list+2
	%sprite_pose_pack_offs(16, 16)
	jsl spr_gfx_2

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
	; TODO real gfx code
	rep #$20
	ldy #$00
	lda goonie_wing_r_pose_ptrs,y
	sta !gen_gfx_pose_list
	ldy #$00
	lda goonie_body_pose_ptrs,y
	sta !gen_gfx_pose_list+2
	stz !gen_gfx_pose_list+4
	%sprite_pose_pack_offs(16, 16)
	jsl spr_gfx_2

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
	inc
	cmp #$24
	bne .no_ani_frame_loop
	tdc
.no_ani_frame_loop:
	sta !goonie_ani_frame,x

	lda !goonie_f_body_frame,x
	inc
	cmp #$0c
	bne .no_body_ani_frame_loop
	tdc
.no_body_ani_frame_loop:
	sta !goonie_f_body_frame,x
	rts

%start_sprite_pose_entry_list("goonie_body")
	%start_sprite_pose_entry("goonie_body_1", 0, 0)
		%sprite_pose_tile_entry($F8,$FF,$06,$00,$02, 1)
		%sprite_pose_tile_entry($03,$07,$00,$00,$02, 1)
		%sprite_pose_tile_entry($04,$FB,$08,$00,$00, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("goonie_body_1")
	%start_sprite_pose_entry("goonie_body_2", 0, 0)
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($03,$08,$02,$00,$02, 1)
		%sprite_pose_tile_entry($04,$FC,$0A,$00,$00, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("goonie_body_2")
	%start_sprite_pose_entry("goonie_body_3", 0, 0)
		%sprite_pose_tile_entry($F8,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($03,$08,$04,$00,$02, 1)
		%sprite_pose_tile_entry($04,$FC,$0C,$00,$00, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("goonie_body_3")
%finish_sprite_pose_entry_list()

%start_sprite_pose_entry_list("goonie_wing_r")
	%start_sprite_pose_entry("goonie_wing_r_glide", 0, 0)
		%sprite_pose_tile_entry($0B,$FF,$34,$00,$00, 1)
		%sprite_pose_tile_entry($16,$FF,$22,$00,$02, 1)
;		%sprite_pose_tile_entry($0C,$0F,$2E,$00,$02, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("goonie_wing_r_1", 0, 0)
		%sprite_pose_tile_entry($08,$03,$37,$00,$00, 1)
		%sprite_pose_tile_entry($0C,$0F,$2E,$00,$02, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("goonie_wing_r_2", 0, 0)
		%sprite_pose_tile_entry($0C,$09,$28,$80,$02, 1)
		%sprite_pose_tile_entry($0D,$12,$2D,$80,$00, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()

goonies_done:
%set_free_finish("bank7", goonies_done)