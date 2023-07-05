!goomba_sprnum = $00
; todo - not really much to do, just proper configs/update std interaction
!galoomba_sprnum = $01
; todo - probably own sprite behavior, its different enough
!paragoomba_sprnum = $03
; todo - smb3 flying/microgoomba spawning shithead

!shelless_koopa_sprnum = $02
!koopa_sprnum = $04
!shell_sprnum = $05
!lame_parakoopa_sprnum = $06
!flyin_parakoopa_v_sprnum = $07
!flyin_parakoopa_h_sprnum = $08

!koopa_is_winged_scr    = $45

!koopa_stays_on_ledges     = !sprite_misc_c2
!koopa_winged              = !sprite_misc_1528
!koopa_falling_last_frame  = !sprite_misc_151c
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

!parakoopa_accel_timer     = !sprite_misc_c2
!parakoopa_accel_dir       = !sprite_misc_151c
!parakoopa_accel_wait      = !sprite_misc_1540

!wing_out_tile = $EC
!wing_in_tile  = $FE

; todo reimplement the koopa wing gfx routine
; note - new sprites have walking parakoopas that stay on ledges,
;        the new version should account for this and not flare the wing
;        out for a frame in this case
; koopa wings
org $019E1C|!bank
	db !wing_in_tile, !wing_out_tile
	db !wing_in_tile, !wing_out_tile

%alloc_sprite_sharedgfx_entry_3(!goomba_sprnum,$AE,$AE,$AE)

%alloc_sprite(!goomba_sprnum, "goomba", koopa_init_goomba, goomba_main, 2, \
	$30, $00, $00, $00, $00, $00)
%alloc_sprite_sharedgfx_entry_mirror(!paragoomba_sprnum, !goomba_sprnum)

%alloc_sprite_sharedgfx_entry_3(!shelless_koopa_sprnum,$02,$00,$04)

%alloc_sprite_spriteset_1(!shelless_koopa_sprnum, "shelless_koopa", koopa_init, shelless_koopa_main, 2, \
	$104, \
	$70, $00, $00, $00, $00, $00)

%alloc_sprite_spriteset_1(!koopa_sprnum, "koopas", koopa_init, koopa_main, 5, $0100, \
	$10, $40, $00, $00, $02, $A0)
%alloc_sprite_spriteset_1(!shell_sprnum, "koopa_shell", koopa_init_stun, koopa_main, 5, $0100,\
	$10, $40, $00, $00, $02, $A0)
%alloc_sprite_spriteset_1(!lame_parakoopa_sprnum, "lame_parakoopa", koopa_init, koopa_main, 3, $0100,\
	$10, $40, $00, $00, $42, $B0)
%alloc_sprite_spriteset_1(!flyin_parakoopa_v_sprnum, "flyin_parakoopa_vert", koopa_init, flyin_parakoopa_main, 3, $0100,\
	$10, $40, $00, $00, $52, $B0)
%alloc_sprite_spriteset_1(!flyin_parakoopa_h_sprnum, "flyin_parakoopa_horz", koopa_init, flyin_parakoopa_main, 3, $0100,\
	$10, $40, $00, $00, $52, $B0)

%alloc_sprite_sharedgfx_entry_9(!koopa_sprnum, $82,$A0,$82,$A2,$84,$A4,$8C,$8A,$8E)
%alloc_sprite_sharedgfx_entry_mirror(!shell_sprnum, !koopa_sprnum)
%alloc_sprite_sharedgfx_entry_mirror(!lame_parakoopa_sprnum, !koopa_sprnum)
%alloc_sprite_sharedgfx_entry_mirror(!flyin_parakoopa_v_sprnum, !koopa_sprnum)
%alloc_sprite_sharedgfx_entry_mirror(!flyin_parakoopa_h_sprnum, !koopa_sprnum)

%set_free_start("bank1_koopakids")
koopa_init_stun:
	; sprite init caller sets state to 08 before calling
	inc !sprite_status,x
koopa_init:
	; flag to not turn in place when falling
	; needs to be set for flying parakoopas, and
	; for normal koopas that stay on ledges so they don't
	; turn in the air
	inc !koopa_jumping_over_shell,x
.goomba:
	ldy !spr_extra_bits,x
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
.exit:
	rtl
.pals:
	; green, yellow, blue, red
	db $5*2,$2*2,$4*2,$3*2

; TODO FIX WINGS
koopa_gfx:
	; used as 'is parakoopa' scratch throughout sprite
	stz !koopa_is_winged_scr
	lda !sprite_num,x
	cmp #!koopa_sprnum
	beq .no_wings
	inc !koopa_is_winged_scr
.fly_entry:
	; todo port this routine, needs at least one fix
;	jsr $9E28
.no_wings:
	; gfx
	lda !koopa_face_dir,x
	eor #$01
	sta $06
	ldy !koopa_ani_frame,x
	lda koopa_table_off_lo,y
	sta $04
	lda koopa_table_off_hi,y
	sta $05
	stz !sprite_off_screen_horz,x
	jsl spr_gfx
