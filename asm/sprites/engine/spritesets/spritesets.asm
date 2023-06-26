incsrc "spriteset_macros.asm"
incsrc "spriteset_config.asm"
incsrc "finish_oam_write.asm"
incsrc "generic_gfx_routines.asm"

if read1($0FF8C6|!bank) != $22
	error "LM Super GFX hijack not installed, or this code has changed. Install this hijack first before patching with LM hijacks."
else
	!exgfx_table #= read3($0FF7FF)
endif

org $0096F8|!bank
ss_hijack:
	jml ss_set_spriteset|!bank
	NOP #6
.done:
;warnpc $009705|!bank

; orignally, a call to the LM code that decompresses graphics files after
; pulling the graphics file number from a long pointer at $8A
org $0FF8C6|!bank
	jsl spriteset_setup_lm

org $07F78B|!bank
;; originally, this routine preserved Y, but doesnt use it itself.
;; we get the JSL we want 'for free' by removing pushing Y as we then
;; have a 'tidied' stack, so we just go right into loading the tweaker bytes
;; instead of JSLing to the routine like the game originally did.
load_sprite_tables:
	PHX
;	LDA   !9E,x
	%sprite_num(LDA,x)
	TAX
	LDA.l $07F3FE,x
	AND.b #$0F
	PLX
	STA.w !sprite_oam_properties,x
autoclean \
	JSL.l sprset_init
	BRA load_tweaker_bytes : NOP
warnpc $07F7A0|!bank
org $07F7A0|!bank
load_tweaker_bytes:

;%set_free_start("bank6", sprset_init)
freecode
sprset_init:
	phy
	phx
	php

	lda.b #spritesets>>16
	sta.b !sprset_tbl_scr+$02

	%sprite_num(LDA,x)
	rep #$30
	and #$00FF
	asl
	tax
	lda.l spriteset_off_ptrs,x
	sta !sprset_tbl_scr
	sep #$30
	ldy   !current_spriteset
	lda [!sprset_tbl_scr],y

	plp
	plx
	sta   !spriteset_offset,x

	ply
	rtl

; x has sprite id
auto_spriteset_alloc:
	phy
	ply
	rts

; pull spriteset before sprite inits run. By default, it uses the low byte of the SP3 graphics
; file number to determine the spriteset.
!ss_sprite_parser_exlevel = $45
!ss_temp_sprite_data_ptr  = $46
ss_set_spriteset:
	ldx.b #$07         ; \
.loop:                     ; | restore hijacked code
	lda $1A,x          ; |
	sta $1462|!addr,x  ; |
	dex                ; |
	bpl .loop          ; /

; todo implement auto-spriteset
bra .skip
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
	tax
;	lda.l 

	tya
	clc
	adc.l sprite_size_table,x
	sec
	sbc #$02
	tay
	bpl ..parse_sprite_entry
	clc
	adc !ss_temp_sprite_data_ptr
	sta !ss_temp_sprite_data_ptr
	ldy #$00
	bra ..parse_sprite_entry

..done:
.skip:
	lda.b #(!exgfx_table>>16)
	sta $8C
	rep #$30
	lda #!exgfx_table
	sta $8A
	lda $010B
	asl #5
	clc
	adc #$0010                 ; SP4 graphics file index
	tay
	sep #$20
	lda [$8A],y
	sta !level_header_sgfx1_lo+0
	iny #2                       ; SP3 graphics file index
	lda [$8A],y
	cmp #$7F
	bne .spriteset_ok
	lda #$00
.spriteset_ok
	sta   !current_spriteset
	iny #2                       ; SP2 graphics file index (now hardcoded to GFX 01)
	lda [$8A],y
	sta !level_header_sgfx1_lo+1
	iny #2                       ; SP1 graphics file index (now hardcoded to GFX 00)
	lda [$8A],y
	sta !level_header_sgfx1_lo+2
	sep #$10
	jml ss_hijack_done|!bank
; AXY are 16 bit here. $8A contains a pointer to the level's ExGFX list, and Y
; is the index to the current file to be uploaded. We will use the lower 8 bits
; of the SP3 ExGFX file number as the spriteset number. The others can be used
; for other things during load time, if desired.
spriteset_setup_lm:
	phx : phy : pha : php
	; note: this code is called with 8-bit axy when not using
	; note: LM's super gfx bypass, 16-bit otherwise. i'd like a more proper
	; note: way to detect this, though: maybe it's in the 32 bytes of
	; note: ram at $7FC000 somewhere.

	; check if we're 16 or 8 bit A:
	; loads EA00 with 16 bit A, or LDA #$00 : NOP
	; with 8-bit A.
	lda #$EA00
	bpl .skip
	sep #$20
	lda $0100|!addr
	cmp #$12
	bne .skip
	cpy #$0010          ; SP4 index
	beq .ss_continue
	cpy #$0012          ; SP3 index
	beq .ss_continue
	cpy #$0014          ; SP2 index
	beq .cont_hardcode
	cpy #$0016          ; SP1 index
	bne .skip
.cont_hardcode:
	plp : pla : plx
	lda.l .hardcoded_files-$14,x
	txy : plx
	jml $0FF900|!bank
.skip:
	plp : pla : ply : plx
	jml $0FF900|!bank
.ss_continue:
	tyx
	rep #$20
	lda.l .nfiles-$10,x
	tay

	; a = current_spriteset * 12
	lda !current_spriteset
	and #$00FF
	asl
	asl
	sta $55
	asl
	clc
	adc $55

	; x will be 0012 or 0010 here
	; the result is an index into the graphics table
	; based on the spriteset number
	adc.l .indexes-$10,x
	tax
.gfx_loop:
	lda.l spriteset_gfx_listing,x
	; decomp gfx
	jsl $0FF900|!bank
	lda.b $00
	clc
	; 1KB file
	adc #$0400
	sta $00
	dex
	dex
	dey
	bpl.b .gfx_loop

	lda #$AD00             ; \ restore original upload destination
	sta $00                ; /
	plp : pla : ply : plx
	rtl
.indexes:
	dw $0002,$000A
.nfiles:
	dw $0002-1,$0004-1
.hardcoded_files:
	dw $0001,$0000
sprset_stuff_done:

incsrc "spriteset_listing.asm"
;incsrc "extra_routines.asm"

;pushpc
;incsrc "remaps.asm"
;pullpc
