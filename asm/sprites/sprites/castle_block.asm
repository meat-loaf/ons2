
!castle_block_sprnum = $BB

; castle block init in spritesets.asm
;%alloc_spr_nocfg(!castle_block_sprnum, castle_block_init, bank3_sprcaller)

%alloc_sprite(!castle_block_sprnum, "moving_castle_block", castle_block_init, castle_block_main, 4, 0, \
	$00, $2F, $3B, $A2, $19, $40)
!castle_block_phase        = !sprite_misc_c2
!castle_block_x_movement   = !sprite_misc_1528
!castle_block_moving_timer = !sprite_misc_1540

%set_free_start("bank3_sprites")
castle_block_init:
	lda !spr_extra_bits,x
	and #$01
	asl
	sta !castle_block_phase,x
.exit
	rtl
castle_block_main:
	jsr spr_gfx_32x32
	lda !sprites_locked
	bne castle_block_init_exit
	lda !castle_block_moving_timer,x
	bne .no_phase_change
	inc !castle_block_phase,x
	lda !castle_block_phase,x
	and #$03
	tay
	lda .move_timing,y
	sta !castle_block_moving_timer,x
	lda .move_speed,y
	sta !sprite_speed_x,x
.no_phase_change:
	jsl spr_upd_x_no_grv_l
	sta !castle_block_x_movement,x
	jml spr_invis_blk_rt_l
.move_timing:
	db $40,$50,$40,$50
.move_speed:
	db $00,$F0,$00,$10
castle_block_done:
%set_free_finish("bank3_sprites", castle_block_done)
