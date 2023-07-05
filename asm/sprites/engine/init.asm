includeonce
; relocating sprite table init calls

; palace switch block - spawn flattened switch
org $00FA75|!bank
	jsl init_sprite_tables
; level end powerup spawn
org $00FB60|!bank
	jsl init_sprite_tables

; some yoshi code maybe?
org $00FCBC|!bank
	jsl init_sprite_tables
; lakitu code?
;org $0184C6|!bank
;	jsl init_sprite_tables

; spiny egg
;org $018C34|!bank
;	jsl init_sprite_tables

; sprite part of sprite unstunning routine
org $0196F6|!bank
	jsl init_sprite_tables

; spawn moving coin
org $019798|!bank
	jsl init_sprite_tables

; yoshi code?
org $01A2DC|!bank
	jsl init_sprite_tables

; magikoopa magic
;org $01BC97|!bank
;	jsl init_sprite_tables

; magikoopa
;org $01BF53|!bank
;	jsl init_sprite_tables

; boss code
;org $01D0A4|!bank
;	jsl init_sprite_tables

; bonus game stuff
;org $01DDD9|!bank
;	jsl init_sprite_tables

; yoshi egg hatching?
org $01ECC5|!bank
	jsl init_sprite_tables

; yoshi eat sprite related
org $01F5E7|!bank
	jsl init_sprite_tables

; something yoshi/baby yoshi spawning related
org $01F855|!bank
	jsl init_sprite_tables
org $01F867|!bank
	jsl init_sprite_tables

; yoshi code
org $01F2F9|!bank
	jsl load_sprite_tables


; bank 2 stuff: most of this is overwritten
