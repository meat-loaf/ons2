!goomba_sprnum = $00
; todo - not really much to do, just proper configs/update std interaction
!galoomba_sprnum = $01
; todo - probably own sprite behavior, its different enough
!paragoomba_sprnum = $03
; todo - smb3 flying/microgoomba spawning shithead

;!shell_sprnum = $05
!giant_koopa_sprnum       = $09

!koopa_stays_on_ledges     = !sprite_misc_c2
!koopa_falling_last_frame  = !sprite_misc_151c
!koopa_winged              = !sprite_misc_1528
!koopa_pushed_by_kickable  = !sprite_misc_1534
!koopa_post_kick_frz_timer = !sprite_misc_1540
!koopa_ani_timer           = !sprite_misc_1570
!koopa_face_dir            = !sprite_misc_157c
!koopa_jumping_over_shell  = !sprite_misc_1594
!koopa_turn_timer          = !sprite_misc_15ac
!koopa_ani_frame           = !sprite_misc_1602
!koopa_kick_shell_slot     = !sprite_misc_160e
!koopa_kicking_shell_timer = !sprite_misc_163e
!disco_shell_flag          = !sprite_misc_187b

;!parakoopa_accel_timer     = !sprite_misc_c2
!parakoopa_accel_timer     = !sprite_dyn_gfx_id

;!parakoopa_accel_dir       = !sprite_misc_151c
!parakoopa_accel_dir       = !sprite_misc_160e

!parakoopa_accel_wait      = !sprite_misc_1540
!parakoopa_hv              = !sprite_misc_1534

;%alloc_sprite(!goomba_sprnum, "goomba", koopa_init_goomba, goomba_main, 2, \
;	$30, $00, $00, $00, $00, $00,
;	$0000)

%alloc_sprite_spriteset_1(!shelless_koopa_sprnum, "shelless_koopa", koopa_init, shelless_koopa_main, 2, \
	$104, \
	$70, $00, $00, $00, $00, $00,
	shelless_koopa_main_gfx_tiles,
	!spr_norm_gfx_single_rt_id)

%alloc_sprite_spriteset_1(!koopa_sprnum, "koopas", koopa_init, koopa_main, 5, $0100, \
	$10, $40, $00, $00, $02, $A0,
	koopa_gfx_ptrs,
	!spr_norm_gfx_generic_rt_id)

%alloc_sprite_spriteset_1(!lame_parakoopa_sprnum, "lame_parakoopa", koopa_init, koopa_main, 3, $0100,\
	$10, $40, $00, $00, $42, $B0,
	winged_koopa_gfx_ptrs,
	!spr_norm_gfx_generic_rt_id)
	
%alloc_sprite_spriteset_1(!flyin_parakoopa_v_sprnum, "flyin_parakoopa_vert", parakoopa_init, flyin_parakoopa_main, 3, $0100,\
	$10, $40, $00, $00, $52, $B0,
	parakoopa_gfx_ptrs,
	!spr_norm_gfx_generic_rt_id)
;%alloc_sprite_spriteset_1(!flyin_parakoopa_h_sprnum, "flyin_parakoopa_horz", koopa_init, flyin_parakoopa_main, 3, $0100,\
;	$10, $40, $00, $00, $52, $B0,
;	koopa_pose_tbl)
;
;%alloc_sprite_spriteset_1(!giant_koopa_sprnum, "giant_koopas", koopa_init, koopa_main, 5, $0110, \
;	$10, $40, $00, $00, $02, $A0,
;	giant_koopa_pose_tbl)

;%alloc_sprite_sharedgfx_entry_9(!koopa_sprnum, $82,$A0,$82,$A2,$84,$A4,$8C,$8A,$8E)
;%alloc_sprite_sharedgfx_entry_mirror(!shell_sprnum, !koopa_sprnum)
;%alloc_sprite_sharedgfx_entry_mirror(!lame_parakoopa_sprnum, !koopa_sprnum)
;%alloc_sprite_sharedgfx_entry_mirror(!flyin_parakoopa_v_sprnum, !koopa_sprnum)
;%alloc_sprite_sharedgfx_entry_mirror(!flyin_parakoopa_h_sprnum, !koopa_sprnum)

