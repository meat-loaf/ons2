includefrom "spritesets.asm"

spriteset_off_ptrs:
	dw spritesets_null_spriteset          ; sprite 00 - nakie koopa grn
	dw spritesets_null_spriteset          ; sprite 01 - nakie koopa red
	dw spritesets_null_spriteset          ; sprite 02 - nakie koopa blu
	dw spritesets_null_spriteset          ; sprite 03 - nakie koopa ylw
	dw spritesets_null_spriteset          ; sprite 04 - koopa grn
	dw spritesets_null_spriteset          ; sprite 05 - koopa red
	dw spritesets_null_spriteset          ; sprite 06 - koopa blu
	dw spritesets_null_spriteset          ; sprite 07 - koopa ylw
	dw spritesets_null_spriteset          ; sprite 08 - parakoopa grn (flies)
	dw spritesets_null_spriteset          ; sprite 09 - parakoopa grn (bounces)
	dw spritesets_null_spriteset          ; sprite 0A - parakoopa red (vert)
	dw spritesets_null_spriteset          ; sprite 0B - parakoopa red (horz)
	dw spritesets_null_spriteset          ; sprite 0C - parakoopa ylw (dumb)
	dw spritesets_null_spriteset          ; sprite 0D - bob omb
	dw spritesets_null_spriteset          ; sprite 0E - keyhole
	dw spritesets_null_spriteset          ; sprite 0F - goomba     (galoomba)
	dw spritesets_null_spriteset          ; sprite 10 - paragoomba (paragaloomba)
	dw spritesets_sakasatachi             ; sprite 11 - buzzy beetle
	dw spritesets_null_spriteset          ; sprite 12 - unused sprite
	dw spritesets_lakitu_spiny            ; sprite 13 - spiny
	dw spritesets_lakitu_spiny            ; sprite 14 - falling spiny
	dw spritesets_fish                    ; sprite 15 - horz fish
	dw spritesets_fish                    ; sprite 16 - vert fish
	dw spritesets_fish                    ; sprite 17 - generator fish
	dw spritesets_fish                    ; sprite 18 - jumping fish
	dw spritesets_null_spriteset          ; sprite 19 - message box display
	dw spritesets_piranhas                ; sprite 1A - piranha plant
	dw spritesets_chucks                  ; sprite 1B - chuck football
	dw spritesets_bills                   ; sprite 1C - bullet bill
	dw spritesets_null_spriteset          ; sprite 1D - hoppin' flame
	dw spritesets_hoopster                ; sprite 1E - hoopster
	dw spritesets_magikoopa_bgflame       ; sprite 1F - magikoopa
	dw spritesets_magikoopa_bgflame       ; sprite 20 - magikoopa's magic
	dw spritesets_null_spriteset          ; sprite 21 - moving coin
	dw spritesets_climbing_koopas         ; sprite 22 - net koopa (grn, vert)
	dw spritesets_climbing_koopas         ; sprite 23 - net koopa (red, vert)
	dw spritesets_climbing_koopas         ; sprite 24 - net koopa (grn, horz)
	dw spritesets_climbing_koopas         ; sprite 25 - net koopa (red, horz)
	dw spritesets_blurp                   ; sprite 26 - blurp fish
	dw spritesets_thwomp_thwimp_spike     ; sprite 27 - thwimp
	dw spritesets_bigboo_smashplayers     ; sprite 28 - big boo
	dw spritesets_piranhas                ; sprite 29 - growing vine
	dw spritesets_piranhas                ; sprite 2A - upside-down piranha
	dw spritesets_null_spriteset          ; sprite 2B - sumo bros lightning
	dw spritesets_null_spriteset          ; sprite 2C - yoshi egg
	dw spritesets_null_spriteset          ; sprite 2D - baby yoshi (grn)
	dw spritesets_spiketop                ; sprite 2E - spike top
	dw spritesets_null_spriteset          ; sprite 2F - springboard
	dw spritesets_dry_bones_beetle_pencil ; sprite 30 - dry bones, throws bones
	dw spritesets_dry_bones_beetle_pencil ; sprite 31 - bony beetle
	dw spritesets_dry_bones_beetle_pencil ; sprite 32 - dry bones, stays on ledge
	dw spritesets_null_spriteset          ; sprite 33 - podoboo
	dw spritesets_null_spriteset          ; sprite 34 - boss fireball
	dw spritesets_null_spriteset          ; sprite 35 - yoshi
	dw spritesets_null_spriteset          ; sprite 36 - unused sprite
	dw spritesets_boo_booblock            ; sprite 37 - boo
	dw spritesets_eerie_fishin_boo        ; sprite 38 - eerie
	dw spritesets_eerie_fishin_boo        ; sprite 39 - wave eerie
	dw spritesets_null_spriteset          ; sprite 3A - urchin, fixed
	dw spritesets_null_spriteset          ; sprite 3B - urchin, wall-aware
	dw spritesets_null_spriteset          ; sprite 3C - urchin, wall-follow
	dw spritesets_rip_van_fish            ; sprite 3D - rip van fish
	dw spritesets_null_spriteset          ; sprite 3E - pow switch
	dw spritesets_null_spriteset          ; sprite 3F - para-goomba
	dw spritesets_null_spriteset          ; sprite 40 - para-bomb
	dw spritesets_dolphin                 ; sprite 41 - dolphin, long horz jump
	dw spritesets_dolphin                 ; sprite 42 - dolphin, short horz jump
	dw spritesets_dolphin                 ; sprite 43 - dolphin, vert jump
	dw spritesets_null_spriteset          ; sprite 44 - torpedo ted
	dw spritesets_null_spriteset          ; sprite 45 - directional coin
	dw spritesets_chucks                  ; sprite 46 - diggin' chuck
	dw spritesets_fish                    ; sprite 47 - magic fish
	dw spritesets_chucks                  ; sprite 48 - diggin' chuck's rock
	dw spritesets_null_spriteset          ; sprite 49 - dong pipe
	dw spritesets_goalsphere              ; sprite 4A - goal sphere
	dw spritesets_lakitu_spiny            ; sprite 4B - pipe lakitu
	dw spritesets_null_spriteset          ; sprite 4C
	dw spritesets_monty_mole_pokey        ; sprite 4D - ground monty mole
	dw spritesets_monty_mole_pokey        ; sprite 4E - ledge monty mole
	dw spritesets_piranhas                ; sprite 4F - jumpin' piranha plant
	dw spritesets_piranhas                ; sprite 50 - jumpin' piranha plant, spits fire
	dw spritesets_ninji                   ; sprite 51 - ninji
	dw spritesets_null_spriteset          ; sprite 52
	dw spritesets_null_spriteset          ; sprite 53
	dw spritesets_null_spriteset          ; sprite 54
	dw spritesets_wood_checkered_plats    ; sprite 55 - horizonal checkered platform
	dw spritesets_rock_grass_plats        ; sprite 56 - horz flying rock platform
	dw spritesets_wood_checkered_plats    ; sprite 57 - vertical checkered platform
	dw spritesets_rock_grass_plats        ; sprite 58 - vert flying rock platform
	dw spritesets_null_spriteset          ; sprite 59 - turn block bridge - horz
	dw spritesets_null_spriteset          ; sprite 5A - turn block bridge - horz/vert
	dw spritesets_wood_checkered_plats    ; sprite 5B - brown wood plat, floats
	dw spritesets_wood_checkered_plats    ; sprite 5C - checkered platform, floats
	dw spritesets_rock_grass_plats        ; sprite 5D - floating grass platform
	dw spritesets_rock_grass_plats        ; sprite 5E - grass platform, goes on forever if no buoyancy
	dw spritesets_null_spriteset          ; sprite 5F - brown platform on chain (moves when mario stands on it)
	dw spritesets_null_spriteset          ; sprite 60
	dw spritesets_lava_skull_raft         ; sprite 61 - skull raft
	dw spritesets_wood_checkered_plats    ; sprite 62 - brown line guided platform (starts on its own)
	dw spritesets_wood_checkered_plats    ; sprite 63 - brown/checkered line guided platform (starts when jumped on)
	dw spritesets_line_machines           ; sprite 64 - line guided rope
	dw spritesets_line_machines           ; sprite 65 - line guided chainsaw
	dw spritesets_line_machines           ; sprite 66 - line guided chainsaw, upside-down
	dw spritesets_castle_blk_bnc_gndr     ; sprite 67 - line guided grinder
	dw spritesets_fuzzy                   ; sprite 68 - line guided fuzzy
	dw spritesets_cloud_drop              ; sprite 69 - cloud drop
	dw spritesets_null_spriteset          ; sprite 6A
	dw spritesets_null_spriteset          ; sprite 6B
	dw spritesets_null_spriteset          ; sprite 6C
	dw spritesets_null_spriteset          ; sprite 6D
	dw spritesets_null_spriteset          ; sprite 6E
	dw spritesets_null_spriteset          ; sprite 6F
	dw spritesets_monty_mole_pokey        ; sprite 70 - pokey
	dw spritesets_superkoopas             ; sprite 71 - super koopa (swoops, red cape)
	dw spritesets_superkoopas             ; sprite 72 - super koopa (swoops, yellow cape)
	dw spritesets_superkoopas             ; sprite 73 - super koopa (running, with feather/ylw cape)
	dw spritesets_null_spriteset          ; sprite 74
	dw spritesets_null_spriteset          ; sprite 75
	dw spritesets_null_spriteset          ; sprite 76
	dw spritesets_null_spriteset          ; sprite 77
	dw spritesets_null_spriteset          ; sprite 78
	dw spritesets_piranhas                ; sprite 79 - growing vine
	dw spritesets_null_spriteset          ; sprite 7A
	dw spritesets_null_spriteset          ; sprite 7B - goal point tape
	dw spritesets_null_spriteset          ; sprite 7C
	dw spritesets_null_spriteset          ; sprite 7D
	dw spritesets_null_spriteset          ; sprite 7E - red flying coin
	dw spritesets_null_spriteset          ; sprite 7F - gold 1up
	dw spritesets_null_spriteset          ; sprite 80 - key
	dw spritesets_null_spriteset          ; sprite 81 - item roulette
	dw spritesets_null_spriteset          ; sprite 82 - bonus game roulette
	dw spritesets_null_spriteset          ; sprite 83 - flying question block, left
	dw spritesets_null_spriteset          ; sprite 84 - flying question block, back and forth
	dw spritesets_null_spriteset          ; sprite 85 - unused sprite
	dw spritesets_wiggler                 ; sprite 86 - wiggler
	dw spritesets_null_spriteset          ; sprite 87 - lakitu's cloud
	dw spritesets_null_spriteset          ; sprite 88 - layer 3 wing cage
	dw spritesets_null_spriteset          ; sprite 89 - layer 3 smasher
	dw spritesets_null_spriteset          ; sprite 8A - yoshi's house bird
	dw spritesets_null_spriteset          ; sprite 8B - yoshi's house smoke
	dw spritesets_null_spriteset          ; sprite 8C - side exit/yoshi house smoke generator
	dw spritesets_null_spriteset          ; sprite 8D - ghost house exit sign/door
	dw spritesets_null_spriteset          ; sprite 8E - 'warp hole' blocks
	dw spritesets_null_spriteset          ; sprite 8F - mushroom platforms
	dw spritesets_bigboo_smashplayers     ; sprite 90 - gas bubble
	dw spritesets_chucks                  ; sprite 91 - Chargin' Chuck
	dw spritesets_chucks                  ; sprite 92 - Splittin' Chuck
	dw spritesets_chucks                  ; sprite 93 - Bouncin' Chuck
	dw spritesets_chucks                  ; sprite 94 - Whistlin' Chuck
	dw spritesets_chucks                  ; sprite 95 - Clappin' Chuck
	dw spritesets_chucks                  ; sprite 96 - Chargin' Chuck clone
	dw spritesets_chucks                  ; sprite 97 - Puntin' Chuck
	dw spritesets_chucks                  ; sprite 98 - Pitchin' Chuck
	dw spritesets_vlotus                  ; sprite 99 - volcano lotus
	dw spritesets_null_spriteset          ; sprite 9A - sumo bro
	dw spritesets_null_spriteset          ; sprite 9B - hammer bro
	dw spritesets_null_spriteset          ; sprite 9C - hammer bro's flying blocks
	dw spritesets_null_spriteset          ; sprite 9D - forest bubble
	dw spritesets_ball_n_chain            ; sprite 9E - ball 'n' chain
	dw spritesets_banzai_bill             ; sprite 9F - Banzai Bill
	dw spritesets_null_spriteset          ; sprite A0
	dw spritesets_bowling_ball            ; sprite A1 - bowser's bowling ball
	dw spritesets_mechakoopa              ; sprite A2 - mechakoopa
	dw spritesets_null_spriteset          ; sprite A3 - single grey wood platform on chain
	dw spritesets_null_spriteset          ; sprite A4
	dw spritesets_fuzzy_and_sparky        ; sprite A5 - wall following fuzzy/sparky
	dw spritesets_big_hothead             ; sprite A6 - large wall following hothead
	dw spritesets_thwomp                  ; sprite A7 - thwomp (was iggy's ball)
	dw spritesets_blargg                  ; sprite A8 - blargg
	dw spritesets_null_spriteset          ; sprite A9 - reznor
	dw spritesets_fishbone                ; sprite AA - fishbone
	dw spritesets_rex                     ; sprite AB - rex
	dw spritesets_dry_bones_beetle_pencil ; sprite AC - wooden spike, down then up
	dw spritesets_dry_bones_beetle_pencil ; sprite AD - wooden spike, up then down
	dw spritesets_eerie_fishin_boo        ; sprite AE - fishin' boo
	dw spritesets_boo_booblock            ; sprite AF - boo block
	dw spritesets_boo_booblock            ; sprite B0 - boo stream
	dw spritesets_null_spriteset          ; sprite B1
	dw spritesets_thwomp_thwimp_spike     ; sprite B2 - falling spike
	dw spritesets_bowser_statue           ; sprite B3 - bowser statue fireball
	dw spritesets_castle_blk_bnc_gndr     ; sprite B4 - non-line-guided grinder
	dw spritesets_null_spriteset          ; sprite B5
	dw spritesets_dry_bones_beetle_pencil ; sprite B6 - reflecting fireball
	dw spritesets_null_spriteset          ; sprite B7 - carrot plat down-right
	dw spritesets_null_spriteset          ; sprite B8 - carrot plat up-left
	dw spritesets_dynamic_sprs            ; sprite B9 - star coin
	dw spritesets_dynamic_sprs            ; sprite BA - woozyguy
	dw spritesets_castle_blk              ; sprite BB - grey moving castle block
	dw spritesets_bowser_statue           ; sprite BC - bowser statue
	dw spritesets_dynamic_sprs            ; sprite BD - yi pswitch (dynamic)
	dw spritesets_dynamic_sprs            ; sprite BE - chomp rock
	dw spritesets_mega_mole               ; sprite BF - mega_mole
	dw spritesets_rock_grass_plats        ; sprite C0 - sinking grey rock
	dw spritesets_null_spriteset          ; sprite C1 - flying grey turn blocks
	dw spritesets_blurp                   ; sprite C2 - blurp
	dw spritesets_porcupuffer             ; sprite C3
	dw spritesets_null_spriteset          ; sprite C4
	dw spritesets_bigboo_smashplayers     ; sprite C5 - big boo boss
	dw spritesets_disco                   ; sprite C6 - disco ball
	dw spritesets_null_spriteset          ; sprite C7 - invisible mushroom
	dw spritesets_null_spriteset          ; sprite C8 - light switch block

; TODO use a nybble per spriteset
spritesets:
.null_spriteset:                              ; used by sprites that don't use the system.
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.dynamic_sprs:
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets C0-07
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets 08-0F
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets 10-17
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets 18-1F
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets 20-27
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets 28-2F
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets 30-37
	db $C0,$C0,$C0,$C0,$C0,$C0,$C0,$C0    ; spritesets 38-3F
.sakasatachi                                  ; buzzy beetle, upsd. buzzy/spiny
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$20,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.lakitu_spiny:                                ; lakitu variants, spiny
	db $00,$20,$00,$00,$00,$00,$20,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$20,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.fish:
.nipper:
	db $00,$00,$C0,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$40,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.chucks:
	db $00,$20,$00,$00,$00,$00,$00,$80    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$20,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.monty_mole_pokey:
	db $00,$80,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.banzai_bill:
	db $00,$00,$40,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.rex:
	db $00,$00,$80,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.piranhas:
	db $A0,$80,$E0,$00,$C0,$80,$00,$20    ; spritesets 00-07
	db $00,$A0,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.dolphin
	db $00,$00,$00,$20,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.porcupuffer
	db $00,$00,$00,$40,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.rip_van_fish:
.blurp:
	db $00,$40,$00,$A0,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$20    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F

.line_machines:
.fuzzy:
.fuzzy_and_sparky:
	db $00,$00,$00,$60,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.big_hothead:
.bowser_statue:
	db $00,$00,$00,$80,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.spiketop:
	db $00,$00,$00,$00,$80,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.blargg:
	db $00,$00,$00,$00,$E0,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.bigboo_smashplayers:
	db $00,$00,$00,$00,$00,$20,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.boo_booblock:
	db $00,$00,$00,$00,$00,$60,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.eerie_fishin_boo:
	db $00,$00,$00,$00,$00,$80,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.dry_bones_beetle_pencil:
.dry_bones:
.bony_beetle:
.pencil:
	db $00,$00,$00,$00,$00,$00,$00,$20    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$20    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.fishbone:
.thwomp_thwimp_spike:
.thwomp:
	db $00,$00,$00,$00,$00,$00,$00,$60    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$80    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.climbing_koopas:
	db $00,$00,$00,$00,$00,$00,$00,$80    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.ball_n_chain:
.castle_blk:
.castle_blk_bnc_gndr:
	db $00,$00,$00,$00,$00,$00,$00,$A0    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$60    ; spritesets 08-0F
	db $00,$00,$20,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.magikoopa_bgflame:
	db $00,$00,$00,$00,$00,$00,$00,$C0    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.superkoopas:
.lava_skull_raft:
.vlotus:
	db $00,$A0,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$20,$00,$00,$00,$00    ; spritesets 08-0F
	db $40,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.bills:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $20,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.goalsphere:
.beezo:
.parabeetle:
.rock_grass_plats:
.wood_checkered_plats:
	db $80,$A0,$A0,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $40,$00,$00,$80,$A0,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.mega_mole:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$80,$00,$A0,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.mechakoopa:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$20,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.disco:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$40,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.bowling_ball:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$60,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.cloud_drop:
.fly_guy:
	db $40,$00,$60,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$60,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.hoopster:
.wiggler:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$40,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.cluster_spawner:
.bumpty:
	db $00,$00,$00,$00,$00,$00,$00,$40    ; spritesets 00-07
	db $00,$00,$00,$00,$60,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.ninji:
	db $00,$00,$00,$00,$00,$00,$00,$60    ; spritesets 00-07
	db $00,$00,$00,$00,$80,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.yi_spike:
	db $00,$00,$00,$00,$00,$00,$00,$80    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$60,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.switch:
.pipe:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$20,$00,$00,$00    ; spritesets 08-0F
	db $20,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.blowhard:
.needlenose:
.falling_leaf:
	db $00,$60,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F
.spear_guy:
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 00-07
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 08-0F
	db $00,$00,$60,$00,$00,$00,$00,$00    ; spritesets 10-17
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 18-1F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 20-27
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 28-2F
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 30-37
	db $00,$00,$00,$00,$00,$00,$00,$00    ; spritesets 38-3F



; NOTE: The VRAM uploads happen backwards, so the first item is the bottom-most (16 pixel high) row of SP4,
; NOTE: the second entry is the second-bottom-most 16-pixel row, and so on.
spriteset_gfx_listing:
	dw $010D,$0108,$010B,$010A,$0104,$0103		; spriteset 00: chargin, clappin chucks, cloud drop, grass plat w beetles/beezos, piranha plants
	dw $0108,$010D,$0116,$011F,$0115,$0102		; spriteset 01: fish, nipper, lakitu, rip van fish, blurp, needlenose, gras plat w/beezo, buzzy beetle
	dw $0108,$010B,$010A,$0105,$0104,$0103		; spriteset 02: ss 00 alt: no piranhas, adds pitchin chucks
	dw $0117,$0124,$0112,$0116,$0114,$0111		; spriteset 03: dolphins, porcupuffer
	dw $0104,$011A,$010A,$0109,$0108,$0107		; spriteset 04: all chucks, spike top, buzzy, swooper, blargg
	dw $007F,$010D,$0100,$0112,$0111,$0110		; spriteset 05: boos, big boo
	dw $007F,$007F,$007F,$007F,$011F,$0128		; spriteset 06: lakitu, porcu-puffer
	dw $007F,$010C,$011D,$011C,$010D,$0108		; spriteset 07: snow outside -- platforms, piranhas, bumptys, ninji, yi spike
	dw $007F,$007F,$007F,$0111,$0127,$007F		; spriteset 08: athletic
	dw $0110,$010F,$010A,$0128,$0108,$0107		; spriteset 09: underground with diggin chucks
	dw $007F,$007F,$012B,$012A,$0129,$007F		; spriteset 0A: mechakoopa
	dw $010F,$0108,$010C,$010E,$0107,$010D		; spriteset 0B: wiggler, volcano lotus, piranha plants, platforms, mega mole
	dw $0108,$011D,$011C,$0105,$011E,$0103		; spriteset 0C: snow 2: chucks (pitchin), bumpty, ninji, plats
	dw $007F,$00E0,$007F,$007F,$007F,$0013		; spriteset 0D: testing (replace later)
	dw $007F,$007F,$0105,$0104,$0103,$0107		; spriteset 0E: chucks + kickin chuck, volc lotus
	dw $007F,$0127,$0122,$0121,$0120,$0123		; spriteset 0F: dry bones/bony/beetle/pencil/grinder/castle block/reflec ball, thwomp
	dw $007F,$007F,$007F,$0107,$0124,$010D		; spriteset 10: piranhas, expanding pipes, lotus
	dw $007F,$007F,$010C,$0125,$0115,$010D		; spriteset 11: cave: piranhas, lakitu/spiny, buzzy/spiny upside-down, yi spike
	dw $007F,$007F,$0126,$0102,$0122,$010E		; spriteset 12: wiggler, castle block/grinder, fish, spearguy
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 13: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 14: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 15: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 16: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 16: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 17: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 18: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 19: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 1A: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 1B: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 1C: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 1D: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 1E: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 1F: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 20: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 21: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 22: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 23: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 24: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 25: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 26: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 26: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 27: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 28: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 29: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 2A: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 2B: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 2C: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 2D: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 2E: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 2F: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 30: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 31: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 32: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 33: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 34: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 35: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 36: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 36: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 37: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 38: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 39: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 3A: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 3B: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 3C: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 3D: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 3E: none
	dw $007F,$007F,$007F,$007F,$007F,$007F		; spriteset 3F: none
