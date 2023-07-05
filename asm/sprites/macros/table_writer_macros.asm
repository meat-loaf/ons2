includefrom "macros.asm"

macro write_dynamic_spr_gfx_ptrs()
if defined("n_dyn_gfx")
  !have_dyn = 1
  org !spr_dyn_gfx_tbl
  print "Dynamic gfx pointers start at $", pc, " (max !dyn_gfx_files_max)"
  !ix #= 0
  while !ix < !n_dyn_gfx
  	!tbl_e_def = "dl"
  	if defined("dyn_gfx_!{ix}_free")
  		!tbl_e_def = "autoclean dl"
  	endif
  	!tbl_e_def !{dyn_gfx_!{ix}_dat}
  	!ix #= !ix+1
  endif
  print "Dynamic gfx pointers end at $", pc, " (total used: !ix)"
  undef "ix"
endif

endmacro

macro write_sprite_tables()

if defined("spr_dyn_gfx_tbl")
	%write_dynamic_spr_gfx_ptrs()
endif

if and(!sprites_have_exbytes, not(!sprites_use_exbytes))
	error "Sprites have extra bytes, but extra byte functionality is not enabled."
endif
org sprite_size_table_ptr
;if !sprites_have_exbytes
;	print "Sprites have extra bytes."
	; lm requirements
	dl sprite_size_table
	db $42
;else
;	; the code in the sprite loader isn't reliable to undo (because it needs to overwrite
;	; lm hijacks), so if the code gets written once, it stays.
;	!magic #= read1(!sprite_size_table_ptr+3)
;	if !magic == $42
;		print "No sprites have extra bytes, but they did previously. Overriding."
;		!sprites_have_exbytes = 1
;	else
;		print "No sprites have extra bytes."
;		; db $FF,$FF,$FF,$FF
;	endif
;	undef "magic"
;endif
	!ix #= 0
	while !ix < $100
	if defined("sprite_!{ix}_defined")
		if defined("sprite_!{ix}_oamtiles")
			org oam_tile_count+!ix
			db !{sprite_!{ix}_oamtiles}
		else
			error "Number of OAM tiles to allocate for sprite not defined."
		endif
		;if defined("sprite_!{ix}_sz")
			;assert !{sprite_!{ix}_sz} >= 3, "Sprite size for sprite id !ix is less than 3."
			org !{sprite_size_table}+($100*0)+(!ix*1)
			;db !{sprite_!{ix}_sz}
			db $04
			org !{sprite_size_table}+($100*1)+(!ix*1)
			;db !{sprite_!{ix}_sz}
			db $04
			org !{sprite_size_table}+($100*2)+(!ix*1)
			;db !{sprite_!{ix}_sz}
			db $04
			org !{sprite_size_table}+($100*3)+(!ix*1)
			;db !{sprite_!{ix}_sz}
			db $04
		;else
		;	error "Sprite size for sprite id !ix not defined."
		;endif
		if defined("sprite_!{ix}_init")
			autoclean (read1((!sprite_init_table_lo)+(!{ix})))|((read1((!sprite_init_table_hi)+(!{ix})))>>8)|((read1((!sprite_init_table_bk)+(!{ix})))>>16)

			org (!sprite_init_table_lo)+(!{ix})
			db !{sprite_!{ix}_init}
			org (!sprite_init_table_hi)+(!{ix})
			db (!{sprite_!{ix}_init})>>8
			org (!sprite_init_table_bk)+(!{ix})
			db (!{sprite_!{ix}_init})>>16
		else
			error "Init routine for sprite id !ix not defined."
		endif
		if defined("sprite_!{ix}_main")
			autoclean (read1((!sprite_main_table_lo)+(!{ix})))|((read1((!sprite_main_table_hi)+(!{ix})))>>8)|((read1((!sprite_main_table_bk)+(!{ix})))>>16)

			org (!sprite_main_table_lo)+(!{ix})
			db !{sprite_!{ix}_main}
			org (!sprite_main_table_hi)+(!{ix})
			db (!{sprite_!{ix}_main})>>8
			org (!sprite_main_table_bk)+(!{ix})
			db (!{sprite_!{ix}_main})>>16
		else
			error "Main routine for sprite id !ix not defined."
		endif

		org spr_tweaker_1656_tbl+(!ix)
		db !{sprite_!{ix}_1656}
		org spr_tweaker_1662_tbl+(!ix)
		db !{sprite_!{ix}_1662}
		org spr_tweaker_166E_tbl+(!ix)
		db !{sprite_!{ix}_166E}
		org spr_tweaker_167A_tbl+(!ix)
		db !{sprite_!{ix}_167A}
		org spr_tweaker_1686_tbl+(!ix)
		db !{sprite_!{ix}_1686}
		org spr_tweaker_190F_tbl+(!ix)
		db !{sprite_!{ix}_190F}
		!fmt = ""
		if !ix < 16
			!fmt = 0
		endif

		print "sprite $!fmt", hex(!ix), " [!{sprite_!{ix}_tag}]:"," init ptr-1 = $", hex(!{sprite_!{ix}_init}), ", main ptr-1 = $", hex(!{sprite_!{ix}_main})
		undef "fmt"
	else
;	  if !sprites_have_exbytes
	    if !ix < $fe
		org !{sprite_size_table}+($100*0)+(!ix*1)
		db $04
		org !{sprite_size_table}+($100*1)+(!ix*1)
		db $04
		org !{sprite_size_table}+($100*2)+(!ix*1)
		db $04
		org !{sprite_size_table}+($100*3)+(!ix*1)
		db $04
	    ; camera control / ambient spawner entires are 4 bytes
	    else
		org !{sprite_size_table}+($100*0)+(!ix*1)
		db $04
		org !{sprite_size_table}+($100*1)+(!ix*1)
		db $04
		org !{sprite_size_table}+($100*2)+(!ix*1)
		db $04
		org !{sprite_size_table}+($100*3)+(!ix*1)
		db $04
	    endif
;	  endif
		org oam_tile_count+!ix
			db $00
	endif

	!ix #= !ix+1
	endif
endmacro

macro write_ambient_tables(table_label, tsize_label, grv_tbl, default)
;	org <table_label>
	!ix #= 0
	while !ix < !ambient_sprid_max+1
		org <table_label>+(!{ix}*2)
		if defined("ambient_!{ix}_defined")
			dw !{ambient_!{ix}_main}
			org <tsize_label>+(!{ix}*2)
				dw !{ambient_!{ix}_tweaker}
			org <grv_tbl>+(!{ix}*2)
				dw (!{ambient_!{ix}_grav_accel})|(!{ambient_!{ix}_grav_tv}<<8)
			!fmt = ""
			if !ix < 16
				!fmt = 0
			endif
			print "ambient sprid $!fmt", hex(!ix), " [!{ambient_!{ix}_tag}] main: $", hex(!{ambient_!{ix}_main})
		else
			dw <default>
		endif
		!ix #= !ix+1
	endif
endmacro

macro write_spriteset_table(table_label)
;freedata
org <table_label>
	!ix #= 0
	while !ix < $100
		!jx #= 0
		while !jx < 4
			if defined("sprite_!{ix}_ss_file_!{jx}")
				!ireel #= !ix*4*2
				dw !{sprite_!{ix}_ss_file_!{jx}}
			else
				dw $8000
			endif
			!jx #= !jx+1
		endif
		!ix #= !ix+1
	endif
endmacro
