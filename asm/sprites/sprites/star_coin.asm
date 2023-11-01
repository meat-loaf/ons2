includefrom "list.def"

%alloc_sprite_dynamic_512k(!starcoin_sprnum, "starcoin", starcoin_init, starcoin_main, 4, \
	$8E, $0E, $75, $9B, $B9, $46, "bank7",\
	dyn_starcoin_gfx_ptrs,
	!spr_norm_gfx_dyn_rt_id)

!starcoin_collect_sfx  = $1A
!starcoin_collect_port = $1DFC|!addr

!starcoin_ani_timer    = !sprite_misc_1570
!starcoin_ani_frame_id = !sprite_misc_160e

%set_free_start("bank3_sprites")
starcoin_init:
	%dyn_slot_setup("starcoin")
	jsl sprite_read_item_memory
	beq .nodie
	stz !sprite_status,x
.exit:
	rtl

.nodie:
	lda !spr_extra_byte_1,x
	%spr_offset_xy8()
	rtl

starcoin_main:
	lda #$00
	jsl sub_off_screen
	; update ani frame
	inc !starcoin_ani_timer,x
	lda !starcoin_ani_timer,x
	lsr #3
	and #$03
	sta !starcoin_ani_frame_id,x
	jsl mario_spr_interact_l
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

%start_sprite_pose_entry_list("dyn_starcoin")
	%start_sprite_pose_entry("dyn_starcoin_impl", 32, 32)
		%sprite_pose_tile_entry($F8, $F8, $80, $00, 2, 1)
		%sprite_pose_tile_entry($08, $F8, $82, $00, 2, 1)
		%sprite_pose_tile_entry($F8, $08, $84, $00, 2, 1)
		%sprite_pose_tile_entry($08, $08, $86, $00, 2, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()

starcoin_done:
%set_free_finish("bank3_sprites", starcoin_done)
