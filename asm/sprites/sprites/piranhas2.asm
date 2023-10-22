; big thanks to imamelia for the original

%alloc_sprite_spriteset_1(!piranhas_sprite_id, "piranha_plants", piranha_plants_init, piranha_plants_main, 5, \
	$113, \
	$81, $01, $00, $00, $10, $20, \
	piranha_plants_gfx_ptrs, \
	!spr_norm_gfx_generic_rt_id)

!piranha_exbyte_invert   = $01
!piranha_exbyte_horz     = $02
!piranha_exbyte_orient   = !piranha_exbyte_invert|!piranha_exbyte_horz

!piranha_exbyte_is_red   = $04
!piranha_exbyte_length   = $08
!piranha_exbyte_is_venus = $10
!piranha_exbyte_venus_shoot_kind = $E0

!piranha_prox_check_dist = $37

!piranha_phase          = !sprite_misc_c2
!piranha_head_ani_off   = !sprite_misc_151c
!piranha_x_low_bak      = !sprite_misc_1528
!piranha_y_low_bak      = !sprite_misc_1534
!piranha_phase_timer    = !sprite_misc_1540
!piranha_head_ani_timer = !sprite_misc_1570
!piranha_in_pipe        = !sprite_misc_1594
!piranha_ani_frame      = !sprite_misc_1602
!venus_shoot_kind       = !sprite_misc_187b

; clear: vert
; set: horiz
!piranha_hv             = !sprite_misc_160e
!piranha_is_venus       = !sprite_misc_1626

; exbit setup:
; sssvlcoo
; oo: orientation
;  00: starts down, moves up
;  01: starts up, moves down
;  02: starts right, moves left
;  03: starts left, moves right
; c: (stem) color
;  0: green. enables player proximity checks
;  1: red. disables player proximity checks
; l: (stem) length
;  0: long (16x16 stem). Head becomes green
;  1: short (8x16 stem). Head becomes green
; v: venus flag
;  0: normal piranha
;  1: venus piranha, shoot fireballs
; s: venus shoot kind
;  001: one fireball, smb3 style
;  010: two fireballs, smb3 style
;  011-111: undefined

%set_free_start("bank1_koopakids")
piranha_set_ani_frame:
	lda !piranha_is_venus,x
	bne .venus_ani
	inc !piranha_head_ani_timer,x
	lda !piranha_head_ani_timer,x
	and #$08
	lsr #2
	sta !piranha_head_ani_off,x
.exit:
	rts

.venus_ani:
	ldy !piranha_phase,x
	lda ..frames,y
	sta !piranha_head_ani_off,x
..venus_face:
	cpy #$01
	bcs .exit
	lda !piranha_hv,x
	bne ...horz
	jsl sub_horz_pos
	tya
	sta !sprite_misc_157c,x
	rts

...horz:
	jsl sub_vert_pos
	lda !sprite_oam_properties,x
	and #$7F
	ora ....props,y
	sta !sprite_oam_properties,x
	rts

....props:
	db $00,$80
..frames:
	db $00,$00,$02,$00

venus_face:
	lda !piranha_hv,x
	bne .horz
	jsl sub_horz_pos
	tya
	sta !sprite_misc_157c,x
	rts
.horz:
	jsl sub_vert_pos
	rts

venus_check_shoot:
	ldy !venus_shoot_kind,x
	lda .rts_lo,y
	sta $00
	lda .rts_hi,y
	sta $01
	lda !piranha_phase_timer,x
	jmp ($0000)

.rts_lo:
	db .shoot_once
	db .shoot_twice
.rts_hi:
	db .shoot_once>>8
	db .shoot_twice>>8

.shoot_twice:
	cmp #$61
	beq shoot_fire
.shoot_once:
	cmp #$19
	beq shoot_fire
	rts

shoot_fire:
	jsl sub_horz_pos
	stz $03
	tya
	beq +
	lda $0E
	eor #$ff
	inc
	sta $0E
+
	lda $0E
	cmp #$40
	bcs +
	lda #$04
	sta $03
