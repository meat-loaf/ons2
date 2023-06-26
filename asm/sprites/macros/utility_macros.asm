includefrom "macros.asm"

macro jump_hijack(jump_op, length, target, hijack_addr, maxaddr)
	org <hijack_addr>
	<jump_op>.<length> <target>
	warnpc <maxaddr>
endmacro

macro set_free_start(tag)
	pushpc
	if not(defined("<tag>_free_start"))
		error "Freespace tag '<tag>' invalid [start]."
	else
		org !<tag>_free_start
		;print "(<tag>) free start: ", pc
		!next_free_tag = <tag>
		!free_finished = 0
	endif
endmacro

macro set_free_finish(tag, label)
	; freespace doesn't deal with end tags, handled by asar's
	; freespace allocator
	if and(not(defined("<tag>_free_end")), not(defined("<tag>_free_not_512k")))
		error "Freespace tag '<tag>' invalid (no end defined and in first 512k) [finish]."
		pullpc ; silence error
	else
	  if not(defined("<tag>_free_not_512k"))
		warnpc !<tag>_free_end
	  endif

	  if or(not(defined("free_finished")), notequal(!free_finished,0))
		error "use 'set_free_start' before 'set_free_finish'."
		pullpc ; silence error
	  else
		assert stringsequal("<tag>","!next_free_tag"), "Expected to free tag !next_free_tag next."
		!<tag>_free_start = <label>
		!free_finished = 1
		pullpc
	  endif
	endif
endmacro

macro jsl2rts(rtl_addr, target_addr)
	assert bank(<rtl_addr>) == bank(<target_addr>), "JSL2RTS Bank of RTL and Target do not match."
	pea.w (<rtl_addr>)-1
	jml.l <target_addr>|!bank
endmacro
