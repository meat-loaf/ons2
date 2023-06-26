!bank = $800000

test_level_l1_ptr  = $068000|!bank

; null sprite list, at top of bank (original sprite data loader
; has all sprite data in bank 07)
org $078000|!bank
test_level_spr_ptr:
db $00,$FF

!ix #= 0
while !ix != $200
	org ($05E000+(!ix*3))|!bank
	dl test_level_l1_ptr
	org ($05EC00+(!ix*2))|!bank
	dw test_level_spr_ptr
	!ix #= !ix+1
endif
