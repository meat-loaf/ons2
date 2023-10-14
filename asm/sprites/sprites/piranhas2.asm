%alloc_sprite_spriteset_1(!piranhas_sprite_id, "piranha_plants", piranha_plants_init, piranha_plants_main, 5, \
	$113, \
	$81, $01, $00, $00, $10, $20, \
	piranha_plants_gfx_ptrs, \
	spr_gfx_2)

!piranha_exbit_invert   = $01
!piranha_exbit_horz     = $02
!piranha_exbit_length   = $04
!piranha_exbit_is_red   = $08
!piranha_exbit_is_venus = $10

!piranha_prox_check_dist = $37

!piranha_phase          = !sprite_misc_c2
!piranha_head_ani_off   = !sprite_misc_151c
!piranha_x_low_bak      = !sprite_misc_1528
!piranha_y_low_bak      = !sprite_misc_1534
!piranha_head_ani_timer = !sprite_misc_1570
!piranha_phase_timer    = !sprite_misc_1540
!piranha_in_pipe        = !sprite_misc_1594
!piranha_ani_frame      = !sprite_misc_1602

; clear: vert
; set: horiz
!piranha_hv             = !sprite_misc_160e

%set_free_start("bank1_koopakids")
piranha_set_ani_frame:
	inc !piranha_head_ani_timer,x
	lda !piranha_head_ani_timer,x
	and #$08
	lsr #2
	sta !piranha_head_ani_off,x
	rts

piranha_plants_init:
	; ani frame scr
	stz $00
	; todo
	lda !spr_extra_byte_1,x
	and #$03
	tay
	lda !sprite_y_low,x
	clc
	adc .y_off_lo,y
	sta !sprite_y_low,x
	sta !piranha_y_low_bak,x

	lda !sprite_y_high,x
	adc .y_off_hi,y
	sta !sprite_y_high,x

	lda !sprite_x_low,x
	clc
	adc .x_off_lo,y
	sta !sprite_x_low,x
	sta !piranha_x_low_bak,x

	lda !sprite_x_high,x
	adc .x_off_hi,y
	sta !sprite_x_high,x

	lda .clipping,y
	sta !sprite_tweaker_1662,x

	lda !spr_extra_byte_1,x
	tay

	bit #!piranha_exbit_horz
	beq .vert_check_flip
	sta !piranha_hv,x
	inc $00
	tya
	lsr
	bcs .no_yflip
	inc !sprite_misc_157c,x
	
	tya
	bra .no_yflip

.vert_check_flip:
	tya
	bit #!piranha_exbit_invert
	beq .no_yflip
	lda !sprite_oam_properties,x
	ora #$80
	sta !sprite_oam_properties,x
.no_yflip:
	tya
	and #!piranha_exbit_length
	lsr
	ora $00
	sta $00
	tya
	and #!piranha_exbit_is_venus
	lsr #2
	ora $00
	sta !piranha_ani_frame,x
.exit:
	rtl

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

	; TODO skipped venus fire check
;	jsr _spr_set_ani_frame
	jsr piranha_set_ani_frame
	lda !piranha_in_pipe,x
	bne .skip_interact
	jsr _sprspr_mario_spr_rt
.skip_interact:
	; TODO skipped venus fire check
	lda !piranha_phase,x
	and #$03
	tay
	lda !piranha_phase_timer,x
	beq .change_phase
	; check for horiz
	lda !spr_extra_byte_1,x
	; carry: invert speed (moving right or down)
	lsr
	lda .base_speeds,y
	bcc .noinvert
	eor #$ff
	inc
.noinvert:
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
	; TODO skipped venus fire check
	lda !piranha_phase,x
	sta $00
	lda !spr_extra_byte_1,x
	and #!piranha_exbit_is_red
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
;	sta $00
	sta !piranha_phase,x
	lda !spr_extra_byte_1,x
	and #!piranha_exbit_length
	ora !piranha_phase,x
	; TODO skipped venus fire handling
	tay
	lda .time_in_state,y
	sta !piranha_phase_timer,x
.exit
	rtl

.base_speeds:
	; in the pipe, moving forward, resting at the apex, moving backward
	db $00,$F0,$00,$10

; the time the sprite will spend in each sprite state, indexed by bits 2, 4, and 5 of the behavior table
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
		%sprite_pose_tile_entry($00,$F8,$04|$80,$24,$02, 0)
		%sprite_pose_tile_entry($FC,$0C,$1C,$20,$00, 1)
		%sprite_pose_tile_entry($04,$0C,$1C,$60,$00, 1)
		%sprite_pose_tile_entry($FC,$04,$1C,$20,$00, 1)
		%sprite_pose_tile_entry($04,$04,$1C,$60,$00, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("piranha_horz", 32, 16)
		%sprite_pose_tile_entry($F9,$00,$08|$80,$24,$02, 0)
		%sprite_pose_tile_entry($0D,$FC,$0C,$20,$00, 1)
		%sprite_pose_tile_entry($0D,$04,$0C,$A0,$00, 1)
		%sprite_pose_tile_entry($05,$FC,$0C,$20,$00, 1)
		%sprite_pose_tile_entry($05,$04,$0C,$A0,$00, 1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("piranha_vert_s", 16, 32)
		%sprite_pose_tile_entry_withnext($00,$F8,$04|$80,$24,$02, 0, piranha_vert_tile_3)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("piranha_horz_s", 32, 16)
		%sprite_pose_tile_entry_withnext($F9,$00,$08|$80,$24,$02, 0, piranha_horz_tile_3)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_vert", 16, 32)
		%sprite_pose_tile_entry_withnext($00,$F8,$00|$80,$24,$02, 0, piranha_vert_tile_1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_horz", 32, 16)
		%sprite_pose_tile_entry_withnext($00,$F8,$00|$80,$24,$02, 0, piranha_horz_tile_1)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_vert_s", 16, 32)
		%sprite_pose_tile_entry_withnext($00,$F8,$00|$80,$24,$02, 0, piranha_vert_tile_3)
	%finish_sprite_pose_entry()
	%start_sprite_pose_entry("venus_horz_s", 32, 16)
		%sprite_pose_tile_entry_withnext($00,$F8,$00|$80,$24,$02, 0, piranha_horz_tile_3)
	%finish_sprite_pose_entry()


%finish_sprite_pose_entry_list()

;piranha_tiles:
;	db $00

piranhas_done:
%set_free_finish("bank1_koopakids", piranhas_done)