+
	lda !spr_extra_byte_1,x
	and #!piranha_exbyte_orient
	asl #2
	sta $01
	; we only set 'facing' dir for vertical venus
	;clc
	;lda !sprite_oam_properties,x
	;and #$40
	;rol #4
	lda !sprite_misc_157c,x
	sta $02
	tsb $01

	ldy $01
	lda !sprite_x_low,x
	clc
	adc .xoffs_lo,y
	sta !ambient_get_slot_xpos
	lda !sprite_x_high,x
	adc .xoffs_hi,y
	sta !ambient_get_slot_xpos+1

	lda !sprite_y_low,x
	clc
	adc .yoffs_lo,y
	sta !ambient_get_slot_ypos
	lda !sprite_y_high,x
	adc .yoffs_hi,y
	sta !ambient_get_slot_ypos+1

	ldy $02
	lda .x_spd,y
	sta !ambient_get_slot_xspd
	tya
	ora $03
	tay
	lda .y_spd,y
	sta !ambient_get_slot_yspd

	lda #!ambient_fireball_enemy_ng_id
	jsl ambient_get_slot
	rts

.xoffs_lo:
	db $0F,$FA,$0E,$00,$0E,$FE,$0D,$FE,$FB,$FB,$FE,$FE,$1D,$1D,$1D,$1D
.xoffs_hi:
	db $00,$FF,$00,$00,$00,$FF,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
.yoffs_lo:
	db $09,$09,$FF,$FF,$18,$18,$13,$13,$06,$06,$01,$01,$0A,$0A,$01,$01
.yoffs_hi:
	db $00,$00,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
.x_spd:
	db $0C,$F4,$0C,$F4
.y_spd:
	db $06,$06,$FA,$FA
	db $0C,$0C,$F4,$F4


piranha_plants_init:
	; ani frame scr
	stz $00
	lda !spr_extra_byte_1,x
	bit #!piranha_exbyte_is_venus
	beq .not_venus
	sta !piranha_is_venus,x
	and #!piranha_exbyte_venus_shoot_kind
	lsr #5
	sta !venus_shoot_kind,x
	lda !spr_extra_byte_1,x
.not_venus:
	and #$03
	tay
	lda !sprite_y_low,x
	clc
	adc .y_off_lo,y
	sta !sprite_y_low,x
;	sta !piranha_y_low_bak,x

	lda !sprite_y_high,x
	adc .y_off_hi,y
	sta !sprite_y_high,x

	lda !sprite_x_low,x
	clc
	adc .x_off_lo,y
	sta !sprite_x_low,x
;	sta !piranha_x_low_bak,x

	lda !sprite_x_high,x
	adc .x_off_hi,y
	sta !sprite_x_high,x

	lda .clipping,y
	sta !sprite_tweaker_1662,x

	lda !spr_extra_byte_1,x
	tay

	bit #!piranha_exbyte_orient
	beq .is_vert
	sta !piranha_hv,x
	inc $00
.is_vert:
	tya
	and #!piranha_exbyte_length
	lsr #2
	ora $00
	sta $00
	tya
	and #!piranha_exbyte_is_venus
	lsr #2
	ora $00
	sta !piranha_ani_frame,x
.exit:
	tya
	and #$07
	tay
	lda .properties,y
	sta !sprite_oam_properties,x

	rtl
.properties:
	db pack_props($00, $00, $05, 0)
	db pack_props($80, $00, $05, 0)
	db pack_props($01, $00, $05, 0)
	db pack_props($00, $00, $05, 0)
	db pack_props($00, $00, $04, 0)
	db pack_props($80, $00, $04, 0)
	db pack_props($01, $00, $04, 0)
	db pack_props($00, $00, $04, 0)


.clipping:
	db $01,$01,$14,$14

.y_off_lo:
	db $FF,$EF,$08,$08

.y_off_hi:
	db $FF,$FF,$00,$00

.x_off_lo:
	db $08,$08,$FF,$EF

.x_off_hi:
	db $00,$00,$FF,$FF

piranha_plants_main:
	lda #$00
	jsl sub_off_screen

	jsr piranha_set_ani_frame
;	lda !piranha_is_venus,x
;	beq .no_face
;	lda !piranha_phase,x
;	cmp #$02
;	bne .no_face
;	jsr venus_face
.no_face:

	lda !piranha_in_pipe,x
	bne .skip_interact
	jsr _sprspr_mario_spr_rt
.skip_interact:
	lda !piranha_phase,x
	cmp #$02
	bne .phase_cont
	lda !piranha_is_venus,x
	beq .phase_cont
	jsr venus_check_shoot

	lda !piranha_phase,x
