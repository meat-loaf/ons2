;!move_plats_x_or_y_sprid  = $54
!move_plats_x_or_y_sprid  = $56
!move_plats_x_and_y_sprid = !plats_x_or_y_sprid+$1

%alloc_sprite(!move_plats_x_or_y_sprid, "move_plats", plats_init, plats_main, 5, 0, \
	$01, $04, $E3, $A2, $A9, $65)

!move_plats_turn_wait     = !sprite_misc_1540
!move_plats_accel_counter = !sprite_misc_c2
!move_plats_direction     = !sprite_misc_151c
!move_plats_x_movement    = !sprite_misc_1528

%set_free_start("bank1_plats")
plats_init:
	lda #$18
	sta !move_plats_turn_wait,x
	; todo: set clipping/style via extra byte?
.exit:
	rtl

plats_main:
	jsr float_plat_gfx
	lda !sprites_locked
	bne plats_init_exit
	lda !move_plats_turn_wait,x
	bne .do_movement
	inc !move_plats_accel_counter,x
	lda !move_plats_accel_counter,x
	and #$03
	bne .do_movement
	lda !move_plats_direction,x
	and #$01
	tay
	lda !sprite_speed_y,x
	clc
	adc .accel_speeds,y
	sta !sprite_speed_y,x
	sta !sprite_speed_x,x
	cmp .accel_max,y
	bne .do_movement
	inc !move_plats_direction,x
	lda #$18
	sta !move_plats_turn_wait,x
.do_movement:
	; todo probably use another table
	txy
	lda !spr_extra_bits,x
	and #$01
	asl
	tax
	jsr (.move_rts,x)
	jsr _spr_invis_solid_rt
	lda #$03
	jml sub_off_screen

.move_rts:
	dw .x_only
	dw .y_only
	dw .yx

.y_only:
	tyx
	stz !move_plats_x_movement,x
	jmp.w _spr_upd_y_no_grav
.yx:
	tyx
	jsr.w _spr_upd_y_no_grav
.x_only:
	ldx !current_sprite_process
	jsr.w _spr_upd_x_no_grav
	lda !sprite_x_movement
	sta !move_plats_x_movement,x
	rts
.accel_speeds:
	db $FF,$01
.accel_max:
	db $F0,$10

float_plat_gfx:
	jsr _get_draw_info_bank1
	lda $00
	sta $0300|!addr,y
	; bottom - left
	clc : adc #$08
	sta $0304|!addr,y
	; top - center
	clc : adc #$08
	sta $0308|!addr,y
	; bottom - right
	clc : adc #$08
	sta $030C|!addr,y
	clc : adc #$08
	; top - right
	sta $0310|!addr,y
	lda $01
	sta $0301|!addr,y
	sta $0309|!addr,y
	sta $0311|!addr,y
	clc : adc #$10
	sta $0305|!addr,y
	sta $030D|!addr,y

	lda #$00
	sta $0302|!addr,y
	sta $0312|!addr,y
	lda #$01
	sta $030A|!addr,y
	lda #$03
	sta $0306|!addr,y
	sta $030E|!addr,y

	lda !sprite_oam_properties,x
	sta $0303|!addr,y
	sta $0307|!addr,y
	sta $030B|!addr,y
	ora #$40
	sta $030F|!addr,y
	sta $0313|!addr,y

	lda #$05
	ldy #$02
	jmp _finish_oam_write

plats_done:
%set_free_finish("bank1_plats", plats_done)
