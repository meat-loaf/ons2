;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Dynamic Sprites Patch
;; By smkdan & edit1754 
;;
;; Original description:
;; code to provide sprites with dynamic video memory updating
;; patched with asar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This update copies SA-1 method to handle the dynamic sprite slots.
;;
;; Originally, dsx.asm just uploaded the whole lower half of SP4 every frame,
;; now it only uploads the graphics of the sprites that are on screen.
;;
;; It also has integrated garble.asm instead of having it on another file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

lorom

!dsx_buffer     = !dynamic_buffer

org $00816A|!bank
	autoclean jml dsx_main

;;;;;;;;;;;;;
;; Macro borrowed from SA-1 patch
;;;;;;;;;;;;;

; A is 16-bit, X is 8-bit.
macro transferslot(slot, bytes, shift)
	lda.w #$7C00+(<slot>*256)+<shift>	; \ VRAM address + line*slot
	sta.w $2116				; /
	lda.w #(!dsx_buffer&65535)+(<slot>*512)+(<shift>*2) ;\ Set Buffer location
	sta.w $4302				; /
	lda.w #<bytes>				; \ Set bytes to transfer
	sta.w $4305				; /
	sty.w $420B				; Run DMA.
endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode
return:
	sep #$30
	jml $008176|!bank       ;jump to code just after pushing, into FastROM area
dsx_main:
	sei
	php
	rep #$30		;initialize NMI
	pha
	phx
	phy
	phb
	sep #$30
	
	lda #$80		;set bank to zero in FastROM area
	pha
	plb
	
	lda #$01		;FastROM on
	sta $420D

	lda !gamemode		;check game mode to see if in game
	cmp #$14		;must be in either this mode (level)...
	beq GameModeOK
	cmp #$07		;... or this mode (title screen)
	bne return

GameModeOK:
	lda !dyn_slots		;and only if there's actual stuff to transfer
	beq return
	
	rep #$20
	tdc			;clear A
	ldy #$80
	sty $2115		;setup some DMA transfer info
	lda #$1801
	sta $4300
	ldy.b #!dsx_buffer/65536
	sty $4304
	ldy #$01

	; note: used slots ram cleared in sprite loop each frame, not here like original
	lda !dyn_slots
	asl
	tax
	jmp (dsx_modes-2,x)

dsx_modes:
	dw .transfer_one
	dw .transfer_two
	dw .transfer_three
	dw .transfer_four

.transfer_one:
	%transferslot(0, $0100, $00)
	%transferslot(1, $0100, $00)
	sep #$30
	jml $808176

.transfer_two:
	%transferslot(0, $0400, $00)
	sep #$30
	jml $808176

.transfer_three:
	%transferslot(0, $0500, $00)
	%transferslot(3, $0100, $00)
	sep #$30
	jml $808176

.transfer_four:
	%transferslot(0, $0800, $00)
	sep #$30
	jml $808176
