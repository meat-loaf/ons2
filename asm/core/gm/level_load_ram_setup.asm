org $00A5AB|!bank
autoclean \
	jsl level_setup_ram_special
freecode
level_setup_ram_special:
	; restore hijacked code
	jsl $05809E|!bank
	stz !ambient_playerfireballs
	stz !ambient_playerfireballs+1
	stz !camera_control_resident
	stz !camera_control_resident+1

	lda #(!num_ambient_sprs*2)-2
	sta !ambient_spr_ring_ix
	ldx #(!num_turnblock_slots-1)*6
	stx !turnblock_run_index
	stx !turnblock_free_index
.loop:
	lda #$00
	sta turnblock_status_d.timer,x
	sta turnblock_status_d.timer+1,x
	txa
	sec : sbc #$06
	tax
	bpl .loop
	ldx #(!num_skidsmoke_slots-1)*6
	stx !skidsmoke_run_index
	stx !skidsmoke_free_index
.loop2:
	lda #$00
	sta skidsmoke_status_d.timer,x
	sta skidsmoke_status_d.timer+1,x
	txa
	sec : sbc #$06
	tax
	bpl .loop2

	rtl