includefrom "engine.asm"

; replace 'sprite in block' ids.
org $0288A3|!bank
; ?, mushroom, flower, star, feather, 1up
; there's more but this is all i used from the originals
db $00,$40,$42,$44,$41,$47
; table repeats at 88b4?
warnpc $0288C5|!bank

%set_free_start("bank2_altspr1")
ambient_sub_off_screen:
	stz $0e
	; clear x high bit in tilesz props
	lda !ambient_twk_tilesz,x
	and #$FFFE
	sta !ambient_twk_tilesz,x

	bit #!ambient_twk_check_offscr
	beq .ok
	lda !ambient_y_pos,x
	cmp !exlvl_screen_size
	bpl .erase
	sec
	sbc !layer_1_ypos_curr
	cmp !scr_max_y_off_sprspawn
	bpl .erase
	sec
	sbc !scr_min_y_off_sprspawn
	eor #$8000
	bpl .erase
.check_offscr_x:
	lda !layer_1_xpos_curr
	clc
	adc #$0130
	cmp !ambient_x_pos,x
	bcc .erase
	lda !layer_1_xpos_curr
	clc
	adc #$FFC0
	bmi .ok
	cmp !ambient_x_pos,x
	; TODO fix this, when all the way to the left, moving
	;      ambient sprites won't despawn when offscreen to the left
	bcs .erase
.ok:
	lda !ambient_x_pos,x
	sec
	sbc !layer_1_xpos_curr
	cmp #$0100
	bcc .do_store
	lsr !ambient_twk_tilesz,x
	sec
	rol !ambient_twk_tilesz,x
.do_store:
	sta $00
	lda !ambient_y_pos,x
	sec
	sbc !layer_1_ypos_curr
	cmp #$00F0
	bcc .yok
	lda #$00F0
.yok:
	sta $01
.next_oam_slot:
	ldy $0c
	lda .oam_offs,y
	sta $0c

	lda !next_oam_index
	cmp #$0100
	bcs .no_oam_left
	tay
	adc $0c
	sta !next_oam_index
	sty $0c
	rts
.erase:
	stz !ambient_rt_ptr,x
.no_oam_left:
	; immediately terminate the ambient sprite routine
	; by destroying this return val
	inc $0e
	pla
.exit:
	rts
.oam_offs:
	dw $0004
	dw $0008
	dw $000C
	dw $0010

; todo still needs a decent amount of work: tile-checking code
;      not really properly implemented
ambient_obj_interact:
	; todo layer 2 collision
;	ldy #$0000
;	lda !screen_mode-1
;	bmi .on_layer_1
;	ldy #$0048
;.on_layer_1:
;	; offset to screen data pointer table
;	; when interacting with layer 2
;	sty $0e
	lda !ambient_y_pos,x
	clc
	adc #$0008
	sta !block_ypos
	and #$FFF0
	cmp !exlvl_screen_size
	bcs .no_interact_p_ok
	sta $00
	lda !ambient_x_pos+1,x
	and #$00FF
	sta $02
	; note: no comparison to $5D, number of screens in level
	asl
	adc $02
	; y index = x pos high * 3
	tay
	; low/high bytes to map16 data for current screen
	; TODO LAYER 2 CHECK
	lda !lm_exlevel_per_scr_dat_ptrs_lo_l1,y
	;lda $0F
	;and #$00FF
	;bne .no_l2
	;lda !lm_exlevel_per_scr_dat_ptrs_lo_l2,y
;.no_l2:
	sta $05
	lda !ambient_x_pos,x
	clc
	adc #$0004
	sta !block_xpos
	and #$00F0
	lsr #4
	; y index = YYYYYYYYyyyyxxxx
	; this is the offset to the block in the current screen
	ora $00
	tay
	sep #$20

	lda #$7E
	sta $07
	lda [$05],y
	sta !block_interact_map16_id
	inc $07
	lda [$05],y
	sep #$10
	; gps uses this to restore the running entity index
	stx !current_sprite_process
	jsl lm_block_interact
	; following is mostly copied from lm's modified
	; extended block interact routine
	cmp #$00
	beq .no_interact
	lda !block_interact_map16_id
;	cmp #$00
	beq .solid_interact
	cmp #$11
	bcc .no_interact
	cmp #$6e
	bcc .solid_interact
	;
