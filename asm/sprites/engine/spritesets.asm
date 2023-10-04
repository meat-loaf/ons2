
if read1($0FF8C6|!bank) != $22
	error "LM Super GFX hijack not installed, or this code has changed. Install this hijack first by installing ExGFX."
else
	!exgfx_table #= read3($0FF7FF)
endif

org $0096F8|!bank
ss_hijack:
;autoclean \
	jml ss_setup_spriteset
	nop #6
.done:

; orignally, a call to the LM code that decompresses graphics files after
; pulling the graphics file number from a long pointer at $8A
org $0FF8C6|!bank
;autoclean \
	jsl spriteset_extract_gfx_hijack

;freecode
%set_free_start("bank7")
ss_data_table:
	skip $100*2*4
level_setup_ram_special:
	stz !ambient_playerfireballs
	stz !ambient_playerfireballs+1
	stz !camera_control_resident
	stz !camera_control_resident+1

	lda #(!num_ambient_sprs*2)-2
	sta !ambient_spr_ring_ix
	ldx #(!num_turnblock_slots-1)*6
	stx !turnblock_run_index
	stx !turnblock_free_index
	rep #$20


	ldy #$7E
	sty $84
	lda #!level_load_spriteset_files
	sta $82
	lda.w #($0ef4-!level_load_spriteset_files)
	ldy #$00
	jsl dma_set_ram_l

	lda #!turnblock_status
	sta $82
	inc $84

	lda.w #((!num_turnblock_slots*sizeof(turnblock_status_d))+(!num_skidsmoke_slots*sizeof(skidsmoke_status_d)))
	jsl dma_set_ram_l

	lda #!level_ss_sprite_offs
	sta $82
	dey
	lda #$0100
	jsl dma_set_ram_l

	sep #$20
	rts

; pull spriteset before sprite inits run. By default, it uses the low byte of the SP3 graphics
; file number to determine the spriteset.
; 1 byte
!ss_sprite_parser_exlevel = $45
; 3 bytes
!ss_temp_sprite_data_ptr  = $46
; 2 bytes
!n_ss_data_files          = $49
!ss_off_curr              = $4B


!ss_tile_offset_start     = ($80>>1)
!ss_tile_offset = ($20>>1)
ss_setup_spriteset:
	ldx.b #$07         ; \
.loop:                     ; | restore hijacked code
	lda $1A,x          ; |
	sta $1462|!addr,x  ; |
	dex                ; |
	bpl .loop          ; /

	jsr level_setup_ram_special

	phb
	phk
	plb
.begin_table_parse:
	stz !n_ss_data_files
	stz !n_ss_data_files+1
	lda #!ss_tile_offset_start
	sta !ss_off_curr
	stz !ss_off_curr+1

	lda !level_sprite_data_ptr
	sta !ss_temp_sprite_data_ptr
	lda !level_sprite_data_ptr+1
	sta !ss_temp_sprite_data_ptr+1
	lda !level_sprite_data_ptr+2
	sta !ss_temp_sprite_data_ptr+2
.parse_sprite_table:
	ldy #$01
	lda [!ss_temp_sprite_data_ptr]
	and #%00100000
	sta !ss_sprite_parser_exlevel
..parse_sprite_entry:
	lda [!ss_temp_sprite_data_ptr],y
	cmp #$ff
	bne ..next_sprite
	lda !ss_sprite_parser_exlevel
	beq ..done
	iny
	lda [!ss_temp_sprite_data_ptr],y
	cmp #$fe
	beq ..done
	cmp #$ff
	beq ..next_sprite
	iny
..next_sprite:
	iny #2
	lda [!ss_temp_sprite_data_ptr],y
	phx
	phy
	tax
	rep #$30
	and #$00FF
	asl #3
	tay
	lda.l !level_ss_sprite_offs,x
	and #$00FF
	cmp #$00FF
	bne ...ss_already_set
	lda #$0003
	sta $00
...set_files_loop:
	; load exgfx file num
	lda ss_data_table,y
	bmi ...ss_already_set
	cmp #$007F
	beq ...skip_slot
	sty $06
	sta $02
	; this is probably a bug, we could have a sprite that allocates
	; the final slot, we should check allocated first and then do this
	lda !n_ss_data_files
	cmp.w #!max_ss_data_files
	bcs ss_no_available_abort
