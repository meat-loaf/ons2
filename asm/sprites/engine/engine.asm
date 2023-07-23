; some temporary shims for long-calling original rts routines
incsrc "jslshims.asm"
; TODO deprecated, remove
incsrc "gfx_rts.asm"
incsrc "spritesets.asm"

; old sprite types -> new ambient sprites
incsrc "ambient.asm"

; core code
incsrc "load.asm"
incsrc "run.asm"

; hijacks for relocated sprite table initers
incsrc "init.asm"

; generic bank-specific stuff
incsrc "bank1.asm"
; ambient sprites impl
incsrc "bank2.asm"
incsrc "bank3.asm"
; routines only
incsrc "bank4.asm"
incsrc "bank6.asm"
incsrc "bank7.asm"