%set_free_start("bank1_spr0to13")
; koopa extra byte:
; s---focc
; cc:
;   00: green
;   01: yellow
;   02: red
;   03: blue
;    yellow and blue move fast.
; o: orientation, for flying parakoopas only
;   0: vertical
;   1: horizontal
; f: initial facing dir, for flying parakoopas only
;   0: right
;   1: left
; s: stunned
;   0: normal
;   1: start in stunned state
parakoopa_init:
	lda !spr_extra_byte_1,x
	bit #$08
	beq .no_right_first
	inc !parakoopa_accel_dir,x
	;inc !koopa_face_dir,x
.no_right_first:
	and #$04
	lsr #2
	sta !parakoopa_hv,x

koopa_init:
	lda !sprite_num,x
	cmp #!lame_parakoopa_sprnum
	bne .no_wings
	inc !koopa_winged,x
.no_wings:

	; flag to not turn in place when falling
	; needs to be set for flying parakoopas, and
	; for normal koopas that stay on ledges so they don't
	; turn in the air
	inc !koopa_jumping_over_shell,x
.goomba:
	lda !spr_extra_byte_1,x
	and #$03
	tay
	lda .pals,y
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	cpy #$02
	bcc .set_facing
	inc !koopa_stays_on_ledges,x
.set_facing:
	jsr _spr_face_mario_rt
	jsl get_rand
	sta !koopa_ani_timer,x
	lda !spr_extra_byte_1,x
	bpl .exit
	inc !sprite_status,x
.exit:
	rtl
.pals:
	; green, yellow, blue, red
	db $5*2,$2*2,$4*2,$3*2
goomba_main:
	lda !sprite_oam_properties,x
	sta $00
	
	lda !koopa_ani_frame,x
	lsr
	lda #$40
	bcc .noflip
	tsb $00
	bra .set_props
.noflip:
	trb $00
.set_props:
	lda $00
	sta !sprite_oam_properties,x

shelless_koopa_main:
	jsr _suboffscr0_bank1
	lda !koopa_post_kick_frz_timer,x
	beq .not_finish_kick
	jmp koopa_main_interact

.not_finish_kick:
	lda !koopa_pushed_by_kickable,x
	beq .check_kick
	ldy !koopa_kick_shell_slot,x
	lda !sprite_status,y
	cmp #$09
	bcs .do_catch_slide
	jmp koopa_main_interact

.do_catch_slide:
	lda !sprite_blocked_status,x
	bit #$03
	bne ..prep_shell_kick
	bit #$04
	beq ..falling
	; todo original code accounted for 'is level slippery'
	lda.w !sprite_speed_x,y
	cmp #$02
	bcc ..prep_shell_kick
	bpl ..subtract_speed
	clc
	adc #$02
	clc
	adc #$02
..subtract_speed:
	sec
	sbc #$02
	sta !sprite_speed_x,x
	sta.w !sprite_speed_x,y
	; todo: dust particles
..falling:
	stz !koopa_ani_frame,x
	jmp koopa_main_interact

..prep_shell_kick:
	lda #$00
	sta.w !sprite_speed_x,y
	sta !sprite_speed_x,x
	stz !koopa_pushed_by_kickable,x
	lda #$09
	sta !sprite_status,y
	lda #$20
	sta !koopa_kicking_shell_timer,x
	jmp .mario_ixn

.check_kick:
	lda !koopa_kicking_shell_timer,x
	beq koopa_main_shelless_entry
	stz !sprite_speed_x,x

	ldy !koopa_kick_shell_slot,x
	lda !sprite_status,y
	cmp #$08
	bcs .cont
	stz !koopa_kicking_shell_timer,x
	jmp koopa_main_interact
.cont:
	lda !koopa_kicking_shell_timer,x
	cmp #$01
	beq .do_kick
	lda #$00
	sta !koopa_ani_frame,x
.abort_kick:
	jmp koopa_main_interact

