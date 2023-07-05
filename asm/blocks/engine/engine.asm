; initial lm hijacks (from gps)

org acts_like_00_to_3f_ptr
autoclean \
	dl block_actslike

%hijack_offset($00, $06F690, block_execute) ; below
%hijack_offset($01, $06F6A0, block_execute) ; above
%hijack_offset($02, $06F6B0, block_execute) ; side
%hijack_offset($07, $06F6C0, block_execute) ; top corner
%hijack_offset($08, $06F6D0, block_execute) ; body
%hijack_offset($09, $06F6E0, block_execute) ; head

; TODO these are 'special' in gps' code, figure it out
%hijack_offset($03, $06F720, block_execute) ; sprite v
%hijack_offset($04, $06F730, block_execute) ; sprite h
;
%hijack_offset($05, $06F780, block_execute) ; cape
%hijack_offset($06, $06F7C0, block_execute) ; fireball
%hijack_offset($0A, $06F7D0, block_execute) ; wallrun feet
%hijack_offset($0B, $06F7E0, block_execute) ; wallrun body

!block_ptr = $00
freecode
prot block_banks
prot block_ptrs
; a16i16
block_execute:
	sta $05
	ldx $03
	lda.l block_banks-1,x
	and #$FF00
	beq .exit
	sta !block_ptr+1
	txa
	asl
	tax
	lda.l block_ptrs,x
	sta $00
;	sta $00
;	lda [$00]
	clc
	adc $05
	sta $00
	lda [$00]
	sta $00
;	sta $00
	sep #$30
	jml [$0000]
.exit:
	sep #$30
	rtl

%build_actslike_table(block_actslike, $40)
%build_block_tables(block_ptrs, block_banks)
