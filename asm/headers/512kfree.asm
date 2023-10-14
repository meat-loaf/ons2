!bank1_early_free_start      = $018042|!bank
!bank1_early_free_end        = $01808C|!bank

;!bank1_gfx_stuff_free_start  = $01|!bank
;!bank1_gfx_stuff_free_end  = $01|!bank

!bank1_fish_free_start       = $01B00B|!bank
!bank1_fish_free_end         = $01B192|!bank

!bank1_sprcall_inits_free_start = $0180D2|!bank
!bank1_sprcall_inits_free_end   = $018898|!bank

; todo validate range - overwrites more than just spr0to13
!bank1_spr0to13_free_start        = $0188EC|!bank
!bank1_spr0to13_free_end          = $019032|!bank

; TODO should be expanded to $0197AD but there is a stun timer handler in the middle
;      that needs to be ported. Can expand further by porting grounded speed adj routine,
;      which should be simple
!bank1_stunned_handler_start      = $01953C|!bank
!bank1_stunned_handler_end        = $0195FC|!bank

!bank1_thwomp_free_start     = $01AE96|!bank
!bank1_thwomp_free_end       = $01AF9F|!bank

!bank1_plats_free_start      = $01B268|!bank
; stops at invis solid block rt
; note: rewrite it
!bank1_plats_free_end        = $01B44F|!bank

;!bank1_growvine_free_start   = $01C183|!bank
;!bank1_growvine_free_end     = $01C1EE|!bank

; starts just before turn block bridge stuff
!bank1_powerups_free_start   = $01B93C|!bank
; ends at rotating chain platform
!bank1_powerups_free_end     = $01C74A|!bank

; starts at koopakids sprite code (before this is the brown swinging platform code
!bank1_bossfire_free_start   = $01CD2A|!bank
;!bank1_bossfire_free_start   = $01D442|!bank
; overwrite a bunch of sprites, up to smushed gfx rt (slated for removal)
!bank1_bossfire_free_end     = $01E6FD|!bank
;!bank1_bossfire_free_end     = $01D4E4|!bank

; starts at yoshi egg code, really most of the mode7 handling code
!bank1_koopakids_free_start  = $01F75C|!bank
!bank1_koopakids_free_end    = $020000|!bank

;!bank2_d51e_free_start       = $02D51E|!bank
;!bank2_d51e_free_end         = $02D580|!bank

; TODO there's more space here, but there's also
;  some cape interaction after this range?
!bank2_altspr1_free_start     = $028B67|!bank
!bank2_altspr1_free_end       = $029391|!bank

; TODO validate this range! bank2 has a bunch of random
;      stuff smattered throughout it. this nukes shooters,
;      generators, cluster sprites, and some other original
;      normal sprite code
; TODO there is two routines at $02A751, invoked as part of the level transition
;      repoint these
; This range is mostly intended for use by the new ambient sprites system
!bank2_altspr2_free_start     = $02ACE5|!bank
!bank2_altspr2_free_end       = $030000|!bank

!bank3_sprites_free_start    = $038000|!bank
!bank3_sprites_free_end      = $03AF34|!bank

!bank4_free_start            = $04A1B6|!bank
!bank4_free_end              = $04A400|!bank

!bank6_free_start            = $068063|!bank
!bank6_free_end              = $06F600|!bank

!bank7_free_start            = $078003|!bank
;!bank7_free_end              = $07F0C8|!bank
!bank7_free_end              = $07F7DB|!bank
