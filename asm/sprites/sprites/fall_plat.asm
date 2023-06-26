;ditto, for custom platforms
!falling_plat_sprnum = $A9
%alloc_sprite(!falling_plat_sprnum, "falling_plats", fall_plats_init, fall_plats_main, 5, 1, \
	$00, $00, $F2, $A2, $A9, $41)

!fall_plats_accel_wait_timer = !sprite_misc_1540
%set_free_start("bank1_plats")
fall_plats_init:
	ldy !spr_extra_bits,x
	lda .clippings,y
	ora !sprite_tweaker_1662,x
	sta !sprite_tweaker_1662,x
	rtl
.clippings:
	db $1D,$04,$00,$05
fall_plats_main:
	jsr fall_plats_gfx
	lda !sprites_locked
	bne .exit
	lda #$03
	jsl sub_off_screen
	lda !sprite_speed_y,x
	beq .pos_upd
	lda !fall_plats_accel_wait_timer,x
	bne .pos_upd
	lda !sprite_speed_y,x
	cmp #$40
	bpl .pos_upd
	clc
	adc #$02
	sta !sprite_speed_y,x
.pos_upd:
	jsr _spr_upd_y_no_grav
	jsr _spr_invis_solid_rt
	bcc .exit
	lda !sprite_speed_y,x
	bne .exit
	lda #$03
	sta !sprite_speed_y,x
	lda #$18
	sta !fall_plats_accel_wait_timer,x
.exit:
	rtl

fall_plats_gfx:
	jsr _get_draw_info_bank1
	lda !sprite_oam_properties,x
	sta $04
	lda !spr_extra_bits,x
	tax
	lda .ntiles,x
	dec
	sta $02
	tax
	lda #$86
	sta $03
.loop:
	lda $00
	sta $0300|!addr,y
	clc : adc #$10
	sta $00
	lda $01
	sta $0301|!addr,y
	lda $03
	cpx #$00
	bne .store
	inc
	sta $03
.store
	sta $0302|!addr,y
	cpx $02
	bne .nooff
	inc
	sta $03
.nooff:
	lda $04
	ora !sprite_level_props
	sta $0303|!addr,y
	iny #4
	dex
	bpl .loop
	ldx !current_sprite_process
	ldy #$02
	lda $02
	jmp _finish_oam_write
.ntiles:
	db $02,$03,$04,$05
fall_plats_done:
%set_free_finish("bank1_plats", fall_plats_done)
