includeonce

macro declare_block(name, tile, actslike, sigbyte,
	mario_above, mario_below, mario_side, mario_top_corner, mario_body, mario_head,
	sprite_v, sprite_h, cape, fireball,
	wallrun_footie, wallrun_body)

	namespace <name>

	!t #= <tile>
	; TODO sigbyte check
	if defined("tile_!{t}_actslike")
		error "Block at tile <tile> already defined!"
	else
		!{tile_!{t}_name} = <name>
		!{tile_!{t}_actslike} #= <actslike>
		!{tile_!{t}_sigbyte}  #= <sigbyte>

		!{tile_!{t}_mario_above}      = <mario_above>
		!{tile_!{t}_mario_below}      = <mario_below>
		!{tile_!{t}_mario_side}       = <mario_side>
		!{tile_!{t}_mario_top_corner} = <mario_top_corner>
		!{tile_!{t}_mario_body}       = <mario_body>
		!{tile_!{t}_mario_head}       = <mario_head>
		!{tile_!{t}_sprite_v}         = <sprite_v>
		!{tile_!{t}_sprite_h}         = <sprite_v>
		!{tile_!{t}_cape}             = <cape>
		!{tile_!{t}_fireball}         = <fireball>
		!{tile_!{t}_wallrun_footie}   = <wallrun_footie>
		!{tile_!{t}_wallrun_body}     = <wallrun_body>
	endif
	undef "t"
endmacro

macro define_block(tile)
	!t #= <tile>
	if not(defined("tile_!{t}_actslike"))
		error "Block at tile <tile> not defined!"
	else

	!{block_!{t}_decl} = 1
	block_!{tile_!{t}_name}_sigbyte:
		db !{tile_!{t}_sigbyte}
	block_!{tile_!{t}_name}_jumptable:
		dw !{tile_!{t}_mario_below}
		dw !{tile_!{t}_mario_above}
		dw !{tile_!{t}_mario_side}
		dw !{tile_!{t}_sprite_v}
		dw !{tile_!{t}_sprite_h}
		dw !{tile_!{t}_cape}
		dw !{tile_!{t}_fireball}
		dw !{tile_!{t}_mario_top_corner}
		dw !{tile_!{t}_mario_body}
		dw !{tile_!{t}_mario_head}
		dw !{tile_!{t}_wallrun_footie}
		dw !{tile_!{t}_wallrun_body}
	endif
	undef "t"
endmacro

macro define_block_duplicate(this_tile, dupe_tile)
	if not(defined("tile_<this_tile>_decl"))
		error "Block at tile ", <this_tile>, "not declared!"
	else
		if not(defined("tile_<dupe_tile>_decl"))
			error "Block at tile ", <dupe_tile>, "not declared!"
		else
			block_!{tile_!{<this_tile>}_name}_sigbyte   = block_!{tile_!{<dupe_tile>}_name}_sigbyte
			block_!{tile_!{<this_tile>}_name}_jumptable = block_!{tile_!{<dupe_tile>}_name}_jumptable
		endif
	endif
endmacro

macro finish_block()
namespace off
endmacro
