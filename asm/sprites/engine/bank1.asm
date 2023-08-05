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

org $01803D|!bank
	jsr.w _sprspr_mario_spr_rt

%set_free_start("bank1_spr0to13")
_spr_kick:
	lda #$10
	sta !player_kicking_timer
	%write_sfx("kick")
	jsl sub_horz_pos
	lda .spd,y
	sta !sprite_speed_x,x
	lda #$E0
	sta !sprite_speed_y,x
	lda #$02
	sta !sprite_status,x
	sty !player_dir
	dec
	jsl spr_give_points
	rts
.spd:
	db $F0, invert($F0)
spr_killed:
	lda !sprite_num,x
	cmp #!throwblock_sprnum
	bne .not_throwblock
	; todo impl break throw block
	stz !sprite_status,x
	rtl

.not_throwblock:
	lda !sprite_tweaker_1656,x
	bpl sprite_die_no_smoke
sprite_set_spinkill_l:
	lda #$04
	sta !sprite_status,x
	; timer to die in state 4
	lda #$14
	sta !sprite_misc_1540,x
	rtl

sprite_die_no_smoke:
	lda !sprites_locked
	bne .no_pos_update
	jsr.w _spr_upd_pos
	lda #$00
.no_pos_update:
	jsl sub_off_screen
	lda !sprite_tweaker_167a,x
	and #!spr_167a_prop_keep_clipping_on_starkill
	beq .no_call_main
	jmp spr_handle_main

.no_call_main:
	; yeah i guess this is fine
	jml spr_gfx_2

spr_spinkill:
	lda !sprite_misc_1540,x
	beq .die
	lsr #3
	and #$03
	tay
	; clean up tile offset to draw properly
	;  TODO might be better as part of the code that sets sprite state to 4
	stz !spr_spriteset_off,x
	lda !sprite_oam_properties,x
	and #(~$01)
	sta !sprite_oam_properties,x
	lda .smoke_tiles,y
	jml spr_gfx_single_have_tile

.die:
	; TODO originally was a call to the 'erase sprite' part of suboffscreen.
	;      make a small routine for this when reintroducing sprites that auto-respawn
	;      such as lakitu and the magikoopa
	stz !sprite_status,x
	rtl
.smoke_tiles:
	db $64,$62,$60,$62

_sprspr_mario_spr_rt:
	jsr.w _spr_spr_interact
	jmp.w _mario_spr_interact
.done:
%set_free_finish("bank1_spr0to13", _sprspr_mario_spr_rt_done)

; remap sprite spinjump smoke tiles
;org $019A4E|!bank
;	db $E4,$E2,$E0,$E2

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

; kick kill - needs fix as fish data tables overwrite some code currently
;org $01B149|!bank
;	jsl spr_give_points

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

	lda #$0030
	jsl ambient_get_slot

	ply
.exit:
	rtl
warnpc $01ABCC|!bank
