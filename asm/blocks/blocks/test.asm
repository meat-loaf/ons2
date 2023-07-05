%declare_block("test", $0200, $0025, $00,
	mario_above, mario_below, mario_side, mario_top_corner, mario_body, mario_head,
	sprite_v, sprite_h, cape, fireball,
	wallrun_footie, wallrun_body)

%define_block($0200)

mario_above:
mario_below:
mario_side:
mario_top_corner:
mario_body:
mario_head:
sprite_v:
sprite_h:
cape:
fireball:
wallrun_footie:
wallrun_body:
	lda #$03
	sta $1DFC
	rtl
