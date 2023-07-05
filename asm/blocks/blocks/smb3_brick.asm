%declare_block("smb3_brick", $0201, $0130, $00,
	mario_above, mario_below, mario_side, mario_top_corner, mario_body, mario_head,
	sprite_v, sprite_h, cape, fireball,
	wallrun_footie, wallrun_body)

%define_block($0201)

sprite_h:
mario_below:
	lda !block_xpos
	and #$F0
	sta !block_xpos
	lda !block_ypos
	and #$F0
	sta !block_ypos
	lda $05
	cmp #($04*2)+1
	beq shatter

	lda $19
	beq bounce
shatter:
	phy
	sep #$20
	jsl shatter_block
	rep #$30
	ldx #$0025
	jsl change_map16
	stz $05
	lda #$0003
	sta !ambient_get_slot_timer
	bra bounce_ready

bounce:
	phy
	rep #$20
	lda.w #!break_brick_block_ambient_id
	sta $05
	lda #$0008
	sta !ambient_get_slot_timer
	; y speed of $C0
	lda #$C000
	sta !ambient_get_slot_xspd
.ready:
	lda !block_xpos
	sta !ambient_get_slot_xpos
	lda !block_ypos
	sta !ambient_get_slot_ypos
	lda $05
	jsl ambient_get_slot
	ply
	rtl

mario_above:
mario_side:
mario_top_corner:
mario_body:
mario_head:
sprite_v:
cape:
fireball:
wallrun_footie:
wallrun_body:
	rtl

%finish_block()
