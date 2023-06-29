includefrom "engine.asm"

; patch out contatct gfx display in generic sprite interaction for now
org $01A847|!bank
	nop #4


org $00FE94|!addr
fireball_xspeed:
;	db $FD,$03
	db $D0,$30
;fireball_xoffset:
;	db $00,$08,$F8,$10,$F8,$10

org $00FEA8|!addr
mario_shoot_fireball:
	lda !ambient_playerfireballs
	cmp #$02
	bcs .no_shoot
	lda #$06
	sta $1DFC|!addr
	lda #$0a
	sta !player_shoot_fireball_timer
	lda #$30
	sta !ambient_get_slot_yspd
	ldy !player_dir
	lda.w $00FE94,y
;	eor #$30
;	asl #2
	sta !ambient_get_slot_xspd
	lda !player_on_yoshi
	beq .no_yoshi
	iny #2
	lda !player_duck_on_yoshi
	beq .no_yoshi
	iny #2
.no_yoshi:
	lda.w $00FEA2,y
	sta $02
	stz $03

	lda.w $00FE9C,y
	xba
	lda.w $00FE96,y
	rep #$21
	adc !player_x_next
	sta !ambient_get_slot_xpos
	lda $02
	clc
	adc !player_y_next
	sta !ambient_get_slot_ypos
	lda #$003d
	jsl ambient_get_slot
	bcs .no_shoot
	inc !ambient_playerfireballs
.no_shoot:
	rts
warnpc $00FF07|!addr

; generic interaction - replace with stub
org $01AB64|!bank
	jsl spr_give_points

; this table is used as a 'bounce block id'.
; in the original game it was a bit weirder, but the new code
; uses it directly as an ambient sprite id.
org $00F05C|!bank
bounce_ids:
	; todo noteblock with item
	skip 1
	; on/off switch
	db $0D
	; noteblock
	skip 1
	; ? block with directional coins
	db $09
	; note blocks
	skip 2
	; item turn blocks
	db $04,$04,$04,$04,$04,$04,$04
	; turning turn block
	db $03
	; item ? blocks
	db $09,$09,$09,$09
	; multicoin ? block
	db $0A
	; remaining item ? blocks
	db $09,$09,$09,$09,$09
	; turn block with nothing
	db $04
	; side feather turn block, side bounce turn block
	skip 2
	; unused (tile 12c), green star block
	skip 2
	; unused (door tiles...?)
	skip 4
	; ! blocks (green, yellow)
	skip 2
warnpc $00F080|!bank

freecode
fuckme:
	sta !skidsmoke_free_index

;	lda !player_x_next
;	adc #$0004
;	sta $45
;	lda !player_y_next
;	adc #$001A
;	ldy !player_on_yoshi
;	beq .no_yoshi
;	adc #$0010
;.no_yoshi:
;	sta $47
;	lda #$0018
;	sta $49
;
;	lda #$0000
;	jsl ambient_get_slot
	; axy width cleaned up here
	sep #$30
	rtl


; this replaces old sprite types with ambient ones.
; see 'bank2.asm' for the ambient sprite caller
org $00FE56|!bank
mario_turn_smoke_spawn_hijack:
	bne .ret
org $00FE65|!bank
	bcc .ret
	rep #$30
	ldx !skidsmoke_free_index
	lda !player_x_next
	adc #$0004
	sta skidsmoke_status_d.x_pos,x
	lda !player_y_next
	adc #$001A
	sta skidsmoke_status_d.y_pos,x
	lda #$0018
	sta skidsmoke_status_d.timer,x
	txa
	sec
	sbc.w #sizeof(skidsmoke_status_d)
	bpl .next_slot_ok
	lda.w #(!num_skidsmoke_slots-1)*6
.next_slot_ok:
autoclean \
	jsl fuckme
.ret:
	rts
warnpc $00FE94|!bank

org $028779|!bank
	jsl shatter_block
	nop #3

org $028663|!bank
shatter_block:
	phx
;	sta $00
	ldy #$03
.spawn_loop:
	lda !block_xpos
	clc
	adc .xoff,y
	sta !ambient_get_slot_xpos
	lda !block_xpos+1
	adc #$00
	sta !ambient_get_slot_xpos+1

	lda !block_ypos
	clc
	adc .yoff,y
	sta !ambient_get_slot_ypos
	lda !block_ypos+1
	adc #$00
	sta !ambient_get_slot_ypos+1
	lda .xspd,y
	sta !ambient_get_slot_xspd
	lda .yspd,y
	sta !ambient_get_slot_yspd
	lda #$3E
	phy
	jsl ambient_get_slot
	ply
	bcs .abort
;	lda $00
	; fractional bits?
;	sta !ambient_x_speed,y
	dey
	bpl .spawn_loop
.abort:
	plx
	rtl
.xoff:
	db $00,$08,$00,$08
.yoff:
	db $00,$00,$08,$08
.xspd:
	db $F8,$08,$F8,$08
.yspd:
	db $D0,$D0,$E0,$E0
warnpc $0286BE|!bank

; replace bounce block spawns
; $04 has the block id
org $028792|!bank
spawn_ambient_bounce_sprite:
	rep #$20
	lda !block_xpos
	sta !ambient_get_slot_xpos
	lda !block_ypos
	sta !ambient_get_slot_ypos
	; y speed of $C0
	lda #$C000
	sta !ambient_get_slot_xspd
	lda #$0008
	sta !ambient_get_slot_timer
	lda $04
	and #$00FF
	jsl ambient_get_slot

	lda $05
	beq .done
	cmp #$08
	bcs .go_spawn_spr
	cmp #$06
	bcc .go_spawn_spr
	cmp #$07
	bne .spawn_coin
	; todo set multicoin timer
.spawn_coin:
	rep #$20
	lda !block_xpos
	sta !ambient_get_slot_xpos
	lda !block_ypos
	sec
	sbc #$0010
	sta !ambient_get_slot_ypos
	lda #$d000
	sta !ambient_get_slot_xspd
	lda #$0010
	jsl ambient_get_slot
	; inc coin adder, play sfx,
	; track green star block ram
	jml $05B34A|!bank
.done:
	rtl
.go_spawn_spr:
	jmp .spawn_spr
warnpc $0288A1|!bank

org $0288DC|!bank
.spawn_spr:
warnpc $02AD33|!bank
