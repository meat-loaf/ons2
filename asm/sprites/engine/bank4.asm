%set_free_start("bank4")
sub_horz_pos:
	ldy #$00
	lda !player_x_next
	sec
	sbc !sprite_x_low,x
	sta $0E
	lda !player_x_next+1
	sbc !sprite_x_high,x
	sta $0F
	bpl .left
	iny
.left:
	rtl

sub_vert_pos:
	ldy #$00
	lda !player_y_next
	sec
	sbc !sprite_y_low,x
	sta $0F
	lda !player_y_next+1
	sbc !sprite_y_high,x
	bpl .above
	iny
.above:
	rtl
; a: packed sprite offset in pixels, YX
spr_init_pos_offset:
	sta $00
	and #$0F
	clc
	adc !sprite_x_low,x
	sta !sprite_x_low,x
	bcc .no_xhi_adj
	inc !sprite_x_high,x
.no_xhi_adj:
	lda $00
	lsr #4
	clc
	adc !sprite_y_low,x
	sta !sprite_y_low,x
	bcc .no_yhi_adj
	inc !sprite_y_high,x
.no_yhi_adj:
	rtl
; sets $00 to screen-relative x-position, and
; $01 to screen-relative y-position for sprite graphics
; routines. If sprite is offscreen, destroys the JSL used
; to call it and sets up the stack to rtl to the graphics
; routine's calling jsr return value.
get_draw_info:
	stz !sprite_off_screen_vert,x
	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$20
	sec
	sbc !layer_1_xpos_curr
	sta $00
	clc
	adc #$0040
	cmp #$0180
	sep #$20
	lda $01
	beq .not_horz_offscreen
	lda #$01
.not_horz_offscreen:
	sta !sprite_off_screen_horz,x
	lda #$00
	; shift carry into a
	rol a
	sta !sprite_off_screen,x
	bne .abort
	lda !sprite_y_high,x
	xba
	lda !sprite_tweaker_190f,x
	and #$20
	beq .check_once
.check_twice:
	lda !sprite_y_low,x
	rep #$21
	adc #$001C
	sec
	sbc !layer_1_ypos_curr
	sep #$20
	lda !sprite_y_high,x
	xba
	beq .check_once
	lda #$02
.check_once:
	sta !sprite_off_screen_vert,x
	lda !sprite_y_low,x
	rep #$21
	adc #$000C
	sec
	sbc !layer_1_ypos_curr
	sep #$21
	sbc #$0C
	sta $01
	xba
	beq .vert_onscreen
	inc !sprite_off_screen_vert,x
.vert_onscreen:
	ldy !sprite_oam_index,x
	clc
	rtl

.abort:
	rep #$20
	; pull low/high of jsl
	pla
	; pull bank of jsl
	ply
	; pull calling function's jsr ret
	pla
	; push the bank as before
	phb
	pha
	sep #$20
	rtl

; big horiz levels only, no vertical level support.
;   adapted from pixi's shared routine
; input: a = index of despawn values to use
;            (generally, higher values = despawn farther from camera)
sub_off_screen:
	and #$07
	asl
	sta $03
	lda !sprite_off_screen_horz,x
	ora !sprite_off_screen_vert,x
	beq .exit
	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	rep #$20
	cmp !exlvl_screen_size
	bpl .check_erase
	sec
	sbc !layer_1_ypos_curr
	cmp !scr_max_y_off_sprspawn
	bpl .check_erase
	sec
	sbc !scr_min_y_off_sprspawn
	eor #$8000
.check_erase:
	sep #$20
	; offscreen y
	bpl .erase
	lda !sprite_tweaker_167a,x
	and #$04
	bne .exit
	txy
	lda !true_frame
	and #$01
	ora $03
	sta $01
	tax
	lda !layer_1_xpos_curr
	clc
	adc.l .offscr_x_off_lo,x
	rol $00
	cmp.w !sprite_x_low,y
	php
	lda !layer_1_xpos_curr+1
	lsr $00
	adc.l .offscr_x_off_hi,x
	plp
	sbc !sprite_x_high,y
	sta $00
	lsr $01
	bcc .spr_l31
	eor #$80
	sta $00
.spr_l31:
	tyx
	lda $00
	; onscreen
	bpl .exit
.erase:
	lda !sprite_status,x
	cmp #$08
	bcc .kill
	ldy !sprite_load_index,x
	cpy #$FF
	beq .kill
	lda #$00
	sta !sprite_load_table,y
.kill:
	stz !sprite_status,x
.exit
	rtl
.offscr_x_off_lo:
	db $30,$C0,$A0,$C0,$A0,$F0,$60,$90
.offscr_x_off_hi:
	db $01,$FF,$01,$FF,$01,$FF,$01,$FF
spr_long_rts_done:
%set_free_finish("bank4", spr_long_rts_done)
