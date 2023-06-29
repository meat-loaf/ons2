macro define_block(name, tile, actslike)
	if not defined("highest_tile_id")
		!highest_tile_id #= <tile>
	else
		!highest_tile_id #= max(!highest_tile_id, <tile>)
	endif
	
	if defined("tile_<tile>_actslike")
		error "Block at tile ", <tile>, " already defined!"
	else
		!tile_!{<tile>}_actslike #= actslike
	endif
endmacro
