!starcoin_sprnum = $B9

%alloc_sprite_dynamic_512k(!starcoin_sprnum, "starcoin", starcoin_init, starcoin_main, 4, 1,\
	$8E, $0E, $75, $9B, $B9, $46, "bank7")

!starcoin_collect_sfx = $1A
!starcoin_collect_port = $1DFC|!addr

!starcoin_ani_timer = !sprite_misc_1570
!starcoin_slot      = !sprite_misc_1602

%set_free_start("bank3_sprites")
starcoin_init:
	jsl sprite_read_item_memory
	beq .nodie
	stz !sprite_status,x
.exit:
	rtl
.nodie:
	lda !spr_extra_byte_1,x
	jml spr_init_pos_offset

starcoin_main:
	%dynamic_gfx_rt_bank3("lda !starcoin_ani_timer,x : lsr #3 : and #$03", "starcoin")

	lda !sprites_locked
	bne starcoin_init_exit
	jsl sub_off_screen
	; update ani frame
	inc !starcoin_ani_timer,x
	jsl   mario_spr_interact_l
	bcc starcoin_init_exit
	lda #!starcoin_collect_sfx
	sta !starcoin_collect_port

	sec
	rol !yoshi_coins_collected

	ldy #$07
.popcount:
	stz.b $00
	lda.w !yoshi_coins_collected
.loop:
	lsr
	bcc .next
	inc $00
.next:
	dey
	bpl .loop

	lda.b #$03
	clc
	adc $00
	jsl spr_give_points

	stz !sprite_status,x
	jml sprite_write_item_memory|!bank

;.exit:
;	rtl
.done:
%set_free_finish("bank3_sprites", starcoin_main_done)
