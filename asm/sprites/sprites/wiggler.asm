includefrom "list.def"

!wiggler_sprnum = $86

%alloc_sprite(!wiggler_sprnum, "wiggler", wiggler_init, wiggler_main, 6, 0, \
	$00, $00, $F5, $80, $00, $00)

!wiggler_segment_face_bit      = !sprite_misc_c2
!wiggler_angry                 = !sprite_misc_151c
!wiggler_segbuff_position      = !sprite_misc_1528
!wiggler_angry_facemario_timer = !sprite_misc_1534
!wiggler_nocontact             = !sprite_misc_154c
!wiggler_stunned_timer         = !sprite_misc_1540
!wiggler_ani_counter           = !sprite_misc_1570
!wiggler_facing_dir            = !sprite_misc_157c
!wiggler_turn_timer            = !sprite_misc_15ac
!wiggler_segflip_timer         = !sprite_misc_1602
!wiggler_buffer_index          = !sprite_misc_160e
!wiggler_bloomer               = !spr_extra_bits

; note: the head alternate head tile is intended to be 2 16x16s away
;       from the 'normal' head tile
!wiggler_head_tile       = $00
!wiggler_angry_eyes_tile = $08
!wiggler_flower_tile     = $18
; yxppccct
!wiggler_flower_palette  = $0A

!wiggler_bonk_sfx        = $03
!wiggler_bonk_sfx_port   = $1DF9|!addr

%set_free_start("bank6")
update_segment_buffer:
	lda !wiggler_segbuff_position,x
	dec
	dec
	and #$7E
	sta !wiggler_segbuff_position,x
	tay
	lda !sprite_x_low,x
	sta [!wiggler_segment_ptr],y
	iny
	lda !sprite_y_low,x
	sta [!wiggler_segment_ptr],y
	rts

segment_buff_ptr_init:
	ldy !wiggler_buffer_index,x
	lda.b #!wiggler_segment_buffer
	clc
	adc wiggler_seg_off_lo,y
	sta !wiggler_segment_ptr+$0
	lda.b #!wiggler_segment_buffer>>8
	clc
	adc wiggler_seg_off_hi,y
	sta !wiggler_segment_ptr+$1
	lda.b #!wiggler_segment_buffer>>16
	sta !wiggler_segment_ptr+$2
	rts

segbuffer_spr_suboffscreen_bookeeping:
	jsl sub_off_screen
	lda !sprite_status,x
	bne .nodespawn
	dec ; a = 0xff
	ldy !wiggler_buffer_index,x
	sta !wiggler_segment_slots,y
.nodespawn:
	rts

wiggler_seg_off_lo:
	db $00,$80,$00,$80
wiggler_seg_off_hi:
	db $00,$00,$01,$01
wiggler_move_speeds:
	db $08,$F8,$10,$F0
; wiggler init
wiggler_init:
	jsl sub_horz_pos
	tya
	sta !wiggler_facing_dir,x
.findsegslot_start:
	ldy #$03
.findsegslot_loop:
	ldx !wiggler_segment_slots,y
	; if negative, a wiggler despawned and cleared the slot
	bmi .found
	; TODO is this sprite number check logic still necessary?
	;      i dont think it is, when the wigglers can now
	;      properly clean up this table; only thing would be
	;      the table needs to be initialized with 0xFF
	; check that we've spawned in a slot
	; that a wiggler sat in previously
	cpx !current_sprite_process
	beq .found
	lda !sprite_num,x
	cmp #$86
	bne .found
	lda !sprite_status,x
	beq .found
	dey
	bpl .findsegslot_loop
.spawn_fail:
	ldx !current_sprite_process
	; kill self: no room to spawn (ensure enabling respawn)
	lda #$00
	ldy !sprite_load_index,x
	sta !sprite_status,x
	sta !sprite_load_table,y
	rtl

.found:
	lda !current_sprite_process
	; store this wigglers sprite slot number to
	; track what slot has what index
	sta !wiggler_segment_slots,y
	; x gets sprite slot
	tax
	; a gets wiggler segment buffer index
	tya
	; track the buffer index in a previously unused sprite table
	sta !wiggler_buffer_index,x
	jsr segment_buff_ptr_init

	; todo can this be an sram->ram dma? then we
	;      don't even need to set up the segment pointer
	ldy #$7F
.seg_buff_init_loop:
	lda !sprite_y_low,x
	sta [!wiggler_segment_ptr],y
	dey
	lda !sprite_x_low,x
	sta [!wiggler_segment_ptr],y
	dey
	bpl .seg_buff_init_loop
.seg_init_done:
	rtl

wiggler_main:
	jsr segment_buff_ptr_init
	lda !sprites_locked
	beq .cont
	jmp .call_gfx
