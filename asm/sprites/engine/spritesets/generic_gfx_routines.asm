includefrom "spritesets.asm"

spr_tmap_off = $019C7F|!bank
spr_tiles    = $019B83|!bank

; subspr gfx 0 optimization
org $019CFC|!bank
	; saves a byte, originally LDY/TYA for no discernable reason
	LDA.b $0F
	CLC
	ADC.b $01
	STA.b $01
	%sprite_num(LDY,x)
	LDA.w !1602,x
	ASL   #2
	ADC.w spr_tmap_off,y
	STA.b $02
	LDA.w !15F6,x
	ORA.b $64
	STA.b $03
	LDY.w !15EA,x
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
	LDA.w !15F6,x
	STA.b $02
	%sprite_num(LDA,x)
	CMP.b #$0F
	BCS .nostdsprite
	; standard sprites with wings use the first
	; assigned oam slot, apparently
	INY #4
.nostdsprite
	STY.b $05
	%sprite_num(LDY,x)
	LDA.w !1602,x
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
	LDA.w !157C,x
	LSR
	LDA.b #$00
	ORA !15F6,x
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
	ORA.w !15A0,x
	STA.w $0460|!addr,y
	STA.w $0461|!addr,y
	JMP.w $01A3DF|!bank
getdrawinfo_generic_prefix:
	LDA   !spriteset_offset,x
	STA.b !tile_off_scratch
	JMP.w $01A365|!bank
; todo mark free space here to be usable
warnpc $019E0D|!bank

; subsprgfx 2 optimization
org $019F0D|!bank
sub_spr_gfx_2:
	STZ.b $04
	JSR.w getdrawinfo_generic_prefix|!bank
org $019F27|!bank
	; carry cleared at $019F1C, we get to save a (needed) byte
	ADC.b !tile_off_scratch
	STA.w $0302|!addr,y
	LDX.w $15E9|!addr
	LDA.b $00
	STA.w $0300|!addr,y
	LDA.b $01
	STA.w $0301|!addr,y
	; saves a byte (1/2): stored earlier but this routine just reloaded from the table?
	LDA.b $02
	LSR
	LDA.b #$00
	ORA.w !15F6,x
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
	ORA.w !15A0,x
	STA $0460|!addr,y
	; saves a byte (2/2): originally jsr'd then rts'd after. we just JMP and save the byte + 12 cycles
	JMP.w $01A3DF|!bank
warnpc $019F5B|!bank