;	rts
	lsr
	lda !sprite_y_low,x
	pha
	sbc #$0F
	sta !sprite_y_low,x
	lda !sprite_y_high,x
	pha
	sbc #$00
	sta !sprite_y_high,x
	jsr sub_spr_gfx_1
	pla
	sta !sprite_y_high,x
	pla
	sta !sprite_y_low,x
	rts
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
	stz !koopa_is_winged_scr

	jsr sub_spr_gfx_2
	lda !sprites_locked
	bne koopa_init_exit
	jsr _suboffscr0_bank1
	lda !koopa_post_kick_frz_timer,x
	beq .not_finish_kick
;	jmp .mario_ixn
	jmp koopa_main_interact

.not_finish_kick:
	lda !koopa_pushed_by_kickable,x
	beq .check_kick
	ldy !koopa_kick_shell_slot,x
	lda !sprite_status,y
	cmp #$09
	bcs .do_catch_slide
;	cmp #$0a
;	beq .do_catch_slide
	jmp koopa_main_interact

.do_catch_slide:
	lda !sprite_blocked_status,x
	bit #$03
	bne ..prep_shell_kick
	bit #$04
	beq ..falling
	; todo original code accounted for 'is level slippery'
	lda !sprite_speed_x,y
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
	sta !sprite_speed_x,y
	; todo: dust particles
..falling:
	stz !koopa_ani_frame,x
	jmp koopa_main_interact
;	bra .mario_ixn

..prep_shell_kick:
	lda #$00
	sta !sprite_speed_x,y
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
;	bra .mario_ixn
	jmp koopa_main_interact
.cont:
	lda !koopa_kicking_shell_timer,x
	cmp #$01
	beq .do_kick
	lda #$00
	sta !koopa_ani_frame,x
;	bra .mario_ixn
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
	sta !sprite_speed_x,y
	lda #$0a
	sta !sprite_status,y

	; check yellow
	lda !spr_extra_bits,x
	cmp #$01
	beq .disco
	jmp koopa_main_interact
	;bne .mario_ixn
.disco:
	sta !disco_shell_flag,y
.mario_ixn:
	jmp koopa_main_interact

;	jsr _mario_spr_interact
;	jsr _spr_upd_pos
.exit:
	rtl

.kick_speeds:
	db $30,$D0

koopa_main:
	jsr koopa_gfx
	lda !sprites_locked
	bne shelless_koopa_main_exit
	jsr _suboffscr0_bank1
	lda !koopa_is_winged_scr
	bne .ani_upd
.shelless_entry:
	lda !koopa_falling_last_frame,x
	bne .no_ani_upd
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
	lda !spr_extra_bits,x
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
	lda !koopa_is_winged_scr
	beq .interact
	jsr _spr_jump_over_shell
	lda !sprite_speed_y,x
	bpl .interact
	inc !koopa_jumping_over_shell,x
	bra .interact

.airborne:
	lda !koopa_stays_on_ledges,x
	beq .check_wings
	lda !koopa_falling_last_frame,x
	cmp #$02
	bcs .check_wings
	inc !koopa_falling_last_frame,x
.check_flip:
	bcs .check_wings
	; only parakoopas jump over shells
	lda !koopa_jumping_over_shell,x
	bne .double_ani
	jsr _flip_sprite_dir_imm
	; TODO if kicked as a shell don't do this. might need 'was airborne last frame'
	;      as part of standard stunned routine...original never had a state 9 -> 8 transition
	stz !sprite_speed_y,x
	bra .interact
.check_wings:
	lda !koopa_is_winged_scr
	beq .interact
	; double time
.double_ani:
	jsr _spr_set_ani_frame
.interact:
	jsr _sprspr_mario_spr_rt
	jsr _spr_upd_pos
	jsr _flip_if_side_blocked
.exit:
	rtl
.speeds:
	db $08,$F8,$0C,$F4

flyin_parakoopa_main:
	jsr koopa_gfx_fly_entry
	lda !sprites_locked
	bne .exit
	ldy !sprite_num,x
	lda .suboff_val-!flyin_parakoopa_v_sprnum,y
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
	; todo modify this logic
	lda !sprite_num,x
	cmp #!flyin_parakoopa_v_sprnum
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
	lda !spr_extra_bits,x
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
; koopa gfx tables
%start_sprite_table("koopa_walk_1", $08, $10)
	%sprite_table_entry($FFFC, $0008, $00, $00, 1)
	%sprite_table_entry($FFFC, $FFF8, $06, $00, 1)
%finish_sprite_table()
%start_sprite_table("koopa_walk_2", $08, $10)
	%sprite_table_entry($FFFC, $0009, $02, $00, 1)
	%sprite_table_entry($FFFC, $FFF9, $06, $00, 1)
%finish_sprite_table()
%start_sprite_table("koopa_walk_turn", $08, $10)
	%sprite_table_entry($FFFC, $0008, $04, $00, 1)
	%sprite_table_entry($FFFC, $FFF8, $08, $00, 1)
%finish_sprite_table()
koopa_table_off_lo:
	db koopa_walk_1
	db koopa_walk_2
	db koopa_walk_turn
koopa_table_off_hi:
	db koopa_walk_1>>8
	db koopa_walk_2>>8
	db koopa_walk_turn>>8


koopas_done:
%set_free_finish("bank1_koopakids", koopas_done)