.cont:
	jsl spr_spr_interact
	lda !wiggler_stunned_timer,x
	beq .not_stunned
	cmp #$01
	bne .palette_cycle
	lda #$08
	bra .no_palette_cycle
.palette_cycle
	and #$0E
.no_palette_cycle:
	sta $00
	lda !sprite_oam_properties,x
	and #$F1
	ora $00
	sta !sprite_oam_properties,x
	jmp .call_gfx
.not_stunned:
	jsl spr_upd_yx_no_grav_l
	jsr segbuffer_spr_suboffscreen_bookeeping
	inc !wiggler_ani_counter,x
	lda !wiggler_angry,x
	beq .not_angry
	inc !wiggler_ani_counter,x
	inc !wiggler_angry_facemario_timer,x
	lda !wiggler_angry_facemario_timer,x
	and #$3F
	bne .not_angry
	jsl sub_horz_pos
	tya
	sta !wiggler_facing_dir,x
.not_angry:
	ldy !wiggler_facing_dir,x
	lda !wiggler_angry,x
	beq .not_angry_2
	iny #2
.not_angry_2:
	lda wiggler_move_speeds,y
	sta !sprite_speed_x,x
	inc !sprite_speed_y,x
	jsl spr_obj_interact
	lda !sprite_blocked_status,x
	bit #$03
	bne .check_flip
	bit #$04
	; not falling
	beq .check_flip
	lda !sprite_blocked_status,x
	; set flags on A
;	tay
	bmi .layer2_i_guess
	lda #$00
	ldy !sprite_slope,x
	beq .noslope
.layer2_i_guess:
	lda #$18
.noslope:
	sta !sprite_speed_y,x
	bra .noflip
.check_flip:
	lda !wiggler_turn_timer,x
	bne .noflip
	lda !wiggler_facing_dir,x
	eor #$01
	sta !wiggler_facing_dir,x
	stz !wiggler_segflip_timer,x
	lda #$08
	sta !wiggler_turn_timer,x
.noflip:
	jsr update_segment_buffer
	lda !wiggler_segflip_timer,x
	inc !wiggler_segflip_timer,x
	and #$07
	bne .call_gfx
	lda !wiggler_segment_face_bit,x
	asl
	ora !wiggler_facing_dir,x
	sta !wiggler_segment_face_bit,x
.call_gfx:
	jsr wiggler_gfx
	; originally this would have been handled
	; by the stack shenanigans of getdrawinfo
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
;	ora !wiggler_no_contact,x
	bne .segment_check_contact_exit
	lda !sprite_x_high,x
	xba
	lda !sprite_x_low,x
	rep #$20
	sec
	sbc !player_x_next
	clc
	adc #$0050
	cmp #$00A0
	sep #$20
	bcs .segment_check_contact_exit
	lda #$04
	sta $00
	ldy !sprite_oam_index,x
.segment_check_contact:
	lda $0304|!addr,y
	sec
	sbc !player_x_scr_rel
	adc #$0c
	cmp #$18
	bcs ..next_segment
..check_y_contact:
	lda $0305|!addr,y
	sec
	sbc !player_y_scr_rel
	sbc #$10
	phy
	ldy !player_on_yoshi
	beq ..not_riding_yoshi
	sbc #$10
..not_riding_yoshi:
	ply
	clc
	adc #$0c
	cmp #$18
	bcs ..next_segment
	bra ..handle_contact
..next_segment:
	iny #4
	dec $00
	bpl .segment_check_contact
..exit:
	rtl

..handle_contact:
	lda !invincibility_timer
	bne .wiggler_fucking_dies
	lda !wiggler_nocontact,x
	ora !player_y_scr_rel+$1
	bne ..next_segment
	lda #$08
	sta !wiggler_nocontact,x
	lda !sprite_stomp_counter
	bne ..no_y_check
	lda !player_y_speed
	cmp #$08
	bpl ..no_y_check
	; exits sprite code
	jml hurt_mario

..no_y_check:
	lda #!wiggler_bonk_sfx
	sta !wiggler_bonk_sfx_port
	; todo: label (boost mario speed)
	jsl $01AA33|!bank
	lda !wiggler_angry,x
	ora !wiggler_bloomer,x
	ora !sprite_being_eaten,x
	bne ..exit
	; todo display contact gfx
	lda !sprite_stomp_counter
	cmp #$09
	bcs ..stomp_maxx
	inc
	sta !sprite_stomp_counter
..stomp_maxx:
	jsl spr_give_points
	lda #$40
	sta !wiggler_stunned_timer,x
	inc !wiggler_angry,x
	; spawn flower
	; TODO make this sprite-callable subroutine
	lda !sprite_x_low,x
	sta $45
	lda !sprite_x_high,x
	sta $46
	lda !sprite_y_low,x
	sta $47
	lda !sprite_y_high,x
	sta $48

	stz $49
	lda #$08
	sta $4b
	lda #$d0
	sta $4c
	lda #!ambient_wiggler_flower_id
	jml ambient_get_slot

