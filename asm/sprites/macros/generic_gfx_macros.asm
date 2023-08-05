includefrom "macros.asm"

; 4 bytes - scratch
!gen_gfx_tile_offs          = $4B
macro sprite_pose_pack_offs(hsize, vsize)
	lda.w #(<hsize>/2)
	sta !gen_gfx_tile_offs+0
if <hsize> != <vsize>
	lda.w #(<vsize>/2)
endif
	sta !gen_gfx_tile_offs+2
endmacro

macro start_sprite_pose_entry_list(name)
	if defined("sprite_pose_entry_list_name")
		error "use 'finish_sprite_pose_entry_list' macro before starting another. Currently defined as `!sprite_pose_entry_list_name'"
	endif
	!sprite_pose_entry_list_name = <name>
	!n_poses #= 0
endmacro

macro start_sprite_pose_entry(name, hoff, voff)
	if defined("sprite_pose_entry_name_!{n_poses}")
		error "use 'finish_sprite_pose_entry' macro before starting another. Currently defined as: `!{sprite_pose_entry_name_!{n_poses}}'"
	endif

	!{sprite_pose_entry_name_!{n_poses}} = <name>
	!n_tiles #= 0
<name>:
.hsz:
	db <hoff>/2
.vsz:
	db <voff>/2
.start:
	skip 2
endmacro

macro sprite_pose_entry_mirror(name)
	!{sprite_pose_entry_name_!{n_poses}} = <name>
	!n_poses #= !n_poses+1
endmacro

!gen_gfx_tile_tblsz = 14
macro sprite_pose_tile_entry(xoff, yoff, tile, props, size, use_mem_props)

if !{n_tiles} != 0
pushpc
!p #= !{n_tiles}-1
org .tile_!{p}_next
	dw .tile_!{n_tiles}
undef "p"
pullpc
endif

!use_props = 0
if <use_mem_props> == 1
	!use_props = 1
endif

if not(or(equal(<size>,2), equal(<size>, 0)))
	error "sprite_table_entry: size may only be 2 (big) or 0 (small). Is <size>."
endif
if <size> == 2
	!off = $08
else
	!off = $04
endif

if <yoff>&$80 != 0
	!yoff #= <yoff>|($FF00)
else
	!yoff #= <yoff>|($0000)
endif

if <xoff>&$80 != 0
	!xoff #= <xoff>|($FF00)
else
	!xoff #= <xoff>|($0000)
endif

.tile_!{n_tiles}:
..tilesz:
	; high bit shifted in via rol
	db (<size>)>>1
..tile_center_off:
	db !off
..y_off:
	dw !yoff
...inv:
	dw invert(!yoff)
..x_off:
	dw !xoff
...inv:
	dw invert(!xoff)
..tile:
	db (<tile>)
..props:
	db (<props>)|(!use_props)
..next:
	skip 2
undef "use_props"
if !n_tiles == 0
pushpc
org .start
	dw .tile_!{n_tiles}
pullpc
endif
!n_tiles #= !n_tiles+1
endmacro

macro sprite_pose_tile_entry_withnext(xoff, yoff, tile, props, size, use_mem_props, next_tile)
	%sprite_pose_tile_entry(<xoff>, <yoff>, <tile>, <props>, <size>, <use_mem_props>)
	; sprite_pose_tile_entry adds 1 to n_tiles as part of finalization
	!p #= !n_tiles-1
	pushpc
	org .tile_!{p}_next
		dw <next_tile>
	pullpc
	undef "p"
	; todo we really should have a way to enforce that no poses are defined after this
	;      but whatever i guess
endmacro

macro finish_sprite_pose_entry()
	if equal(!n_tiles, 0)
	error "Sprite table !sprite_pose_entry_name_!{n_poses} has no poses defined. Use the 'sprite_pose_entry' macro."
endif
	!p #= !{n_tiles}-1
; finish off the last table with nullptr
	pushpc
	org .tile_!{p}_next
		dw $0000
	pullpc

	!n_poses #= !n_poses+1

	undef "n_tiles"
endmacro

macro finish_sprite_pose_entry_list()
if !n_poses != 1
	!p #= 0
	!{sprite_pose_entry_list_name}_pose_ptrs_lo:
		skip !n_poses
	!{sprite_pose_entry_list_name}_pose_ptrs_hi:
		skip !n_poses
pushpc
	while !p < !n_poses
	;	dw !{sprite_pose_entry_name_!{p}}
		org !{sprite_pose_entry_list_name}_pose_ptrs_lo+!{p}
			db !{sprite_pose_entry_name_!{p}}
		org !{sprite_pose_entry_list_name}_pose_ptrs_hi+!{p}
			db (!{sprite_pose_entry_name_!{p}})>>8
		undef "sprite_pose_entry_name_!{p}"
		!p #= !p+1
	endif
pullpc
else
	undef "sprite_pose_entry_name_0"
endif

undef "n_poses"
undef "sprite_pose_entry_list_name"
endmacro

;; old (todo deprecated) ;;

macro start_sprite_table(name, hsize, vsize)
	if defined("start_sprite_table")
		error("use 'finish_sprite_table' macro before starting another. Currently defined as !start_sprite_table")
	endif
	!start_sprite_table = <name>
	!n_poses #= 0
<name>:
.x_size:
	dw <hsize>/2
.y_size:
	dw <vsize>/2
.n_tiles:
	skip 1
endmacro

macro sprite_table_entry(xoff, yoff, tile, props, size, use_mem_props)

!use_props = 0
if <use_mem_props> == 1
	!use_props = 1
endif

if not(or(equal(<size>,2), equal(<size>, 0)))
	error "sprite_table_entry: size may only be 2 (big) or 0 (small). Is <size>."
endif
if <size> == 2
	!off = $08
