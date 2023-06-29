org $01801A|!bank
spr_upd_y_no_grv_l:
	jsr.w _spr_upd_y_no_grav
	rtl
spr_upd_x_no_grv_l:
	jsr.w _spr_upd_x_no_grav
	rtl
spr_upd_yx_no_grav_l:
	jsr.w _spr_upd_y_no_grav
	jsr.w _spr_upd_x_no_grav
	rtl
warnpc $018029|!bank

; remap sprite spinjump smoke tiles
org $019A4E|!bank
	db $E4,$E2,$E0,$E2

; 'sprite to spawn' table...
org $01A7C9|!bank
	db $00,$00,$00,$00
	db $04,$04,$04,$04

; todo testing only.
; originally --
;   stores 1540,x|1558,x to c2,x as part of standard stunned routine
org $019628|!bank
code_019624_hijack:
	bra .done
org $01965C|!bank
	nop #3
	nop #3
	nop #2
.done:

; sprite unstun: replace original spike top number check
; todo check if this is actually used
org $0196AF|!bank
	cmp #$04

org $01AA12|!bank
	bra set_stunned_timer_stun
; set stunned timer for sprites: generic interaction
; y has sprite id, a has #$02
org $01AA18|!bank
set_stunned_timer:
	cpy #$A2
	beq .stun_long
	cpy #$0D
	beq .stun_long
	cpy #$04
	bcc .stun
	cpy #$06
	bcs .stun
.stun_long:
	lda #$FF
.stun:
	sta !sprite_misc_1540,x
	lda #$09
	sta !sprite_status,x
	rts
warnpc $01AA33|!bank

org $01A85A|!bank
	jsl spr_give_points

org $01A6C1|!bank
	jsl spr_give_points_y

org $01A667|!bank
	jsl spr_give_points

org $01A619|!bank
	jsl spr_give_points_y

org $01B149|!bank
	jsl spr_give_points

; todo i don't feel like relocating these...
org $01AB75|!bank
spr_display_contact_gfx_s_nosnd_alt:
	bne .exit
	phy

	lda !sprite_x_low,x
	sta !ambient_get_slot_xpos
	lda !sprite_x_high,x
	sta !ambient_get_slot_xpos+1
	lda !sprite_y_low,x
	sta !ambient_get_slot_ypos
	lda !sprite_y_high,x
	sta !ambient_get_slot_ypos+1
	lda #$08
	sta !ambient_get_slot_timer
	lda #$30

	jsl ambient_get_slot
	ply
.exit:
	rtl
warnpc $01AB99|!bank

org $01AB9C|!bank
spr_display_contact_gfx_p_alt:
	bne .exit
	phy

	lda #$08
	sta !ambient_get_slot_timer
	rep #$30

	lda !player_x_next
	sta !ambient_get_slot_xpos

	lda #$0014
	ldy !player_on_yoshi
	beq .not_on_yoshi
	lda #$001E
.not_on_yoshi:
	clc
	adc !player_y_next
	sta !ambient_get_slot_ypos

;	stz !ambient_get_slot_xspd

	lda #$0030
	jsl ambient_get_slot

	ply
.exit:
	rtl
warnpc $01ABCC|!bank
