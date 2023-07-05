includefrom "list.def"

; todo clean this up maybe by moving to bank 1 and using
;      thwomps 'direction abstraction' setup, to unify the speed
;      change code?

!cloud_drop_sprnum = $69

%alloc_sprite_spriteset_2(!cloud_drop_sprnum, "yi_cloud_drop", cloud_drop_init, cloud_drop_main, 2, \
	$102, $103, \
	$80, $80, $37, $19, $91, $44)

!cloud_drop_orient  = !spr_extra_bits
!cloud_drop_turning = !sprite_misc_1570
!cloud_drop_dir     = !sprite_misc_157c
!cloud_drop_top_spd = !spr_extra_byte_1

;Graphics defines:
; Horizontal
!Head1 =	$2A	; head frame 1
!Head2 =	$2C	; head frame 2
!Head3 =	$2E	; head frame 3
!Head4 =	$00	; head frame 4
!Head5 =	$02	; head frame 5
!Tail =		$14	; tail
!Tail2 =        $15     ; second tail frame

; Vertical
!VHead1 =	$20	; head frame 1
!VHead2 =	$22	; head frame 2
!VHead3 =	$24	; head frame 3
!VHead4 =	$26	; head frame 4
!VHead5 =	$28	; head frame 5
!VTail  =	$04	; tail

; todo this clusterfuck can almost certainly be cleaned up. do so
%set_free_start("bank6")
cloud_drop_init:
;	lda !spr_extra_byte_2,x
;	jsl spr_init_pos_offset

	lda !cloud_drop_top_spd,x
	bmi .backwards
	inc !cloud_drop_dir,x
	eor #$FF
	sta $00
	bra .continue
.backwards
	inc
	and #$7F                   ; \ need positive speed in spr_extra_byte_1, so fix it.
	dec                        ; | original code didnt do a 'proper' inversion, so
	sta !cloud_drop_top_spd,x  ; / adust accordingly
	sta $00
	lda !cloud_drop_orient,x
	beq .xposadj
	lda !sprite_y_high,x       ; \ For some reason, when starting 'backwards'
	xba                        ; | the sprite is three pixels 'off'.
	lda !sprite_y_low,x        ; | Since I'm a nasty little bastard,
	rep #$20                   ; | I just adjust the sprite's position
	clc : adc #$0003           ; | and call it a day.
	sep #$20                   ; |
	sta !sprite_y_low,x        ; |
	xba                        ; /
	STA !sprite_y_high,x
	bra .continue
.xposadj
	lda !sprite_x_high,x       ; \ For some reason, when starting 'backwards'
	xba                        ; | the sprite is three pixels 'off'.
	lda !sprite_x_low,x        ; | Since I'm a nasty little bastard,
	rep #$20                   ; | I just adjust the sprite's position
	clc : adc #$0003           ; | and call it a day.
	sep #$20                   ; |
	sta !sprite_x_low,x        ; |
	xba                        ; /
	sta !sprite_x_high,x
.continue

	lda !cloud_drop_orient,x
	beq +
	lda $00
	sta !sprite_speed_y,x
	stz !cloud_drop_turning,x
	rtl
+
	lda $00
	sta !sprite_speed_x,x
	stz !cloud_drop_turning,x
	rtl

cloud_drop_main:
	jsr GFX
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	ora !sprite_being_eaten,x
	beq .cont
	rtl
.cont
	lda #$03
	jsl sub_off_screen
	lda !cloud_drop_turning,x
	beq .not_turning
	inc !cloud_drop_turning,x
	cmp #$13
	bne .interact
	lda !cloud_drop_dir,x
	eor #$01
	sta !cloud_drop_dir,x
	lda !cloud_drop_orient,x
	beq .x_dir
.y_dir:
	lda !cloud_drop_top_spd,x
	ldy !cloud_drop_dir,x
	eor .spd_eor_tbl,y
	clc
	adc .spd_twoc_tbl,y
	sta !sprite_speed_y,x
	bra .spd_chg_done
.x_dir:
	lda !cloud_drop_top_spd,x
	ldy !cloud_drop_dir,x
	eor .spd_eor_tbl,y
	clc
	adc .spd_twoc_tbl,y
	sta !sprite_speed_x,x
.spd_chg_done:
	stz !cloud_drop_turning,x
	bra .interact
.not_turning:
	ldy !cloud_drop_dir,x
	lda !cloud_drop_orient,x
	beq .x_spd
.y_spd:
	lda !sprite_speed_y,x
	clc
	adc .inc_dec_tbl,y
	sta !sprite_speed_y,x
	bne .interact
	inc !cloud_drop_turning,x
	bra .interact
.x_spd:
	lda !sprite_speed_x,x
	clc
	adc .inc_dec_tbl,y
	sta !sprite_speed_x,x
	bne .interact
	inc !cloud_drop_turning,x
.interact:
	; todo use names
	jsl spr_upd_yx_no_grav_l
	jsl $01A7DC|!bank		;mario interact
	jml $018032|!bank		;sprites

	; right, left. Sub if going right, add if going left.
.inc_dec_tbl:
	db $FF,$01
.spd_eor_tbl:
	db $00,$FF
.spd_twoc_tbl:
	db $00,$01

TILEMAP:
db !Head1,!Tail
db !Head2,!Tail
db !Head3,!Head3
db !Head4,!Head4
db !Head5,!Tail2
.SIZE
db $02,$00
db $02,$00
db $02,$02
db $02,$02
db $02,00

XDISP:
db $00,$10
db $00,$0E
db $00,$00
db $00,$00
db $00,$F8