else
	!off = $04
endif

.pose_!{n_poses}:
..tilesz:
	; high bit shifted in via rol
	db (<size>)>>1
..tile_center_off:
	db !off
..x_off:
	db <xoff>
	; handle sign because asar doesnt sign extend i guess
	if (<xoff>&$80)
		db $FF
	else
		db $00
	endif
..y_off:
	db <yoff>
	if (<yoff>&$80)
		db $FF
	else
		db $00
	endif

..tile:
	db <tile>
..props:
	db ((<props>)>>1)|(!use_props<<8)
!n_poses #= !n_poses+1
undef "use_props"
undef "off"
endmacro

macro finish_sprite_table()
if equal(!n_poses, 0)
	error "Sprite table !sprite_table_name has no poses defined. Use the 'sprite_table_entry' macro."
endif
; finish off the last table with nullptr
	pushpc
	org !{start_sprite_table}_n_tiles
		db !n_poses
	pullpc
	undef "start_sprite_table"
	undef "n_poses"
endmacro

; todo deprecated, remove all below
macro dynamic_gfx_rt_bank3(load_frame_code, dyn_name)
	<load_frame_code>
	sta !spr_dyn_alloc_slot_arg_frame_num
	if !{dyn_spr_<dyn_name>_gfx_id} == 0
	    stz !spr_dyn_alloc_slot_arg_gfx_id
	else
	    lda #!{dyn_spr_<dyn_name>_gfx_id}
	    sta !spr_dyn_alloc_slot_arg_gfx_id
	endif
	jsr.w spr_dyn_gfx_rt
endmacro

; original shared sprite routine - table allocation macros
macro __alloc_sprite_sharedgfx_begin(sprite_id)
	if not(defined("sharedgfx_tilemap_currentoff"))
		!sharedgfx_tilemap_currentoff #= 0
	endif
	assert !sharedgfx_tilemap_currentoff <= $F8, "Maximum number of sharedgfx routine tiles allocated."
	assert <sprite_id> < $54, "Only sprites with ids less than $54 can use original shared gfx routines (requested <sprite_id>)."
	; set offset
	org sprite_tilemap_offsets+<sprite_id>|!bank
		db !sharedgfx_tilemap_currentoff
	!id_f #= <sprite_id>
	!{sharedgfx_tilemap_off_sprite_!{id_f}} #= !sharedgfx_tilemap_currentoff
	undef "id_f"
endmacro

macro alloc_sprite_sharedgfx_entry_1(sprite_id, frame_1)
	%__alloc_sprite_sharedgfx_begin(<sprite_id>)
	org sprite_tilemaps+!sharedgfx_tilemap_currentoff
		db <frame_1>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_2(sprite_id, frame_1, frame_2)
	%alloc_sprite_sharedgfx_entry_1(<sprite_id>,<frame_1>)
		db <frame_2>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_3(sprite_id, frame_1, frame_2, frame_3)
	%alloc_sprite_sharedgfx_entry_2(<sprite_id>,<frame_1>,<frame_2>)
		db <frame_3>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_4(sprite_id, frame_1, frame_2, frame_3, frame_4)
	%alloc_sprite_sharedgfx_entry_3(<sprite_id>,<frame_1>,<frame_2>,<frame_3>)
		db <frame_4>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_5(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5)
	%alloc_sprite_sharedgfx_entry_4(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>)
		db <frame_5>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_6(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5,frame_6)
	%alloc_sprite_sharedgfx_entry_5(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>,<frame_5>)
		db <frame_6>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_7(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5,frame_6,frame_7)
	%alloc_sprite_sharedgfx_entry_6(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>,<frame_5>,<frame_6>)
		db <frame_7>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_8(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5,frame_6,frame_7,frame_8)
	%alloc_sprite_sharedgfx_entry_7(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>,<frame_5>,<frame_6>,<frame_7>)
		db <frame_8>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_9(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5,frame_6,frame_7,frame_8,frame_9)
	%alloc_sprite_sharedgfx_entry_8(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>,<frame_5>,<frame_6>,<frame_7>,<frame_8>)
		db <frame_9>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_10(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5,frame_6,frame_7,frame_8,frame_9,frame_10)
	%alloc_sprite_sharedgfx_entry_9(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>,<frame_5>,<frame_6>,<frame_7>,<frame_8>,<frame_9>)
		db <frame_10>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_11(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5,frame_6,frame_7,frame_8,frame_9,frame_10,frame_11)
	%alloc_sprite_sharedgfx_entry_10(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>,<frame_5>,<frame_6>,<frame_7>,<frame_8>,<frame_9>,<frame_10>)
		db <frame_11>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro
macro alloc_sprite_sharedgfx_entry_12(sprite_id, frame_1, frame_2, frame_3, frame_4, frame_5,frame_6,frame_7,frame_8,frame_9,frame_10,frame_11,frame_12)
	%alloc_sprite_sharedgfx_entry_11(<sprite_id>,<frame_1>,<frame_2>,<frame_3>,<frame_4>,<frame_5>,<frame_6>,<frame_7>,<frame_8>,<frame_9>,<frame_10>,<frame_11>)
		db <frame_12>
	!sharedgfx_tilemap_currentoff #= !sharedgfx_tilemap_currentoff+1
endmacro

macro alloc_sprite_sharedgfx_entry_mirror(sprite_id, id_to_mirror)
	!id_f #= <id_to_mirror>
	assert defined("sharedgfx_tilemap_off_sprite_!{id_f}"), "Shared sprite gfx entry for sprite id <id_to_mirror> cannot be mirrored: has not been allocated yet!"
	org sprite_tilemap_offsets+<sprite_id>|!bank
		db !{sharedgfx_tilemap_off_sprite_!{id_f}}
	undef "id_f"
endmacro
