includefrom "engine.asm"

spr_tmap_off = $019C7F|!bank
spr_tiles    = $019B83|!bank

; subspr gfx 0 optimization
org $019CF3|!bank
_sub_spr_gfx_0:
	ldy #$00
.entry_1:
	sta $05
	sty $0F
	jsr _get_draw_info_bank1
	; saves a byte, originally LDY/TYA for no discernable reason
	LDA.b $0F
	CLC
	ADC.b $01
	STA.b $01
	;%sprite_num(LDY,x)
	ldy !sprite_num,x
	LDA.w !sprite_misc_1602,x
	ASL   #2
	ADC.w spr_tmap_off,y
	STA.b $02
	LDA.w !sprite_oam_properties,x
	ORA.b $64
	STA.b $03
	LDY.w !sprite_oam_index,x
	LDA.b #$03
	STA.b $04
subspr_gfx0_drawloop:
	; move tile store up: skip carry clear due to ASL above, and
	; ASL for props after should ensure its clear on loop iters)
	LDA.b $02
	ADC.b $04
	TAX
	LDA.w spr_tiles,x
	LDX.b $04
	STA.w $0302|!addr,y
	LDA.b $00
	ADC.w $019CD3|!bank,x
	STA.w $0300|!addr,y
	LDA.b $01
	CLC
	ADC $019CD7|!bank,x
	STA $0301|!addr,y
	LDA.b $05
	ASL   #2
	ADC.b $04
	TAX
	LDA.w $019CDB|!bank,x
	ORA.b $03
	STA.w $0303|!addr,y
	INY #4
	DEC.b $04
	BPL subspr_gfx0_drawloop
	LDX.w $15E9|!addr
	LDA.b #$03
	LDY.b #$00
	JMP.w _finish_oam_write|!bank
warnpc $019D5F|!bank

org $019D67|!bank
sub_spr_gfx_1:
	JSR.w getdrawinfo_generic_prefix|!bank
	LDA.w !sprite_oam_properties,x
	STA.b $02
	;%sprite_num(LDA,x)
	lda !sprite_num,x
	CMP.b #$0F
	BCS .nostdsprite
	; standard sprites with wings use the first
	; assigned oam slot, apparently
	INY #4
.nostdsprite
	STY.b $05
	;%sprite_num(LDY,x)
	ldy !sprite_num,x
	LDA.w !sprite_misc_1602,x
	ASL
	; generic sprite routine: tilemap offsets
	ADC.w spr_tmap_off,y
	TAX
	; generic sprite routine: sprite tiles
	LDA.w spr_tiles,x
	ADC.b !tile_off_scratch
	STA.b $03
	LDA.w spr_tiles+1,x
	ADC.b !tile_off_scratch
	STA.b $04
	LDX.w $15E9|!addr
	LDY.b $05
	LDA.b $02
	BPL.b .rightside_up
	LDA.b $03
	STA.w $0306|!addr,y
	LDA.b $04
	STA.w $0302|!addr,y
	BRA.b .tile_done
.rightside_up
	LDA.b $03
	STA.w $0302|!addr,y
	LDA.b $04
	STA.w $0306|!addr,y
.tile_done
	LDA.b $01
	STA.w $0301|!addr,y
	CLC
	ADC.b #$10
	STA.w $0305|!addr,y
	LDA.b $00
	STA.w $0300|!addr,y
	STA.w $0304|!addr,y
	LDA.w !sprite_misc_157c,x
	LSR
	LDA.b #$00
	ORA !sprite_oam_properties,x
	BCS .face_other_side
	ORA.b #$40
.face_other_side
	ORA.b $64
	STA.w $0303|!addr,y
	STA.w $0307|!addr,y
	TYA
	LSR   #2
	TAY
	LDA.b #$02
	ORA.w !sprite_off_screen_horz,x
	STA.w $0460|!addr,y
	STA.w $0461|!addr,y
	JMP.w $01A3DF|!bank
getdrawinfo_generic_prefix:
	LDA   !spr_spriteset_off,x
	STA.b !tile_off_scratch
	;LDA   !spr_spriteset_off_hi,x
	;STA.b !tile_off_scratch+1
	JMP.w $01A365|!bank

; todo mark free space here to be usable
ssgfx2_tilestore_temp:
	rep #$21
	and #$00ff
	adc !tile_off_scratch
	sep #$20
	sta $0302|!addr,y
	xba
	tsb $04
	rts
