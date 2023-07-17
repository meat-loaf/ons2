!sprnum_chucks = $91

%alloc_sprite_spriteset_2(!sprnum_chucks, "chucks", chucks_init, chucks_main, 5, \
	$108, $109, \
	$00,$0D,$0B,$F9,$11,$48)



!chuck_phase = !sprite_misc_c2

!chuck_ani_flip_cycle  = !sprite_misc_151c
!chuck_ani_frame_cycle = !sprite_misc_1fd6
!chuck_temp_ani_timer = !sprite_misc_163e
!chuck_face_dir = !sprite_misc_157c

!num_chuck_frames = 8

chucks_init:
	inc !chuck_face_dir,x
	lda #$20
	sta !chuck_temp_ani_timer,x
	rtl

chucks_main:

	lda !chuck_temp_ani_timer,x
	bne .no_ani_update

	lda #$20
	sta !chuck_temp_ani_timer,x

	lda !chuck_ani_frame_cycle,x
	inc
	cmp #!num_chuck_frames
	bcc .frame_ok

	lda !chuck_ani_flip_cycle,x
	inc
	cmp #$04
	bcc .chuck_flip_ok
	lda #$00
.chuck_flip_ok:
	sta !chuck_ani_flip_cycle,x
	tay
	lda !sprite_oam_properties,x
	and #$3F
	ora .ani_flip,y
	sta !sprite_oam_properties,x
	lda #$00
.frame_ok:
	sta !chuck_ani_frame_cycle,x
.no_ani_update:
	lda !chuck_ani_frame_cycle,x
	tay
	lda chuck_frame_table_ptr_hi,y
	xba
	lda chuck_frame_table_ptr_low,y
	jsl spr_gfx

	lda #$01
	jml sub_off_screen
.ani_flip:
	db $00, $40, $c0, $80
; frame 0 unused?
; frames 1, 2 unused

; frame 3
%start_sprite_table("chuck_sitting", 16, 16)
	%sprite_table_entry($FC,$00,$0E,$00,$02, 1)
	%sprite_table_entry($04,$00,$0E,$40,$02, 1)
%finish_sprite_table()
; frame 4
%start_sprite_table("chuck_crouching", 16, 16)
	%sprite_table_entry($FC,$00,$26,$00,$02, 1)
	%sprite_table_entry($04,$00,$26,$40,$02, 1)
%finish_sprite_table()
; frame 5
%start_sprite_table("chuck_sitting_lr", 16, 16)
	%sprite_table_entry($FC,$00,$2D,$00,$02, 1)
	%sprite_table_entry($04,$00,$2E,$00,$02, 1)
%finish_sprite_table()
; frame 6
%start_sprite_table("chuck_jumpin", 16, 16)
	%sprite_table_entry($FC,        $00,$20,$00,$02, 1)
	%sprite_table_entry($04,        $00,$20,$40,$02, 1)
	%sprite_table_entry($0A,        $F4,$28,$40,$00, 1)
	%sprite_table_entry(invert($0A),$F4,$28,$00,$00, 1)
%finish_sprite_table()
; frame 7
; note ugg this is gonna be a pain because the hands need to be above the head...
;      probably need to go back to linked list type system for this? or just skip it
;      maybe just draw an 8x8?
%start_sprite_table("chuck_clappin", 16, 16)
	%sprite_table_entry($00,$F0,$24,$00,$02, 1)
	%sprite_table_entry($08,$00,$22,$40,$02, 1)
	%sprite_table_entry($F8,$00,$22,$00,$02, 1)
%finish_sprite_table()
; frame 8 unused
; frame a-d
%start_sprite_table("chuck_hurt", 16, 16)
	%sprite_table_entry($FC,$00,$0C,$00,$02, 1)
	%sprite_table_entry($04,$00,$0C,$40,$02, 1)
%finish_sprite_table()

; frame 12
%start_sprite_table("chuck_run_1", 16, 16)
	%sprite_table_entry($FC,$00,$09,$00,$02, 1)
	%sprite_table_entry($04,$00,$0A,$00,$02, 1)
	%sprite_table_entry($08,$F4,$39,$00,$00, 1)
	%sprite_table_entry($00,$F4,$38,$00,$00, 1)
%finish_sprite_table()
; frame 13
%start_sprite_table("chuck_run_2", 16, 16)
	%sprite_table_entry($FC,$00,$06,$00,$02, 1)
	%sprite_table_entry($04,$00,$07,$00,$02, 1)
	%sprite_table_entry($08,$F4,$39,$00,$00, 1)
	%sprite_table_entry($00,$F4,$38,$00,$00, 1)
%finish_sprite_table()

chuck_frame_table_ptr_low:
	db chuck_sitting
	db chuck_crouching
	db chuck_sitting_lr
	db chuck_jumpin
	db chuck_clappin
	db chuck_hurt
	db chuck_run_1
	db chuck_run_2
chuck_frame_table_ptr_hi:
	db chuck_sitting>>8
	db chuck_crouching>>8
	db chuck_sitting_lr>>8
	db chuck_jumpin>>8
	db chuck_clappin>>8
	db chuck_hurt>>8
	db chuck_run_1>>8
	db chuck_run_2>>8

