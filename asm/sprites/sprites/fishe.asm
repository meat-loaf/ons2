includefrom "list.def"

!fish_sprnum = $15
%alloc_sprite(!fish_sprnum, "cheep-cheep", fish_init, fish_main, 1, 0, \
	$00, $00, $45, $99, $10, $00)

%alloc_sprite_sharedgfx_entry_4(!fish_sprnum,$04,$06,$00,$02)

; 0: normal horiz (left-to-right)
; 1: normal vert (top-to-bottom)
; 2: angled to the left, from bottom
; 3: angled to the left, from top
;   an odd x-position inverts the starting direction
!fish_move_kind  = !spr_extra_bits
!fish_move_dir   = !sprite_misc_c2
!fish_turn_timer = !sprite_misc_1540
!fish_face_dir   = !sprite_misc_157c
!fish_ani_frame  = !sprite_misc_1602

%set_free_start("bank1_fish")
fish_init:
	lda !fish_move_kind,x
	cmp #$01
	bcc .exit
	jsr.w _spr_face_mario_rt
.exit
	lda !sprite_x_low,x
	and #$F0
	lsr #4
	sta !fish_move_dir,x
	rtl

fish_main:
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	beq .cont
	jmp .gfx
.cont:
	jsr.w _spr_set_ani_frame
	lda !sprite_in_water,x
	bne .swim
.flop:
	jsr.w _spr_upd_pos
	lda !sprite_blocked_status,x
	and #$03
	beq ..noflip
	jsr.w _flip_sprite_dir
..noflip:
	lda !sprite_blocked_status,x
	and #$04
	beq ..not_grounded
	lda !sprite_buoyancy
	beq ..no_splash
	jsl $0284BC|!bank
..no_splash:
	jsl get_rand
	lda !random_number_output+1
	adc !true_frame
	and #$07
	tay
	lda .flop_speeds_x,y
	sta !sprite_speed_x,x
	and #$03
	tay
	lda .flop_speeds_y,y
	sta !sprite_speed_y,x
	lda !random_number_output
	and #$40
	bne ..dont_flip_flop
	lda !sprite_oam_properties,x
	eor #$80
	sta !sprite_oam_properties,x
..dont_flip_flop:
	jsl get_rand
	lda !random_number_output
	and #$80
	bne ..not_grounded
	jsr.w _spr_update_dir
..not_grounded:
	lda !fish_ani_frame,x
	clc
	adc #$02
	sta !fish_ani_frame,x
	bra .interact
.swim:
	jsr.w _spr_obj_interact
	jsr.w _spr_update_dir
	asl !sprite_oam_properties,x
	lsr !sprite_oam_properties,x
	lda !sprite_blocked_status,x
	ldy !fish_move_kind,x
	and .fish_dir_willflip,y
	bne ..do_turn
	lda !fish_turn_timer,x
	bne ..no_turn
..do_turn:
	lda #$80
	sta !fish_turn_timer,x
	inc !fish_move_dir,x
..no_turn:
	lda !fish_move_dir,x
	and #$01
	sta $00
	lda !fish_move_kind,x
	asl
	ora $00
	tay
	lda .fish_move_speeds_x,y
	sta !sprite_speed_x,x
	lda .fish_move_speeds_y,y
	sta !sprite_speed_y,x
	jsr.w _spr_upd_x_no_grav
	ldy !fish_move_kind,x
	cpy #$02
	bcs .y_always
	and #$0c
	bne .interact
.y_always:
	jsr.w _spr_upd_y_no_grav
.interact:
	jsr.w _spr_spr_interact
	jsr.w _mario_spr_interact
	bcc .gfx
.contact:
	lda !sprite_in_water,x
	beq .kick_and_gfx
	lda !invincibility_timer
	bne .kick_and_gfx
	lda !player_on_yoshi
	bne .gfx
	jsl hurt_mario
	bra .gfx
.kick_and_gfx:
	; todo kicking breaks sprites at the moment
	stz !sprite_status,x
	rtl
	;jsr.w _spr_kick
.gfx:
	jsr.w sub_spr_gfx_2
	jsr.w _suboffscr0_bank1
	rtl
.flop_speeds_y:
	db $E0,$E8,$D0,$D8
.flop_speeds_x:
	db $08,$F8,$10,$F0,$04,$FC,$14,$EC
.fish_dir_willflip:
	db $03,$0C,$0E,$0E
; note: speeds are 'interleaved' for horz and vert fish
.fish_move_speeds_x:
	db $08,$F8,$00,$00,$08,$F8,$08,$F8
.fish_move_speeds_y:
	db $00,$00,$08,$F8,$08,$F8,$F8,$08
kick_speeds:
	db $F0,$10
fish_done:
%set_free_finish("bank1_fish", fish_done)

; patch the data table for the 'kicking sprite' routine, which is stuck
; in with the fish's data (this routine is used by a handful of other sprites)
org $01B137|!bank
	lda kick_speeds,y
