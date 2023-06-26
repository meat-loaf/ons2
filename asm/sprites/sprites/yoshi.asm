!yoshi_sprnum = $35

; note: yoshi has special oam alloc
%alloc_sprite(!yoshi_sprnum, "yoshi", yoshi_jsl2rts_init, yoshi_jsl2rts_main, 0, 0,\
	$05, $09, $2A, $87, $29, $46)


%set_free_start("bank1_koopakids")
yoshi_jsl2rts:
.init:
	%jsl2rts(!bank01_jsl2rts_rtl, $0183E0|!bank)
.main:
	%jsl2rts(!bank01_jsl2rts_rtl, $01EBCA|!bank)
.done:
%set_free_finish("bank1_koopakids", yoshi_jsl2rts_done)

org $01ED64|!bank
nop #4
