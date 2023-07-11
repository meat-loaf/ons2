includefrom "macros.asm"
includeonce

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
