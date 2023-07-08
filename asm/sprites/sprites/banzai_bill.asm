
!banzai_bill_sprnum = $9F

%alloc_sprite_spriteset_2(!banzai_bill_sprnum, "banzai_bill", banzai_bill_init, banzai_bill_main, 16, \
	$105, $106, \
	$10, $B6, $30, $01, $19, $04)

!banzai_bill_rot      = !sprite_misc_151c
!banzai_bill_face_dir = !sprite_misc_157c

%set_free_start("bank1_koopakids")
banzai_bill_init:
	inc !banzai_bill_face_dir,x
	; always face left
	inc !banzai_bill_face_dir,x
	;lda #$f8
	;sta !sprite_speed_x,x
.exit:
	rtl

banzai_bill_main:
	lda.b #banzai_bill>>8
	xba
	lda.b #banzai_bill
	jsl spr_gfx
	lda !sprite_status,x
	eor #$08
	ora !sprites_locked
	bne banzai_bill_init_exit
	lda !effective_frame
	and #$1F
	bne .skip
	inc !banzai_bill_rot,x
	lda !banzai_bill_rot,x
	and #$03
	tay
	lda !sprite_oam_properties,x
	and #$3F
	ora .rot_props,y
	sta !sprite_oam_properties,x
.skip:
	lda #$02
	jsl sub_off_screen
	jsl spr_upd_x_no_grv_l
	jml mario_spr_interact_l
.rot_props:
	db $00, $40, $C0, $80

%start_sprite_table("banzai_bill", 64, 64)
	; row 1
	%sprite_table_entry($E8, $E8, $08, $02, 2, 1)
	%sprite_table_entry($F8, $E8, $0A, $02, 2, 1)
	%sprite_table_entry($08, $E8, $0C, $02, 2, 1)
	%sprite_table_entry($18, $E8, $0E, $02, 2, 1)
	; row 2
	%sprite_table_entry($E8, $F8, $20, $02, 2, 1)
	%sprite_table_entry($F8, $F8, $22, $02, 2, 1)
	%sprite_table_entry($08, $F8, $2C, $02, 2, 1)
	%sprite_table_entry($18, $F8, $2E, $02, 2, 1)
	; row 3
	%sprite_table_entry($E8, $08, $24, $02, 2, 1)
	%sprite_table_entry($F8, $08, $26, $02, 2, 1)
	%sprite_table_entry($08, $08, $2C, $02, 2, 1)
	%sprite_table_entry($18, $08, $2E, $02, 2, 1)
	; row 4
	%sprite_table_entry($E8, $18, $28, $02, 2, 1)
	%sprite_table_entry($F8, $18, $2A, $02, 2, 1)
	%sprite_table_entry($08, $18, $0C, $82, 2, 1)
	%sprite_table_entry($18, $18, $0E, $82, 2, 1)
%finish_sprite_table()
banzai_bill_done:
%set_free_finish("bank1_koopakids", banzai_bill_done)
