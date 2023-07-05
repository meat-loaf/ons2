incsrc "include/defines.def"
incsrc "macros/toolcode.asm"
incsrc "macros/table_builders.asm"
incsrc "macros/block_def.asm"


;freecode
%set_free_start("bank6")
; setup block macros and allocate blocks
incsrc "list.def"
_BLOCKS_DONE_:
%set_free_finish("bank6", _BLOCKS_DONE_)

; apply the tool code and defined block code
incsrc "engine/engine.asm"
