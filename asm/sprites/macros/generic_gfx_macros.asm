includefrom "macros.asm"


macro start_sprite_table(name, hsize, vsize)
	if defined("start_sprite_table")
		error("use 'finish_sprite_table' macro before starting another. Currently defined as !start_sprite_table")
	endif
	!start_sprite_table = <name>
	!n_poses #= 0
<name>:
	dw (<hsize>)/2
	dw (~<hsize>+1)/2
	dw (<vsize>)/2
	dw (~<vsize>+1)/2
	dw .pose_0
endmacro

macro sprite_table_entry(xoff, yoff, tile, props, use_mem_props)
!last_pose #= !n_poses-1
if and(not(equal(!{n_poses}, 0)), not(defined("pose_!{last_pose}_manual_next")))
org .pose_!{last_pose}_next_ptr
	dw .pose_!{n_poses}
else
	if defined("pose_!{last_pose}_manual_next")
		error "A manual pose definition should be the last in a chain."
	endif
endif

!use_props = 0
if <use_mem_props> == 1
	!use_props = 1
endif
.pose_!{n_poses}:
	dw <xoff>
..y_pos:
	dw <yoff>
..tile:
	db <tile>
..props:
	db (<props>>>1)|(!use_props<<8)
..next_ptr:
	skip 2
!n_poses #= !n_poses+1
undef "use_props"
endmacro

macro sprite_table_entry_manual(xoff, yoff, tile, props, use_mem_props, next_pose)
	%sprite_table_entry(<xoff>,<yoff>,<tile>,<props>,<use_mem_props>)
org .pose_!{last_pose}_next_ptr
	dw <next_pose>
	!pose_!{last_pose}_manual_next = 1
endmacro

macro finish_sprite_table()
if equal(!n_poses, 0)
	error "Sprite table !sprite_table_name has no poses defined. Use the 'sprite_table_entry' macro."
endif
; finish off the last table with nullptr
!last_pose #= !n_poses-1
org .pose_!{last_pose}_next_ptr
	dw $0000
	undef "start_sprite_table"
	undef "n_poses"
	if defined("pose_!{last_pose}_manual_next")
		undef "pose_!{last_pose}_manual_next"
	endif
	undef "last_pose"
endmacro


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
