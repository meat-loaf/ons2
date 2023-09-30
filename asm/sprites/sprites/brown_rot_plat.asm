;includefrom "list.def"
;
;!brown_rot_plat_sprnum = $5F
;brown_chain_plat_init = $01C74A|!bank
;brown_chain_plat_main = $01C773|!bank
;
;!brown_plat_ball_tile_num = $2E
;!brown_plat_props_scratch = $45
;
;%alloc_sprite(!brown_rot_plat_sprnum, "brown_spinny_plat", brown_chain_plat_init, brown_chain_plat_main_new, 10, 1, \
;	$00, $A9, $00, $E2, $A2, $45)
;
;; platform tile numbers
;org $01C9BB|!bank
;brown_chain_plat_tiles:
;	db $86,$87,$87,$88
;
;; original is suboffscreen2, which causes the sprite to nearly always despawn
;; when mario is moving left. and using the 'auto-rotating' feature.
;; however, when using suboffscreen3, it draws garbage near the edge of the
;; despawn range...
;org $01C773|!bank
;	jsr.w _suboffscr2_bank1
;
;; init return
;org $01C772|!bank
;	rtl
;
;; extra bit set: spin at extra byte speed
;org $01C785|!bank
;	JMP.w brown_plat_speed
;org $01CA8C|!bank
;	JMP.w brown_exb_alt
;
;; ball tilestores
;org $01C7E9|!bank
;	LDA.b #!brown_plat_ball_tile_num
;	STA.w $0302|!bank,y
;org $01C870|!bank
;	LDA.b #!brown_plat_ball_tile_num
;	STA.w $0302|!bank,y
;org $01C8C6|!bank
;	LDA.b #!brown_plat_ball_tile_num
;	STA.w $0302|!bank,y
;
;; main sets scratch with different value for props
;org $01C7EE|!bank
;	LDA.b !brown_plat_props_scratch
;org $01C875|!bank
;	LDA.b !brown_plat_props_scratch
;org $01C8CB|!bank
;	LDA.b !brown_plat_props_scratch
;org $01C8FA|!bank
;	LDA.b !brown_plat_props_scratch
;
;; main return: when skipping main physics code
;org $01C9B6|!bank
;	rtl
;
;; $01C9EB should be an rtl, but it's jsr'd to here. just monkeypatch for now
;org $01CA6E|!bank
;	jsr brown_plat_draw_player_kludge
;
;; main return: finished handling physics (when not moving?)
;org $01C9EB|!bank
;brplat_retl_1:
;	rtl
;
;; this branches to a farther return above (in an unrelated routine),
;; but needs to go to an rtl
;; branches here if sprite is offscreen
;org $01CA09|!bank
;	bne brplat_retl_1
;
;; main return: finished handling physics
;org $01CA9B|!bank
;	rtl
;
;%set_free_start("bank1_bossfire")
;brown_chain_plat_main_new:
;	ldy.b #pack_props($00,$03,$00,$00)
;	; extra bit set: set flag for spin
;	lda !spr_extra_bits,x
;	beq .no_exbit
;	; use palette 9
;	ldy.b #pack_props($00,$03,$01,$00)
;.no_exbit:
;	sty !brown_plat_props_scratch
;	; the original main
;	jmp.w brown_chain_plat_main
;brown_plat_speed:
;	lda.w !spr_extra_bits,x
;	beq.b .noexbit
;	lda.w !spr_extra_byte_1,x
;	jmp.w $01C792|!bank
;.noexbit
;	ldy.w !sprite_misc_1504,x
;	jmp.w $01C788|!bank
;brown_exb_alt:
;	lda.w !spr_extra_bits,x
;	beq.b +
;	rtl
;+
;	lda.w !sprite_misc_1504,x
;	jmp.w $01CA8F
;brownplat_hijacks_end:
;%set_free_finish("bank1_bossfire", brownplat_hijacks_end)
;
;%set_free_start("bank1_thwomp")
;brown_plat_draw_player_kludge:
;	jsl $01C9E2|!bank
;	rts
;.done
;%set_free_finish("bank1_thwomp", brown_plat_draw_player_kludge_done)
