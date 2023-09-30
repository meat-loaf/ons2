%alloc_ambient_sprite(!ambient_score_10pt_id, "ambient_score_10pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_20pt_id, "ambient_score_20pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_40pt_id, "ambient_score_40pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_80pt_id, "ambient_score_80pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_100pt_id, "ambient_score_100pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_200pt_id, "ambient_score_200pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_400pt_id, "ambient_score_400pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_800pt_id, "ambient_score_800pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_1000pt_id, "ambient_score_1000pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_2000pt_id, "ambient_score_2000pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_4000pt_id, "ambient_score_4000pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_8000pt_id, "ambient_score_8000pt", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_1up_id, "ambient_score_1up", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_2up_id, "ambient_score_2up", ambient_score, \
	!ambient_twk_pos_upd)
%alloc_ambient_sprite(!ambient_score_3up_id, "ambient_score_3up", ambient_score, \
	!ambient_twk_pos_upd)

%set_free_start("bank2_altspr1")
ambient_score:
	jsr ambient_kill_on_timer
	lda #$0002
	sta $0c
	jsr ambient_sub_off_screen
	lda !sprite_level_props-1
	and #$FF00
	sta $02
	lda !ambient_twk_tilesz,x
	and #$0003
	sta $04

	lda $00
	sta $0200|!addr,y
	clc
	adc #$0008
	sta $0204|!addr,y
	;lda !ambient_misc_1+1,x
	lda !ambient_id_loadval,x
	and #$00FF
	asl : asl
	tax
	lda .tiles_props-(!ambient_score_10pt_id*4),x
	ora $02
	sta $0202|!addr,y
	lda .tiles_props-(!ambient_score_10pt_id*4)+2,x
	ora $02
	sta $0206|!addr,y

	ldx !current_ambient_process
	tya
	lsr #2
	tay
	; todo this is actually wrong since the tiles arent stacked
	;      vertically. its not super noticeable but it should be
	;      corrected regardless
	lda !ambient_twk_tilesz,x
	and #$0003
	sta $00
	xba
	ora $00
	sta $0420|!addr,y

	lda !ambient_sprlocked_mirror
	bne .exit

	lda !ambient_gen_timer,x
	cmp #$002a
	bne .no_reward_yet
	;lda !ambient_misc_1+1,x
	lda !ambient_id_loadval,x
	and #$00FF
	asl
	tax
	jsr (.rewards-(!ambient_score_10pt_id*2),x)
	ldx !current_ambient_process
	lda !ambient_gen_timer,x
.no_reward_yet:
	lsr #4
	tay
	sep #$20
	lda .y_speeds,y
	sta !ambient_y_speed+1,x
	rep #$20
	jmp ambient_physics
.exit:
	rts

.y_speeds:
	db $FC,$FC,$F8,$F6
.tiles_props:
	; 10
	dw $0083,$0044
	; 20
	dw $0083,$0054
	; 40
	dw $0083,$0046
	; 80
	dw $0083,$0047
	; 100
	dw $0044,$0045
	; 200
	dw $0054,$0045
	; 400
	dw $0046,$0045
	; 800
	dw $0047,$0045
	; 1000
	dw $0044,$0055
	; 2000
	dw $0054,$0055
	; 4000
	dw $0046,$0055
	; 8000
	dw $0047,$0055
	; 1up
	dw $0856,$0857
	; 2up
	dw $044B,$0457
	; 3up
	dw $065B,$0657

.rewards:
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_points
	dw .give_lives
	dw .give_lives
	dw .give_lives
	dw .give_lives
	dw .give_coins

.give_points:
	; todo check current player?
	lda ..npoints-(!ambient_score_10pt_id*2),x
	clc
	adc !player_score
	sta !player_score
	lda !player_score+2
	adc #$0000
	sta !player_score+2
	rts
..npoints:
	dw $0001, $0002, $0004, $0008
	dw $000A, $0014, $0028, $0050
	dw $0064, $00C8, $0190, $0320

.give_lives:
	lda ..nlives-(!ambient_score_1up_id*2),x
	sta !give_player_lives
	rts

..nlives:
	dw $0001,$0002,$0003
.give_coins:
	lda ..ncoins-(!ambinet_score_1coin_id*2),x
	sep #$30
	jsl give_coins
	rep #$30
	rts
..ncoins:
	dw $0001,$0002,$0005

ambient_score_done:
%set_free_finish("bank2_altspr1", ambient_score_done)
