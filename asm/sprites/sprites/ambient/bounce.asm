!ambient_quake_sprite            = $00

!turning_turn_block_ambient_id   = $03
!item_turn_block_ambient_id      = $04
!yoshi_g_block_ambient_id        = $05
!yoshi_y_block_ambient_id        = $06
!yoshi_r_block_ambient_id        = $07
!yoshi_b_block_ambient_id        = $08
!question_block_ambient_id       = $09
!question_block_mcoin_ambient_id = $0A
!item_brick_block_ambient_id     = $0B
!break_brick_block_ambient_id    = $0C
!onoff_switch_block_ambient_id   = $0D

%alloc_ambient_sprite(!ambient_quake_sprite, "ambient_quake_sprite", ambient_quake_sprite, 0)

; turn blocks
%alloc_ambient_sprite_grav(!turning_turn_block_ambient_id, "turning_turn_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
%alloc_ambient_sprite_grav(!item_turn_block_ambient_id, "item_turn_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
; yoshi blocks
%alloc_ambient_sprite_grav(!yoshi_g_block_ambient_id, "yoshi_g_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
%alloc_ambient_sprite_grav(!yoshi_y_block_ambient_id, "yoshi_y_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
%alloc_ambient_sprite_grav(!yoshi_r_block_ambient_id, "yoshi_r_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
%alloc_ambient_sprite_grav(!yoshi_b_block_ambient_id, "yoshi_b_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
; question block
%alloc_ambient_sprite_grav(!question_block_ambient_id, "question_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
; brick blocks
%alloc_ambient_sprite_grav(!item_brick_block_ambient_id, "item_brick_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
%alloc_ambient_sprite_grav(!break_brick_block_ambient_id, "breakable_brick_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)
; on/off switch block
%alloc_ambient_sprite_grav(!onoff_switch_block_ambient_id, "onoff_switch_block_bounce", ambient_bounce_spr,\
	!ambient_twk_pos_upd|!ambient_twk_has_grav|!ambient_gfx_tilesz_big|!ambient_twk_spr_interact, \
	$13, $30)

!invis_solid_tile_id = $0152

; TODO sprite interaction
%set_free_start("bank2_altspr2")
ambient_spawn_block:
	tay
	lda !ambient_y_pos,x
	and #$FFF0
	sta !block_ypos
	lda !ambient_x_pos,x
	and #$FFF0
	sta !block_xpos
	tyx
	jsl change_map16
	ldx !current_ambient_process
.exit
	rts

ambient_quake_sprite:
	lda !ambient_gen_timer,x
	bne ambient_bounce_interact
.bad_ambient_default:
	stz !ambient_rt_ptr,x
	rts

ambient_bounce_interact:
	; set up clipping b
	lda !ambient_y_pos,x
	sec
	sbc #$0004
	sta $01
	sta $08

	; store hitbix width/height
	lda #$1818
	sta $02

	lda !ambient_x_pos,x
	sec
	sbc #$0004
	sta $07
	sep #$30
	sta $00

	ldx.b #!num_sprites-1
.interact_loop:
	lda !sprite_status,x
	cmp #$08
	bcc ..next
	cmp #$0b
	beq ..next
	lda !sprite_tweaker_166e,x
	and #!spr_166e_prop_no_cape_kill
	ora !sprite_misc_154c,x
	ora !sprite_cape_disable_time,x
	bne ..next
	jsl get_spr_clipping_a
	jsl check_for_contact
	bcc ..next
	; TODO probably port this, theres a lot of junk going on here
	;      and unsure how much is actually needed. We could use Y instead too
	; cape spr hit routine
	jsr $9404
..next:
	dex
	bpl .interact_loop
	rep #$30
	ldx !current_ambient_process
	rts

ambient_bounce_spr:
	lda !ambient_misc_1,x
	bit #$0002
	bne .nogfx
	xba
	and #$00FF
	asl
	tay
	lda .block_props-(!turning_turn_block_ambient_id*2),y
	sta !ambient_props,x
	jsr ambient_basic_gfx
.nogfx:
	lda !ambient_sprlocked_mirror
	bne ambient_spawn_block_exit
	lda !ambient_gen_timer,x
	cmp #$0005
	bcs .no_interact
	cmp #$0003
	bcc .no_interact
	jsr ambient_bounce_interact
.no_interact:
	lda !ambient_misc_1,x
	and #$00FF
	asl
	tay
	lda .phases,y
	sta $00

	; run physics after everything else
	pea ambient_physics-1
	jmp ($0000)
.block_draw_death:
	; turn blocks
	dw $0048,$0132
	; yoshi blocks
	dw $0132,$0132,$0132,$0132
	; question block
	dw $0132,$0132
	; brick blocks (todo breakable brick id)
	dw $0132,$0201
	; onoff switch
	dw $0112
.block_props:
	; turn blocks
	dw $00C4,$00C4
	; yoshi blocks
	dw $0AC8,$04C8,$08C8,$06C8
	; question block
	dw $00C0, $00C0
	; brick blocks
	dw $00C2,$00C2
	; on/off switch
	dw $06C6
.phases:
	dw ..spawn_solid
	dw ..do_bounce
	dw ..write_block_die
..spawn_solid:

	inc !ambient_misc_1,x
	lda #!invis_solid_tile_id
	jmp ambient_spawn_block

..do_bounce:
	lda !ambient_gen_timer,x
	bne ...exit
	inc !ambient_misc_1,x
...exit:
	rts
..write_block_die:
	;lda !ambient_misc_1+1,x
	lda !ambient_id_loadval,x
	and #$00FF
	asl
	tay
	cpy.w #(!turning_turn_block_ambient_id*2)
	bne .not_turn_block
	jsr ambient_alloc_turnblock
.not_turn_block:
	stz !ambient_rt_ptr,x
	lda .block_draw_death-(!turning_turn_block_ambient_id*2),y
	jmp ambient_spawn_block

ambient_bounce_done:
%set_free_finish("bank2_altspr2", ambient_bounce_done)
