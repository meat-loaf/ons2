!sprnum_chucks = $91

;%alloc_sprite(!sprnum_chucks, "chucks", CHUCKS_INIT, CHUCKS_MAIN, 5, \
;	$00,$0D,$0B,$F9,$11,$48)

%alloc_sprite_spriteset_2(!sprnum_chucks, "chucks", CHUCKS_INIT, CHUCKS_MAIN, 5, \
	$108, $109, \
	$00,$0D,$0B,$F9,$11,$48)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; USES EXTRA BIT: YES
;;
;; If Extra bit is set, the chuck will not change into a chargin' chuck when hit
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Extra bytes used: 2
;;
;; Extra byte 1 determines the Chuck's initial starting state (00-0C). See the Init notes.
;; Extra byte 2 modifies behavior based on the kind of chuck it is:
;; * initial state 00,01,02 (chargin' look to the sides): n/a
;; * initial state 03: phase to change into when hurt animation completes
;;   (if extra bit is set, otherwise it just becomes a chargin' chuck)
;; * initial state: 04: n/a (todo: dig speed?)
;; * initial state 05,06,07,08: jumping (?)
;; * initial state 09: puntin (n/a)
;; * initial state 0A: pitchin (todo: num baseballs to throw)
;; * initial state 0B,0C: whistlin (?)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Subroutines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	InitSpriteTables = $07F7D2|!bank
	SprSprInteract = $018032|!bank
	ShatterBlock = $028663|!bank
	GenerateTile = $00BEB0|!bank
	UpdateXPosNoGrvty = $018022|!bank
	FindFreeSprSlot = $02A9E4|!bank
	GetRand = $01ACF9|!bank
	MarioSprInteract = $01A7DC|!bank
	BoostMarioSpeed = $01AA33|!bank
	DisplayContactGfx = $01AB99|!bank
	HurtMario = $00F5B7|!bank
	; todo get rid of this
	CHUCK_SPAWN_FOOTBALL = $03CBB3|!bank

; consts
!Stomps = $03
!chuck_alt_behavior_no_jump = %00000001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Init
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; starting states:
; 00-02: chargin' (state 2 will start walking immediately)
; 03: hurt (don't use this, jumping directly into this state doesn't initialize the chuck properly.)
; 04: diggin'
; 05: preparin' to split
; 06: jumpin' (but won't give speed by default)
; 07: landing (?)
; 08: clappin'
; 09: puntin'
; 0A: pitchin'
; 0B: waiting to whistle (note: will only change to whistlin' when extra bit is set, otherwise becomes a chargin' chuck)
; 0C: whistlin'
; anything higher will crash, so don't do that


!chuck_behavior        = !sprite_misc_c2
!chuck_face_dir        = !sprite_misc_157c
!chuck_head_ani_frame  = !sprite_misc_151c
!chuck_hurt_ani_phase  = !sprite_misc_1570
!chuck_ani_frame       = !sprite_misc_1602
!chuck_gen_wait_timer  = !sprite_misc_1540
; head turning dir, is jumping flag
!chuck_gen_flag        = !sprite_misc_1534
!chuck_unused_timer    = !sprite_misc_163e
!chuck_hits            = !sprite_misc_1528
!chuck_disable_contact = !sprite_misc_1564
!chuck_start_run_timer = !sprite_misc_15ac
!chuck_jump_kind_flag  = !sprite_misc_160e
!chuck_head_phase      = !sprite_misc_1594

!chuck_head_pose_buff_ix = !sprite_misc_1504

!chuck_diggin_head_turn_ani_timer = !sprite_misc_1558

; TODO clean this up
%set_free_start("bank7")
CHUCKS_INIT:
	jsl get_dyn_pose
	tya
	sta !chuck_head_pose_buff_ix,x
;	LDA !spr_extra_byte_2,x
;	STA !chuck_alt_behaviors,x
	LDA !spr_extra_byte_1,x
	AND #$0F
	CMP #$0D
	BCC .ok
	LDA #$00
.ok:
	STA !chuck_behavior,x

	CMP #$03
	BNE .not_hurt
	STA !chuck_gen_wait_timer,x
.not_hurt:
	LDA !chuck_behavior,x
	CMP #$04
	BNE +
	LDA.B #$30
	STA.W !chuck_gen_wait_timer,x
	LDA.B !sprite_x_low,x
	AND.B #$10
	LSR A
	LSR A
	LSR A
	LSR A
	STA.W !chuck_face_dir,x
+
	jsr FaceMario
	LDA.W ChuckInitialHeadPos,Y
	STA.W !chuck_head_ani_frame,x
	RTL

ChuckInitialHeadPos:
	db $00,$04

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_02C132:
	db $30,$20,$0A,$30

DATA_02C136:
	db $05,$0E,$0F,$10

Diggin:
	TYX
	LDA !chuck_diggin_head_turn_ani_timer,x
	BEQ ADDR_02C156
	CMP #$01
	BNE ADDR_02C150
	LDA #$30
	STA !chuck_gen_wait_timer,x
	LDA #$04
	STA !chuck_gen_flag,x
	STZ !chuck_hurt_ani_phase,x
ADDR_02C150:
	LDA #$02
	STA !chuck_head_ani_frame,x
Return02C155:
	RTS                       ; Return

ADDR_02C156:
	LDA !chuck_gen_wait_timer,x
	BNE ADDR_02C181
	INC !chuck_gen_flag,x
	LDA !chuck_gen_flag,x
	AND #$03
	STA !chuck_hurt_ani_phase,x
	TAY
	LDA DATA_02C132,y
	STA !chuck_gen_wait_timer,x
	CPY #$01
	BNE ADDR_02C181
	LDA !chuck_gen_flag,x
	AND #$0C
	BNE ADDR_02C17E
	LDA #$40
	STA !chuck_diggin_head_turn_ani_timer,x
Return02C17D:
	RTS                       ; Return

ADDR_02C17E:
	JSR DigginChuckSpawnRock
ADDR_02C181:
	LDY !chuck_hurt_ani_phase,x
	LDA DATA_02C136,y
	STA !chuck_ani_frame,x
	LDY !chuck_face_dir,x
	LDA DATA_02C1F3,y
	STA !chuck_head_ani_frame,x
Return02C193:
	RTS                       ; Return


DATA_02C194:
	db $14,$EC

DATA_02C196:
	db $00,$FF

DATA_02C198:
	db $08,$F8

; TODO
DigginChuckSpawnRock:
	rts
	JSL FindFreeSprSlot     ; \ Return if no free slots
	BMI Return02C1F2          ; /
	LDA #$08                ; \ Sprite status = Normal
	STA !sprite_status,y             ; /
	LDA #$48
	STA !sprite_num,y
	LDA #$09
	LDA !chuck_face_dir,x
	STA $02
	LDA !sprite_x_low,x
	STA $00
	LDA !sprite_x_high,x
	STA $01
	PHX
	TYX
	JSL InitSpriteTables
	LDX $02
	LDA $00
	CLC
	ADC DATA_02C194,x
	STA !sprite_x_low,y
	LDA $01
	ADC DATA_02C196,x
	STA !sprite_x_high,y
	LDA DATA_02C198,x
	STA !sprite_speed_x,y
	PLX
	LDA !sprite_y_low,x
	CLC
	ADC #$0A
	STA !sprite_y_low,y
	LDA !sprite_y_high,x
	ADC #$00
	STA !sprite_y_high,y
	LDA #$C0
	STA !sprite_speed_y,y
	LDA #$2C
	STA !chuck_gen_wait_timer,y
Return02C1F2:
	RTS


DATA_02C1F3:
	db $01,$03


CHUCKS_MAIN:
	LDA !sprite_misc_187b,x
	PHA
	JSR chuck_impl
	PLA
	BNE ADDR_02C211
	CMP !sprite_misc_187b,x
	BEQ ADDR_02C211
	LDA !chuck_unused_timer,x
	BNE ADDR_02C211
	LDA #$28
	STA !chuck_unused_timer,x
ADDR_02C211:
	RTL

ChuckDeadHeadFrame:
	db $01,$02,$03,$02

chuck_die_ani:
	lda $14
	lsr
	lsr
	and #$03
	tay
	lda ChuckDeadHeadFrame,y
	sta !chuck_head_ani_frame,x
	jmp chuck_gfx
Return02C227:
	rts


DATA_02C228:
	db $40,$10

DATA_02C22A:
	db $03,$01

chuck_impl:
	LDA !sprite_status,x
	CMP #$08
	BNE chuck_die_ani
	LDA !chuck_start_run_timer,x
	BEQ ADDR_02C23D
	LDA #$05
	STA !chuck_ani_frame,x
ADDR_02C23D:
	LDA !sprite_blocked_status,x             ; \ Branch if on ground
	AND #$04                ;  |
	BNE ADDR_02C253           ; /
	LDA !sprite_speed_y,x
	BPL ADDR_02C253
	LDA !chuck_behavior,x
	CMP #$05
	BCS ADDR_02C253
	LDA #$06
	STA !chuck_ani_frame,x
ADDR_02C253:
	JSR chuck_gfx
	LDA $9D
	BEQ ADDR_02C25B
Return02C25A:
	RTS                       ; Return

ADDR_02C25B:
	jsl sub_off_screen
	JSR chuck_check_contact
	JSL SprSprInteract
;	JSL $019138|!bank
	jsl spr_obj_interact
	LDA !sprite_blocked_status,x
	AND #$08
	BEQ ADDR_02C274
	LDA #$10
	STA !sprite_speed_y,x
ADDR_02C274:
	LDA !sprite_blocked_status,x             ; \ Branch if not touching object
	AND #$03                ;  |
	BEQ ADDR_02C2F4           ; /
;	LDA !sprite_off_screen_horz,x
;	ORA !sprite_off_screen_vert,x
;	BNE ADDR_02C2E4
	LDA !sprite_misc_187b,x
	BEQ ADDR_02C2E4
	LDA !sprite_x_low,x
	SEC
	SBC $1A
	CLC
	ADC #$14
	CMP #$1C
	BCC ADDR_02C2E4
	LDA !sprite_blocked_status,x             ; \ Branch if on ground
	AND #$40                ;  |
	BNE ADDR_02C2E4           ; /
	LDA $18A7|!addr
	CMP #$2E
	BEQ ADDR_02C2A6
	CMP #$1E
	BNE ADDR_02C2E4
ADDR_02C2A6:
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C2F7           ; /
	LDA $9B
	PHA
	LDA $9A
	PHA
	LDA $99
	PHA
	LDA $98
	PHA
	JSL ShatterBlock
	LDA #$02                ; \ Block to generate = #$02
	STA $9C                   ; /
	JSL GenerateTile
	PLA
	SEC
	SBC #$10
	STA $98
	PLA
	SBC #$00
	STA $99
	PLA
	STA $9A
	PLA
	STA $9B
	JSL ShatterBlock
	LDA #$02                ; \ Block to generate = #$02
	STA $9C                   ; /
	JSL GenerateTile
	BRA ADDR_02C2F4

ADDR_02C2E4:
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C2F7           ; /
	LDA #$C0
	STA !sprite_speed_y,x
	jsl spr_upd_y_no_grv_l
	BRA ADDR_02C301

ADDR_02C2F4:
	jsl spr_upd_x_no_grv_l
ADDR_02C2F7:
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C301           ; /
	JSR ADDR_02C579
ADDR_02C301:
	jsl spr_upd_y_no_grv_l
	LDY !sprite_in_water,x
	CPY #$01
	LDY #$00
	LDA !sprite_speed_y,x
	BCC ADDR_02C31A
	INY
	CMP #$00
	BPL ADDR_02C31A
	CMP #$E0
	BCS ADDR_02C31A
	LDA #$E0
ADDR_02C31A:
	CLC
	ADC DATA_02C22A,y
	BMI ADDR_02C328
	CMP DATA_02C228,y
	BCC ADDR_02C328
	LDA DATA_02C228,y
ADDR_02C328:
	TAY
	BMI ADDR_02C334
	LDY !chuck_behavior,x
	CPY #$07
	BNE ADDR_02C334
	CLC
	ADC #$03
ADDR_02C334:
	STA !sprite_speed_y,x
	LDA !chuck_behavior,x
	TXY
	ASL
	TAX
	JMP (ChuckPtrs,x)

ChuckPtrs:
	dw LookSideToSide
	dw Chargin
	dw PrepCharge
	dw Hurt
	dw Diggin
	dw PrepJump
	dw Jumpin
	dw Landin
	dw Clappin
	dw Puntin
	dw Pitchin
	dw PrepWhistle
	dw Whistlin

PrepWhistle:
	TYX
	LDA #$03
	STA !chuck_ani_frame,x
	LDA !sprite_in_water,x
	BEQ ADDR_02C370
	JSR ADDR_02D4FA
	LDA $0F
	CLC
	ADC #$30
	CMP #$60
	BCS ADDR_02C370
	LDA #$0C
	STA !chuck_behavior,x
ADDR_02C370:
	JMP ADDR_02C556


DATA_02C373:
	db $05,$05,$05,$02,$02,$06,$06,$06

Whistlin:
	TYX
	LDA $14
	AND #$3F
	BNE ADDR_02C386
	LDA #$1E                ; \ Play sound effect
	STA $1DFC|!addr               ; /
ADDR_02C386:
	LDY #$03
	LDA $14
	AND #$30
	BEQ ADDR_02C390
	LDY #$06
ADDR_02C390:
	TYA
	STA !chuck_ani_frame,x
	LDA $14
	LSR
	LSR
	AND #$07
	TAY
	LDA DATA_02C373,y
	STA !chuck_head_ani_frame,x
	LDA !sprite_x_low,x
	LSR
	LSR
	LSR
	LSR
	LSR
	LDA #$09
	BCC ADDR_02C3AF
	STA $18B9|!addr
ADDR_02C3AF:
	STA $18FD|!addr
Return02C3B2:
	RTS                       ; Return


pitchin_chuck_pitch_timer:
	db $7F,$BF,$FF,$DF

DATA_02C3B7:
	db $18,$19,$14,$14

DATA_02C3BB:
	db $18,$18,$18,$18,$17,$17,$17,$17
	db $17,$17,$16,$15,$15,$16,$16,$16

Pitchin:
	TYX
	LDA !chuck_gen_flag,x
	BNE ADDR_02C43A
	JSR ADDR_02D50C
	LDA $0E
	BPL ADDR_02C3E7
	CMP #$D0
	BCS ADDR_02C3E7
	LDA #$C8
	STA !sprite_speed_y,x
	LDA #$3E
	STA !chuck_gen_wait_timer,x
	INC !chuck_gen_flag,x
ADDR_02C3E7:
	LDA $13
	AND #$07
	BNE ADDR_02C3F5
	LDA !chuck_gen_wait_timer,x
	BEQ ADDR_02C3F5
	INC !chuck_gen_wait_timer,x
ADDR_02C3F5:
	LDA $14
	AND #$3F
	BNE ADDR_02C3FE
	JSR ADDR_02C556
ADDR_02C3FE:
	LDA !chuck_gen_wait_timer,x
	BNE ADDR_02C40C
	LDY !sprite_misc_187b,x
	LDA pitchin_chuck_pitch_timer,y
	STA !chuck_gen_wait_timer,x
ADDR_02C40C:
	LDA !chuck_gen_wait_timer,x
	CMP #$40
	BCS ADDR_02C419
	LDA #$00
	STA !chuck_ani_frame,x
Return02C418:
	RTS                       ; Return

ADDR_02C419:
	SEC
	SBC #$40
	LSR
	LSR
	LSR
	AND #$03
	TAY
	LDA DATA_02C3B7,y
	STA !chuck_ani_frame,x
	LDA !chuck_gen_wait_timer,x
	AND #$1F
	CMP #$06
	BNE Return02C439
	JSR spawn_ext_baseball
	LDA #$08
	STA !chuck_diggin_head_turn_ani_timer,x
Return02C439:
	RTS                       ; Return

ADDR_02C43A:
	LDA !chuck_gen_wait_timer,x
	BEQ ADDR_02C45C
	PHA
	CMP #$20
	BCC ADDR_02C44A
	CMP #$30
	BCS ADDR_02C44A
	STZ !sprite_speed_y,x                 ; Sprite Y Speed = 0
ADDR_02C44A:
	LSR
	LSR
	TAY
	LDA DATA_02C3BB,y
	STA !chuck_ani_frame,x
	PLA
	CMP #$26
	BNE Return02C45B
	JSR spawn_ext_baseball
Return02C45B:
	RTS                       ; Return

ADDR_02C45C:
	STZ !chuck_gen_flag,x
Return02C45F:
	RTS                       ; Return


BaseballTileDispX:
	db $10,$F8

DATA_02C462:
	db $00,$FF

BaseballSpeed:
	db $18,$E8

spawn_ext_baseball:
	LDA !chuck_diggin_head_turn_ani_timer,x
	ORA !sprite_off_screen_vert,x
	BNE Return02C439
	LDY #$07                ; \ Find a free extended sprite slot
ADDR_02C470:
	LDA $170B|!addr,y             ;  |
	BEQ ADDR_02C479           ;  |
	DEY                       ;  |
	BPL ADDR_02C470           ;  |
Return02C478:
	RTS                       ; / Return if no free slots

ADDR_02C479:
	; TODO implement ambient baseball
	rts
;	LDA #$0D                  ; \ Extended sprite = Baseball
;	STA $170B|!addr,y        ; /
;	LDA !spr_spriteset_off,x
;	TYX
;	STA !ext_spriteset_off,x
;	LDX $15E9|!addr
;	LDA !sprite_x_low,x
;	STA $00
;	LDA !sprite_x_high,x
;	STA $01
;	LDA !sprite_y_low,x
;	CLC
;	ADC #$00
;	STA $1715|!addr,y
;	LDA !sprite_y_high,x
;	ADC #$00
;	STA $1729|!addr,y
;	PHX
;	LDA !chuck_face_dir,x
;	TAX
;	LDA $00
;	CLC
;	ADC BaseballTileDispX,x
;	STA $171F|!addr,y
;	LDA $01
;	ADC DATA_02C462,x
;	STA $1733|!addr,y
;	LDA BaseballSpeed,x
;	STA $1747|!addr,y
;	PLX
;Return02C4B4:
;	RTS                       ; Return


DATA_02C4B5:
	db $00,$00,$11,$11,$11,$11,$00,$00

Puntin:
	TYX
	STZ !chuck_ani_frame,x
	TXA
	ASL
	ASL
	ASL
	ADC $13
	AND #$7F
	CMP #$00
	BNE ADDR_02C4D5
	PHA
	JSR ADDR_02C556
;	LDA #$19
;	CLC
;	%SpawnSprite()
	JSL CHUCK_SPAWN_FOOTBALL
	PLA
ADDR_02C4D5:
	CMP #$20
	BCS Return02C4E2
	LSR
	LSR
	TAY
	LDA DATA_02C4B5,y
	STA !chuck_ani_frame,x
Return02C4E2:
	RTS                       ; Return

Clappin:
	TYX
	JSR ADDR_02C556
	LDA #$06
	LDY !sprite_speed_y,x
	CPY #$F0
	BMI ADDR_02C504
	LDY !chuck_jump_kind_flag,x
	BEQ ADDR_02C504
	LDA !sprite_cape_disable_time,x
	BNE ADDR_02C502
	LDA #$19                ; \ Play sound effect
	STA $1DFC|!addr               ; /
	LDA #$20
	STA !sprite_cape_disable_time,x
ADDR_02C502:
	LDA #$07
ADDR_02C504:
	STA !chuck_ani_frame,x
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ Return02C53B          ; /
	STZ !chuck_jump_kind_flag,x
	LDA #$04
	STA !chuck_ani_frame,x
	LDA !chuck_gen_wait_timer,x
	BNE Return02C53B
	LDA #$20
	STA !chuck_gen_wait_timer,x
	LDA #$F0
	STA !sprite_speed_y,x
	JSR ADDR_02D50C
	LDA $0E
	BPL Return02C53B
	CMP #$D0
	BCS Return02C53B
	LDA #$C0
	STA !sprite_speed_y,x
	INC !chuck_jump_kind_flag,x
ADDR_02C536:
	LDA #$08                ; \ Play sound effect
	STA $1DFC|!addr               ; /
Return02C53B:
	RTS                       ; Return

Jumpin:
	TYX
	LDA #$06
	STA !chuck_ani_frame,x
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ Return02C555          ; /
	JSR ADDR_02C579
	JSR ADDR_02C556
	LDA #$08
	STA !chuck_gen_wait_timer,x
	INC !chuck_behavior,x
Return02C555:
	RTS                       ; Return

ADDR_02C556:
	JSR ADDR_02D4FA
	TYA
	STA !chuck_face_dir,x
	LDA DATA_02C639,y
	STA !chuck_head_ani_frame,x
Return02C563:
	RTS                       ; Return

Landin:
	TYX
	LDA #$03
	STA !chuck_ani_frame,x
	LDA !chuck_gen_wait_timer,x
	BNE ADDR_02C579
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ Return02C57D          ; /
	LDA #$05
	STA !chuck_behavior,x
ADDR_02C579:
	STZ !sprite_speed_x,x                 ; Sprite X Speed = 0
	STZ !sprite_speed_y,x                 ; Sprite Y Speed = 0
Return02C57D:
	RTS                       ; Return


DATA_02C57E:
	db $10,$F0

DATA_02C580:
	db $20,$E0

PrepJump:
	TYX
	JSR ADDR_02C556
	LDA !chuck_gen_wait_timer,x
	BNE .cont
	JMP ADDR_02C602
.cont:
	CMP #$01
	BNE .no_spawn
	LDA !sprite_num,x
	CMP #$93
	BNE ADDR_02C5A7
	JSR ADDR_02D4FA
	LDA DATA_02C580,y
	STA !sprite_speed_x,x
	LDA #$B0
	STA !sprite_speed_y,x
	LDA #$06
	STA !chuck_behavior,x
	JMP ADDR_02C536
.no_spawn:
	LDA #$09
	STA !chuck_ani_frame,x
	RTS

ADDR_02C5A7:
	STZ !chuck_behavior,x
	LDA #$50
	STA !chuck_gen_wait_timer,x
	LDA #$10                ; \ Play sound effect
	STA $1DF9|!addr        ; /
	STZ $185E|!addr        ; scratch: index into spawned chuck x-speed table
	JSR SplittinChuckSplit  ; interesting way to do this twice
	INC $185E|!addr
SplittinChuckSplit:
	; todo more splittn' behavior options?
	JSL FindFreeSprSlot
	BMI NoSpawn
	LDA #$08                ; \ Sprite status = Normal
	STA !sprite_status,y             ; /
	LDA #!sprnum_chucks
	STA !sprite_num,y
	LDA !sprite_x_low,x
	STA !sprite_x_low,y
	LDA !sprite_x_high,x
	STA !sprite_x_high,y
	LDA !sprite_y_low,x
	STA !sprite_y_low,y
	LDA !sprite_y_high,x
	STA !sprite_y_high,y
	LDA !spr_extra_bits,x
	STA !spr_extra_bits,y
	PHA
	TYX
	JSL InitSpriteTables
	STZ !spr_extra_byte_1,x
	LDX $185E|!addr
	LDA DATA_02C57E,x
	STA !sprite_speed_x,y
	LDX $15E9|!addr
	LDA #$C8
	STA !sprite_speed_y,y
	LDA #$50
	STA !chuck_gen_wait_timer,y
	PLA
	STA !spr_extra_bits,y
NoSpawn:
	LDA #$09
	STA !chuck_ani_frame,x
	RTS

ADDR_02C602:
	JSR ADDR_02D4FA
	TYA
	STA !chuck_face_dir,x
	LDA $0F
	CLC
	ADC #$50
	CMP #$A0
	BCS ADDR_02C618
	LDA #$40
	STA !chuck_gen_wait_timer,x
Return02C617:
	RTS                       ; Return

ADDR_02C618:
	LDA #$03
	STA !chuck_ani_frame,x
	LDA $13
	AND #$3F
	BNE Return02C627
	LDA #$E0
	STA !sprite_speed_y,x
Return02C627:
	RTS                       ; Return

ADDR_02C628:
	LDA #$08
	STA !chuck_start_run_timer,x
Return02C62D:
	RTS                       ; Return


DATA_02C62E:
	db $00,$00,$00,$00,$01,$02,$03,$04
	db $04,$04,$04

DATA_02C639:
	db $00,$04

LookSideToSide:
	TYX
	LDA #$03
	STA !chuck_ani_frame,x
	STZ !sprite_misc_187b,x
	LDA !chuck_gen_wait_timer,x
	AND #$0F
	BNE ADDR_02C668
	JSR ADDR_02D50C
	LDA $0E
	CLC
	ADC #$28
	CMP #$50
	BCS ADDR_02C668
	JSR ADDR_02C556
	INC !sprite_misc_187b,x
ADDR_02C65C:
	LDA #$02
	STA !chuck_behavior,x
	LDA #$18
	STA !chuck_gen_wait_timer,x
Return02C665:
	RTS                       ; Return


DATA_02C666:
	db $01,$FF

ADDR_02C668:
	LDA !chuck_gen_wait_timer,x
	BNE ADDR_02C677
	LDA !chuck_face_dir,x
	EOR #$01
	STA !chuck_face_dir,x
	BRA ADDR_02C65C

ADDR_02C677:
	LDA $14
	AND #$03
	BNE ADDR_02C691
	LDA !chuck_gen_flag,x
	AND #$01
	TAY
	LDA !chuck_head_phase,x
	CLC
	ADC DATA_02C666,y
	CMP #$0B
	BCS ADDR_02C69B
	STA !chuck_head_phase,x
ADDR_02C691:
	LDY !chuck_head_phase,x
	LDA DATA_02C62E,y
	STA !chuck_head_ani_frame,x
Return02C69A:
	RTS                       ; Return

ADDR_02C69B:
	INC !chuck_gen_flag,x
Return02C69E:
	RTS                       ; Return


DATA_02C69F:
	db $10,$F0,$18,$E8

DATA_02C6A3:
	db $12,$13,$12,$13

Chargin:
	TYX
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C6BA         ; /
	LDA !chuck_unused_timer,x
	CMP #$01
	BRA ADDR_02C6BA

	LDA #$24                ; \ Play sound effect
	STA $1DF9|!addr               ; /
ADDR_02C6BA:
	JSR ADDR_02D50C
	LDA $0E
	CLC
	ADC #$30
	CMP #$60
	BCS ADDR_02C6D7
	JSR ADDR_02D4FA
	TYA
	CMP !chuck_face_dir,x
	BNE ADDR_02C6D7
	LDA #$20
	STA !chuck_gen_wait_timer,x
	STA !sprite_misc_187b,x
ADDR_02C6D7:
	LDA !chuck_gen_wait_timer,x
	BNE ADDR_02C6EC
	STZ !chuck_behavior,x
	JSR ADDR_02C628
	JSL GetRand
	AND #$3F
	ORA #$40
	STA !chuck_gen_wait_timer,x
ADDR_02C6EC:
	LDY !chuck_face_dir,x
	LDA DATA_02C639,y
	STA !chuck_head_ani_frame,x
	LDA !sprite_blocked_status,x             ; \ Branch if not on ground
	AND #$04                ;  |
	BEQ ADDR_02C713           ; /
	LDA !sprite_misc_187b,x
	BEQ ADDR_02C70E
	LDA $14
	AND #$07
	BNE ADDR_02C70C
	LDA #$01                ; \ Play sound effect
	STA $1DF9|!addr               ; /
ADDR_02C70C:
	INY
	INY
ADDR_02C70E:
	LDA DATA_02C69F,y
	STA !sprite_speed_x,x
ADDR_02C713:
	LDA $13
	LDY !sprite_misc_187b,x
	BNE ADDR_02C71B
	LSR
ADDR_02C71B:
	LSR
	AND #$03
	TAY
	LDA DATA_02C6A3,y
	STA !chuck_ani_frame,x
Return02C725:
	RTS                       ; Return

PrepCharge:
	TYX
	LDA #$03
	STA !chuck_ani_frame,x
	LDA !chuck_gen_wait_timer,x
	BNE Return02C73C
	JSR ADDR_02C628
	LDA #$01
	STA !chuck_behavior,x
	LDA #$40
	STA !chuck_gen_wait_timer,x
Return02C73C:
	RTS                       ; Return


DATA_02C73D:
	db $0A,$0B,$0A,$0C,$0D,$0C

DATA_02C743:
	db $0C,$10,$10,$04,$08,$10,$18

Hurt:
	TYX
	LDY !chuck_hurt_ani_phase,x
	LDA !chuck_gen_wait_timer,x
	BNE ADDR_02C760
	INC !chuck_hurt_ani_phase,x
	INY
	CPY #$07
	BEQ HurtUpdatePhase
	LDA DATA_02C743,y
	STA !chuck_gen_wait_timer,x
ADDR_02C760:
	LDA DATA_02C73D,y
	STA !chuck_ani_frame,x
	LDA #$02
	CPY #$05
	BNE ADDR_02C773
	LDA $14
	LSR
	NOP
	AND #$02
	INC A
ADDR_02C773:
	STA !chuck_head_ani_frame,x
Return02C776:
	RTS                       ; Return

; this was originally a few sprite number checks;
; it also changed the sprite number to 91 to make it a chargin' chuck (..?)
HurtUpdatePhase:
	lda !spr_extra_bits,x
	lsr
	bcs ChuckHitOrigPhase
	LDA #$30
	STA !chuck_gen_wait_timer,x
	LDA #$02
	STA !chuck_behavior,x
	INC !sprite_misc_187b,x
	JMP ADDR_02C556
ChuckHitOrigPhase:
	JSR FaceMario
	LDA.W ChuckInitialHeadPos,Y
	STA.W !chuck_head_ani_frame,x
	LDA !spr_extra_byte_1,x
	AND #$0F
	CMP #$03
	BNE +
	; use the second extra byte to determine what to turn into if
	; we originally spawned in the 'hurt' state
;	LDA !spr_extra_byte_2,x
;	AND #$0F
;	CMP #$0D
;	BCC .next_phase_ok
	LDA #$00
;.next_phase_ok:
	STA !chuck_behavior,x
;	STZ !spr_extra_byte_2,x
+
	CMP #$0B
	BNE +
	INC A                     ; change to 'whistling' phase
+
	STA !chuck_behavior,x
Return02C798:
	RTS                       ; Return


DATA_02C799:
	db $F0,$10

DATA_02C79B:
	db $20,$E0

chuck_check_contact:
	LDA !chuck_disable_contact,x
	BNE Return02C80F
	JSL MarioSprInteract
	BCC Return02C80F
	LDA $1490|!addr               ; \ Branch if Mario doesn't have star
	BEQ ADDR_02C7C4           ; /
	LDA #$D0
	STA !sprite_speed_y,x
ADDR_02C7B1:
	STZ !sprite_speed_x,x                 ; Sprite X Speed = 0
	LDA #$02                ; \ Sprite status = Killed
	STA !sprite_status,x             ; /
	LDA #$03                ; \ Play sound effect
	STA $1DF9|!addr               ; /
	LDA #$03
	jsl spr_give_points
Return02C7C3:
	RTS                       ; Return

ADDR_02C7C4:
	JSR ADDR_02D50C
	LDA $0E
	CMP #$EC
	BPL ADDR_02C810
	LDA #$05
	STA !chuck_disable_contact,x
	LDA #$02                ; \ Play sound effect
	STA $1DF9|!addr               ; /
	JSL DisplayContactGfx
	JSL BoostMarioSpeed
	STZ !chuck_unused_timer,x
	LDA !chuck_behavior,x
	CMP #$03
	BEQ Return02C80F
	INC !chuck_hits,x             ; Increase Chuck stomp count
ADDR_02C7EB:
	LDA !chuck_hits,x             ; \ Kill Chuck if stomp count >= 3
	CMP #!Stomps                ;  |
	BCC ADDR_02C7F6           ;  |
	STZ !sprite_speed_y,x                 ;  | Sprite Y Speed = 0
	BRA ADDR_02C7B1           ; /

ADDR_02C7F6:
	LDA #$28                ; \ Play sound effect
	STA $1DFC|!addr               ; /
	LDA #$03
	STA !chuck_behavior,x
;	LDA #$03
	STA !chuck_gen_wait_timer,x
	STZ !chuck_hurt_ani_phase,x
	JSR ADDR_02D4FA
	LDA DATA_02C79B,y
	STA $7B
Return02C80F:
	RTS                       ; Return

ADDR_02C810:
	LDA $187A|!addr
	BNE Return02C819
	JSL HurtMario
Return02C819:
	RTS                       ; Return

; TODO DRAW HEAD
chuck_gfx:
	lda !chuck_ani_frame,x
	rep #$20
	asl
	tay
	lda chuck_body_pose_ptrs,y
	sta !gen_gfx_pose_list
	stz !gen_gfx_pose_list+2
	%sprite_pose_pack_offs(16, 16)
	jsl spr_gfx_2
	rts

%start_sprite_pose_entry_list("chuck_body")
	; frame 0 unused?
	%start_sprite_pose_entry("chuck_unused", 16,16)
		%sprite_pose_tile_entry($00,$00,$00,$00,$02, 1)
	%finish_sprite_pose_entry()
	; frames 1, 2 unused
	%sprite_pose_entry_mirror("chuck_unused")
	%sprite_pose_entry_mirror("chuck_unused")
	; frame 3
	%start_sprite_pose_entry("chuck_sitting", 16, 16)
		%sprite_pose_tile_entry($00,$F8,$00|$80,$00,$02, 1)
		%sprite_pose_tile_entry($FC,$00,$0E,$00,$02, 1)
		%sprite_pose_tile_entry($04,$00,$0E,$40,$02, 1)
	%finish_sprite_pose_entry()
	; frame 4
	%start_sprite_pose_entry("chuck_crouching", 16, 16)
		%sprite_pose_tile_entry($FC,$00,$26,$00,$02, 1)
		%sprite_pose_tile_entry($04,$00,$26,$40,$02, 1)
	%finish_sprite_pose_entry()
	; frame 5
	%start_sprite_pose_entry("chuck_sitting_lr", 16, 16)
		%sprite_pose_tile_entry($FC,$00,$2D,$00,$02, 1)
		%sprite_pose_tile_entry($04,$00,$2E,$00,$02, 1)
	%finish_sprite_pose_entry()
	; frame 6
	%start_sprite_pose_entry("chuck_jumpin", 16, 16)
		%sprite_pose_tile_entry($FC,        $00,$20,$00,$02, 1)
		%sprite_pose_tile_entry($04,        $00,$20,$40,$02, 1)
		%sprite_pose_tile_entry($0A,        $F4,$28,$40,$00, 1)
		%sprite_pose_tile_entry(invert($0A),$F4,$28,$00,$00, 1)
	%finish_sprite_pose_entry()
	; frame 7
	; note ugg this is gonna be a pain because the hands need to be above the head...
	;      probably need to go back to linked list type system for this? or just skip it
	;      maybe just draw an 8x8?
	%start_sprite_pose_entry("chuck_clappin", 16, 16)
		%sprite_pose_tile_entry($00,$F0,$24,$00,$02, 1)
		%sprite_pose_tile_entry($08,$00,$22,$40,$02, 1)
		%sprite_pose_tile_entry($F8,$00,$22,$00,$02, 1)
	%finish_sprite_pose_entry()
	; frame 8 unused
	%sprite_pose_entry_mirror("chuck_unused")
	; crouching???
	%sprite_pose_entry_mirror("chuck_unused")
	; frame a-d
	%start_sprite_pose_entry("chuck_hurt", 16, 16)
		%sprite_pose_tile_entry($FC,$00,$0C,$00,$02, 1)
		%sprite_pose_tile_entry($04,$00,$0C,$40,$02, 1)
	%finish_sprite_pose_entry()
	%sprite_pose_entry_mirror("chuck_hurt")
	%sprite_pose_entry_mirror("chuck_hurt")
	%sprite_pose_entry_mirror("chuck_hurt")
	; todo diggin e,f, 10
	%sprite_pose_entry_mirror("chuck_unused")
	%sprite_pose_entry_mirror("chuck_unused")
	%sprite_pose_entry_mirror("chuck_unused")
	; todo kickin
	%sprite_pose_entry_mirror("chuck_unused")
	; frame 12
	%start_sprite_pose_entry("chuck_run_1", 16, 16)
		%sprite_pose_tile_entry($FC,$00,$09,$00,$02, 1)
		%sprite_pose_tile_entry($04,$00,$0A,$00,$02, 1)
		%sprite_pose_tile_entry($08,$F4,$39,$00,$00, 1)
		%sprite_pose_tile_entry($00,$F4,$38,$00,$00, 1)
	%finish_sprite_pose_entry()
	; frame 13
	%start_sprite_pose_entry("chuck_run_2", 16, 16)
		%sprite_pose_tile_entry($FC,$00,$06,$00,$02, 1)
		%sprite_pose_tile_entry($04,$00,$07,$00,$02, 1)
		%sprite_pose_tile_entry($08,$F4,$39,$00,$00, 1)
		%sprite_pose_tile_entry($00,$F4,$38,$00,$00, 1)
	%finish_sprite_pose_entry()
%finish_sprite_pose_entry_list()

FaceMario:
	jsl sub_horz_pos
	tya
	sta !chuck_face_dir,x
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; sub horz pos
ADDR_02D4FA:
	LDY #$00
	LDA $94
	SEC
	SBC !sprite_x_low,x
	STA $0F
	LDA $95
	SBC !sprite_x_high,x
	BPL Return02D50B
	INY
Return02D50B:
	RTS
	
; sub vert pos
ADDR_02D50C:
	LDY #$00
	LDA $96
	SEC
	SBC !sprite_y_low,x
	STA $0E
	LDA $97
	SBC !sprite_y_high,x
	BPL Return02D51D
	INY
Return02D51D:
	RTS
chuck_done:
%set_free_finish("bank7", chuck_done)