.solid_interact:
	rep #$30
	sec
	rts
.no_interact:
	rep #$30
..p_ok:
	clc
	rts

ambient_physics:
	lda !ambient_sprlocked_mirror
	bne ambient_sub_off_screen_exit
	sep #$30
	lda !ambient_x_speed+1,x
	beq .no_x_upd
	asl #4
	clc
	adc !ambient_x_speed,x
	sta !ambient_x_speed,x
	php
	ldy #$00
	lda.w !ambient_x_speed+1,x
	lsr
	lsr
	lsr
	lsr
	cmp.b #$08
	bcc .x_not_neg
	ora #$f0
	dey
.x_not_neg:
	plp
	adc !ambient_x_pos,x
	sta !ambient_x_pos,x
	tya
	adc !ambient_x_pos+1,x
	sta !ambient_x_pos+1,x
.no_x_upd:
	lda !ambient_y_speed+1,x
	beq .no_y_upd
	asl #4
	clc
	adc !ambient_y_speed,x
	sta !ambient_y_speed,x
	php
	ldy #$00
	lda.w !ambient_y_speed+1,x
	lsr
	lsr
	lsr
	lsr
	cmp.b #$08
	bcc .y_not_neg
	ora #$f0
	dey
.y_not_neg:
	plp
	adc !ambient_y_pos,x
	sta !ambient_y_pos,x
	tya
	adc !ambient_y_pos+1,x
	sta !ambient_y_pos+1,x
.no_y_upd:
	lda !ambient_twk_tilesz+1,x
	and.b #(!ambient_twk_has_grav>>8)
	beq .exit
	lda !ambient_y_speed+1,x
	cmp !ambient_grav_setting+1,x
	bpl .exit
	clc
	adc !ambient_grav_setting,x
	sta !ambient_y_speed+1,x
.exit:
	rep #$30
	rts

; set y to desired index. currently intended for use
; with the original 'check contact' routine
; note: returns in 8-bit axy
ambient_set_clipping_a_8a8i:
	lda !ambient_y_pos,x
	clc
	adc .yoffs,y
	sta $05
	; store high byte in 0b
	sta $0b-$1
	lda .width_height,y
	sta $06
	lda !ambient_x_pos,x
	clc
	adc .xoffs,y

	sep #$30
	sta $04
	xba
	sta $0a
	rts
.xoffs:
	dw $0003
.yoffs:
	dw $0003
.width_height:
	db $01, $01

; TODO spritesets
ambient_initer:
	lda !ambient_misc_1,x
	; id stored in high byte
	xba
	asl
	tay
	lda ambient_twk_tsz,y
	sta !ambient_twk_tilesz,x
	lda ambient_rts,y
	sta !ambient_rt_ptr,x
	lda ambient_grav_vals,y
	sta !ambient_grav_setting,x

	; execute the sprites code
	jmp (!ambient_rt_ptr,x)
ambient_twk_tsz:
	skip (!ambient_sprid_max+1)*2
ambient_rts:
	skip (!ambient_sprid_max+1)*2
ambient_grav_vals:
	skip (!ambient_sprid_max+1)*2
ambient_rts_done:
%set_free_finish("bank2_altspr1", ambient_rts_done)

%set_free_start("bank2_altspr2")
ambient_alloc_turnblock:
	phy
	txy
	ldx !turnblock_free_index
	lda turnblock_status_d.timer,x
	beq .slot_free
	lda turnblock_status_d.x_pos,x
	sta !block_xpos
	lda turnblock_status_d.y_pos,x
	sta !block_ypos
	; clean up if all the slots are full
	lda #$000C
	sta $9C
	jsl $00BEB0|!bank
	; bebo doesnt preserve y
	ldy !current_ambient_process
.slot_free:
	lda !ambient_x_pos,y
	sta turnblock_status_d.x_pos,x
	lda !ambient_y_pos,y
	sta turnblock_status_d.y_pos,x
	lda #$00FF
	sta turnblock_status_d.timer,x
	txa
	sec
	sbc #$0006
	bpl .next_slot_ok
	lda.w #(!num_turnblock_slots-1)*6
.next_slot_ok:
	sta !turnblock_free_index
	tyx
	ply
	rts

