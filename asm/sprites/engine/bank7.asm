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
	lda.l spr_tweaker_166E_tbl,x
	and #$0f
	lsr
	sta !sprite_oam_properties,y
	lda #$c0
	sta !spr_spriteset_off,y
	bcs .exit

	lda.l !level_ss_sprite_offs,x
	cmp #$ff
	bne .have_set
	inc
	clc
.have_set:
	asl
	sta !spr_spriteset_off,y

	plx
	ply
	rol !sprite_oam_properties,x
.exit:
	rtl

!gfx_x_pos         = $00
!gfx_y_pos         = $02
!gfx_table_ptr     = $04
!gfx_tile_high     = $06
!x_flip            = $07
!n_tiles           = $08
!oam_off           = $09
!spr_props_flip    = $0a
!spr_props_no_flip = $0b
; two bytes
!gfx_tile_off      = $0c
; two bytes
!y_flip            = $0e

!tile_off          = $48
!tile_hitable      = $50
spr_gfx_abort:
	sep #$20
	rtl
; put pointer to graphics table in a
spr_gfx:
	sta !gfx_table_ptr
	xba
	sta !gfx_table_ptr+1

	ldy #$00
	lda !sprite_misc_157c,x
	bne .no_x_flip
	ldy #$40
.no_x_flip:
	sty $00

	stz !tile_off+1

	lda !spr_spriteset_off,x
	sta !gfx_tile_off

	lda !sprite_oam_properties,x
	tay
	and #$3F
	sta !spr_props_no_flip
	tya
	and #$C0
	eor $00
	ora $64
	sta !spr_props_flip

	and #$80
	sta !y_flip
	stz !y_flip+1

	ldy #$00
; getdrawinfo equivalent
	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$20
	sec
	sbc !layer_1_xpos_curr
	clc
	adc (!gfx_table_ptr),y
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
	clc
	adc (!gfx_table_ptr),y
	sta !gfx_y_pos
	sep #$20

	ldy #$04
	; y = start of structure (number of tiles to draw)
	lda (!gfx_table_ptr),y
	sta !n_tiles

	lda !sprite_oam_index,x
	tax
.loop:
	iny
	; y = start of data: tile size
	lda (!gfx_table_ptr),y
	sta !tile_hitable
	iny
	; y = tile offset from center
	lda (!gfx_table_ptr),y
	sta !tile_off

	iny
	lda #$40
	bit !spr_props_flip
	rep #$20
	; y = tile x offset
	lda (!gfx_table_ptr),y
	bvc .x_flip_no_inv
	eor #$ffff
	inc
.x_flip_no_inv:
	clc
	adc !gfx_x_pos
	sec
	sbc !tile_off

	cmp #$0100
	sta $0300|!addr,x
	; shift carry into x high position, then set it
	lda #$0000
	rol !tile_hitable

	iny
	iny
	lda !y_flip
	cmp #$0080
	; y = tile y offset
	lda (!gfx_table_ptr),y
	bcc .y_flip_no_inv
	eor #$ffff
	inc
.y_flip_no_inv:
	clc
	adc !gfx_y_pos
	sec
	sbc !tile_off

	; this seems to fix offscreen issues
	; but its too long ;3;
	;  shorten somehow...
	cmp #$FFF0
	bcs .y_onscr
	cmp #$00F0
	bcc .y_onscr
.y_offscr:
	lda #$00F0
.y_onscr:
	sta $0301|!addr,x
	sep #$20

	iny
	iny
	; y = low 8 bits of tile id
	lda (!gfx_table_ptr),y
	clc
	adc !gfx_tile_off
	sta $0302|!addr,x
	lda #$00
	rol
	; props high bit
	sta !gfx_tile_high

	iny
	; y = properties, right shifted with high bit as 'use prop ram table palette' flag
	lda (!gfx_table_ptr),y
	asl
	eor !spr_props_flip
	ora !gfx_tile_high
	bcs .no_ram_props
	ora !spr_props_no_flip
.no_ram_props:
	sta $0303|!addr,x

	txa
	lsr #2
	tax
	lda !tile_hitable
	sta $0460|!addr,x
	txa
	asl #2
	adc #$04
	tax
	
	dec !n_tiles
;	bmi .done
	beq .done
	jmp .loop
	;bne .loop
.done:

	ldx !current_sprite_process
	rtl
bank7_stuff_done:
%set_free_finish("bank7", bank7_stuff_done)