db $00,$F8
db $00,$FA
db $00,$00
db $00,$00
db $00,$10

YDISP:
db $00,$05
db $00,$03
db $00,$00
db $00,$00
db $00,$04

PROP:	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$40

	db $40,$40
	db $40,$40
	db $40,$40
	db $40,$40
	db $40,$00

; TODO clean this, this has to be able to be better, right?
GFX:
	jsl get_draw_info

	STZ $08		; reset
	STZ $06
	STZ $07
	STZ $05

	LDA !sprite_oam_properties,x	;store sprite properties
	STA $04

LDA !spr_extra_bits,x
BEQ +
JMP Vert
+
	LDA !cloud_drop_dir,x	;flip
	BNE No_Mirror

	LDA #$0A	;skip past entries with no flip
	STA $06
	STA $05

No_Mirror:
	LDA !cloud_drop_turning,x	;frame counter for sprite frames
	LSR #2		;each 8 frames
	ASL		;drop a bit, 2 bytes per entry
	STA $09		;add frame value to indexes

	LDA $08		;chr index
	CLC
	ADC $09
	STA $08
	LDA $06		;xindex
	CLC
	ADC $09
	STA $06
	LDA $07		;yindex
	CLC
	ADC $09
	STA $07
	LDA $05		;$05
	CLC
	ADC $09
	STA $05
	
	LDX #$00	;loop index zero
	STX $0D
OAM_Loop:
	TXA
	CLC
	ADC $06
	PHX
	TAX
	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!addr,y	;xpos
	PLX

	TXA			;loop index into A
	CLC
	ADC $07			;add index bits
	PHX			;preserve loop index
	TAX			;and we have a prepared YDISP index
	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!addr,y	;ypos
	PLX			;restore loop index

	TXA			;same process as seen above
	CLC
	ADC $08
	PHX
	TAX
	LDA TILEMAP,x
	STA $0302|!addr,y	;CHR

	PHY
	TYA                     ; \
	LSR #2                  ; | index into oam extra bits table
	TAY                     ; /
	LDA TILEMAP_SIZE,x
	STA $0460|!addr,y
	PLY

	PLX

	TXA
	CLC
	ADC $05
	PHX
	TAX
	LDA PROP,x
	ORA $04
	ORA $64			;level bits
	STA $0303|!addr,y
	PLX

	INY #4
	INX
	CPX #$02		;3 loops
	BNE OAM_Loop

	LDX $15E9|!addr
	LDY #$FF
	LDA #$01
	JSL finish_oam_write|!bank
	RTS

VTILEMAP:
db !VHead1,!VTail
db !VHead2,!VTail
db !VHead3,!VHead3
db !VHead4,!VHead4
db !VHead5,!VTail
.SIZE
db $02,$00
db $02,$00
db $02,$02
db $02,$02
db $02,$00

VXDISP:	db $00,$04
	db $00,$04
	db $00,$00
	db $00,$00
	db $00,$04

VYDISP:	db $00,$10
	db $00,$0B
	db $00,$00
	db $00,$00
	db $00,$F8

	db $00,$F8
	db $00,$FE
	db $00,$00
	db $00,$00
	db $00,$10

VPROP:	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$00
	db $00,$80

	db $80,$80
	db $80,$80
	db $80,$80
	db $80,$80
	db $80,$00

Vert:
	LDA !cloud_drop_dir,x	;flip
	BNE .No_Mirror

	LDA #$0A	;skip past entries with no flip
	STA $06
	STA $05

.No_Mirror:
	LDA !cloud_drop_turning,x	;frame counter for sprite frames
	LSR #2		;each 8 frames
	ASL		;drop a bit, 2 bytes per entry
	STA $09		;add frame value to indexes

	LDA $08		;chr index
	CLC
	ADC $09
	STA $08
	LDA $07		;xindex
	CLC
	ADC $09
	STA $07
	LDA $06		;yindex
	CLC
	ADC $09
	STA $06
	LDA $05		;$05
	CLC
	ADC $09
	STA $05
	
	;PHX		;preserve sprite index
	LDX #$00	;loop index zero
	
.OAM_Loop:
	TXA
	CLC
	ADC $07
	PHX
	TAX	
	LDA $00
	CLC
	ADC VXDISP,x
	STA $0300|!addr,y	;xpos
	PLX

	TXA			;loop index into A
	CLC
	ADC $06			;add index bits
	PHX			;preserve loop index
	TAX			;and we have a prepared YDISP index
	LDA $01
	CLC
	ADC VYDISP,x
	STA $0301|!addr,y	;ypos
	PLX			;restore loop index

	TXA			;same process as seen above
	CLC
	ADC $08
	PHX
	TAX
	LDA VTILEMAP,x
	STA $0302|!addr,y	;CHR

	PHY
	TYA                     ; \
	LSR #2                  ; | index into oam extra bits table
	TAY                     ; /
	LDA VTILEMAP_SIZE,x
	STA $0460|!addr,y
	PLY

	PLX

	TXA
	CLC
	ADC $05
	PHX
	TAX
	LDA VPROP,x
	ORA $04
	ORA $64			;level bits
	STA $0303|!addr,y
	PLX

	INY #4
	INX
	CPX #$02		;3 loops
	BNE .OAM_Loop

	LDX $15E9|!addr
	LDY #$FF		;16x16 tiles
	LDA #$01		;2 tiles
	jsl finish_oam_write
	rts

cloud_drop_done:
%set_free_finish("bank6", cloud_drop_done)
