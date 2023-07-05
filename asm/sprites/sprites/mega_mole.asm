includefrom "list.def"

!megamole_sprnum = $BF

%alloc_sprite_spriteset_1(!megamole_sprnum, "mega_mole", mega_mole_init, mega_mole_main, 4, $101, \
	$0E, $30, $11, $A1, $00, $20)

!mega_mole_falling_timer = !sprite_misc_1540
!mega_mole_ride_timer    = !sprite_misc_154c
!mega_mole_ani_timer     = !sprite_misc_1570
!mega_mole_facing_dir    = !sprite_misc_157c
!mega_mole_moving_dir    = !sprite_misc_1594
!mega_mole_turning_timer = !sprite_misc_15ac
!mega_mole_ani_frame     = !sprite_misc_1602

%set_free_start("bank3_sprites")
mega_mole_init:
	jsr.w _sub_horz_pos_bank3
	tya
	sta !mega_mole_moving_dir,x
	sta !mega_mole_facing_dir,x
.exit:
	rtl
mega_mole_main:
	jsr.w spr_gfx_32x32
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne mega_mole_init_exit
	; set next animation frame
	inc !mega_mole_ani_timer,x
	lda !mega_mole_ani_timer,x
	lsr #2
	and #$01
	sta !mega_mole_ani_frame,x

	jsr.w _suboffscr3_bank3
	ldy !mega_mole_facing_dir,x
	lda .speeds,y
	sta !sprite_speed_x,x
	lda !sprite_blocked_status,x
	and #$04
	pha
	jsl update_sprite_pos|!bank
	jsl spr_spr_interact|!bank
	lda !sprite_blocked_status,x
	and #$04
	beq .airborne
	stz !sprite_speed_y,x
	pla
	bra .grounded
.airborne:
	pla
	beq .falling
	lda #$0A
	sta !mega_mole_falling_timer,x
.falling:
	lda !mega_mole_falling_timer,x
	beq .grounded
	stz !sprite_speed_y,x
.grounded:
	ldy !mega_mole_turning_timer,x
	lda !sprite_blocked_status,x
	and #$03
	beq .noturn
	cpy #$00
	bne .no_upd_turning_timer
	lda #$10
	sta !mega_mole_turning_timer,x
.no_upd_turning_timer:
	lda !mega_mole_facing_dir,x
	eor #$01
	sta !mega_mole_facing_dir,x
.noturn:
	cpy #$00
	bne .no_upd_facing_dir
	lda !mega_mole_facing_dir,x
	sta !mega_mole_moving_dir,x
.no_upd_facing_dir:
	jsl mario_spr_interact_l
	bcc .exit
	jsr.w _sub_vert_pos_bank3
	lda $0E
	cmp #$D8
	bpl .ok
	bra .check_ride
.ok
	lda !mega_mole_ride_timer,x
	ora !sprite_being_eaten,x
	bne .exit
	jml hurt_mario
.check_ride:
	lda !player_y_speed
	bmi .exit
	lda #$01
	sta !player_on_solid_platform
	lda #$06
	sta !mega_mole_ride_timer,x
	stz !player_y_speed
	ldy !player_on_yoshi
	lda .riding_ypos,y
	clc
	adc !sprite_y_low,x
	sta !player_y_next

	; todo this is just like the original code
	; but always puts mario at y_high = 0...
	;lda !sprite_x_high,x
	;adc #$ff
	;sta !player_y_next+1

	ldy #$00
	lda !sprite_x_movement
	bpl .move_x_pos
	dey
.move_x_pos:
	clc
	adc !player_x_next
	sta !player_x_next
	tya
	adc !player_x_next+1
	sta !player_x_next+1
.exit:
	rtl
.speeds:
	db $10,$F0
.riding_ypos:
	db $D6,$C6,$C6
mega_mole_done:
%set_free_finish("bank3_sprites", mega_mole_done)
