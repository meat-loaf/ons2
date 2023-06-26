includefrom "ambient_list.def"

!ambient_masker_id = $3F

%alloc_ambient_sprite(!ambient_masker_id, "ambient_mask_sprite", ambient_mask, \
	!ambient_gfx_tilesz_big)

%set_free_start("bank2_altspr2")
ambient_mask:
	; aborts if timer is zero
	jsr ambient_kill_on_timer
	; for oam alloc - one tile
	stz $0c
	; aborts if no oam left
	jsr ambient_sub_off_screen_ok
	lda $00
	sta $0200|!addr,y
	lda #$00C0
	sta $0202|!addr,y
	jmp ambient_basic_gfx_smallstore
ambient_mask_done:
%set_free_finish("bank2_altspr2", ambient_bounce_done)
