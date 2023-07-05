; todo probably move to another bank; all gm code will be in the same bank
; a = size (16 bit)
; y = value to initialize (8-bit)
; $82-$84: dest long ptr
%set_free_start("bank7")
dma_set_ram_l:
	sta $4335
	sty $211B
	ldx #$00
	stx $211B
	inx
	stx $211C
	lda.w #dma_pack_ctrl_dst_16($2134, !dma_control_direction)
	sta $4330
	ldx $84
	stx $4334
	lda $82
	sta $4332
	ldx #%0001000
	stx $420B
	rtl
dma_set_ram_l_done:
%set_free_finish("bank7", dma_set_ram_l_done)
