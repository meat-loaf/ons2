%set_free_start("bank6")
; from pixi
; note: this is temporary, eventually implement a unified 'ambient sprite' type
; that this will be converted to
;inputs:
;  a   = number of sprite to spawn
;  $00 = x offset
;  $01 = y offset
;  $02 = timer
;
;outputs:
;  y     = index to spawned sprite
;  carry = clear: successful spawn, set: spawn failed

; clobbers:
;  y
spr_spawn_smoke:
	ldy #$03
	xba
.loop
	lda $17C0|!addr,y
	beq .found
	dey
	bpl .loop
	sec
	rtl

.found:
	xba
	sta $17C0|!addr,y
	lda $02
	sta $17CC|!addr,y

	lda !sprite_y_low,x
	clc
	adc $01
	sta $17C4|!addr,y

	lda !sprite_x_low,x
	clc
	adc $00
	sta $17C8|!addr,y
	clc
	rtl
.done
%set_free_finish("bank6", spr_spawn_smoke_done)
