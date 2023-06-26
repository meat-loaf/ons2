@asar 1.81

; ----------------------------------------------------------------------------------------------------------------------------------
;
; "Item Memory"
; by Ragey <i@ragey.net>
; https://github.com/xragey/smw
;
; Replaces the item memory system in Super Mario World with a different system that assigns a bit to every individual tile in a
; stage, rather than having columns within a screen share the same bit. Also implements item memory settings 3. Implements a flag
; that can be used to toggle the use of item memory. Compatible with the ExLevel system implemented by recent versions of Lunar
; Magic.
;
; Installing this patch reclaims offset $7E19F8 (384 bytes).
;
; Division and multiply routines by GreenHammerBro <https://smwc.me/u/18802>
; Additional coding by lx5 <https://github.com/TheLX5>
;
; ----------------------------------------------------------------------------------------------------------------------------------

!ExLevelScreenSize = !exlvl_screen_size
!ItemMemory = !item_memory
!ItemMemoryMask = !item_memory_mask

assert read1($00FFD5) != $23, "This patch does not support SA-1 images."

if read1($00FFD5)&$10 == $10
	!fast = 1
else
	!fast = 0
endif

; Loading level code
org $0096F4|!bank
	jsl clear_item_memory|!bank

; Item memory offsets, for settings 0,1,2,3 respectively.
org $00BFFF|!bank
ItemMemoryBlockOffsets:
    dw $0000, $0700<<3, $0E00<<3, $1500<<3
warnpc $00C00D|!bank

org $00C00D|!bank
autoclean \
	JSL write_item_memory
	RTS
clear_item_memory:
	; Check if we're entering from the overworld.
	LDA $141A|!addr
	BNE .no_clear

	; clear item memory via rom->ram DMA
	; read the 0000 entry over and over for the whole
	; item memory table
	REP #$30
	LDA.w #!ItemMemory
	STA.w $2181
	SEP #$20
	LDA.b #!ItemMemory>>16
	STA.w $2183
	LDX #$8008
	STX $4300
	LDX #ItemMemoryBlockOffsets
	STX $4302
	LDA #ItemMemoryBlockOffsets>>16
	STA $4304
	; clear item memory and some other assorted backup ram...
	LDX #(!item_memory_size+$8)
	STX $4305
	LDA #$01
	STA $420B
	SEP #$10
;if !use_midway_imem_sram_dma = !true
;	; copy cleaned item mem ram -> sram
;	%move_block(!item_memory,!item_memory_mirror_s,!item_memory_size)
;endif
.no_clear:
	; Restore overwritten jump position.
	JML $05D796|!bank
warnpc $00C063|!bank

freecode
; sprite item memory: use the last 16 bytes of the item memory buffer
; as a faux (compacted) sprite load table. In practice these are never used anyway
; gen entry is used as follows:
;  y = nonzero does a read (with result in Z flag) of item memory
;  y = 0: does a write of the sprite load index bit value to item memory
sprite_write_item_memory:
sprite_item_memory:
.write:
	lda !item_memory_mask
	and #$01
	bne .done
	ldy #$00
.gen_entry:
	lda !sprite_load_index,x
	and #$0F
	sta $00
	stz $01
	lda !sprite_load_index,x
	lsr #4
	sta $02
	stz $03

	lda !item_memory_setting
	asl
	tax
	rep #$30
	lda ItemMemoryBlockOffsets,x
	lsr #3
	clc
	; offset to the end of the buffer
	adc #$0700-($10)
	adc $02
	; store index to buffer
	sta $02
	ldx $00
	; load bit to set
	sep #$20
	lda.l $00C0AA|!bank,x
	ldx $02
	cpy #$0000
	bne .read
	ora !item_memory,x
	sta !item_memory,x
	sep #$10
	ldx !current_sprite_process
.done:
	rtl
.read:
	and !item_memory,x
	sep #$10
	sta $00
	ldx !current_sprite_process
	lda $00
	rtl

; WriteItemMemory. Marks a certain coordinate as collected.
; This can be used as a shared routine.
; On entry, $98 should be set to the X position and $9A as the Y position.
write_item_memory:
	LDA !ItemMemoryMask
	BIT #$01
	BNE .Return
.cont:
	STX $4F
	; X = Item memory index
	LDA $13BE|!addr
	ASL
	TAX

	; $45 = $13D7 * X position
	REP #$30
	LDY $13D7|!addr
	LDA $9A
	LSR #4
	PHA
	LSR #4
	CMP $13D7|!addr
	BCS +
	TAY
	LDA $13D7|!addr
+	SEP #$30
	STA $211B
	XBA
	STA $211B
	STY $211C
	REP #$20
	LDA $2134
	STA $45

	; $47 = Y positon * 16
	LDA $98
	AND #$3FF0
	STA $47

	; A = Absolute offset
	PLA
	AND #$000F
	CLC
	ADC $45
	CLC
	ADC $47
	CLC
	ADC.l ItemMemoryBlockOffsets,x

	; X = Address offset
	; A = Bit to set in address
	REP #$10
	STA $45
	LSR #3
	TAX
	PHX
	LDA $45
	AND #$0007
	TAX
	SEP #$20
	LDA.l $00C0AA|!bank,x
	PLX
	ORA.l !ItemMemory,x
	STA.l !ItemMemory,x
	SEP #$10
	LDX $4F
.Return
	RTL
sprite_read_item_memory:
	lda !item_memory_mask
	and #$02
	bne read_item_memory_abort
	ldy #$01
	jmp sprite_item_memory_gen_entry

; ReadItemMemory. Checks if the current block coordinate is marked as collected.
; This can be used as a shared (object generation) routine.
; On entry, $6B+Y should be set to the current block linear index. For pretty
; much all object generation routines, this is already set correctly. Returns
; A=$00 if the flag is not set or any other value if it's set.
read_item_memory:
	LDA !ItemMemoryMask
	BIT #$02
	BEQ .do_read
.abort:
	LDA #$00
	RTL
.do_read:
	STX $4F
	; A = $45 = Absolute offset
	LDA $13BE
	ASL
	TAX
	REP #$30
	LDA $6B
	SEC
	SBC #$C800
	CLC
	ADC.l ItemMemoryBlockOffsets,x
	STA $45
	TYA
	CLC
	ADC $45
	STA $45

	; X = Address offset
	; A = Bit to read in address
	LSR #3
	TAX
	PHX
	LDA $45
	AND #$0007
	SEP #$20
	TAX
	LDA.l $00C0AA|!bank,x
	PLX
	AND.l !ItemMemory,x
	SEP #$10
	PHP
	LDX $4F
	PLP
.Return
	RTL
