includefrom "list.def"

%alloc_sprite_spriteset_1($A3, "rotating_platforms", rot_plats_init, rot_plats_main, 8, $112, \
	$00, $1F, $E2, $A2, $29, $41, \
	circle_gfx_temp_tile,
	$0000)


%alloc_sprite_spriteset_1($A4, "pendulum_platforms", rot_plats_init, pend_plats_main, 8, $112, \
	$00, $1F, $E2, $A2, $29, $41, \
	circle_gfx_temp_tile,
	$0000)

%set_free_start("bank3_sprites")

!rot_timer = !sprite_misc_1540
!rot_angle_hi = !sprite_misc_151c
!rot_angle_lo = !sprite_misc_1528
!rot_angle_inc = !sprite_misc_1534
!rot_angle_accel = !sprite_misc_1570
!rot_angle_dir   = !sprite_misc_157c

!rot_spr_radius = !sprite_misc_160e

rot_plats_init:
	lda #$30
;	sta !rot_spr_radius,x
;	lda !spr_extra_byte_1,x
;	sta !rot_timer,x
;
;	lda #$02
;	sta !rot_angle_inc,x
	rtl

pend_plats_main:
	lda #$03
	jsl sub_off_screen

	;jsr pendulate
	;jsr pendulate2
	jsr rot_movement
	jsr write_angle_stdout
	jsr circle_gfx_temp
	rtl

rot_movement:
	rts

pendulate2:
	lda !rot_angle_dir,x
	asl #3
	sta $02
	stz $03

	lda !rot_angle_lo,x
	sta $00
	lda !rot_angle_hi,x
	sta $01

	lda #$00
	ldy !rot_angle_accel,x
	bpl .accel_pos
	lda #$ff
.accel_pos:
	xba
	tya
	rep #$31
	stz $04
	clc
	adc $00
	sta $00

;	stz $05
;	lda !rot_angle_accel,x
;	sta $04
;	bpl .accell_ok
;	ldy #$ff
;	sta $05
;.accel_ok:
;	lsr #4
;	clc
;	adc !rot_angle_lo,x
;	sta $00
;	lda !rot_angle_hi,x
;	adc #$00
;	sta $01

;	rep #$30
;	stz $04

;	lda $00
	bit #$00FF
	bne .not_max
	pha
	lda !rot_angle_dir,x
;	and #$FF00
	eor #$0001
	sta !rot_angle_dir,x
	pla
.not_max:
	cmp #$0400
	bcc .ok
	lda #$0400
.ok:
	sta $00

	xba
	and #$00FF
	asl
	ora $02

	tay
	lda .accels,y
	sep #$20
	sta !rot_angle_accel,x
	lda $00
	sta !rot_angle_lo,x
	lda $01
	sta !rot_angle_hi,x
	rts
.accels:
	dw $0004, $0006, $0008, $000A
	;dw invert($0004), invert($0006), invert($0008), invert($000A)
	dw $FFFC, $FFFA, $FFF8, $FFF4

pendulate:
;	lda !rot_timer,x
;	bne .angle_ok
;	lda !spr_extra_byte_1,x
;	sta !rot_timer,x

	stz $02
	ldy #$00
	lda !rot_angle_inc,x
	sta $00
	bpl .hi_zero
	dey
.hi_zero:
	sty $01
	lda !rot_angle_hi,x
	xba
	lda !rot_angle_lo,x
	rep #$21
	adc $00
	bne .chk_hi
	inc $02
	inc #2
	bra .no_clamp
.chk_hi:
	cmp #$0400
	bcc .no_clamp
	inc $02
	lda #$0400-2
.no_clamp:
	sta $00
	cmp #$0200
	bne .no_inc
	inc $02
.no_inc:
	sep #$20
	lda $02
	beq .angle_ok
	lda !rot_angle_inc,x
	eor #$ff
	inc
	sta !rot_angle_inc,x
.angle_ok:
	lda $00
	sta !rot_angle_lo,x
	lda $01
	sta !rot_angle_hi,x
	rts

rot_plats_main:
	lda #$02
	sta !rot_angle_inc,x

	lda #$03
	jsl sub_off_screen
	rtl

	lda !rot_timer,x
	bne .no_angle_upd_yet
	lda !rot_angle_hi,x
	xba
	lda !rot_angle_lo,x
	rep #$20
	inc
	inc
	cmp #(!sine_table_size-(!sine_table_size/5))
	bcc .angle_ok
	sec
	sbc #(!sine_table_size-(!sine_table_size/5))
.angle_ok:
	sep #$20
	sta !rot_angle_lo,x
	xba
	sta !rot_angle_hi,x

	lda !spr_extra_byte_1,x
	sta !rot_timer,x
.no_angle_upd_yet:

	jsr circle_gfx_temp
	rtl

circle_gfx_temp:
	lda !rot_angle_hi,x
	xba
	lda !rot_angle_lo,x

	rep #$30
	asl
	tax
	lda sine_table,x
	sta $0C
	lda sine_table+((!sine_table_size*2)/5),x
	sta $0E
	sep #$30
	ldx !current_sprite_process

	lda !sprite_y_low,x
	pha
	lda !sprite_y_high,x
	pha

	lda !sprite_x_low,x
	pha
	lda !sprite_x_high,x
	pha


	lda $0C
	sta !ppu_matrix_a
	lda $0D
	sta !ppu_matrix_a
	lda !rot_spr_radius,x
	sta !ppu_matrix_b

	lda !sprite_y_high,x
	xba
	lda !sprite_y_low,x
	rep #$30
	clc
	adc !ppu_mult_res+1
	sep #$30
	sta !sprite_y_low,x
	xba
	sta !sprite_y_high,x

	lda $0E
	sta !ppu_matrix_a
	lda $0F
	sta !ppu_matrix_a
	lda !rot_spr_radius,x
	sta !ppu_matrix_b

	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$30
	clc
	adc !ppu_mult_res+1
	sep #$30
	sta !sprite_x_low,x
	xba
	sta !sprite_x_high,x

	jsl spr_gfx_single

	pla
	sta !sprite_x_high,x
	pla
	sta !sprite_x_low,x

	pla
	sta !sprite_y_high,x
	pla
	sta !sprite_y_low,x
	rts

.tile:
	db #$04

write_angle_stdout:
	lda !rot_angle_hi,x
	and #$0F
	sta !status_bar_tilemap
	lda !rot_angle_lo,x
	and #$F0
	lsr #4
	sta !status_bar_tilemap+1
	lda !rot_angle_lo,x
	and #$0F
	sta !status_bar_tilemap+2
	rts

plats_main_done:
%set_free_finish("bank3_sprites", plats_main_done)
