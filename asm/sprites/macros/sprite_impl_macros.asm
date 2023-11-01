includefrom "macros.asm"
includeonce

macro invert_accum_8()
	eor.b #$ff
	inc
endmacro

macro invert_accum_16()
	eor.w #$ffff
	inc
endmacro

macro dyn_slot_setup(dyn_name)
if !{dyn_spr_<dyn_name>_gfx_id} == 0
	stz !sprite_dyn_gfx_id,x
else
	lda #!{dyn_spr_<dyn_name>_gfx_id}
	sta !sprite_dyn_gfx_id,x
endif

endmacro

macro spr_pos_offset(val, table_lo, table_hi)
	lda <table_lo>
	clc
	adc <val>
	sta <table_lo>
	lda <table_hi>
	adc #$00
	sta <table_hi>
endmacro

macro spr_offset_xy8()
	sta $00
	bit #$01
	beq ?no_x
	%spr_pos_offset(#$08, "!sprite_x_low,x", "!sprite_x_high,x")
	lda $00
?no_x:
	bit #$02
	beq  ?done
	%spr_pos_offset(#$08, "!sprite_y_low,x", "!sprite_y_high,x")
?done:
endmacro

macro sub_horz_pos(tag)
<tag>sub_horz_pos:
	ldy #$00
	lda !player_x_next
	sec
	sbc !sprite_x_low,x
	sta $0E
	lda !player_x_next+1
	sbc !sprite_x_high,x
	sta $0F
	bpl <tag>.left
	iny
<tag>.left:
endmacro

macro sub_vert_pos(tag)
<tag>sub_vert_pos:
	ldy #$00
	lda !player_y_next
	sec
	sbc !sprite_y_low,x
	sta $0F
	lda !player_y_next+1
	sbc !sprite_y_high,x
	bpl .above
	iny
<tag>.above:
endmacro

macro spr_obj_blocked(flags)
	lda !sprite_blocked_status,x
	and.b #<flags>
endmacro

macro spr_touching_ceil()
	%spr_obj_blocked(!sprite_blocked_above)
endmacro

macro spr_touching_left()
	%spr_obj_blocked(!sprite_blocked_left)
endmacro

macro spr_touching_right()
	%spr_obj_blocked(!sprite_blocked_right)
endmacro

macro spr_on_ground()
	%spr_obj_blocked(!sprite_blocked_below)
endmacro

macro spr_touching_wall()
	%spr_obj_blocked(!sprite_blocked_left|!sprite_blocked_right)
endmacro

macro set_spr_gfx_rt(routine)
	assert bank(<routine>) == $87, "Graphics routines must be in bank 7."
	lda.b #(<routine>-1)
	sta !spr_gfx_lo,x
	lda.b #(<routine>-1)>>8
	sta !spr_gfx_hi,x
endmacro
