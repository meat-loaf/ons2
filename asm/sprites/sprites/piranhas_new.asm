!piranhas_sprite_id = $1A

%alloc_sprite(!piranhas_sprite_id, "piranha_plants", piranhas_init, piranhas_main, 3, 1, \
	$81, $01, $00, $00, $10, $20)


%set_free_start("bank6")
piranhas_init:
piranhas_main:

piranhas_done:
%set_free_finish("bank6", piranhas_done)
