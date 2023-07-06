includeonce

; todo
;  * make tweaker tables relocatable, we support > c8 sprites
;  * move spriteset changes here? it modifies
;      the load sprite tables routine
; * do something about the goal tape junk here, move it? move all the 
;   goal tape code here?

%set_free_start("bank7")
spr_tweaker_1656_tbl:
	skip $100
spr_tweaker_1662_tbl:
	skip $100
spr_tweaker_166E_tbl:
	skip $100
spr_tweaker_167A_tbl:
	skip $100
spr_tweaker_1686_tbl:
	skip $100
spr_tweaker_190F_tbl:
	skip $100

zero_sprite_tables:
	stz.w !sprite_in_water,x
	stz.w !sprite_behind_scenery,x
	stz.b !sprite_misc_c2,x
	stz.w !sprite_misc_151c,x
	stz.w !sprite_misc_1528,x
	stz.w !sprite_misc_1534,x
	stz.w !sprite_misc_157c,x
	stz.w !sprite_blocked_status,x
	stz.w !sprite_off_screen,x
	stz.w !sprite_misc_1602,x
	stz.w !sprite_misc_1540,x
	stz.w !sprite_misc_154c,x
	stz.w !sprite_misc_1558,x
	stz.w !sprite_misc_1564,x
	stz.w !sprite_cape_disable_time,x
	stz.w !sprite_misc_1626,x
	stz.w !sprite_misc_1570,x
	stz.b !sprite_speed_x,x
	stz.w !sprite_pos_x_frac,x
	stz.b !sprite_speed_y,x
	stz.w !sprite_obj_interact,x
	stz.w !sprite_pos_y_frac,x
	stz.w !sprite_being_eaten,x
	stz.w !sprite_misc_163e,x
	stz.w !sprite_misc_187b,x
	stz.w !sprite_misc_160e,x
	stz.w !sprite_misc_1594,x
	stz.w !sprite_misc_1504,x
	stz.w !sprite_misc_1fd6,x
	stz.w !spr_spriteset_off,x
	stz.w !spr_spriteset_off_hi,x
	;stz.w !spr_extra_bits,x
	;stz.w !spr_extra_byte_1,x
	lda.b #$01
	sta.w !sprite_off_screen_horz,x
	rtl

init_sprite_tables:
	jsl zero_sprite_tables
	; fallthrough
load_sprite_tables:
	phy
	phx
	lda !sprite_num,x
	txy
	tax
	lda.l spr_tweaker_1656_tbl,x
	sta !sprite_tweaker_1656,y
	lda.l spr_tweaker_1662_tbl,x
	sta !sprite_tweaker_1662,y
	lda.l spr_tweaker_166E_tbl,x
	sta !sprite_tweaker_166e,y
	lda.l spr_tweaker_167A_tbl,x
	sta !sprite_tweaker_167a,y
	lda.l spr_tweaker_1686_tbl,x
	sta !sprite_tweaker_1686,y
	lda.l spr_tweaker_190F_tbl,x
	sta !sprite_tweaker_190f,y
	lda.l !level_ss_sprite_offs,x
	cmp #$ff
	bne .have_set
	lda #$00
	clc
.have_set:
	asl
	sta !spr_spriteset_off,y

	lda.l spr_tweaker_166E_tbl,x
	and #$0F
	sta !sprite_oam_properties,y

	plx
	ply
	rol !spr_spriteset_off_hi,x
.exit:
	rtl

!gfx_x_pos         = $00
!gfx_y_pos         = $01

!tile_hitable      = $02
!tile_off          = $03
; two bytes
!gfx_table_ptr     = $04
!y_flip            = $06
!x_flip            = $07
!n_tiles           = $08
!oam_off           = $09
!spr_props_flip    = $0a
!spr_props_no_flip = $0b
; two bytes
!gfx_tile_off      = $0c
!gfx_tile_res      = $0e

!tile_x_scr        = $50
!tile_y_scr        = $51
spr_gfx_abort:
	sep #$20
	rtl
