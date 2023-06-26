includefrom "list.def"

!yi_pswitch_sprnum = $BD

%alloc_sprite_dynamic_free(!yi_pswitch_sprnum, "yi_pswitch", yi_pswitch_init, yi_pswitch_main, 4, \
	$11, $89, $39, $A3, $19, $44)

!pswitch_squish_state = !sprite_misc_151c
!pswitch_squish_index = !sprite_misc_1528
!pswitch_current_slot = !sprite_misc_1602
!pswitch_launch_speed = $50

%set_free_start("bank3_sprites")
yi_pswitch_init:
	lda !sprite_x_low,x
	clc
	adc #$08
	sta !sprite_x_low,x
	bcc .exit
	inc !sprite_x_high,x
.exit
	rtl

yi_pswitch_main:
	%dynamic_gfx_rt_bank3("ldy !pswitch_squish_index,x : lda .dyn_frames,y", "yi_pswitch")
	
	lda !sprites_locked
	bne .ret1
	jsl sub_off_screen
;	jsr.w _suboffscr0_bank3
	lda !pswitch_squish_state,x
	bne .squish
.not_squished:
	jsl $01802A|!bank
	jsl $01A7DC|!bank
	bcc .ret1
	; load pos off (low)
	lda $0E
	cmp #$F0
	; branch if too low
	bpl .check_sides

	; abort if too far on the right
	lda $0F
	cmp #$02
	bmi .ret1
	; abort if too far to the left
	cmp #$1C
	bpl .ret1
	; abort if Mario has upwards y-speed
	lda $7D
	bmi .ret1

	lda #$01
	sta !player_on_solid_platform

	ldy !player_on_yoshi
	lda .squish_displacement,y
	clc
	adc !sprite_y_low,x
	sta $96

	lda !sprite_y_high,x
	adc #$FF
	sta $97

	inc !pswitch_squish_state,x
.ret1
	rtl
.check_sides:
	jsl sub_horz_pos
	beq ..right
..left:
	lda $0E
	cmp #$f3
	bmi .ret1
	bit $7B
	bmi .ret1
	stz $7B
	rtl
..right:
	bit $7B
	bpl .ret1
	stz $7B
	rtl

.squish:
	lda !pswitch_squish_index,x
	asl
	tay
	rep #$20
	lda .ymario,y
	clc
	adc $96
	sta $96
	sep #$20

	stz $7D
	stz $7B
	inc !pswitch_squish_index,x
	lda !pswitch_squish_index,x
	cmp.b #(.dyn_frames_end-.dyn_frames)
	bne .squish_more
	; rocket lawnchair
	lda #(~!pswitch_launch_speed)+1
	sta $7D

	lda #$0B
	sta $1DF9|!addr
	; ground
	lda #$20
	sta !screen_shake_timer
	; set blue pow timer
	lda #$B0
	sta $14AD|!addr

.visuals:
	lda !sprite_y_low,x
	clc
	adc #$0C
	sta !sprite_y_low,x
	lda !sprite_y_high,x
	adc #$00
	sta !sprite_y_high,x

	lda !sprite_x_low,x
	adc #$02
	sta !sprite_x_low,x
	lda !sprite_x_high,x
	adc #$00
	sta !sprite_x_high,x
	jsl $07FC3B|!bank

	stz $01
	lda #$FC
	sta $00
	lda #$10
	sta $02
	lda #$01
	jsl spr_spawn_smoke
	bcs .nosmoke

	lda #$0C
	sta $00
	lda #$01
	jsl spr_spawn_smoke
.nosmoke:

	; respawn on reload
	lda.b #$00
	ldy.w !sprite_load_index,x
	sta.w !sprite_load_table,y
	sta.w !sprite_status,x

	rtl

.squish_more:
	cmp #$10
	bne .exit
	lda !sprite_oam_properties,x
	; mask palette
	and #$F1
	; yellow palette now
	ora #$04
	; new palette
	sta !sprite_oam_properties,x
.exit:
	rtl
.dyn_frames:
	db $00,$02,$03,$04
	db $05,$06,$07,$08
	db $09,$0A,$0B,$0C
	db $0D,$0E,$0F,$0F
	db $0F,$0F,$0D,$0B
	db $09,$05,$02,$00
..end:

.ymario:
	dw $0000,$0000,$0000,$0001
	dw $0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0001
	dw $0001,$0001,$0000,$0000
	dw $0000,$FFFF,$FFFE,$FFFE
	dw $FFFD,$FFFD,$FFFC,$FFFC
; indexed by 'player on yoshi' flag (187A), which can be $02 if yoshi is turning
.squish_displacement:
	db $EE,$DE,$DE
.done:
%set_free_finish("bank3_sprites", yi_pswitch_main_done)
