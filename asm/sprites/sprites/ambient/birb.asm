includefrom "ambient_list.def"

%alloc_ambient_sprite_grav(!ambient_birb_id, "yi_house_bird", ambient_bird, \
	!ambient_twk_has_grav|!ambient_twk_pos_upd|!ambient_twk_check_offscr, \
	$03, $40)

; todo
ambient_bird:
	stz !ambient_rt_ptr,x
	rts
