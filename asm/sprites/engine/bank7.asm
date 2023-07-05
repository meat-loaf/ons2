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

; input:
; $04 pointer to 'head' tile data structure
; $06 yx flip (------yx)
!gfx_x_pos     = $00
!gfx_y_pos     = $02
!gfx_table_ptr = $04
!yx_flip_inp   = $06
!props         = $08
!xy_pos        = $0a
; 0c gets corrupted on y-pos store
!oam_off       = $0d
!x_flip        = $0e
!y_flip        = $0f

!gfx_tile_off  = $47
!gfx_tile_res  = $49
!x_high_tilesz = $4B
!spr_props_tbl = $4D
spr_gfx_abort:
	sep #$20
	rtl
spr_gfx:
	; memoize a bunch of shit
	lda !spr_spriteset_off,x
	sta !gfx_tile_off
	lda !spr_spriteset_off_hi,x
	sta !gfx_tile_off+1

	lda !sprite_oam_properties,x
	; TODO make this not necessary
	and #$FE
	sta !spr_props_tbl+1
	stz !spr_props_tbl

	lda !sprite_oam_index,x
	sta !oam_off

	lda $64
	sta !props+1
	stz !props+1

	rep #$20
	ldy #$00
	lda (!gfx_table_ptr),y
	ldy !x_flip
	beq .no_inv_x_base
	eor #$ffff
	inc
.no_inv_x_base:
	sta $00
	ldy #$04
	lda (!gfx_table_ptr),y
	ldy !y_flip
	beq .no_inv_y_base
	eor #$ffff
	inc
.no_inv_y_base:
	sta $02
	sep #$20

	ldy #$00
; getdrawinfo equivalent
	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$20
	sec
	sbc !layer_1_xpos_curr
;	adc $00
	adc (!gfx_table_ptr),y
	sta $00
	; stolen from original suboffscreen...
	; not much of a better way to do it i don't think
	; since we still need to pack 8-bit tables. we need
	; to drop to 8-bit a for y calcs anyway

	clc
	adc #$0040
	cmp #$0180
	sep #$20
	lda #$00
	rol
	;sta !sprite_off_screen,x
	sta !sprite_off_screen_horz,x
	bne .abort

	ldy #$04
	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	rep #$20
	sec
	sbc !layer_1_ypos_curr
;	sbc $02
	
	sbc (!gfx_table_ptr),y
	cmp #$00f0
	bcc .y_pos_ok
	lda #$00f0
.y_pos_ok:
	sta $02
	ldy #$08
	lda (!gfx_table_ptr),y
	sta !gfx_table_ptr

.loop:
	ldy #$00
	lda (!gfx_table_ptr),y
	; todo handle flip
	clc
	adc !gfx_x_pos
	sta !xy_pos
	and #$FF00
	beq .no_x_high
	lda #$0001
.no_x_high:
	; TODO FIX, SUPPORT 8x8s
	ora #$0002
	sta !x_high_tilesz
	ldy #$02
	lda (!gfx_table_ptr),y

	; todo handle flip
	clc
	adc !gfx_y_pos
	sta !xy_pos+1
	ldy #$04
	lda (!gfx_table_ptr),y
	and #$00FF
	clc
	adc !gfx_tile_off
	sta !gfx_tile_res

	lda (!gfx_table_ptr),y
	and #$FF00
	; high bit is 'use props' flag
	asl
	and #$CE00
	bcs ..nopal
	ora !spr_props_tbl
..nopal:
	ora !props
	ora !gfx_tile_res

	ldx !oam_off
	sta $0302|!addr,x
	lda !xy_pos
	sta $0300|!addr,x
	; todo use a lut maybe? doing it manually is already going to be much better than finishoamwrite
	;      a large lookup table with long-addressing is one cycle faster than calculation, is it worth
	;      the size? With enough tiles drawn via this method it almost adds up to a scanline...
	txa
	lsr
	lsr
	tax
	lda !x_high_tilesz
	;sta $0420|!addr,x
	; note could overwrite size of next tile, fix
	sta $0460|!addr,x
	ldx !oam_off
	inx #4
	stx !oam_off
	
	ldy #$06
	lda (!gfx_table_ptr),y
	sta !gfx_table_ptr
	bne .loop

	sep #$20
	ldx !current_sprite_process
.done
	rtl
bank7_stuff_done:
%set_free_finish("bank7", bank7_stuff_done)
