includefrom "list.def"

!ambient_player_dust_id = $00
!ambient_dust_puff_id   = $01

%alloc_ambient_sprite(!ambient_player_dust_id, "turn_dust", ambient_dust_main, \
	0)
%alloc_ambient_sprite(!ambient_dust_puff_id, "smoke_puff", ambient_dust_main, \
	!ambient_gfx_tilesz_big)

%set_free_start("bank2_altspr2")
ambient_dust_main:
	lda !ambient_gen_timer,x
	bne .cont
.bad_ambient_default:
	stz !ambient_rt_ptr,x
	rts
.cont:
	lsr #2
	asl
	tay
	lda .prop_tiles_tbl,y
	sta !ambient_props,x
	jmp ambient_basic_gfx
.prop_tiles_tbl:
	dw $00E6,$00E6,$00E4,$00E2,$00E2,$00E2
.done:
%set_free_finish("bank2_altspr2", ambient_dust_main_done)
