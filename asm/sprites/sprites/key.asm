includefrom "list.def"

!key_sprnum = $80

%alloc_sprite(!key_sprnum, "key", generic_carryable_init, generic_carryable_init, 1, 0, \
	$00, $0C, $20, $3E, $3A, $C0)

; remap key tile
org $01A1FA|!bank
	db $42
