includefrom "macros.asm"

; spriteset files are implicitly $100-$1FF. use $7F to skip a file where a sprite's tile offsets require it.
macro alloc_sprite_spriteset_1(sprite_id, name, init_rt, main_rt, n_oam_tiles, ssfile_1, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, spr_pose_tbl, spr_gfx_rt)
	%alloc_sprite(<sprite_id>, <name>, <init_rt>, <main_rt>, <n_oam_tiles>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>, <spr_pose_tbl>, <spr_gfx_rt>)
	!{sprite_!{sid}_n_ss_files} #= 1
	!{sprite_!{sid}_ss_file_0} = <ssfile_1>
endmacro

macro alloc_sprite_spriteset_2(sprite_id, name, init_rt, main_rt, n_oam_tiles, ssfile_1, ssfile_2, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, spr_pose_tbl, spr_gfx_rt)
	%alloc_sprite_spriteset_1(<sprite_id>, <name>, <init_rt>, <main_rt>, <n_oam_tiles>, <ssfile_1>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>, <spr_pose_tbl>, <spr_gfx_rt>)
	!{sprite_!{sid}_n_ss_files} #= !{sprite_!{sid}_n_ss_files}+1
	!{sprite_!{sid}_ss_file_1} = <ssfile_2>
endmacro

macro alloc_sprite_spriteset_3(sprite_id, name, init_rt, main_rt, n_oam_tiles, ssfile_1, ssfile_2, ssfile_3, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, spr_pose_tbl, spr_gfx_rt)
	%alloc_sprite_spriteset_2(<sprite_id>, <name>, <init_rt>, <main_rt>, <n_oam_tiles>, <ssfile_1>, <ssfile_2>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>, <spr_pose_tbl>, <spr_gfx_rt>)
	!{sprite_!{sid}_n_ss_files} #= !{sprite_!{sid}_n_ss_files}+1
	!{sprite_!{sid}_ss_file_2} = <ssfile_3>
endmacro

macro alloc_sprite_spriteset_4(sprite_id, name, init_rt, main_rt, n_oam_tiles, ssfile_1, ssfile_2, ssfile_3, ssfile_4, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, spr_pose_tbl, spr_gfx_rt)
	%alloc_sprite_spriteset_3(<sprite_id>, <name>, <init_rt>, <main_rt>, <n_oam_tiles>, <ssfile_1>, <ssfile_2>, <ssfile_3>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>, <spr_pose_tbl>, <spr_gfx_rt>)
	!{sprite_!{sid}_n_ss_files} #= !{sprite_!{sid}_n_ss_files}+1
	!{sprite_!{sid}_ss_file_3} = <ssfile_4>
endmacro

macro alloc_sprite(sprite_id, name, init_rt, main_rt, n_oam_tiles, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, spr_pose_tbl, spr_gfx_rt)
	!sid #= <sprite_id>
	if defined("sprite_!{sid}_defined")
		error "Sprite id <sprite_id> already defined."
	endif
	if not(defined("sprite_!{sid}_n_ss_files"))
		!{sprite_!{sid}_n_ss_files} #= 0
	endif
	!{sprite_!{sid}_defined} = 1
	!{sprite_!{sid}_tag} = <name>
	!{sprite_!{sid}_init} = (<init_rt>)-1
	!{sprite_!{sid}_main} = (<main_rt>)-1
	!{sprite_!{sid}_sz}   #= 4
	!{sprite_!{sid}_oamtiles} = <n_oam_tiles>*4
	!{sprite_!{sid}_1656} = <spr_1656_val>
	!{sprite_!{sid}_1662} = <spr_1662_val>
	!{sprite_!{sid}_166E} = (<spr_166E_val>&$FE)
	!{sprite_!{sid}_167A} = <spr_167A_val>
	!{sprite_!{sid}_1686} = <spr_1686_val>
	!{sprite_!{sid}_190F} = <spr_190F_val>
	!{sprite_!{sid}_pose_tbl} = <spr_pose_tbl>
	!{sprite_!{sid}_gfxptr} = <spr_gfx_rt>-1
endmacro

macro alloc_sprite_dynamic_512k(sprite_id, gfx_name, init_rt, main_rt, n_oam_tiles, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val, free_tag)
	%alloc_sprite(<sprite_id>, <gfx_name>, <init_rt>, <main_rt>, <n_oam_tiles>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>, $0000)
	if not(defined("n_dyn_gfx"))
		!n_dyn_gfx #= 0
	endif
	if not(getfilestatus("dyn_gfx/<gfx_name>.bin"))
		error "No read access to file `<gfx_name>.bin', or file doesn't exist."
	else
		if !n_dyn_gfx > !dyn_gfx_files_max
			error "Too many dynamic gfx files. Allocate more space (define dyn_gfx_files_max)"
		else
			%set_free_start(<free_tag>)
			!dyn_spr_<gfx_name>_gfx_id #= !n_dyn_gfx
			dyn_gfx_<gfx_name>_dat:
			!{dyn_gfx_!{n_dyn_gfx}_dat} = dyn_gfx_<gfx_name>_dat
			incbin "../../../gfx/dyn/<gfx_name>.bin"
			dyn_gfx_<gfx_name>_dat_end:
			%set_free_finish(<free_tag>, dyn_gfx_<gfx_name>_dat_end)
			!n_dyn_gfx #= !n_dyn_gfx+1
		endif
	endif
endmacro

macro alloc_sprite_dynamic_free(sprite_id, gfx_name, init_rt, main_rt, n_oam_tiles, spr_1656_val, spr_1662_val, spr_166E_val, spr_167A_val, spr_1686_val, spr_190F_val)
	%alloc_sprite(<sprite_id>, <gfx_name>, <init_rt>, <main_rt>, <n_oam_tiles>, <spr_1656_val>, <spr_1662_val>, <spr_166E_val>, <spr_167A_val>, <spr_1686_val>, <spr_190F_val>, $0000)
	if not(defined("n_dyn_gfx"))
		!n_dyn_gfx #= 0
	endif
	if !n_dyn_gfx > !dyn_gfx_files_max
		error "Too many dynamic gfx files. Allocate more space (define dyn_gfx_files_max)"
	else
		!{dyn_gfx_!{n_dyn_gfx}_dat} = <gfx_name>_gfx
		!{dyn_gfx_!{n_dyn_gfx}_free} = 1
		!dyn_spr_<gfx_name>_gfx_id #= !n_dyn_gfx
		!n_dyn_gfx #= !n_dyn_gfx+1
	endif
endmacro
