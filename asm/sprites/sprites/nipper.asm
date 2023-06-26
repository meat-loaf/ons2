!nipper_sprnum = $1A

%alloc_sprite(!nipper_sprnum, "smb3 nipper", nipper_init, nipper_main, 1, 0,\
	$00, $00, $0B, $01, $00, $00)

%alloc_sprite_sharedgfx_entry_4(!nipper_sprnum,\
	$08,$0A,$0C,$0E)

!nipper_phase                = !sprite_misc_c2
!nipper_behavior             = !spr_extra_bytes
!nipper_firespt_count        = !sprite_misc_1528
!nipper_firespt_timer        = !sprite_misc_1540
!nipper_wait_fireshoot_timer = !sprite_misc_1558
!nipper_move_timer           = !sprite_misc_15ac
!nipper_ani_counter          = !sprite_misc_1570
!nipper_facing_dir           = !sprite_misc_157c
!nipper_ani_frame            = !sprite_misc_1602
!nipper_horz_frame_status    = !sprite_misc_160E

!move_timer_val              = $60  ; time to move back and forth

%set_free_start("bank1_koopakids")
nipper_init:
	lda !nipper_behavior,x
	cmp #$02
	bne .nomove
	sta !nipper_phase,x
	lda #!move_timer
	sta !nipper_move_timer,x
.nomove
	rtl
nipper_main:
	lda !nipper_horz_frame_status,x
	asl #2
	sta $00
	lda !nipper_ani_counter,x
	lsr #2
	and #$03
	ora $00
	tay
	lda .gfx_frames,y
	sta !nipper_ani_frame,x
	lda !nipper_firespt_timer,x
	bne .no_force_mouth_open
	lda #01
	sta !nipper_ani_frame,x
.no_force_mouth_open:
	jsr.w sub_spr_gfx_2
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne .exit
	jsl sub_off_screen
	inc !nipper_ani_counter,x
	lda !nipper_phase,x
	asl
	txy
	tax
	jsr (.phases,x)
	jsr.w _spr_upd_pos
	jsr.w _sprspr_mario_spr_rt
	lda !sprite_blocked_status,x
	and #$03
	beq .exit
	lda !nipper_facing_dir,x
	eor #$01
	sta !nipper_facing_dir,x
	lda !sprite_speed_x,x
	eor #$ff
	inc
	sta !sprite_speed_x,x
.exit:
	rtl
.phases:
	dw .stationary
	dw .waiting
	dw .moving
	dw .firespit
.stationary:
	tyx
	jsl sub_horz_pos
	tya
	sta !nipper_facing_dir,x
	lda !sprite_blocked_status,x
	and #$04
	beq ..dont_jump
	stz !nipper_horz_frame_status,x
..dont_jump:
	rtl
.waiting:
	tyx
	rtl
.moving:
	tyx
	rtl
.firespit:
	tyx
	rts

.gfx_frames
	db $00,$00,$01,$01,$02,$03,$02,$03
%set_free_end("bank1_koopakids", nipper_done)