.do_kick:
	; check the shell is still in state 9 or a
	ldy !koopa_kick_shell_slot,x
	lda !sprite_status,y
	cmp #$09
	bcc .abort_kick
	cmp #$0b
	bcs .abort_kick

	lda #$02
	sta !koopa_ani_frame,x
	lda #$18
	sta !koopa_post_kick_frz_timer,x

	ldy !koopa_face_dir,x
	lda .kick_speeds,y
	ldy !koopa_kick_shell_slot,x
	sta.w !sprite_speed_x,y
	lda #$0a
	sta !sprite_status,y

	; check yellow
	; (TODO check if koopa)
	lda !spr_extra_byte_1,x
	and #$03
	cmp #$01
	beq .disco
	stz !disco_shell_flag,x
	jmp koopa_main_interact

.disco:
	sta !disco_shell_flag,y
.mario_ixn:
	jmp koopa_main_interact

.exit:
	rtl
.gfx_tiles:
	db $00,$02,$04,$06,$06,$06

.kick_speeds:
	db $30,$D0

koopa_main:
	lda !sprites_locked
	bne shelless_koopa_main_exit
	jsr _suboffscr0_bank1
	lda !koopa_winged,x
	bne .ani_upd
.shelless_entry:
	lda !koopa_falling_last_frame,x
	bne .no_ani_upd
	lda !koopa_stays_on_ledges,x
	bne .ani_upd
	lda !sprite_blocked_status,x
	and #$04
	beq .no_ani_upd
.ani_upd:
	jsr _spr_set_ani_frame
.no_ani_upd:
	lda !sprite_blocked_status,x
	and #$08
	beq .not_blocked_top
	stz !sprite_speed_y,x
.not_blocked_top:
	lda !sprite_blocked_status,x
	and #$04
	beq .airborne
	ldy !koopa_face_dir,x
	lda !spr_extra_byte_1,x
	lsr
	bcc .not_fast
	iny #2
.not_fast:
	lda .speeds,y
	eor !sprite_slope,x
	asl
	lda .speeds,y
	bcc .slope_speed
	clc
	adc !sprite_slope,x
.slope_speed:
	sta !sprite_speed_x,x
	stz !koopa_jumping_over_shell,x
	stz !koopa_falling_last_frame,x
	jsr _set_some_y_spd
	lda !koopa_winged,x
	beq .interact
	lda !koopa_ani_frame,x
	and #$01
	sta !koopa_ani_frame,x
	jsr _spr_jump_over_shell
	lda !sprite_speed_y,x
	bpl .interact
	inc !koopa_jumping_over_shell,x
	bra .interact

.airborne:
	lda !koopa_stays_on_ledges,x
	;ora !koopa_falling_last_frame,x
	beq .check_wings
	lda !koopa_falling_last_frame,x
	cmp #$02
	bcs .check_wings
	inc !koopa_falling_last_frame,x
.check_flip:
	lda !koopa_jumping_over_shell,x
	bne .double_ani
	jsr _flip_sprite_dir_imm
	; TODO if kicked as a shell don't do this. might need 'was airborne last frame'
	;      as part of standard stunned routine...original never had a state 9 -> 8 transition
	stz !sprite_speed_y,x
	bra .interact

.check_wings:
	lda !koopa_winged,x
	beq .interact
	; double time
.double_ani:
	jsr _spr_set_ani_frame
	lda !sprite_misc_1602,x
	ora #$02
	sta !sprite_misc_1602,x
.interact:
	jsr _sprspr_mario_spr_rt
	jsr _spr_upd_pos
	jsr _flip_if_side_blocked
.exit:
	rtl
.speeds:
	db $08,$F8,$0C,$F4

flyin_parakoopa_main:
	lda !sprites_locked
	bne .exit
	ldy !parakoopa_hv,x
	lda .suboff_val,y
	jsl sub_off_screen
	ldy !koopa_face_dir,x
	jsr _spr_update_dir
	tya
	cmp !koopa_face_dir,x
	beq .no_turn
	lda #$08
	sta !koopa_turn_timer,x
.no_turn:
	jsr _spr_set_ani_frame
	lda !koopa_ani_frame,x
	ora #$02
	sta !koopa_ani_frame,x
	lda !parakoopa_hv,x
	bne .horz
	jsr _spr_upd_y_no_grav
	bra .vert_cont

.horz:
	ldy #$fc
	lda !koopa_ani_timer,x
	and #$20
	beq .noback
	ldy #$04