...num_files_ok:
	asl
	tay
	jsr check_file_allocated
	ldy $06
...skip_slot:
	iny #2
	dec $00
	bpl ...set_files_loop

...ss_already_set
	sep #$30
	ply
	plx
	; all sprite entries are 4 bytes
	iny #2
	bpl ..parse_sprite_entry
	clc
	adc !ss_temp_sprite_data_ptr
	sta !ss_temp_sprite_data_ptr
	ldy #$00
	bra ..parse_sprite_entry

..done:
	plb
	jml ss_hijack_done|!bank

ss_no_available_abort:
	;stp
	;brk #$AA
;	pla
	pla
	sep #$30
	bra ss_setup_spriteset_parse_sprite_table_done

; $02 has file
check_file_allocated:
	sty $04
	lda !n_ss_data_files
	asl
	tay
.loop:
	lda !level_load_spriteset_files,y
	cmp $02
	beq .found
	dey
	dey
	bpl .loop

	inc !n_ss_data_files
	ldy $04

	lda $02
	sta !level_load_spriteset_files,y
	lda !level_ss_sprite_offs,x
	and #$00FF
	cmp #$00FF
	bne .skip_set_sprite_offset
	lda !level_ss_sprite_offs,x
	and #$FF00
	ora !ss_off_curr
	sta !level_ss_sprite_offs,x

.skip_set_sprite_offset:
	lda !ss_off_curr
	clc
	adc.w #!ss_tile_offset
	sta !ss_off_curr
	rts

.found:
	lda !level_ss_sprite_offs,x
	and #$FF00
	ora ..offs,y
	sta !level_ss_sprite_offs,x
	ldy $04
	rts

..offs:
;	dw $0000,$0020,$0040,$0060,$0080,$00A0
	dw $0080>>1,$00A0>>1,$00C0>>1,$00E0>>1
	dw $0100>>1,$0120>>1,$0140>>1,$0160>>1
	dw $0180>>1,$01A0>>1,$01C0>>1

; AXY are 16 bit here. $8A contains a pointer to the level's ExGFX list, and Y
; is the index to the current file to be uploaded. We will use the lower 8 bits
; of the SP3 ExGFX file number as the spriteset number. The others can be used
; for other things during load time, if desired.
spriteset_extract_gfx_hijack:
	phx : phy : pha : php
	; note: this code is called with 8-bit axy when not using
	; note: LM's super gfx bypass, 16-bit otherwise. i'd like a more proper
	; note: way to detect this, though: maybe it's in the 32 bytes of
	; note: ram at $7FC000 somewhere.

	; check if we're 16 or 8 bit A:
	; loads EA00 with 16 bit A, or LDA #$00 : NOP
	; with 8-bit A.
	lda #$EA00
	bpl .handle_normal

	rep #$30
	lda !gamemode
	and #$00FF
	cmp #$0012
	bne .handle_normal
	cpy #$0010          ; SP4 index
	beq .ss_continue
	cpy #$0012          ; SP3 index
	beq .ss_continue
	cpy #$0014          ; SP2 index
	beq .ss_continue
	;cpy #$0016          ; SP1 index
	;bne .handle_normal
.handle_normal:
	plp : pla : ply : plx
	jml $0FF900|!bank

.ss_continue:
	tyx
	lda.l .nfiles-$10,x
	tay

	lda.l .table_offsets-$10,x
	tax

.gfx_loop:
	lda !level_load_spriteset_files,x
	beq .skip
	; decomp gfx
	jsl $0FF900|!bank
	lda.b $00
	clc
	; 1KB file
	adc #$0400
	sta $00
.skip:
	inx
	inx
	dey
	bpl.b .gfx_loop

	lda #$AD00             ; \ restore original upload destination
	sta $00                ; /
	plp : pla : ply : plx
	rtl
.table_offsets:
	dw $0010,$0008,$0000
.nfiles:
	dw $0002-1,$0004-1,$0004-1
ss_stuff_done:
%set_free_finish("bank7", ss_stuff_done)
