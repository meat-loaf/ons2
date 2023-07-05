!roulette_sprnum   = $3F
!mushroom_sprnum   = $40
!feather_sprnum    = $41
!fireflower_sprnum = $42
!poison_sprnum     = $43
!star_sprnum       = $44
!pballoon_sprnum   = $46
!1up_sprnum        = $47


!roulette_change_frames = $20

%alloc_sprite(!roulette_sprnum, "item_roulette", powerup_init, roulette_main, 1, \
	$00, $00, $00, $C2, $28, $40)
%alloc_sprite(!mushroom_sprnum, "mushroom", powerup_init, powerup_main, 1, \
	$00, $00, $08, $C2, $28, $40)
%alloc_sprite(!feather_sprnum, "cape_feather", powerup_init, feather_main, 1, \
	$00, $00, $24, $C2, $28, $40)
%alloc_sprite(!fireflower_sprnum, "fire_flower", fire_flower_init, fire_flower_main, 1, \
	$00, $00, $0A, $C2, $28, $40)
%alloc_sprite(!poison_sprnum, "poison_mushroom", powerup_init, powerup_main, 1, \
	$00, $00, $08, $C2, $28, $40)
%alloc_sprite(!star_sprnum, "starman", powerup_init, powerup_main, 1, \
	$00, $00, $04, $C2, $08, $40)

%alloc_sprite_sharedgfx_entry_1(!mushroom_sprnum, $24)
%alloc_sprite_sharedgfx_entry_1(!feather_sprnum, $22)
%alloc_sprite_sharedgfx_entry_1(!fireflower_sprnum, $26)
%alloc_sprite_sharedgfx_entry_1(!poison_sprnum, $20)
%alloc_sprite_sharedgfx_entry_1(!star_sprnum, $28)

%alloc_sprite_sharedgfx_entry_mirror(!roulette_sprnum, !mushroom_sprnum)

!powerup_no_move_flag        = !sprite_misc_c2
!roulette_current_powerup_ix = !sprite_misc_151c
!fire_flower_ani_counter     = !sprite_misc_1570
!feather_fall_accel_dir      = !sprite_misc_1528
!powerup_face_dir            = !sprite_misc_157c
!powerup_spawn_wait_timer    = !sprite_misc_1558
!powerup_rising_from_block   = !sprite_misc_1540
!powerup_disable_interaction = !sprite_misc_154c
!powerup_spawned_mask        = !sprite_misc_1594
!roulette_current_powerup    = !sprite_misc_1602

%set_free_start("bank1_powerups")
powerup_init:
	lda !powerup_rising_from_block,x
	bne init_alt
fire_flower_init:
	inc !powerup_no_move_flag,x
	rtl

init_alt:
	lda #$08
	sta !powerup_spawn_wait_timer,x
	lda !powerup_rising_from_block,x
	clc
	adc #$08
	sta !powerup_rising_from_block,x
	rtl
powerup_should_interact:
	jsr.w $01A80F|!bank
	bcc .no
	lda !powerup_disable_interaction,x
	bne .no_set_carry
	lda !powerup_rising_from_block,x
	cmp #$18
	bcs .no_set_carry
	sec
	rts
.no_set_carry:
	clc
.no:
	rts
roulette_init:
	lda #(!fireflower_sprnum-!mushroom_sprnum)
	jsr roulette_set_powerup

	lda #!roulette_change_frames
	sta !powerup_spawn_wait_timer,x
	rtl

roulette_set_powerup:
	sta !roulette_current_powerup,x
	tax
	lda.l spr_tweaker_166E_tbl+!mushroom_sprnum,x
	and #$0F
	ldx !current_sprite_process
	sta !sprite_oam_properties,x
	rts

roulette_main:
	jsr.w sub_spr_gfx_2
	lda !sprites_locked
	bne .no_change
	jsr powerup_should_interact
	bcc .not_touched
	jmp spr_give_powerup
.not_touched:
	lda !powerup_spawn_wait_timer,x
	bne .no_change
	lda #!roulette_change_frames
	sta !powerup_spawn_wait_timer,x
	
	inc !roulette_current_powerup_ix,x
	lda !roulette_current_powerup_ix,x
	cmp #$06
	bcc .ok
	lda #$00
	sta !roulette_current_powerup_ix,x
.ok:
	tay
	lda .powerups,y
	jsr roulette_set_powerup
.no_change:
	rtl

.powerups:
	db !fireflower_sprnum-!mushroom_sprnum
	db !poison_sprnum-!mushroom_sprnum
	db !feather_sprnum-!mushroom_sprnum
	db !poison_sprnum-!mushroom_sprnum
	db !star_sprnum-!mushroom_sprnum
	db !poison_sprnum-!mushroom_sprnum

feather_main:
	jsr.w sub_spr_gfx_2
	lda !sprites_locked
	beq .ok
	jmp powerup_main_gfx_interact
.ok:
	lda !powerup_no_move_flag,x
	beq .not_rising
	jsr.w _spr_obj_interact
	lda !sprite_blocked_status,x
	and #$04
	bne .floor_blocked
	stz !powerup_no_move_flag,x
.floor_blocked:
	lda !powerup_no_move_flag,x
	bne .interact
	lda !powerup_disable_interaction,x
	beq .not_rising
	jsr.w _spr_upd_y_no_grav
	inc !sprite_speed_y,x
	bra .y_upd_interact
