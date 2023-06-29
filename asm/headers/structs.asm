includefrom "../main.asm"
if not(defined("_ons_struct_h_"))
!_ons_struct_h_ ?= 1

;struct oam_entry $0200|!addr
;	.x_pos: skip 1
;	.y_pos: skip 1
;	.tile:  skip 1
;	.props: skip 1
;endstruct align 4

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

!oam_lo = oam_entry[$0000]
!oam_hi = oam_entry[$0100]

!turnblocks = turnblock_status_d[!num_turnblock_slots]
endif