ambient_kill_on_timer:
	lda !ambient_gen_timer,x
	bne .ok
	stz !ambient_rt_ptr,x
	; destroy the return, exiting out of the sprite code entirely
	pla
.ok:
	rts
; basic 'check despawn and draw single tile' ambient gfx routine.
ambient_basic_gfx:
	stz $0c
.oam_tiles_set:
	jsr ambient_sub_off_screen
	lda !sprite_level_props-1
	and #$FF00
	sta $02
	; todo put spriteset offset in high nybble of low byte
	;lda !ambient_twk_tilesz,x
	;and #$00F0
	;xba
	;sta $02

	lda $00
	sta $0200|!addr,y
	lda !ambient_props,x
	ora $02
	sta $0202|!addr,y
.smallstore:
	tya
	lsr #2
	tay

	sep #$20
	lda !ambient_twk_tilesz,x
	and #$03
	sta $0420|!addr,y
	rep #$20
	rts

; a gets tile number to write, use 98-9B for tile nums; ensure low nybbles are clear
; clobbers y
ambient_write_map16:
	sta $45
;	lda $98
	ldx $9b+1
	and #$00FF
	sta $05
	lda $9a
	and #$00FF
	ora $98
	tay
	lda !lm_exlevel_per_scr_dat_ptrs_lo_l1,y
	sta $05
	sep #$20
	lda #$7e
	sta $07
	lda $45
	sta [$05],y
	inc $07
	lda $46
	sta [$05],y
	sep #$20
; TODO write to dynamic stripe image ram to perform vram upload
	rts

spr_give_points_y:
	phy
	phx
	tyx
	jsl spr_give_points
	plx
	ply
	rtl

spr_give_points:
	clc
	; todo defines
	adc #(($13-$1)+$5)
	tay
	lda !sprite_x_low,x
	sta !ambient_get_slot_xpos
	lda !sprite_x_high,x
	sta !ambient_get_slot_xpos+1
	lda !sprite_y_low,x
	sta !ambient_get_slot_ypos
	lda !sprite_y_high,x
	sta !ambient_get_slot_ypos+1
	lda #$30
	sta !ambient_get_slot_timer
	stz !ambient_get_slot_xspd
	stz !ambient_get_slot_yspd
	tya
; fallthrough

; input: a = ambient sprite id to spawn
;        $45 = ambient sprite xpos
;        $47 = ambient sprite ypos
;        $49 = ambient timer val
;        $4B = x speed - if it doesn't use physics it is never applied
;        $4C = y speed - if it doesn't use physics it is never applied
; output:
;       carry set: failure, clear: success
;       y: ambient slot index
ambient_get_slot:
;	sty $4d
	rep #$30
	and #$00FF
	xba
	pha
	ldy.w !ambient_spr_ring_ix
	lda.w #$0000
.loop:
	sta $0E
	lda !ambient_rt_ptr,y
	beq .found
	dey : dey
	bpl .y_ok
	ldy.w #(!num_ambient_sprs*2)-2
.y_ok:
	lda $0E
	inc
	cmp !num_ambient_sprs-1
	bne .loop
	
	; tidy the stack
	pla
	sep #$30
	sec
	rtl
.found:
	tya
	sec
	sbc #$0002
	bpl .no_ring_ix_adj
	lda.w #(!num_ambient_sprs*2)-2
.no_ring_ix_adj:
	sta !ambient_spr_ring_ix
	pla
	; note: ambinet id stored in high byte
	; low byte for common use as e.g. phase pointer
	sta !ambient_misc_1,y
	lda #ambient_initer
	sta !ambient_rt_ptr,y
	
	lda !ambient_get_slot_xpos
	sta !ambient_x_pos,y
	lda !ambient_get_slot_ypos
	sta !ambient_y_pos,y
	lda !ambient_get_slot_timer
	; todo fix call sites to zero top byte if applicable
	and #$00FF
	sta !ambient_gen_timer,y
	sep #$30

	lda #$00
	sta !ambient_x_speed,y
	sta !ambient_y_speed,y
	lda !ambient_get_slot_xspd
	sta !ambient_x_speed+1,y
	lda !ambient_get_slot_yspd
	sta !ambient_y_speed+1,y
	clc
;	ldy $4d
	rtl
.done
%set_free_finish("bank2_altspr2", ambient_get_slot_done)
