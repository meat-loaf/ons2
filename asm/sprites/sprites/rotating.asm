includefrom "list.def"

%alloc_sprite_spriteset_1($A3, "rotating_platforms", rot_plats_init, rot_plats_main, 8, $112, \
	$00, $1F, $E2, $A2, $29, $41, \
	circle_gfx_temp_tile, \
	!spr_nom_gfx_rot_rt_id)

%set_free_start("bank3_sprites")

!rot_angle_lo = !sprite_misc_151c
!rot_playermove = !sprite_misc_1528
!rot_angle_inc = !sprite_misc_1534
;!rot_timer = !sprite_misc_1540
!rot_angle_accel = !sprite_misc_1570
!rot_angle_dir   = !sprite_misc_157c
!rot_angle_hi = !sprite_misc_1594

!rot_spr_radius = !sprite_misc_160e
!rot_spr_last_x_lo = !sprite_misc_1626
;!rot_spr_ball_off  = !sprite_misc_187b

!resultant_angle_scr = $0E

!x_low_bak  = $45
!x_high_bak = !x_low_bak+1
!y_low_bak  = !x_high_bak+1
!y_high_bak = !y_low_bak+1
!sine_scr = !y_high_bak+1
!cosine_scr = !sine_scr+2

rot_plats_init:
	txy
	lda.l spr_id_to_rot_spr_gfx_buff,x
	tax
	; TODO make all these dynamic
	;lda #$02
	lda #$03
	sta rot_spr_gfx_buff.ntiles,x

	lda #$03
	sta rot_spr_gfx_buff.end_ntiles,x

	lda #$04
	sta rot_spr_gfx_buff.tile_id,x

	lda #$02
	sta rot_spr_gfx_buff.tile_prop,x

	lda #$00
	sta rot_spr_gfx_buff.draw_end,x
	sta rot_spr_gfx_buff.draw_end+1,x

	tyx
	; TODO variable
	;lda #$48
	lda #$30
	sta !rot_spr_radius,x
	rtl

rot_plats_main:
	lda #$03
	jsl sub_off_screen

	ldy #$00
	lda !spr_extra_byte_1,x
	lsr
	bcc .no_pendulum
	ldy #$02
.no_pendulum:
	tyx
	jsr (.angle_handlers,x)
	jsr backup_spr_pos
	jsr apply_angle_to_pos
	jsl spr_invis_blk_rt_l
	;jsr circle_gfx_temp
	jsr rot_setup_gfx
	jsr restore_spr_pos
	rtl

.angle_handlers:
	dw rot_movement
	dw pend_movement

backup_spr_pos:
	lda !sprite_x_low,x
	sta !x_low_bak
	lda !sprite_x_high,x
	sta !x_high_bak

	lda !sprite_y_low,x
	sta !y_low_bak
	lda !sprite_y_high,x
	sta !y_high_bak
	rts

restore_spr_pos:
	lda !x_low_bak
	sta !sprite_x_low,x
	lda !x_high_bak
	sta !sprite_x_high,x

	lda !y_low_bak
	sta !sprite_y_low,x
	lda !y_high_bak
	sta !sprite_y_high,x
	rts

apply_angle_to_pos:
	rep #$30

	lda !resultant_angle_scr
	asl
	tax
	lda.l sine_table,x
	sta !sine_scr
	lda.l sine_table+((!sine_table_size*2)/5),x
	sta !cosine_scr
	sep #$30

	ldx !current_sprite_process
	ldy !rot_spr_radius,x

	lda !sine_scr
	sta !ppu_matrix_a
	lda !sine_scr+1
	sta !ppu_matrix_a
	sty !ppu_matrix_b

	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	rep #$21
	adc !ppu_mult_res+1
	sta !sine_scr
	sep #$20
	sta !sprite_y_low,x
	xba
	sta !sprite_y_high,x

	lda !cosine_scr
	sta !ppu_matrix_a
	lda !cosine_scr+1
	sta !ppu_matrix_a
	sty !ppu_matrix_b


	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$21
	adc !ppu_mult_res+1
	sta !cosine_scr
	sep #$21
	sta !sprite_x_low,x
	xba
	sta !sprite_x_high,x

	lda !sprite_x_low,x
	tay
	sbc !rot_spr_last_x_lo,x
	sta !rot_playermove,x
	tya
	sta !rot_spr_last_x_lo,x
	rts

pend_movement:
	ldx !current_sprite_process
	rts

rot_movement:
	ldx !current_sprite_process
	lda !spr_extra_byte_1,x
	lsr
	; A = !spr_extra_byte_1,x >> 1
	; todo mask out other eventual bits
	tay
	lda .angle_traversal_speeds,y
	sta !rot_angle_inc,x

	stz $01
	;lda !rot_angle_inc,x
	sta $00
	bpl .not_neg
	dec $01
.not_neg:
	lda !rot_angle_hi,x
	xba
	lda !rot_angle_lo,x
	rep #$20
	clc
	adc $00
	and #$03FF
.angle_ok:
	sta !resultant_angle_scr
	sep #$20
	sta !rot_angle_lo,x
	xba
	sta !rot_angle_hi,x
	rts

.angle_traversal_speeds:
	db $02, invert($02)
	db $04, invert($04)

circle_gfx_temp:
	jsl spr_gfx_single
	rts

.tile:
	db #$04

; TODO DYNAMIC POSITIONING FOR DIVISOR
rot_setup_gfx:
	stz $01
	stz $02
	ldx #$ff

	; NUMBER OF SEGMENTS TO DRAW
	;ldy #$02
	ldy #$03
	rep #$20
	lda !cosine_scr
	sec
	sbc !x_low_bak
	bpl .x_off_ok
	eor #$ffff
	inc
	stx $01
.x_off_ok:
	sta !hw_dividend_c_lo
	sty !hw_divisor_b
	lda !sine_scr
	sec
	sbc !y_low_bak
	bpl .y_off_ok
	eor #$ffff
	inc
	stx $02
.y_off_ok:
	; TODO i think this nop is unnecesary
	;nop
	ldx !hw_div_result_lo
	stx $00
	sta !hw_dividend_c_lo
	sty !hw_divisor_b
	ldx !current_sprite_process
	txy
	lda.l spr_id_to_rot_spr_gfx_buff,x
	tax
	lda $00
	eor $01
	bpl .x_store
	inc
.x_store:
	sta rot_spr_gfx_buff.tile_x_delta,x
	sep #$20
	lda !hw_div_result_lo
	eor $02
	bpl .y_store
	inc
.y_store:
	sta rot_spr_gfx_buff.tile_y_delta,x
	tyx
	rts

;write_angle_stdout:
;	lda !rot_angle_hi,x
;	and #$0F
;	sta !status_bar_tilemap
;	lda !rot_angle_lo,x
;	and #$F0
;	lsr #4
;	sta !status_bar_tilemap+1
;	lda !rot_angle_lo,x
;	and #$0F
;	sta !status_bar_tilemap+2
;	rts

plats_main_done:
%set_free_finish("bank3_sprites", plats_main_done)
