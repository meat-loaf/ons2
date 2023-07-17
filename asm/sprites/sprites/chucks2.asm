!sprnum_chucks = $91

%alloc_sprite_spriteset_2(!sprnum_chucks, "chucks", chucks_init_1, chucks_main, 5, \
	$108, $109, \
	$00,$0D,$0B,$F9,$11,$48)

!chuck_behavior         = !sprite_misc_c2

!chuck_head_face_dir   = !sprite_misc_151c
!chuck_hits            = !sprite_misc_1528
!chuck_hurt_ani_timer  = !sprite_misc_1540
!chuck_hurt_phase_counter = !sprite_misc_1570
!chuck_face_dir        = !sprite_misc_157c
!chuck_prepare_run_tmr = !sprite_misc_15ac
!chuck_ani_frame       = !sprite_misc_1602
!chuck_disable_player_contact = !sprite_misc_1564

!chuck_mario_in_sight  = !sprite_misc_187b

!chuck_ani_frame_sitting_lr  = $05
!chuck_ani_frame_jumping  = $06

!chuck_behavior_hurt      = $03
!chuck_behavior_prep_jump = $05

!scr_chuck_grounded       = $4D

macro chuck_exec_gfx(tbl, return)
	ldy !chuck_ani_frame,x
	lda <tbl>_hi,y
	xba
	lda <tbl>_lo,y
if <return> == 0
	jml spr_gfx
else
	jsl spr_gfx
endif
endmacro

%set_free_start("bank7")
chucks_init_1:
	lda !spr_extra_byte_1,x
	and #$03
	tay
	lda .states,y
	jsl sub_horz_pos
	tya
	sta !chuck_face_dir,x
	lda .head_pos,y
	sta !chuck_head_face_dir,x
	; TODO customizable maybe?
	lda #$02
	sta !chuck_hits,x
	rtl
.states:
	; chargin', splittin', jumpin', whistlin'
	db $00, $05, $08, $0B
.head_pos:
	db $00,$04

chuck_dead_head_animate:
	lda !effective_frame
	lsr #2
	and #$03
	tay
	lda .head_pos,y
	sta !chuck_head_face_dir,x
	; noreturn
	%chuck_exec_gfx(chuck_frame_table_ptr, 1)
.head_pos:
	db $01,$02,$03,$02

chucks_main:
	; note: skipped some seemingly unused line-of-sight code
	;       here.
	lda !sprite_status,x
	cmp #$08
	; originally bne (?)
	bcc chuck_dead_head_animate
	lda !chuck_prepare_run_tmr,x
	beq .not_run
	lda #!chuck_ani_frame_sitting_lr
	sta !chuck_ani_frame,x
.not_run:
	lda !sprite_blocked_status,x
	and #!sprite_blocked_below
	sta !scr_chuck_grounded
	bne .chuck_grounded
	lda !sprite_speed_y,x
	bpl .chuck_grounded
	lda !chuck_behavior,x
	cmp #!chuck_behavior_prep_jump
	bcs .chuck_grounded
	lda #!chuck_ani_frame_jumping
	sta !chuck_ani_frame,x
.chuck_grounded:
	%chuck_exec_gfx(chuck_frame_table_ptr, 1)
	lda !sprites_locked
	beq .continue
	rtl
.continue:
	jsl sub_off_screen
	jsr chuck_contact_rt
	jsl spr_spr_interact
	jsl spr_obj_interact
	lda !sprite_blocked_status,x
	bit #!sprite_blocked_above
	beq .not_above_blocked
	ldy #$10
	sty !sprite_speed_x,x
.not_above_blocked:
	; TODO block shatter check
	bit #(!sprite_blocked_left|!sprite_blocked_right)
	beq .not_sides_blocked
	lda !chuck_mario_in_sight,x
	beq .check_jump
	lda !sprite_off_screen_horz,x
	ora !sprite_off_screen_vert,x
	beq .check_jump
	lda !sprite_x_low,x
	sec
	sbc !layer_1_xpos_curr
	clc
	adc #$14
	cmp #$1C
	bcc .check_jump
	lda !sprite_blocked_status,x
	bit #!sprite_blocked_layer2_side
	bne .check_jump
	lda !tile_map16_lo_bak
	; throw block
	cmp #$2e
	beq .shatter_blocks
	; turn block
	cmp #$1e
	bne .check_jump
.shatter_blocks:
	; todo
	bra .not_sides_blocked
.check_jump:
	lda !scr_chuck_grounded
	beq .not_grounded
	lda #$c0
	sta !sprite_speed_y,x
	; TODO why is this ultimately called twice?
	jsl spr_upd_y_no_grv_l
	bra .dont_clear_speeds

.not_sides_blocked:
	jsl spr_upd_x_no_grv_l
.not_grounded:
	lda !scr_chuck_grounded
	beq .dont_clear_speeds
	stz !sprite_speed_x,x
	stz !sprite_speed_y,x
.dont_clear_speeds:
	jsl spr_upd_y_no_grv_l
; in water water/overall speed handling?
	ldy !sprite_in_water,x
	cpy #$01
	ldy #$00
	lda !sprite_speed_y,x
	bcc .chuck_not_in_water
	iny
	; check against speed loaded previous
	cmp #$00
	bpl .chuck_not_in_water
	cmp #$e0
	bcs .chuck_not_in_water
	lda #$e0
