includeonce

function pack_props(flip, priority, palette, page) = ((flip&03)<<$06)|((priority&03)<<$04)|((palette&$07)<<1)|(page&$01)

function dma_pack_ctrl_dst_16(dest, ctrl) = ((dest<<8)&$FF00)|(ctrl&$FF)

macro pack(...)
endmacro

function invert(val) = (~val)+1

macro implement_timer(ram)
	lda <ram>
	beq ?no_dec
	dec <ram>
?no_dec:
endmacro

macro write_sfx(name)
	if or(not(defined("sfx_<name>_id")), not(defined("sfx_<name>_port")))
		error "Sound effect `<name>' not defined."
	else
		lda.b #!sfx_<name>_id
		sta.w !sfx_<name>_port
	endif
endmacro

; abuse open bus and unused dma register behavior to quickly duplicate the
; high low/high byte of a register in 16-bit mode. thanks ladida
; note: not interrupt safe
macro dupe_low(index_s, index_r)
	; writes low to 437b (unused but mapped) and high 437c (open bus, ignored)
	st<index_s> $437b
	; read value written to 437b, that value will be on the bus so it is read again
	; due to open bus behavior
	ld<index_r> $437b
endmacro

macro dupe_high(index_s, index_r)
	; writes low to 437e (open bus, ignored) and high to 437f (unused but mapped)
	st<index_s> $437e
	; read from 437b (43xb and 43xf are mirrors of each other); otherwise same as
	; before, just with the high byte
	ld<index_r> $437b
endmacro