.phase_cont:
	tay
	lda !piranha_phase_timer,x
	beq .change_phase
	lda !spr_extra_byte_1,x
	lsr
	lda .base_speeds,y
	bcc .noinvertspd
	eor #$ff
	inc
.noinvertspd:
	ldy !piranha_hv,x
	bne .move_horz
	sta !sprite_speed_y,x
	jsr _spr_upd_y_no_grav
	rtl

.move_horz:
	sta !sprite_speed_x,x
	jsr _spr_upd_x_no_grav
	rtl

.change_phase:
	lda !piranha_phase,x
	sta $00
	lda !spr_extra_byte_1,x
	and #!piranha_exbyte_is_red
	ora $00
	bne .skip_prox_check
	jsl sub_horz_pos
	lda #$01
	sta !piranha_in_pipe,x

	lda $0E
	clc
	adc #(!piranha_prox_check_dist/2)
	cmp #!piranha_prox_check_dist
	bcc .exit

.skip_prox_check
	stz !piranha_in_pipe,x
	lda !piranha_phase,x
	inc
	and #$03
	sta !piranha_phase,x

	lda !spr_extra_byte_1,x
	and #!piranha_exbyte_length
	lsr
	ora !piranha_phase,x
	sta $00

	lda !spr_extra_byte_1,x
	and #(!piranha_exbyte_venus_shoot_kind|!piranha_exbyte_is_venus)
	lsr
	ora $00
	tay
	lda .time_in_state,y
	sta !piranha_phase_timer,x
.exit
	rtl

.base_speeds:
	; in the pipe, moving forward, resting at the apex, moving backward
	db $00,$F0,$00,$10

.time_in_state:
	db $30,$20,$30,$20        ; long Piranha Plants
	db $30,$18,$30,$18        ; short Piranha Plants
	db $30,$20,$60,$20        ; long Venus Fire Traps spitting 1 fireball
	db $30,$18,$60,$18        ; short Venus Fire Traps spitting 1 fireball
	db $FF,$FF,$FF,$FF        ; null
	db $FF,$FF,$FF,$FF        ; null
	db $30,$20,$90,$20        ; long Venus Fire Traps spitting 2 fireballs
	db $30,$18,$90,$18        ; short Venus Fire Traps spitting 2 fireballs

%start_sprite_pose_entry_list("piranha_plants")
	%start_sprite_pose_entry("piranha_vert", 16, 32)
		%sprite_pose_tile_entry($00,$F8,$04|$80,$28,$02, 0)
		%sprite_pose_tile_entry($FC,$0C,$1C,$20,$00, 1)
		%sprite_pose_tile_entry($04,$0C,$1C,$60,$00, 1)
		%sprite_pose_tile_entry($FC,$04,$1C,$20,$00, 1)
		%sprite_pose_tile_entry($04,$04,$1C,$60,$00, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("piranha_horz", 32, 16)
		%sprite_pose_tile_entry($F9,$00,$08|$80,$28,$02, 0)
		%sprite_pose_tile_entry($0D,$FC,$0C,$20,$00, 1)
		%sprite_pose_tile_entry($0D,$04,$0C,$A0,$00, 1)
		%sprite_pose_tile_entry($05,$FC,$0C,$20,$00, 1)
		%sprite_pose_tile_entry($05,$04,$0C,$A0,$00, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("piranha_vert_s", 16, 32)
		%sprite_pose_tile_entry_withnext($00,$F8,$04|$80,$2A,$02, 0, piranha_vert_tile_3)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("piranha_horz_s", 32, 16)
		%sprite_pose_tile_entry_withnext($F9,$00,$08|$80,$2A,$02, 0, piranha_horz_tile_3)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_vert", 16, 32)
		%sprite_pose_tile_entry_withnext($00,$F8,$00|$80,$28,$02, 0, piranha_vert_tile_1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_horz", 32, 16)
		%sprite_pose_tile_entry_withnext($F9,$00,$00|$80,$28,$02, 0, piranha_horz_tile_1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_vert_s", 16, 32)
		%sprite_pose_tile_entry_withnext($00,$F8,$00|$80,$2A,$02, 0, piranha_vert_tile_3)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_horz_s", 32, 16)
		%sprite_pose_tile_entry_withnext($F9,$00,$00|$80,$2A,$02, 0, piranha_horz_tile_3)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()

piranhas_done:
%set_free_finish("bank1_koopakids", piranhas_done)