.chuck_not_in_water:
	clc
	adc chuck_fall_speeds,y
	rtl

chuck_fall_speeds:
	db $03, $01

; this probably fits inline
chuck_contact_rt:
	lda !chuck_disable_player_contact,x
	bne .no_contact
	jsl mario_spr_interact_l
	bcc .no_contact
	; todo star stuff
	lda !invincibility_timer
	beq .no_star
	lda #$D0
	sta !sprite_speed_y,x
.die:
	stz !sprite_speed_x,x
	lda #$02
	sta !sprite_status,x
	lda #$03
	sta !spc_io_1_sfx_1DF9
	lda #$03
	jsl spr_give_points
	rts
.no_star:
	lda #$05
	sta !chuck_disable_player_contact,x
	lda #$02
	sta !spc_io_1_sfx_1DF9
	jsl display_contact_gfx_p
	jsl boost_mario_speed_l
	; stz 163e, unused timer
	lda !chuck_behavior,x
	cmp #!chuck_behavior_hurt
	beq .no_contact
	; initially negative = infinite hp
	; positive -> negative = death
	lda !chuck_hits,x
	bmi .not_dead
	dec
	bmi .die
	sta !chuck_hits,x
.not_dead:
	lda #$28
	sta !spc_io_4_sfx_1DFC
	lda #!chuck_behavior_hurt
	sta !chuck_behavior,x
	; 3
	sta !chuck_hurt_ani_timer,x
	stz !chuck_hurt_phase_counter,x
	jsl sub_horz_pos
	lda .player_bounceback_speeds,y
	sta !player_x_spd
.no_contact:
	rts

.player_bounceback_speeds:
	db $20,$E0
	;rtl

; frame 0 unused?
; frames 1, 2 unused

; frame 3
%start_sprite_table("chuck_sitting", 16, 16)
	%sprite_table_entry($FC,$00,$0E,$00,$02, 1)
	%sprite_table_entry($04,$00,$0E,$40,$02, 1)
%finish_sprite_table()
; frame 4
%start_sprite_table("chuck_crouching", 16, 16)
	%sprite_table_entry($FC,$00,$26,$00,$02, 1)
	%sprite_table_entry($04,$00,$26,$40,$02, 1)
%finish_sprite_table()
; frame 5
%start_sprite_table("chuck_sitting_lr", 16, 16)
	%sprite_table_entry($FC,$00,$2D,$00,$02, 1)
	%sprite_table_entry($04,$00,$2E,$00,$02, 1)
%finish_sprite_table()
; frame 6
%start_sprite_table("chuck_jumpin", 16, 16)
	%sprite_table_entry($FC,        $00,$20,$00,$02, 1)
	%sprite_table_entry($04,        $00,$20,$40,$02, 1)
	%sprite_table_entry($0A,        $F4,$28,$40,$00, 1)
	%sprite_table_entry(invert($0A),$F4,$28,$00,$00, 1)
%finish_sprite_table()
; frame 7
; note ugg this is gonna be a pain because the hands need to be above the head...
;      probably need to go back to linked list type system for this? or just skip it
;      maybe just draw an 8x8?
%start_sprite_table("chuck_clappin", 16, 16)
	%sprite_table_entry($00,$F0,$24,$00,$02, 1)
	%sprite_table_entry($08,$00,$22,$40,$02, 1)
	%sprite_table_entry($F8,$00,$22,$00,$02, 1)
%finish_sprite_table()
; frame 8 unused
; frame a-d
%start_sprite_table("chuck_hurt", 16, 16)
	%sprite_table_entry($FC,$00,$0C,$00,$02, 1)
	%sprite_table_entry($04,$00,$0C,$40,$02, 1)
%finish_sprite_table()

; frame 12
%start_sprite_table("chuck_run_1", 16, 16)
	%sprite_table_entry($FC,$00,$09,$00,$02, 1)
	%sprite_table_entry($04,$00,$0A,$00,$02, 1)
	%sprite_table_entry($08,$F4,$39,$00,$00, 1)
	%sprite_table_entry($00,$F4,$38,$00,$00, 1)
%finish_sprite_table()
; frame 13
%start_sprite_table("chuck_run_2", 16, 16)
	%sprite_table_entry($FC,$00,$06,$00,$02, 1)
	%sprite_table_entry($04,$00,$07,$00,$02, 1)
	%sprite_table_entry($08,$F4,$39,$00,$00, 1)
	%sprite_table_entry($00,$F4,$38,$00,$00, 1)
%finish_sprite_table()

chuck_frame_table_ptr_lo:
	db chuck_sitting
	db chuck_sitting
	db chuck_sitting
	db chuck_sitting
	db chuck_crouching
	db chuck_sitting_lr
	db chuck_jumpin
	db chuck_clappin
	db chuck_hurt
	db chuck_run_1
	db chuck_run_2
chuck_frame_table_ptr_hi:
	db chuck_sitting>>8
	db chuck_sitting>>8
	db chuck_sitting>>8
	db chuck_sitting>>8
	db chuck_crouching>>8
	db chuck_sitting_lr>>8
	db chuck_jumpin>>8
	db chuck_clappin>>8
	db chuck_hurt>>8
	db chuck_run_1>>8
	db chuck_run_2>>8

chucks2_end:
%set_free_finish("bank7", chucks2_end)