.wiggler_fucking_dies:
	lda #$02
	sta !sprite_status,x
	lda #$d0
	sta !sprite_speed_y,x
	lda !starkill_counter
	cmp #$09
	bcs ..starkill_maxx
	inc
	sta !starkill_counter
..starkill_maxx:
	jsl spr_give_points
	; todo: stomp sfx tbl
;	ldy !starkill_counter
	rtl

; actual remap next
wiggler_small_tile_xoffs:
	db $00,$08
	db $04,$04
wiggler_segment_buff_offs:
	db $00,$1E,$3E,$5E,$7E
wiggler_segment_yoffs:
	db $00,$01,$02,$01
wiggler_body_tiles:
	db $02,$0D,$06,$02
wiggler_small_tiles:
	db !wiggler_flower_tile, !wiggler_flower_tile
	db !wiggler_angry_eyes_tile, !wiggler_angry_eyes_tile
wiggler_small_tile_yoffs:
	db $F8,$F8
	db $00,$00
wiggler_gfx:
	jsl get_draw_info
	lda.w !wiggler_bloomer,x
	asl #2
	sta.b $0B
	lda.w !wiggler_ani_counter,x       ; \ animation frame counter
	sta.b $03                          ; /
	lda.w !sprite_oam_properties,x     ; \ yxppccct
	sta.b $07                          ; /
	lda.w !wiggler_angry,x             ; \ wiggler is angry flag
	sta.b $08                          ; /
	lda   !wiggler_segment_face_bit,x  ; \ bitfield: segment direction flag
	sta.b $02                          ; /
	lda   !wiggler_segbuff_position,x
	sta.b $0C
	ldx.b #$00
.draw_loop:
	iny   #4          ; angry face/flower tile drawn later
	sty.b $0A         ; > sprite OAM index
	stx.b $05
	lda.b $03
	lsr   #3
	clc
	adc.b $05         ; current loop index
	and.b #$03
	sta.b $06         ; body tile yoff table index
	lda.w wiggler_segment_buff_offs,x
	ldy.b $08
	beq.b .no_angry
	lsr
	and.b #$FE
.no_angry:
	clc
	adc.b $0C
	and.b #$7E
	tay
	sty.b $09         ; index to segment buffer
	lda.b [!wiggler_segment_ptr],y
	sec
	sbc.b $1A
	ldy.b $0A
	sta.w $0300|!addr,y
	ldy.b $09
	iny
	lda.b [!wiggler_segment_ptr],y
	sec
	sbc.b $1C
	ldx.b $06
	sec
	sbc.w wiggler_segment_yoffs,x
	ldy.b $0A
	sta.w $0301|!addr,y
	lda.b #!wiggler_head_tile
	ora.b $0B
	ldx.b $05
	beq .draw_head
	ldx.b $06
	lda.w wiggler_body_tiles,x
.draw_head:
	ldy.b $0A
	sta.w $0302|!addr,y
	lda.b $07
	ora.b $64
	lsr.B $02
	bcs .no_flip
	ora.b #$40
.no_flip:
	sta.w $0303|!addr,y
	ldx.b $05
	; changing this to a DEX/BPL would require reversing the bitfield
	; in the C2 table, at least
	inx
	cpx.b #$05
	bne.b .draw_loop
	ldx.w !current_sprite_process
	ldy.w !sprite_oam_index,x
	lda.b $08
	asl
	ora.w !wiggler_facing_dir,x           ; horz facing dir
	tax
	lda.w wiggler_small_tiles,x
	sta.w $0302|!addr,y
	; carry clear free from above: won't overflow
	lda.w $0304|!addr,y
	adc.w wiggler_small_tile_xoffs,x
	sta.w $0300|!addr,y
	lda.w $0305|!addr,y
	clc
	adc.w wiggler_small_tile_yoffs,x
	sta.w $0301|!addr,y
	lda.w $0307|!addr,y
	cpx.b #$02
	bcs.b .not_flower
	and.b #$F1
	ora.b #!wiggler_flower_palette
.not_flower:
	sta.w $0303|!addr,y
	tya
	lsr   #2
	tay
	; store tilesizes
	; this is shorter and less cycles than
	; staying in 8-bit mode
	rep.b #$20
	lda.w #$0200
	sta.w $0460|!addr,y
	; is one byte larger but one cycle faster than two INCs
	lda.w #$0202
	sta.w $0462|!addr,y
	sta.w $0464|!addr,y
	sep.b #$20
	ldx.w !current_sprite_process
	lda.b #$05
	ldy.b #$FF
	jsl.l finish_oam_write
	rts
wiggler_done:
%set_free_finish("bank6", wiggler_done)
