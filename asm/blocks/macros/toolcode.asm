includeonce

; TODO REVISIT THIS
; from gps - hijack LM map16 code for block interactions
macro hijack_offset(id, addr, routine)
	org <addr>
	!id #= <id>
	block_hijack_!{id}:
		PHB : PHX
		REP #$30
		LDA.w #(<id>*2)+1
		autoclean JSL <routine>
		PLX : PLB
		JMP $F602
endmacro
