includefrom "list.def"

;%alloc_sprite($00, "shelless_koopa_green", init_standard_sprite, shelless_koopa_main, 2, 0,\
;	$70, $00, $0A, $00, $00, $00)
;%alloc_sprite($01, "shelless_koopa_red", init_standard_sprite, shelless_koopa_main, 2, 0,\
;	$70, $00, $08, $00, $00, $00)
;%alloc_sprite($02, "shelless_koopa_blue", init_standard_sprite, shelless_koopa_main, 2, 0,\
;	$70, $00, $06, $00, $00, $00)
;%alloc_sprite($03, "shelless_koopa_yellow", init_standard_sprite, shelless_koopa_main, 2, 0,\
;	$70, $00, $04, $00, $00, $00)

;%alloc_sprite($04, "koopa_green", init_standard_sprite, spr0to13_main, 5, 0,\
;	$10, $40, $0A, $00, $02, $A0)
;%alloc_sprite($05, "koopa_red", init_standard_sprite, spr0to13_main, 5, 0,\
;	$10, $40, $08, $00, $02, $A0)
;%alloc_sprite($06, "koopa_blue", init_standard_sprite, spr0to13_main, 5, 0,\
;	$10, $40, $06, $00, $02, $A0)
;%alloc_sprite($07, "koopa_yellow", init_standard_sprite, spr0to13_main, 5, 0,\
;	$10, $40, $04, $00, $02, $A0)
;
;; todo: change kicking animation frame index, to save a slot
;; note: stunned frames are (eventually) not going to be used
;%alloc_sprite_sharedgfx_entry_5($00,$CE,$CC,$CC,$FF,$80)
;
;; koopa + shell
;%alloc_sprite_sharedgfx_entry_9($04,$82,$A0,$82,$A2,$84,$A4,$8C,$8A,$8E)


;%alloc_sprite_sharedgfx_entry_mirror($01, $00)
;%alloc_sprite_sharedgfx_entry_mirror($02, $00)
;%alloc_sprite_sharedgfx_entry_mirror($03, $00)

;%alloc_sprite_sharedgfx_entry_mirror($05, $04)
;%alloc_sprite_sharedgfx_entry_mirror($06, $04)
;%alloc_sprite_sharedgfx_entry_mirror($07, $04)

;%set_free_start("bank6")
;init_standard_sprite:
;	%jsl2rts(!bank01_jsl2rts_rtl, $018575|!bank)
;spr0to13_main:
;	lda #$01
;	pha
;	plb
;	%jsl2rts(!bank01_jsl2rts_rtl, $018AFC|!bank)
;shelless_koopa_main:
;	lda #$01
;	pha
;	plb
;	%jsl2rts(!bank01_jsl2rts_rtl, $018904|!bank)
;.done:
;%set_free_finish("bank6", shelless_koopa_main_done)
