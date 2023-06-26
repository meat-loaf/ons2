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

org $00816A
	autoclean jml dsx_main

;;;;;;;;;;;;;
;; Macro borrowed from SA-1 patch
;;;;;;;;;;;;;

; A is 16-bit, X is 8-bit.
macro transferslot(slot, bytes, shift)
	LDA.W #$7C00+(<slot>*256)+<shift>	; \ VRAM address + line*slot
	STA.W $2116				; /
	LDA.W #(!dsx_buffer&65535)+(<slot>*512)+(<shift>*2) ;\ Set Buffer location
	STA.W $4302				; /
	LDA.W #<bytes>				; \ Set bytes to transfer
	STA.W $4305				; /
	STY.W $420B				; Run DMA.
endmacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

freecode
return:
	SEP #$30		;8bit AXY
	JML $808176		;jump to code just after pushing, into FastROM area
dsx_main:
	SEI
	PHP
	REP #$30		;initialize NMI
	PHA
	PHX
	PHY
	PHB
	SEP #$30
	
	LDA #$80		;set bank to zero in FastROM area
	PHA
	PLB
	
	LDA #$01		;FastROM on
	STA $420D

	LDA !gamemode		;check game mode to see if in game
	CMP #$14		;must be in either this mode (level)...
	BEQ GameModeOK		
	CMP #$07		;... or this mode (title screen)
	BNE return

GameModeOK:
	LDA !dyn_slots		;and only if there's actual stuff to transfer
	BEQ return
	
	REP #$20
	TDC			;clear A
	LDY #$80
	STY $2115		;setup some DMA transfer info
	LDA #$1801
	STA $4300
	LDY.b #!dsx_buffer/65536
	STY $4304
	LDY #$01

	; note: used slots ram cleared in sprite loop each frame, not here like original
	LDA !dyn_slots
	ASL
	TAX
	JMP (dsx_modes-2,x)

dsx_modes:
	dw .transfer_one
	dw .transfer_two
	dw .transfer_three
	dw .transfer_four

.transfer_one:
	%transferslot(0, $0100, $00)
	%transferslot(1, $0100, $00)
	SEP #$30
	JML $808176

.transfer_two:
	%transferslot(0, $0400, $00)
	SEP #$30
	JML $808176
.transfer_three:
	%transferslot(0, $0500, $00)
	%transferslot(3, $0100, $00)
	SEP #$30
	JML $808176
.transfer_four:
	%transferslot(0, $0800, $00)
	SEP #$30
	JML $808176
