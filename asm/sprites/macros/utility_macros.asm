includefrom "macros.asm"

macro jump_hijack(jump_op, length, target, hijack_addr, maxaddr)
	org <hijack_addr>
	<jump_op>.<length> <target>
	warnpc <maxaddr>
endmacro
