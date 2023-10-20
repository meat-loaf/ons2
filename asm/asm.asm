includeonce
lorom

incsrc "headers/hw_regs.asm"
incsrc "headers/consts.asm"
incsrc "headers/routines.asm"
incsrc "headers/macros.asm"
incsrc "headers/ram.asm"
incsrc "headers/structs.asm"
incsrc "headers/512kfree.asm"

incsrc "core/core.asm"
incsrc "tweaks/tweaks.asm"
incsrc "sprites/sprites.asm"
incsrc "blocks/blocks.asm"

incsrc "data.asm"

print "freespace used: ", freespaceuse, " bytes."
print "bytes modified: ", bytes, " bytes."

print "bank_7_end at ", hex(!bank7_free_start)
