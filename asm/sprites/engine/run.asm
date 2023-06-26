; fix the game not clearing the full sprite load status table
org $02ABF3|!bank
	db $7F

; basic init routine for carryable sprites
org $018435|!bank
generic_carryable_init:
	lda #$09
	sta !sprite_status,x
	rtl
warnpc $01843B|!bank

org $01808C|!bank
run_sprites:
	phb
	lda !player_carrying_item
	sta !carrying_flag
	stz !player_carrying_item
	stz !player_on_solid_platform
	stz !player_in_cloud
	lda !current_yoshi_slot
	sta !yoshi_is_loose
	stz !current_yoshi_slot
	stz !dyn_slots
	ldx #!num_sprites-1
.loop
	stx !current_sprite_process
	jsr allocate_oam_dec_timers
	jsl handle_sprite
	dex
	bpl .loop
	lda !current_yoshi_slot
	bne .on_yoshi
	stz !player_on_yoshi
	stz !screen_shake_player_yoff
.on_yoshi:
	plb
	rtl
warnpc $0180CB|!bank
assert read1($0180CA) == !RTL_OPCODE, "RTL used for JSL2RTS by Lunar Magic overwritten."

%set_free_start("bank1_sprcall_inits")
allocate_oam_dec_timers:
	lda !sprite_status,x
	beq .done
	lda !sprite_num,x
	cmp #$35
	bne .cont
.yoshi:
	ldy #$3C
	lda $13F9|!addr
	beq +
	ldy #$1C
+	tya
	sta !sprite_oam_index,x
	bra .handle_timers
.cont:
	tax
	lda !next_oam_index
	tay
	clc
	adc.l oam_tile_count,x
	sta !next_oam_index
	ldx !current_sprite_process
	tya
	sta !sprite_oam_index,x
.handle_timers
	lda !sprites_locked
	bne .done
	%implement_timer("!sprite_misc_1540,x")
	%implement_timer("!sprite_misc_154c,x")
	%implement_timer("!sprite_misc_1558,x")
	%implement_timer("!sprite_misc_1564,x")
	%implement_timer("!sprite_cape_disable_time,x")
	%implement_timer("!sprite_misc_15ac,x")
	%implement_timer("!sprite_misc_163e,x")
.done:
	rts
handle_sprite:
	lda !sprite_status,x
	bne .cont
	dec
	sta !sprite_load_index,x
	rtl
.cont:
	phk
	plb
	asl
	tay
	lda .status_ptrs-2+1,y
	pha
	lda .status_ptrs-2+0,y
	pha
	rts

; todo split tables
.status_ptrs:
	; 1
	dw spr_handle_init-1
	; 2
	dw spr_killed_shim-1
	; 3
	dw spr_smushed_shim-1
	; 4
	dw spr_spinkill_shim-1
	; 5
	dw spr_lavadie_shim-1
	; 6 - todo (code overwritten at the moment)
	dw spr_levelend-1
	; 7 - unused: TODO yoshi tongue state?
	dw !bank01_jsl2rts_rtl-1
	; 8
	dw spr_handle_main-1
	; 9
	dw spr_stunned_shim-1
	; A
	dw spr_kicked_shim-1
	; B
	dw spr_carried_shim-1
	; C todo
spr_handle_init:
	lda #$08
	sta !sprite_status,x
	lda !sprite_num,x
	tax
	lda.l sprite_init_table_bk,x
	pha
	pha
	plb
	lda.l sprite_init_table_hi,x
	pha
	lda.l sprite_init_table_lo,x
	pha
	ldx !current_sprite_process
	rtl

spr_handle_main:
	lda !sprite_num,x
	tax
	lda.l sprite_main_table_bk,x
	pha
	pha
	plb
	lda.l sprite_main_table_hi,x
	pha
	lda.l sprite_main_table_lo,x
	pha
	ldx !current_sprite_process
	rtl
spr_callers_done:
%set_free_finish("bank1_sprcall_inits", spr_callers_done)

; note: this nukes the functionality for sprites that auto-respawn (lakitu, magikoopa)
org $028B05|!bank
	jsr ambient_sprcaller
	; cape interaction
	jsr.w $0294F5|!bank
	jsr.w _load_spr_from_lvl
	plb
	rtl
warnpc $028B67|!bank

%set_free_start("bank2_altspr1")
ambient_sprcaller:
	lda !sprites_locked
	sta !ambient_sprlocked_mirror
	stz !ambient_sprlocked_mirror+1

	lda #$24
	sta !next_oam_index
	rep #$30
if !ambient_debug
	stz !ambient_resident
endif
	ldx.w #(!num_ambient_sprs*2)-2
.loop:
	lda !ambient_rt_ptr,x
	beq .go_next
	stx !current_ambient_process
	lda !ambient_sprlocked_mirror
	bne .no_timer
	%implement_timer("!ambient_gen_timer,x")
.no_timer:
if !ambient_debug
	inc !ambient_resident
endif
	jsr (!ambient_rt_ptr,x)
;	lda !ambient_twk_tilesz,x
;	bpl .go_next
;	jsr ambient_physics
.go_next:
	dex : dex
	bpl .loop

handle_turnblocks:
	lda !ambient_sprlocked_mirror
	bne .done
	lda.w #(!num_turnblock_slots-1)
	sta $45
	ldx !turnblock_run_index
.loop:
	txa
	sec
	sbc #$0006
	bpl .next_ix_ok
	lda.w #(!num_turnblock_slots-1)*6
.next_ix_ok:
	sta $47

	lda turnblock_status_d.timer,x
	; if current run index has a zero timer,
	; there is nothing after it to run, this ring
	; is first-in last-out
	beq .done
	dec
	sta turnblock_status_d.timer,x
	bne .no_terminate
	lda turnblock_status_d.x_pos,x
	sta !block_xpos
	lda turnblock_status_d.y_pos,x
	sta !block_ypos
	; turn block
	lda #$000C
	sta $9C
	jsl $00BEB0|!addr
	ldx $47
	stx !turnblock_run_index
.no_terminate:
	ldx $47
	dec $45
	bpl .loop
.done:
	sep #$30
	rts
ambient_sprcaller_done:
%set_free_finish("bank2_altspr1", ambient_sprcaller_done)

org $00A1DA|!bank
oam_refresh_hijack:
	jml oam_refresh|!bank
	nop

oam_refresh_hijack_done  = $00A1DF|!bank
oam_refresh_hijack_done2 = $00A1E4|!bank

%set_free_start("bank6")
; courtesy of ragey. thanks!
oam_refresh:
	lda $1426|!addr
	beq +
	jml oam_refresh_hijack_done
+	ldy #$44
	lda $13F9|!addr
	beq +
	ldy #$24
+	sty !next_oam_index
	jml oam_refresh_hijack_done2
; This table is automatically generated when sprite tables are created
oam_tile_count:
	skip $100
oam_alloc_free_done:
%set_free_finish("bank6", oam_alloc_free_done)