.noback:
	sty !sprite_speed_y,x
	jsr _spr_upd_x_no_grav
	jsr _spr_upd_y_no_grav
.vert_cont:
	; set carry - fast speed
	lda !spr_extra_byte_1,x
	lsr

	lda !parakoopa_accel_wait,x
	bne .no_accel_yet
	inc !parakoopa_accel_timer,x
	lda !parakoopa_accel_timer,x
	and #$03
	bne .no_accel_yet
	lda !parakoopa_accel_dir,x
	and #$01
	tay
	bcc .not_fast
	iny #2
.not_fast:
	lda !sprite_speed_x,x
	clc
	adc .accel,y
	sta !sprite_speed_y,x
	sta !sprite_speed_x,x
	cmp .spd_max,y
	bne .no_accel_yet
	inc !parakoopa_accel_dir,x
	lda .timer,y
	sta !parakoopa_accel_wait,x
.no_accel_yet:
	jsr _sprspr_mario_spr_rt
.exit:
	rtl
.suboff_val:
	db $00,$01
.accel:
	db $FF,$01
	db $FE,$02
.spd_max:
	db $F0,$10
	db $E8,$18
.timer:
	db $30,$30
	db $18,$18

%start_sprite_pose_entry_list("koopa")
	%start_sprite_pose_entry("k_walk_1", 16, 32)
		%sprite_pose_tile_entry($00, $F7, $00, $00, 2, 1)
		%sprite_pose_tile_entry($00, $E7, $06, $00, 2, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("k_walk_2", 16, 32)
		%sprite_pose_tile_entry($00, $F8, $02, $00, 2, 1)
		%sprite_pose_tile_entry($00, $E8, $06, $00, 2, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("k_walk_1")
	%sprite_pose_entry_mirror("k_walk_2")
	; TODO
	%start_sprite_pose_entry("k_stunned", 16, 16)
		%sprite_pose_tile_entry($00, $00, $0C, $00, 2, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()

%start_sprite_pose_entry_list("winged_koopa")
	%start_sprite_pose_entry_callback("kw_walk_1", 16, 32, winged_koopa_callback)
		%sprite_pose_tile_entry_withnext($05, $EF, $00, $06, 0, 0, k_walk_1_tile_0)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry_callback("kw_walk_2", 16, 32, winged_koopa_callback)
		%sprite_pose_tile_entry_withnext($05, $EF, $00, $06, 0, 0, k_walk_2_tile_0)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("kw_walk_1")
	%start_sprite_pose_entry_callback("kw_walk_wingout", 16, 32, winged_koopa_callback)
		%sprite_pose_tile_entry_withnext($09, $EB, $00, $06, 2, 0, k_walk_2_tile_0)
	%finish_sprite_pose_entry()
	; TODO
	%start_sprite_pose_entry("kw_stunned", 16, 16)
		%sprite_pose_tile_entry($00, $00, $0C, $00, 2, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()

%start_sprite_pose_entry_list("parakoopa")
	%sprite_pose_entry_mirror("kw_walk_1")
	%sprite_pose_entry_mirror("kw_walk_wingout")
	%sprite_pose_entry_mirror("kw_walk_1")
	%sprite_pose_entry_mirror("kw_walk_wingout")
%finish_sprite_pose_entry_list()

%start_sprite_pose_entry_list("giant_koopa")
	%start_sprite_pose_entry("g_walk_1", 24, 32)
		%sprite_pose_tile_entry($FC, $F8, $00, $00, 2, 1)
		%sprite_pose_tile_entry($04, $F8, $01, $00, 2, 1)
		%sprite_pose_tile_entry($FC, $08, $03, $00, 2, 1)
		%sprite_pose_tile_entry($04, $08, $04, $00, 2, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("g_walk_2", 24, 32)
		%sprite_pose_tile_entry($FC, $F8, $06, $00, 2, 1)
		%sprite_pose_tile_entry($04, $F8, $01, $00, 2, 1)
		%sprite_pose_tile_entry($FC, $08, $08, $00, 2, 1)
		%sprite_pose_tile_entry($04, $08, $09, $00, 2, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()
koopas_done:
%set_free_finish("bank1_spr0to13", koopas_done)
