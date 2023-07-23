;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Para-Beetle, by Romi, modified by imamelia
;
; This is a sprite from SMB3, a Buzzy Beetle that flies through the air and can
; carry the player.
;
; Extra byte 1:
; --dd-ppp
; -: unused
; ppp: palette/speed index
; dd: direction:
;   00: face player
;   01: face left
;   10: face right
;   11: face away from player
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!parabeetle_sprnum = $12
!parabeetle_tile_off_loc = $09

%alloc_sprite_spriteset_1(!parabeetle_sprnum, "smb3_parabeetle", parabeetle_init, parabeetle_main, 1, \
	$10E, \
	$10, $95, $11, $B9, $90, $01)

!para_pal_index       = !sprite_misc_151c
!para_ani_timer       = !sprite_misc_1570
!para_facing_dir      = !sprite_misc_157c
!para_ani_frame       = !sprite_misc_1602
!para_fast_ani_speed  = !sprite_misc_160e
!para_contact_disable = !sprite_misc_154c

%set_free_start("bank1_thwomp")
x_speed:
	db $0C,$0C,$06,$1A,$0C,$14,$0C,$0C        ; normal speeds. order is sequential with the palette (first = palette 8, last = palette F)
parabeetle_init:
	lda !spr_extra_byte_1,x
	and #$07
	sta !para_pal_index,x
	asl
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
.handle_dir:
	lda $94
	cmp !sprite_x_low,x
	lda $95
	sbc !sprite_x_high,x
	bpl .facing_right
	inc !para_facing_dir,x
.facing_right:
	lda !spr_extra_byte_1,x
	and #$30
	beq .exit
	cmp #$30
	beq .face_away
	lsr #4
	dec
	eor #$01
	sta !para_facing_dir,x
.exit
	rtl

.face_away:
	lda !para_facing_dir,x
	eor #$01
	sta !para_facing_dir,x
	rtl

parabeetle_main:
	ldy !para_ani_frame,x
	lda gfx_tiles,y
	jsl spr_gfx_single
	lda !sprites_locked
	bne .done
	lda !sprite_status,x
	cmp #$08
	bcs .cont
.dead:
	lda #$80
	ora !sprite_oam_properties,x
	sta !sprite_oam_properties,x
.done:
	rtl
.cont:
	jsr.w _suboffscr2_bank1

	inc !para_ani_timer,x
	lda !para_ani_timer,x
	lsr #2
	ldy !para_fast_ani_speed,x
	bne .fastor_ani
	lsr
.fastor_ani:
	and #$01
	sta !para_ani_frame,x
	ldy !para_pal_index,x
	lda x_speed,y
	ldy !para_facing_dir,x
	beq .no_invert_speed
	eor #$FF
	inc
.no_invert_speed:
	sta !sprite_speed_x,x
	lda !para_fast_ani_speed,x
	bne .speed_update
	lda #$01
	ldy !sprite_speed_y,x
	beq .speed_update
	bmi .YSpeed000
	dec : dec
.YSpeed000:
	clc
	adc !sprite_speed_y,x
	sta !sprite_speed_y,x
.speed_update
	jsr.w _spr_upd_y_no_grav
	jsr.w _spr_upd_x_no_grav
	lda !sprite_movement
	sta !sprite_misc_1528,x
	lda #$B9
	ldy !invincibility_timer
	beq .no_default_interact
	lda #$39
.no_default_interact:
	sta !sprite_tweaker_167a,x
	lda !sprite_being_eaten,x
	bne Return2_ret
	
	jsr.w _sprspr_mario_spr_rt
	bcc Return2

;	jsr.w _spr_invis_solid_rt
	jsr.w _spr_invis_solid_rt_c
	bcc .SpriteWins
	lda !para_fast_ani_speed,x
	bne .PlayerWins000
	lda #$01
	sta !para_fast_ani_speed,x
	lda #$10
	sta !sprite_speed_y,x
.PlayerWins000
	lda #$08
	sta !para_contact_disable,x
	lda !sprite_speed_y,x
	dec
	cmp #$F0
	bmi .Return
	sta !sprite_speed_y,x
.Return
	rtl
.SpriteWins
	lda !para_contact_disable,x
	bne Return2
	jsl hurt_mario
Return2:
	lda !para_contact_disable,x
	bne .ret
	stz !para_fast_ani_speed,x
.ret:
	rtl
gfx_tiles:
	db $00, $02
parabeetle_done:
%set_free_finish("bank1_thwomp", parabeetle_done)
