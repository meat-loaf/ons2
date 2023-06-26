includefrom "macros.asm"

macro alloc_ambient_sprite(ambient_id, name, main_rt, tweaker_bitfield)
	%alloc_ambient_sprite_grav(<ambient_id>, <name>, <main_rt>, <tweaker_bitfield>, 0, 0)
endmacro

macro alloc_ambient_sprite_grav(ambient_id, name, main_rt, tweaker_bitfield, grav_accel, grav_max)
	!aid #= <ambient_id>
	assert !aid < !ambient_sprid_max+1, "Maximum ambient sprite id is !ambient_sprid_max"
	assert not(defined("ambient_!{aid}_defined")), "Ambient sprite id <ambient_id> already defined."
	assert bank(<main_rt>)&$7F == $02, "Ambient sprites are allowed in bank 2 only."
	!{ambient_!{aid}_defined} = 1
	!{ambient_!{aid}_tag}     = <name>
	!{ambient_!{aid}_main}    = <main_rt>
	!{ambient_!{aid}_tweaker} = <tweaker_bitfield>
	!{ambient_!{aid}_grav_accel} = <grav_accel>
	!{ambient_!{aid}_grav_tv}    = <grav_max>
	undef "aid"
endmacro


