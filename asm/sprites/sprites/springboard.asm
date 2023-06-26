includefrom "list.def"

springboard_main = $01E623|!bank

!springboard_sprnum = $2F
%alloc_sprite(!springboard_sprnum, "springboard", springboard_end, springboard_main, 4, 0, \
	$00, $00, $3A, $BE, $0A, $C4)

%alloc_sprite_sharedgfx_entry_12(!springboard_sprnum, \
	$0E,$0E,$0E,$0E, \
	$0F,$0F,$0F,$0F, \
	$83,$83,$1E,$1E)
; end of springboard routine
org $01E6FC|!bank
springboard_end:
	rtl

; springboard carried state shim - uses RTL above
org $01A229|!bank
springboard_carried_callgfx:
	jmp springshim
warnpc $01A22C|!bank
