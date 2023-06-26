includefrom "list.def"

!hoopster_sprnum = $1E
%alloc_sprite(!hoopster_sprnum, "smb2_hoopster", hoopster_init, hoopster_main, 1, 0, \
	$00, $00, $0D, $19, $00, $01)
%alloc_sprite_sharedgfx_entry_2(!hoopster_sprnum, $09, $0B)


!hoopster_vert_dir = !sprite_misc_1594
!hoopster_ani_frame = !sprite_misc_1602,x

%set_free_start("bank1_koopakids")
hoopster_init:
	lda $96
	cmp !sprite_y_low,x
	lda $97
	sbc !sprite_y_high,x
	bpl .exit
	inc !sprite_misc_157c,x
.exit:
	rtl

; todo animation
hoopster_main:
	jsr.w sub_spr_gfx_2
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne .exit
	jsr update_animation_frame_alt
	jsl sub_off_screen
	ldy !hoopster_vert_dir,x
	lda !player_x_next
	sec
	sbc !sprite_x_low,x
	clc
	adc #$18
	cmp #$30
	bcs .not_near_mario
	iny #2
.not_near_mario:
	lda .y_speed,y
	sta !sprite_speed_y,x
	jsr.w _spr_upd_y_no_grav
	jsr.w _spr_obj_interact

	lda !spr_touch_tile_low
	cmp #$25
	bne .check_ground
	lda !spr_touch_tile_high
	beq .change_dir
.check_ground:
	lda !sprite_blocked_status,x
	beq .interact
.change_dir:
	lda !hoopster_vert_dir,x
	eor #$01
	sta !hoopster_vert_dir,x
	lda !sprite_oam_properties,x
	eor #$80
	; update flipping for graphics routine
	sta !sprite_oam_properties,x
.interact:
	jsr.w _sprspr_mario_spr_rt
.exit:
	rtl
.y_speed:
	db $08,$FA
	db $16,$F0
update_animation_frame_alt:
	inc !sprite_misc_1570,x
	lda !sprite_misc_1570,x
	lsr #2
	ldy !hoopster_vert_dir,x
	bne .set_frame
	lsr
.set_frame:
	and #$01
	sta !sprite_misc_1602,x
	rts
hoopster_done:
%set_free_finish("bank1_koopakids", hoopster_done)
