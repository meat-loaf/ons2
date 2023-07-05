includeonce

incsrc "headers/consts.asm"
incsrc "headers/routines.asm"
incsrc "headers/macros.asm"
incsrc "headers/ram.asm"
incsrc "headers/structs.asm"

incsrc "tweaks/tweaks.asm"
incsrc "sprites/sprites.asm"
incsrc "blocks/blocks.asm"
incsrc "core/core.asm"

incsrc "data.asm"

print "freespace used: ", freespaceuse, " bytes."
print "bytes modified: ", bytes, " bytes."