; put pointer to graphics table in a
spr_gfx:
	sta !gfx_table_ptr
	xba
	sta !gfx_table_ptr+1

	lda !spr_spriteset_off,x
	sta !gfx_tile_off
	lda !spr_spriteset_off_hi,x
	sta !gfx_tile_off+1

	lda !sprite_oam_index,x
	sta !oam_off

	lda !sprite_oam_properties,x
	tay
	; TODO can probably eliminate this table entirely by
	;      just putting it in the props table on sprite load.
	;      re-use this bit as 'is dynamic' maybe?
	and #$3E
	ora !spr_spriteset_off_hi,x
	sta !spr_props_no_flip
	tya
	and #$C0
	sta !spr_props_flip

	bit #$80
	ldy #$00
	beq .no_y_flip
	dey
.no_y_flip:
	sty !y_flip

	ldy #$00
	bit #$40
	beq .no_x_flip
	dey
.no_x_flip:
	sty !x_flip

	ldy #$00
; getdrawinfo equivalent
	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$20
	sec
	sbc !layer_1_xpos_curr
	sbc (!gfx_table_ptr),y
	sta !gfx_x_pos
	; stolen from original suboffscreen...
	; not much of a better way to do it i don't think
	; since we still need to pack 8-bit tables. we need
	; to drop to 8-bit a for y calcs anyway

	ldy #$02
	clc
	adc #$0040
	cmp #$0180
	sep #$20
	lda #$00
	rol
	sta !sprite_off_screen_horz,x
	bne .abort

	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	rep #$20
	sec
	sbc !layer_1_ypos_curr
	sbc (!gfx_table_ptr),y
	cmp #$00f0
	sep #$20
	bcc .y_pos_ok
	lda #$f0
.y_pos_ok:
	sta !gfx_y_pos

; todo might be worth unpacking these. investigate
	ldy #$04
	; y = start of structure (number of tiles to draw)
	lda (!gfx_table_ptr),y
	sta !n_tiles
.loop:
	iny
	; y = start of pose, packed tile size/tile offset to center
	lda (!gfx_table_ptr),y
	tax
	and #$F0
	beq .tile_size_store
	lda #$02
.tile_size_store:
	sta !tile_hitable
	txa
	and #$0F
	eor #$ff
	inc
	sta !tile_off

	iny
	; y = tile x offset
	lda (!gfx_table_ptr),y
	ldx !x_flip
	beq .x_flip_no_inv
	eor #$ff
	inc
.x_flip_no_inv:
	clc
	adc $00
	adc !tile_off

	ldx !oam_off
	sta $0300|!addr,x
	; shift carry into x high position, then set it
	lda #$00
	asl
	tsb !tile_hitable

	iny
	; y = tile y offset
	lda (!gfx_table_ptr),y
	ldx !y_flip
	beq .y_flip_no_inv
	eor #$ff
	inc
.y_flip_no_inv:
	clc
	adc $01
	adc !tile_off
	ldx !oam_off
	sta $0301|!addr,x

	iny
	; y = low 8 bits of tile id
	lda (!gfx_table_ptr),y
	clc
	adc !gfx_tile_off
	sta $0302|!addr,x
	lda #$00
	asl
	; props high bit
	sta !gfx_tile_res+1

	iny
	; y = properties, right shifted with high bit as 'use prop ram table palette' flag
	lda (!gfx_table_ptr),y
	asl
	ora $64
	eor !spr_props_flip
	ora !gfx_tile_res+1
	bcs .no_oam_props
	ora !spr_props_no_flip
.no_oam_props:
	sta $0303|!addr,x

	txa
	lsr #2
	tax
	lda !tile_hitable
	sta $0460|!addr,x
	txa
	asl #2
	clc
	adc #$04
	tax
	stx !oam_off
	
	dec !n_tiles
	bne .loop

	ldx !current_sprite_process
	rtl
bank7_stuff_done:
%set_free_finish("bank7", bank7_stuff_done)
