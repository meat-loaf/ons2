if !sprites_use_exbytes

load_next_sprite       = $02A82E|!bank
load_normal_sprite     = $02A8DD|!bank
load_normal_sprite_fin = $02A9C9|!bank

; y here 'points' to the current sprite's x position value, so must be
; incremented once to get to that sprite's id in the case of normal,
; 3-byte sprites, as required
org $02A846|!bank
	jml sprite_loader_prep_for_next_sprite

; completely skip loading any other sprite type.
; this frees up indices C9-FF for normal sprites,
; at the expense of everything else (not much of a loss)
; TODO figure out what to do for shooters (probably part of ambient sprite
;      rework) and enable loading said ambient sprites directly
org $02A866|!bank
spr_type_hack:
; TODO need to figure out new lm code for getting sprite positions
;     i think we just need to account for the 'ff' command offset if we
;     have new-style level data
	cmp #$fe
	bcc .not_control
	jml load_control_spr
.not_control:
	jmp.w load_normal_sprite
warnpc load_normal_sprite

; here y = sprite id
; this skips the koopa shell finangling, special world koopa
; color changes, and sprites turning into moving coins if the
; silver p-switch is active.
org $02A978|!bank
load_new_sprite_dat:
	lda $02
	sta !sprite_load_index,x

	phy
	iny
	lda [!level_sprite_data_ptr],y
	sta !spr_extra_byte_1,x
	; go to spr y pos: get extra bits
	dey #3
	lda [!level_sprite_data_ptr],y
	and #$0C
	lsr #2
	sta !spr_extra_bits,x
	lda $05
	sta !sprite_num,x
	ply
	bra load_normal_sprite_fin
warnpc load_normal_sprite_fin

; y here points to the current loading sprite's id, as required
org $02A9D7|!bank
	; restore 'sprite index in level' count
	ldx $02
autoclean \
	jml sprite_loader_prep_for_next_sprite_no_y_adj

freecode
; a = sprite id
; y = index to sprite x position
load_control_spr:
	cmp #$ff
	beq .camera
	; todo: ambient spawner
	bra sprite_loader_prep_for_next_sprite
.camera:
	; always initialize camera script when in-range
	stz !sprite_load_table,x
	; TODO handle new level sizes (y pos changes specifically, when relevant)
	dey
	lda [!level_sprite_data_ptr],y
	and #$F0
	sta !camera_control_y_pos
	lda [!level_sprite_data_ptr],y
	and #$01
	sta !camera_control_y_pos+1

	iny
	lda [!level_sprite_data_ptr],y
	and #$F0
	sta !camera_control_x_pos
	lda [!level_sprite_data_ptr],y
	and #$0F
	sta !camera_control_x_pos+1
	iny
	; don't care about id
	iny
	; CAMERA SPRITES ARE ALWAYS 4 BYTES
	lda [!level_sprite_data_ptr],y
	;asl
	cmp !camera_control_resident
	beq ..ok
	sta !camera_control_resident
	stz !camera_state
..ok:
	dey
	bra sprite_loader_prep_for_next_sprite_no_y_adj

; y should be just before sprite id here
sprite_loader_prep_for_next_sprite:
	iny
; y should be at sprite id here
.no_y_adj:
	tya
	clc
	adc #$02
	bpl .no_update_spr_data_ptr
	clc
	adc !level_sprite_data_ptr
	sta !level_sprite_data_ptr
	
	lda #$00
	bcc .no_update_spr_data_ptr
	inc !level_sprite_data_ptr+1
.no_update_spr_data_ptr:
	tay
	inx
	jml load_next_sprite

endif
