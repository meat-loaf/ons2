includefrom "ambient_list.def"

;%alloc_ambient_sprite(!ambient_birb_id, "yi_house_bird", ambient_bird_init, \
;	!ambient_twk_pos_upd|!ambient_twk_check_offscr)

%alloc_ambient_sprite_grav(!ambient_birb_id, "yi_house_bird", ambient_bird_init, \
	!ambient_twk_has_grav|!ambient_twk_pos_upd|!ambient_twk_check_offscr, \
	$01, $30)

%set_free_start("bank2_altspr2")

!bird_hops    = !ambient_misc_1
!bird_state   = !ambient_misc_2
!bird_dir     = !ambient_misc_2+1

ambient_bird_init:
	lda #$0821
	sta !ambient_props,x
	jsr set_rand_hops
	lda #ambient_bird
	sta !ambient_rt_ptr,x
ambient_bird:
	jsr ambient_basic_gfx
	lda !ambient_sprlocked_mirror
	bne .exit
	jsr ambient_physics
	lda !ambient_y_speed,x
	jsr ambient_obj_interact
	stz !ambient_misc_3,x
	bcc .no_obj
	inc !ambient_misc_3,x
.no_obj:
	lda !ambient_y_speed,x
	clc
	adc #$0300
	sta !ambient_y_speed,x

	lda !bird_state,x
	and #$00FF
	asl
	tay
	lda .states,y
	sta $00
	jmp ($0000)

.exit:
	rts

.states:
	dw .moving
	dw .stopped

.moving:
	lda !ambient_misc_3,x
	beq ..exit

	lda !ambient_y_speed,x
	bmi ..yok
	and #$00FF
	ora #$F000
	sta !ambient_y_speed,x
..yok:
	lda !bird_dir,x
	tay
	lda !ambient_x_speed+1,x
	and #$00FF
	ora ..x_spd,y
	sta !ambient_x_speed+1,x
	lda !ambient_y_speed,x
	bmi ..check_next

..check_next:
	lda !bird_hops,x
	dec
	bne ..still_hopping
	;jsr set_rand_hops
	inc !bird_state,x
	rts

..still_hopping:
	sta !bird_hops,x
..exit
	rts

..x_spd:
	dw $0008, $00F8

.stopped:
	lda !ambient_y_speed,x
	and #$00FF
	sta !ambient_y_speed,x

	lda !ambient_x_speed,x
	and #$00FF
	sta !ambient_x_speed,x
	rts

set_rand_hops:
	;sep #$30
	;jsl get_rand
	;rep #$30
	;and #$0003
	lda #$0003
	sta !bird_hops,x
	rts

ambient_bird_done:
%set_free_finish("bank2_altspr2", ambient_bird_done)
