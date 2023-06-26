includefrom "ambient_list.def"

!ambient_contact_id = $30

%alloc_ambient_sprite(!ambient_contact_id, "contact_fx", ambient_contact_fx, 0)

%set_free_start("bank2_altspr1")
ambient_contact_fx:
	jsr ambient_kill_on_timer
	lda #$0006
	sta $0c
	; also does get_draw_info equivalent
	jsr ambient_sub_off_screen
	lda !ambient_gen_timer,x
	and #$0002
	asl #2
	tax

	lda !sprite_level_props-1
	and #$FF00
	sta $02

	lda .tile_props,x
	ora $02
	sta $0202|!addr,y
	lda .tile_props+2,x
	ora $02
	sta $0206|!addr,y
	lda .tile_props+4,x
	ora $02
	sta $020A|!addr,y
	lda .tile_props+6,x
	ora $02
	sta $020E|!addr,y
	ldx !current_ambient_process

	clc
	lda $00
	sta $0200|!addr,y
	adc #$0008
	sta $0204|!addr,y
	adc #$0800
	sta $020C|!addr,y
	; carry always clear - subtracts 8
	sbc #$0007
	sta $0208|!addr,y

	tya
	lsr #2
	tay
	lda !ambient_twk_tilesz,x
	and #$0003
	sta $00
	xba
	ora $00
	sta $0420|!addr,y
	sta $0422|!addr,y

	rts
.tile_props:
	; frame 1
	dw $007C,$007D,$C07D,$C07C
	; frame 2
	dw $407D,$407C,$807C,$807D
ambient_contact_fx_done:
%set_free_finish("bank2_altspr1", ambient_contact_fx_done)
