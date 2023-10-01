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
	rtl

spr_spinkill:
	lda !sprite_misc_1540,x
	beq .die
	lsr #3
	and #$03
	sta !sprite_misc_1602,x
	; clean up tile offset to draw properly
	;  TODO might be better as part of the code that sets sprite state to 4?
	stz !spr_spriteset_off,x
	lda !sprite_oam_properties,x
	and #(~$01)
	sta !sprite_oam_properties,x
	; setup table
	%set_spr_gfx_rt(spr_gfx_single)
	lda.b #.smoke_tiles
	sta !spr_gfx_tbl_lo,x
	lda.b #.smoke_tiles>>8
	sta !spr_gfx_tbl_hi,x
	lda.b #bank(.smoke_tiles)
	sta !spr_gfx_tbl_bk,x
	rtl

.die:
	; TODO originally was a call to the 'erase sprite' part of suboffscreen.
	;      make a small routine for this when reintroducing sprites that auto-respawn
	;      such as lakitu and the magikoopa
	stz !sprite_status,x
	rtl
.smoke_tiles:
	db $64,$62,$60,$62

; TODO handle springboard, pballoon turning to normal state here? what's up with that
;      springboard probably wants to go from 0b->08 immediately
_spr_stunned:
	; TODO introduce a cfg bit for this?
	lda !sprite_num,x
	cmp #!springboard_sprnum
	bne .cont
.set_normal:
	stz !sprite_speed_y,x
	lda #$08
	sta !sprite_status,x
	rtl

.cont:
	jsr _spr_handle_stun_tmr
	jsr _spr_upd_pos
	%spr_on_ground()
	beq .airborne
	jsr _ground_spr_speed_adj
	lda !sprite_num,x
	cmp #!fish_sprnum
	beq .set_normal
	; TODO yoshi check was here
.airborne:
	%spr_touching_ceil()
	beq .no_block_interact
	lda #$10
	sta !sprite_speed_y,x
	%spr_touching_wall()
	bne .no_block_interact
	lda !sprite_x_low,x
	clc
	adc #$08
	sta !block_xpos
	lda !sprite_x_high,x
	adc #$00
	sta !block_xpos+1
	lda !sprite_y_low,x
	and #$F0
	sta !block_ypos
	lda !sprite_y_high,x
	sta !block_ypos+1
	ldy #$00
	%spr_obj_blocked(!sprite_blocked_layer2_below)
	beq .set_layer
	iny
.set_layer
	sty !current_layer_process
	ldy #$00
	lda !map16_hi_table
	jsl kick_spr_hit_block
	lda #$08
	sta !sprite_cape_disable_time,x
.no_block_interact:
	%spr_touching_wall()
	beq .interact
	lda !sprite_num,x
	cmp #$0d
	bcc .no_koopa_special
	; TODO somethign about this
	jsr $999E
.no_koopa_special
	; signed divide by 2?
	lda !sprite_speed_x,x
	asl
	php
	ror !sprite_speed_x,x
	plp
	ror !sprite_speed_x,x
.interact:
	jsr _sprspr_mario_spr_rt
	jsr _suboffscr0_bank1
	rtl

_spr_carried:
	; todo pipe/yoshi prio stuff, probably handle that elsewhere?
	; todo p-balloon is 'carried' while mario is using that, reimpl
	jsr _spr_obj_interact
	lda !player_ani_trigger_state
	; todo why not just bne?
	cmp #$01
	bcc .dont_uncarry
	lda !yoshi_in_pipe
	bne .dont_uncarry
	lda #$09
	sta !sprite_status,x
.exit:
	rtl

.dont_uncarry:
	lda !sprite_status,x
	cmp #$08
	beq .exit
	; no need to check sprites locked
	jsr _spr_handle_stun_tmr
	jsr _spr_spr_interact
	lda !yoshi_in_pipe
	bne .code_01a011
	bit !byetudlr_hold
	bvc .y_not_held
.code_01a011:
	; todo port
	jsr _set_carried_spr_pos
	rtl

.y_not_held:
	; ?
	stz !sprite_misc_1626,x
	ldy #$00
	lda !sprite_num,x
	; TODO goomba (weird logic...?)
	cmp #$0F
	bne .not_goom
	lda !player_in_air
	bne .not_goom
	ldy #$ec
.not_goom:
	sty !sprite_speed_y,x
	lda #$09
	sta !sprite_status,x
	lda !byetudlr_hold
	and #$08
	bne .kick_up
	lda !sprite_num,x
	cmp #$15
	bcs .check_drop
	lda !byetudlr_hold
	and #$04
	beq .kick
	bra .drop

.check_drop:
	lda !byetudlr_hold
	and #$03
	bne .kick
.drop:
	ldy !player_dir
	lda !player_x_current
	clc
	adc ..spr_x_off_lo,y
	sta !sprite_x_low,x
	lda !player_x_current+1
	adc ..spr_x_off_hi,y
	sta !sprite_x_high,x
	jsr _sub_horz_pos_bank1
	lda ..spr_x_spd_off,y
	clc
	adc !player_x_spd
	sta !sprite_speed_x,x
	stz !sprite_speed_y,x
	bra .finish_spr_transition
..spr_x_off_lo:
	db $F3,$0D
..spr_x_off_hi:
	db $FF,$00
..spr_x_spd_off:
	db $FC,$04

.kick_up:
	jsl display_contact_gfx_s
	lda #$90
	sta !sprite_speed_y,x
	lda !player_x_spd
	sta !sprite_speed_x,x
	asl
	ror !sprite_speed_x,x
	bra .finish_spr_transition
.kick:
	jsl display_contact_gfx_s
	;lda !sprite_misc_1540,x
	;sta !sprite_misc_c2,x
	lda #$0a
	sta !sprite_status,x
	ldy !player_dir
	lda !player_on_yoshi
	beq ..not_on_yoshi
	iny #2
..not_on_yoshi:
	lda c_shell_speed_x,y
	sta !sprite_speed_x,x
	eor !player_x_spd
	bmi .finish_spr_transition
	lda !player_x_spd
	sta $00
	asl $00
	ror
	clc
	adc c_shell_speed_x,y
	sta !sprite_speed_x,x
.finish_spr_transition:
	lda #$10
	sta !sprite_misc_154c,x
	lda #$0c
	sta !player_kicking_timer
	rtl

; todo reloc
c_shell_speed_x = $019F6B|!bank

_spr_kicked:
	rtl

_sprspr_mario_spr_rt:
	jsr _spr_spr_interact
	jmp _mario_spr_interact
.done:
%set_free_finish("bank1_spr0to13", _sprspr_mario_spr_rt_done)

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
