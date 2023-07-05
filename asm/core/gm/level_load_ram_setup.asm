;org $00A5AB|!bank
;autoclean \
;	jsl level_setup_ram_special
;freecode
;level_setup_ram_special:
;	; restore hijacked code
;	jsl $05809E|!bank
;	stz !ambient_playerfireballs
;	stz !ambient_playerfireballs+1
;	stz !camera_control_resident
;	stz !camera_control_resident+1
;
;	lda #(!num_ambient_sprs*2)-2
;	sta !ambient_spr_ring_ix
;	ldx #(!num_turnblock_slots-1)*6
;	stx !turnblock_run_index
;	stx !turnblock_free_index
;	rep #$20
;
;	stz !level_load_spriteset_files
;	stz !level_load_spriteset_files+$2
;	stz !level_load_spriteset_files+$4
;	stz !level_load_spriteset_files+$6
;	stz !level_load_spriteset_files+$8
;	stz !level_load_spriteset_files+$A
;	stz !level_load_spriteset_files+$C
;
;	lda #!turnblock_status
;	sta $82
;	ldy #$7F
;	sty $84
;
;	ldy #$00
;	lda.w #((!num_turnblock_slots*sizeof(turnblock_status_d))+(!num_skidsmoke_slots*sizeof(skidsmoke_status_d)))
;	jsl dma_set_ram_l
;	lda #!level_ss_sprite_offs
;	sta $82
;	dey
;;	ldy #$ff
;	lda #$0100
;	jsl dma_set_ram_l
;	sep #$20
;
;	rtl