warnpc $019E0D|!bank

; subsprgfx 2 optimization
org $019F0D|!bank
sub_spr_gfx_2:
	STZ.b $04
	JSR.w getdrawinfo_generic_prefix|!bank
org $019F27|!bank
	; carry cleared at $019F1C, we get to save a (needed) byte
	jsr ssgfx2_tilestore_temp
;	ADC.b !tile_off_scratch
;	STA.w $0302|!addr,y
	LDX.w $15E9|!addr
	LDA.b $00
	STA.w $0300|!addr,y
	LDA.b $01
	STA.w $0301|!addr,y
	; saves a byte (1/2): stored earlier but this routine just reloaded from the table?
	LDA.b $02
	LSR
	LDA.b #$00
	ORA.w !sprite_oam_properties,x
	BCS .noflip
	EOR.b #$40
.noflip:
	ORA.b $04|!bank
	ORA.b $64|!bank
	STA.w $0303|!addr,y
	TYA
	LSR  #2
	TAY
	LDA #$02
	ORA.w !sprite_off_screen_horz,x
	STA $0460|!addr,y
	; saves a byte (2/2): originally jsr'd then rts'd after. we just JMP and save the byte + 12 cycles
	JMP.w $01A3DF|!bank
warnpc $019F5B|!bank

;;; finish oam write ;;;
org $018E5B|!bank
	JMP.w _finish_oam_write|!bank
; generic sprgfx routine 0 handled by rewrite
;org $019D5B|!bank
;	JMP.w _finish_oam_write|!bank
org $01B380|!bank
	JMP.w _finish_oam_write|!bank
org $01B69C|!bank
	JMP.w _finish_oam_write|!bank
org $01BD95|!bank
	JMP.w _finish_oam_write|!bank
org $01C172|!bank
	JMP.w _finish_oam_write|!bank
org $01D4E4|!bank
	JMP.w _finish_oam_write|!bank
org $01DC06|!bank
	JMP.w _finish_oam_write|!bank
org $01E266|!bank
	JMP.w _finish_oam_write|!bank
org $01E4B0|!bank
	JSR.w _finish_oam_write|!bank
org $01E94E|!bank
	JSR.w _finish_oam_write|!bank
org $01E95B|!bank
	JSR.w _finish_oam_write|!bank
org $01FF4F|!bank
	JMP.w _finish_oam_write|!bank

; stick tile offset in finishoamwrite
;org finish_oam_write
org $01B7B3|!bank
finish_oam_write:
; the phb/phk/plb wrapper isnt at all necessary, so don't do it
JSR.w _finish_oam_write|!bank
RTL
; this is an optimized version of the routine, yoinked from PIXI
; attributed to Akaginite
_finish_oam_write:
	STY $0B
	STA $08
	LDA !spriteset_offset,x
	STA $0A

	LDA !sprite_y_low,x
	SEC
	SBC $1C
	STA $00
	LDA !sprite_y_high,x
	SBC $1D
	STA $01
	LDY !sprite_oam_index,x
	LDA !sprite_x_high,x
	XBA
	LDA !sprite_x_low,x
	REP #$20
	SEC
	SBC $1A
	STA $02
	TYA
        LSR #2
	TAX
	SEP #$21

.loop:
	LDA $0300|!addr,y
	SBC $02
	REP #$21
	BPL +
	ORA.w #$FF00
+
	ADC $02
	CMP.w #$0100
	TXA
	SEP #$20
	LDA $0B
	BPL +
	LDA $0460|!addr,x
	AND #$02
+
	ADC #$00
	STA $0460|!addr,x
	LDA $0301|!addr,y
	SEC
	SBC $00
	REP #$21
	BPL +
	ORA.w #$FF00
+
	ADC $00
	CLC
	ADC.w #$0010
	CMP.w #$0100
	BCC .next
	LDA.w #$00F0
	SEP #$20
	STA $0301|!addr,y
.next:
	SEP #$21
	LDA $0302|!addr,y
	BMI .no_tileoff
	CLC
	ADC $0A
	STA $0302|!addr,y
	SEC
.no_tileoff
	INY #4
	INX
	DEC $08
	BPL .loop
	LDX $15E9|!addr
	RTS
warnpc $01B844|!bank