.not_rising:
	lda !feather_fall_accel_dir,x
	and #$01
	tay
	lda !sprite_speed_x,x
	clc
	adc .x_accel,y
	sta !sprite_speed_x,x
	cmp .x_speed_max,y
	bne .no_flip
	inc !feather_fall_accel_dir,x
.no_flip:
	lda !sprite_speed_x,x
	bpl .no_y_adj
	iny
.no_y_adj:
	lda .y_speeds,y
	clc
	adc #$06
	sta !sprite_speed_y,x
	jsr.w _spr_upd_x_no_grav
.y_upd_interact:
	jsr.w _spr_upd_y_no_grav
	jsr.w _spr_update_dir
.interact:
	jsr powerup_should_interact
	bcc .not_touched
	jmp spr_give_powerup
.not_touched:
	rtl
.x_accel:
	db $02,$FE
.x_speed_max:
	db $20,$E0
.y_speeds:
	db $0A,$F6,$08
fire_flower_main:
	lda !effective_frame
	and #$08
	lsr #3
	sta !powerup_face_dir,x
powerup_main:
	lda !powerup_spawn_wait_timer,x
	beq .cont
	rtl
.cont:
	lda !powerup_rising_from_block,x
	beq .gfx_interact
	lda !powerup_spawned_mask,x
	bne .gfx_interact
	; todo probably get rid of this ambient sprite type,
	;      it has the unfortunate side effect of also hiding
	;      mario if he comes up to the block
	lda !sprite_x_low,x
	sta !ambient_get_slot_xpos
	lda !sprite_x_high,x
	sta !ambient_get_slot_xpos+1
	lda !sprite_y_low,x
	sec
	sbc #$01
	sta !ambient_get_slot_ypos
	lda !sprite_y_high,x
	sbc #$00
	sta !ambient_get_slot_ypos+1
	lda !powerup_rising_from_block,x
	sta !ambient_get_slot_timer
	lda #$3F
	jsl ambient_get_slot
	inc !powerup_spawned_mask,x
.gfx_interact:
	jsr.w sub_spr_gfx_2
	lda !sprites_locked
	beq .not_locked
	rtl
.not_locked:
	jsl sub_off_screen
	; interaction without proximity check
	; why did the original game call it like this?
	jsr powerup_should_interact
	bcc powerup_no_interact
spr_give_powerup:
	stz !sprite_status,x
	lda !sprite_num,x
	sec
	sbc #!mushroom_sprnum
	bpl .not_roulette
	lda !roulette_current_powerup,x
	inc
	tay
	bra .load_tbl
.not_roulette:
	cmp #$03
	bcc .not_special
	inc
	tay
	bra .load_tbl
.not_special:
	asl #2
	ora !powerup
	tay
	; todo handle item box
	lda power_pointer_index,y
	tay
.load_tbl:
	lda power_pointer_routines_lo,y
	sta $00
	lda power_pointer_routines_hi,y
	sta $01
	jmp ($0000)

powerup_no_interact:
	lda !powerup_rising_from_block,x
	bne .rise_from_block
	jsr.w _spr_obj_interact
	lda !sprite_blocked_status,x
	bit #$04
	bne .on_ground
	stz !powerup_no_move_flag,x
	bra .no_zero_y
.on_ground:
	stz !sprite_speed_y,x
.no_zero_y:
	and #$03
	beq .not_touching_wall
	lda !powerup_face_dir,x
	eor #$01
	sta !powerup_face_dir,x
.not_touching_wall:
	lda !powerup_no_move_flag,x
	bne .no_move
	lda !sprite_num,x
	cmp #!fireflower_sprnum
	beq .no_x_speed
	ldy !powerup_face_dir,x
	lda moving_powerup_x_speeds,y
	sta !sprite_speed_x,x
	jsr.w _spr_upd_x_no_grav
.no_x_speed:
	jsr.w _spr_upd_y_no_grav
	lda !sprite_speed_y,x
	clc
	adc #$03
	sta !sprite_speed_y,x
.no_move:
	rtl
.rise_from_block:
	lda #$FC
	sta !sprite_speed_y,x
	jsr _spr_upd_y_no_grav
	rtl

moving_powerup_x_speeds:
	db $F0,$10

power_pointer_index:
	; small->mushroom, big->mushroom, fire->mushroom, mushroom->cape
	db $01, $00, $02, $03
	; small->cape, big->cape, cape->cape, cape->fire
	db $02, $02, $00, $03
	; small->fire, big->fire, fire->cape, fire->fire
	db $03, $03, $02, $00


power_pointer_routines_lo:
	db power_do_nothing
	db give_mushroom
	db give_cape
	db give_flower
	db powerup_hurt
	;db give_1up
	;db give_star
	;db give_pballoon
power_pointer_routines_hi:
	db power_do_nothing>>8
	db give_mushroom>>8
	db give_cape>>8
	db give_flower>>8
	db powerup_hurt>>8
powerup_hurt:
	jml hurt_mario

give_mushroom:
	lda #$02
	sta !player_ani_trigger_state
	lda #$2F
	sta !player_ani_timer
	sta !sprites_locked
power_do_nothing:
	lda #$0A
	sta !spc_io_1_sfx_1DF9
; todo
.points:
	lda #$04
	jml spr_give_points
;	rtl
; todo
give_cape:
	rtl
give_flower:
	lda #$20
	sta !player_palette_cycle_timer
	sta !sprites_locked
	lda #$04
	sta !player_ani_trigger_state
	lda #$03
	sta !powerup
	bra power_do_nothing
give_star:
	rtl
powerups_done:
%set_free_finish("bank1_powerups", powerups_done)
