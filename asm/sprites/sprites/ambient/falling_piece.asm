includefrom "ambient_list.def"

%alloc_ambient_sprite_grav(!ambient_falling_piece_id, "falling_piece", ambient_falling_piece, \
	!ambient_twk_has_grav|!ambient_twk_pos_upd|!ambient_twk_check_offscr, \
	$03, $40)

%set_free_start("bank2_altspr1")
ambient_falling_piece:
	lda !effective_frame
	and #$000E
	tay
	lda .props,y
	sta !ambient_props,x
	jsr ambient_basic_gfx
	lda !ambient_sprlocked_mirror
	bne .exit
	jmp ambient_physics
.exit:
	rts
.props:
	dw $003C,$003D,$803D,$803C,$C03C,$C03D,$403D,$403C

ambient_falling_piece_done:
%set_free_finish("bank2_altspr1", ambient_falling_piece_done)
