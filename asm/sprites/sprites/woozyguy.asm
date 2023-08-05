!woozyguy_sprnum = $BA

%alloc_sprite_dynamic_free(!woozyguy_sprnum, "woozyguy", woozyguy_init, woozyguy_main, 4, \
	$30, $80, $01, $01, $00, $00)

!woozy_phase         = !sprite_misc_c2
!woozy_phase_counter = !sprite_misc_1534
!woozy_face_dir      = !sprite_misc_157c
!woozy_ani_frame_id  = !sprite_misc_160e

!jump_interval = $20
!squish_interval = $08

!jump_y_speed = $30

%set_free_start("bank3_sprites")
woozyguy_init:
	lda #$C0
	sta !spr_spriteset_off,x
	lda #!jump_interval
	sta !woozy_phase_counter,x

	lda !sprite_x_low,x
	lsr #4
	and #$03
	inc : inc
	clc
	asl
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	jsl sub_horz_pos
	tya
	sta !woozy_face_dir,x
.exit
	rtl

woozyguy_main:
	%dynamic_gfx_rt_bank3("lda !woozy_ani_frame_id,x", "woozyguy")

	lda !sprite_status,x
	eor #$08
	ora !sprite_being_eaten,x
	ora !sprites_locked
	bne woozyguy_init_exit
	lda !sprite_blocked_status,x
	and #$08
	beq .not_touching_ceiling
	stz !sprite_speed_y,x
.not_touching_ceiling:
	lda !sprite_blocked_status,x
	and #$03
	beq .not_touching_wall
	lda !woozy_face_dir,x
	eor #$01
	sta !woozy_face_dir,x
.not_touching_wall:

	lda !woozy_phase,x
	;lda #$00
	txy
	asl
	tax
	jsr (.behaviors,x)
	; mario interact
	jsl mario_spr_interact_l
	; speed
	jsl update_sprite_pos
	; sprites
	jml spr_spr_interact

.behaviors:
	dw ..wait
	dw ..squish
	dw ..jump
	dw ..rotating
	dw ..squish
..wait:
	tyx
	stz !woozy_ani_frame_id,x
	lda !sprite_blocked_status,x
	and #$04
	beq ...done
	dec !woozy_phase_counter,x
	bne ...done
	inc !woozy_phase,x
	lda #!squish_interval
	sta !woozy_phase_counter,x
...done:
	rts

..squish:
	tyx
	dec !woozy_phase_counter,x
	beq ...done
	lda #!squish_interval
	sec
	sbc !woozy_phase_counter,x
	bit #$04
	beq ...no_inv
	eor #$07
...no_inv:
	asl
	adc #$10
	sta !woozy_ani_frame_id,x
	rts
...done:
	ldy !woozy_phase,x
	lda ...next_phase-1,y
	sta !woozy_phase,x
	lda #!jump_interval
	sta !woozy_phase_counter,x
	rts
...next_phase:
	db $02,$00,$00,$00

..jump:
	tyx
	ldy !woozy_face_dir,x
	lda ..x_speed,y
	sta !sprite_speed_x,x
	lda #(~!jump_y_speed)-1
	sta !sprite_speed_y,x
	inc !woozy_phase,x
	rts

; todo setting props better would be nice, if possible
;      this is kind of ugly
..rotating:
	tyx
	; gfx - TODO handle flipping
	dec !woozy_phase_counter,x
	lda !woozy_phase_counter,x
	bit #$10
	beq ..nofr
	pha
	lda #$C0
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
	pla
	bra ..cont
..nofr:
	pha
	lda !sprite_oam_properties,x
	and #(~$C0)
	sta !sprite_oam_properties,x
	pla
..cont:
	and #$0F
	sta !woozy_ani_frame_id,x

	ldy !woozy_face_dir,x
	lda ..x_speed,y
	sta !sprite_speed_x,x
	lda !sprite_blocked_status,x
	and #$04
	beq ...done
	lda !sprite_oam_properties,x
	and #(~$C0)
	sta !sprite_oam_properties,x

	lda #!squish_interval
	sta !woozy_phase_counter,x
	inc !woozy_phase,x
	stz !woozy_ani_frame_id,x
	stz !sprite_speed_x,x
...done:
	rts

..x_speed:
	db $10,$F0
woozyguy_done:
%set_free_finish("bank3_sprites", woozyguy_done)
