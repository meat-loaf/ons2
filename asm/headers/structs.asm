includefrom "../main.asm"
includeonce

org $7E0200
struct oam_entry
	.x_pos: skip 1
	.y_pos: skip 1
	.tile:  skip 1
	.props: skip 1
endstruct align 4

org !turnblock_status
struct turnblock_status_d
	.x_pos: skip 2
	.y_pos: skip 2
	.timer: skip 2
endstruct align 6

org !skidsmoke_status
struct skidsmoke_status_d
	.x_pos: skip 2
	.y_pos: skip 2
	.timer: skip 2
endstruct align 6

org !oam_rts_highest_prio
struct oam_rt_d
	.ptr: skip 2
	.ptr_bank: skip 1
	.arg: skip 2
endstruct

org !rot_spr_gfx_arr
struct rot_spr_gfx_buff
	.ntiles: skip 1
	.end_ntiles: skip 1
	.tile_x_delta: skip 1
	.tile_y_delta: skip 1
	.tile_id: skip 1
	.tile_prop: skip 1
	.draw_end: skip 2
endstruct



;struct entity_pose_entry
;	.x_off: skip 1
;	.y_off: skip 1
;	.tile_props: skip 2
;	.next_ptr: skip 2
;endstruct
	

;oam_lo = oam_entry[$0000]
;oam_hi = oam_entry[$0100]

;!turnblocks = turnblock_status_d[!num_turnblock_slots]
