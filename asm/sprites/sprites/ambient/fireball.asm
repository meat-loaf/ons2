includefrom "ambient_list.asm"
!ambient_fireball_enemy_ng = $3B
!ambient_fireball_enemy    = $3C
!ambient_fireball_ix       = $3D


%alloc_ambient_sprite_grav(!ambient_fireball_ix, "fireball", fireballz, !ambient_twk_check_offscr|!ambient_twk_has_grav, $04, $30)
%alloc_ambient_sprite_grav(!ambient_fireball_enemy, "enemy_fireball", fireballz, !ambient_twk_check_offscr|!ambient_twk_has_grav, $04, $30)
%alloc_ambient_sprite(!ambient_fireball_enemy_ng, "enemy_fireball_nograv", fireballz, !ambient_twk_check_offscr)

%set_free_start("bank2_altspr1")
fireballz:
	lda !ambient_misc_2,x
	and #$000C
	lsr
	tay
	lda .props,y
	sta !ambient_props,x
	jsr ambient_basic_gfx
	lda !ambient_sprlocked_mirror
	bne exit_short
	inc !ambient_misc_2,x
	jsr ambient_physics
	lda !ambient_misc_1+1,x
	and #$00FF
	asl
	tay
	lda.w .interaction_rts-(!ambient_fireball_enemy_ng*2),y
	sta $02
	jmp ($0002)
.interaction_rts:
	dw ambient_fb_checkplayer
	dw ambient_fb_checkplayer
	dw ambient_fb_checkobj_spr
.props:	
	dw $042C,$042D
	dw $C42C,$C42D

exit_short:
	rts

pfireball_set_clipping_b_8a8i:
	lda !ambient_y_pos,x
	sec
	sbc #$0004
	sta $01
	; store high byte of y displacement to $09
	sta $08
	lda !ambient_x_pos,x
	sec
	sbc #$0002
	; store high byte of x displacement to $07
	sta $07
	sep #$30
	; store x low
	sta $00
	lda #$0C
	sta $02
	lda #$13
	sta $03
	rts

ambient_fb_checkplayer:
	ldy #$0000
	jsr ambient_set_clipping_a_8a8i
	jsl get_mario_clipping
	jsl check_for_contact
	bcc .no_contact
	jsl hurt_mario
.no_contact:
	rep #$30
	rts

ambient_fb_checkobj_spr:
	lda $0e
	sta $45

	lda !ambient_x_speed,x
	; $48 has actual speed
	sta $47

	jsr pfireball_set_clipping_b_8a8i
	; iterate through odd/even sprite slots every
	; other frame
	lda !true_frame
	and #$01
	eor.b #!num_sprites-1
	tax
;	ldx #!num_sprites-1
.sprite_loop:
	lda !sprite_status,x
	cmp #$08
	bcc ..next
	lda !sprite_tweaker_167a,x
	and #$02
	bne ..next
	jsl get_spr_clipping_a
	jsl check_for_contact
	bcc ..next

	lda !sprite_tweaker_166e,x
	and #$10
	bne ..die_nokill
	lda #$02
	sta !sprite_status,x
	ldy #$00

	lda #$d0
	sta !sprite_speed_y,x
	lda $48
	bpl ..pos_spd
	iny
..pos_spd:
	lda ..kill_sprite_x_speeds,y
	sta !sprite_speed_x,x
..die:
	lda #$30
	sta !ambient_get_slot_timer

	rep #$30
	ldx !current_ambient_process
	lda !ambient_x_pos,x
	sta !ambient_get_slot_xpos
	lda !ambient_y_pos,x
	sta !ambient_get_slot_ypos

	stz !ambient_get_slot_xspd
	lda.w #!ambient_score_100pt_id
	jsl ambient_get_slot
	rep #$30
	bra .kill_to_smoke

..die_nokill:
	rep #$30
	ldx !current_ambient_process
	bra .kill_to_smoke
..kill_sprite_x_speeds:
	db $10,(~$10)+1

..next:
	dex : dex
	bpl .sprite_loop
.done:
	rep #$30
	lda $45
	sta $0e
	ldx !current_ambient_process

	jsr ambient_obj_interact
	bcc .exit
	inc !ambient_misc_1,x
	lda !ambient_misc_1,x
	and #$00FF
	cmp #$0002
	bcs .kill_to_smoke
	lda.w #$D000
	sta !ambient_y_speed,x
	bra .exit_no_obji_fc

.exit:
	lda !ambient_misc_1,x
	and #$FF00
	sta !ambient_misc_1,x
.exit_no_obji_fc:
	lda $0e
	beq .exit_real
	dec !ambient_playerfireballs
.exit_real:
	rts

.kill_to_smoke:
	dec !ambient_playerfireballs
	lda #ambient_initer
	sta !ambient_rt_ptr,x
	lda #$0100
	sta !ambient_misc_1,x
	lda #$000F
	sta !ambient_gen_timer,x
	rts
fireballz_done:
%set_free_finish("bank2_altspr1", fireballz_done)
