includeonce
macro build_actslike_table(label, npages)
freedata cleaned
<label>:
	!old_acts_like_data #= read3(!acts_like_00_to_3f_ptr)
	!ix #= 0
	while !ix < (<npages>*$100)
		if defined("tile_!{ix}_actslike")
			dw !{tile_!{ix}_actslike}
		else
			dw read2(!old_acts_like_data+(!ix*2))
		endif
	!ix #= !ix+1
	endif
endmacro

macro build_block_tables(ptrs_lbl, bank_lbl)
	if not(defined("highest_tile_id"))
		error("No blocks defined.")
	else
		if !highest_tile_id > $3FFF
			error("Max block index $3FFF")
		endif
	endif
freedata cleaned
<ptrs_lbl>:
	!ix #= 0
	while !ix <= !highest_tile_id
		if defined("block_!{ix}_decl")
			dw !{tile_!{ix}_name}_block_!{tile_!{ix}_name}_sigbyte
		else
			dw $0000
		endif
		!ix #= !ix+1
	endif
freedata cleaned
<bank_lbl>:
	!ix #= 0
	while !ix <= !highest_tile_id
		if defined("block_!{ix}_decl")
			db bank(!{tile_!{ix}_name}_block_!{tile_!{ix}_name}_sigbyte)
		else
			db $00
		endif
		!ix #= !ix+1
	endif
endmacro
