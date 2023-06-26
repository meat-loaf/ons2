
!ambient_wiggler_flower_id = $02
%alloc_ambient_sprite_grav(!ambient_wiggler_flower_id, "wiggler_flower", wiggler_flower_main, \
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_twk_check_offscr, $02, $30)

%set_free_start("bank2_altspr2")
wiggler_flower_main:
	lda !ambient_gen_timer,x
	bne .no_inv
	sep #$20
	lda !ambient_x_speed+1,x
	eor #$FF
	inc
	sta !ambient_x_speed+1,x
	lda #$08
	sta !ambient_gen_timer,x
	rep #$20
.no_inv:
	lda #$0B18
	sta !ambient_props,x
	jsr ambient_basic_gfx
	lda !ambient_sprlocked_mirror
	bne .exit
	jmp ambient_physics
;	jmp ambient_obj_interact
;	
.exit
	rts
wiggler_flower_done:
%set_free_finish("bank2_altspr2", wiggler_flower_done)
