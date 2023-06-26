includeonce
if read1($00FFD5) == $23
	if read1($00FFD7) == $0D ; full 6/8 mb sa-1 rom
		fullsa1rom
		!fullsa1 = 1
	else
		sa1rom
	endif
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!ramlo = $400000
	!ramhi = $410000

	!num_sprites = $16
else
	lorom
	!sa1 = 0
	!fullsa1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!bank8 = $80
	!ramlo = $7E0000
	!ramhi = $7F0000
	!num_sprites = $0C
endif

!ambient_debug = 0

!JSL_OPCODE           = $22
!JML_OPCODE           = $5C
!RTL_OPCODE           = $6B

!num_turnblock_slots  = $10

hurt_mario            = $00F5B7|!bank

!num_ambient_sprs = $28

!ambient_sprid_max = $3F

!spr_tweaker_1656_tbl = $07F26C|!bank
!spr_tweaker_1662_tbl = $07F335|!bank
!spr_tweaker_166E_tbl = $07F3FE|!bank
!spr_tweaker_167A_tbl = $07F4C7|!bank
!spr_tweaker_1686_tbl = $07F590|!bank
!spr_tweaker_190F_tbl = $07F659|!bank

!spr_inits_start     = $01817D|!bank
!spr_mains_start     = $0185CC|!bank

!ambient_twk_pos_upd          = %1000000000000000
!ambient_twk_has_grav         = %0100000000000000
!ambient_twk_check_offscr     = %0010000000000000
!ambient_twk_spr_interact     = %0001000000000000
!ambient_twk_player_interact  = %0000010000000000
!ambient_twk_cape_interact    = %0000001000000000
!ambient_twk_spinjumpable     = %0000000100000000
!ambient_gfx_tilesz_big       = %0000000000000010

; intended to be set by ambient gfx routines! dont set it
; in configs
!ambient_gfx_xhigh            = %0000000000000001

_spr_face_mario_bank1 = $01857C|!bank

!true  = $01
!false = $00

!sram_size = $03

!JML_OPCODE = $5C
!JSL_OPCODE = $22

!dyn_max_slots = $04

!red_coin_sfx_id      = $2E
!last_red_coin_sfx_id = $2F

!timer_frames_to_dec  = $28

!item_memory_size       = $1C00
!item_memory_dma_frames = $08
!wiggler_buffer_index_len = $80
!num_wigglers             = $04

!frames_before_waterfall_reset = $04
!frames_for_on_off_cooldown    = $0A

!level_status_flag_always_slip       = %00000001
!state_flag_player_l2_lastf          = %00000010
!level_status_flag_sprite_water      = %10000000

; set in old sprite memory ram byte
!level_status_flag_lava_slope_toggle = %00000001
!level_status_flag_slope_no_dirt     = %00000010
!level_status_flag_goal_move_left    = %00000100

!level_constrain_top   = %00001000
!level_constrain_bot   = %00000100
!level_constrain_left  = %00000010
!level_constrain_right = %00000001

!item_mem_write_disable = %00000001
!item_mem_read_disable  = %00000010

!19D8_flag_norm_exit_hi   = %00000001
!19D8_flag_is_secondary   = %00000010
!19D8_flag_lm_modified    = %00000100
!19D8_flag_water_lvl_mid  = %00001000
!19D8_flag_b8_12_seconary = %11110000

!slip_block_slipperyness = $FF
;; sprite props ;;
!spr_167a_prop_keep_clipping_on_starkill   = %00000001
!spr_167a_prop_nodie_fire_cape_star_bounce = %00000010
!spr_167a_prop_process_offscreen           = %00000100
!spr_167a_not_shell_when_stunned           = %00001000
!spr_167a_not_shell_kickable               = %00010000
!spr_167a_player_interact_every_frame      = %00100000
!spr_167a_powerup_on_yoshi_eat             = %01000000
!spr_167a_no_default_player_interaction    = %10000000

;; spr 0 to 13 props ;;
; originals
!gen_spr_prop_move_fast         = %00000001
!gen_spr_prop_stay_on_ledge     = %00000010
!gen_spr_prop_follow_mario      = %00000100
!gen_spr_prop_jump_over_shells  = %00001000
!gen_spr_prop_use_32x16_tilemap = %01000000
!gen_spr_prop_fast_ani_in_air   = %10000000

; NEW, added by changes (TODO);
!gen_spr_prop_reverse_gravity   = %00010000


;;; screen scrolling pipe stuff ;;;
;This will make mario visible and in front of objects when enabled, set to 1 if you encounter issues like Mario ignoring turn corners.
!Setting_SSP_PipeDebug = 0

;0 = can't carry sprites through pipes, 1 = enable carrying.
!Setting_SSP_CarryAllowed	= 1

;0 = yoshi cannot enter, 1 = can. NOTE: Small pipes always prohibits Yoshi regardless of this setting. Another note that unlike FuSoYa
; that makes the "spat" SFX, this plays SFX ONLY if you are tapping the 1-frame controller to prevent repeatedly playing the SFX and overwriting
; the channel and replacing SFX.
!Setting_SSP_YoshiAllowed	= 1

;SFX stuff for yoshi prohibited from entering pipes (only for normal-sized pipes):
;Set this to $00 for no sound (no worry, it won't cancel the SFX port of any current SFX.)
!Setting_SSP_YoshiProhibitSFXNum	= $20

;The sound effect played when you tried to enter pipes on yoshi when yoshi is prohibited.
!Setting_SSP_YoshiProhibitSFXPort	= $1DF9

;0 = off, 1 = on. Due to a bug in GPS with blocks with the wrong description, I added an option just in case if GPS has that fixed in the future.
!Setting_SSP_Description	= 1

;0 = FuSoYa's pipe to not freeze stuff, 1 = freeze stuff.
!Setting_SSP_FreezeTime	= 0

;0 = SMW styled speed (fast stem speed by default), 1 = fast FuSoYa speed.
!Setting_SSP_FuSoYaSpd		= 1

;Pipe travel speeds:
;Use only values $01-$7F (negative speeds already calculated).
;
 if !Setting_SSP_FuSoYaSpd == 0		;>Don't change this if statement.
  ;SMW styled speed
  !SSP_HorizontalSpd		= $40 ;\Stem speed (changing this does not affect the timing of the entering/exiting)
  !SSP_VerticalSpd		= $40 ;/
  !SSP_HorizontalSpdPipeCap	= $08 ;\cap speed (if changed, you must change the timers below this section)
  !SSP_VerticalSpdPipeCap	= $10 ;/
 else
  ;FuSoYa styled speed.
  !SSP_HorizontalSpd		= $40 ;\Duplicate of above, but for fusoya style speeds.
  !SSP_VerticalSpd		= $40 ;|
  !SSP_HorizontalSpdPipeCap	= $40 ;|
  !SSP_VerticalSpdPipeCap	= $40 ;/
 endif

;Pipe exiting (and entering) timers (needed in case if you changed the cap speeds and have to fiddle to make
;sure the player exit the pipes properly, as well as the player hitbox to not exit while overlapping the pipes.)
;Numbers here are how long (in frames) before the player returns to normal when hitting pipe caps.
;The faster you set the pipe cap speed, the lower the values here should be.
;Hint: by using the scale by factor (Speed*X leads to Timer/X), it makes it much easier to work with this.
;
;Easiest to know is to test them, if the player exits the pipe further ahead of the cap past it, the timer is too long
;and needs to be a lower value, if the player exits the pipe while inside the cap (embedded inside the solid pipe),
;the timer is too short and needs to be a higher value. For downwards facing pipes, shorter timers also enable entering
;back in them just after exiting it by holding up.

;Alternative way, have the timer be $FF. Then use a debugger and check out the RAM address "!Freeram_SSP_PipeTmr" is
;using, from the time the timer is $FF about to decrement to the time the value is at a certain number when the player's
;body (including yoshi when riding it) is at the position he should be freely be able to move, the difference is the
;correct amount of frames for the player to exit the pipe properly:

if !Setting_SSP_FuSoYaSpd == 0
;Regular pipe timing
  !SSP_PipeTimer_Enter_Leftwards                    = $3A
  !SSP_PipeTimer_Enter_Rightwards                   = $3C
  !SSP_PipeTimer_Enter_Upwards_OffYoshi             = $1D
  !SSP_PipeTimer_Enter_Upwards_OnYoshi              = $27
  !SSP_PipeTimer_Enter_Downwards_OffYoshi           = $20
  !SSP_PipeTimer_Enter_Downwards_OnYoshi            = $30
  !SSP_PipeTimer_Enter_Downwards_SmallPipe          = $1D

  !SSP_PipeTimer_Exit_Leftwards                     = $1B
  !SSP_PipeTimer_Exit_Rightwards                    = $1B
  !SSP_PipeTimer_Exit_Upwards_OffYoshi              = $1D
  !SSP_PipeTimer_Exit_Upwards_OnYoshi               = $27
  !SSP_PipeTimer_Exit_Downwards_OffYoshi_SmallMario = $0E
  !SSP_PipeTimer_Exit_Downwards_OffYoshi_BigMario   = $1B
  !SSP_PipeTimer_Exit_Downwards_OnYoshi_SmallMario  = $18
  !SSP_PipeTimer_Exit_Downwards_OnYoshi_BigMario    = $25
 else
  ;FuSoYa enter and exit timers.
  !SSP_PipeTimer_Enter_Leftwards			= $0A
  !SSP_PipeTimer_Enter_Rightwards			= $0A
  !SSP_PipeTimer_Enter_Upwards_OffYoshi			= $0A
  !SSP_PipeTimer_Enter_Upwards_OnYoshi			= $0A
  !SSP_PipeTimer_Enter_Downwards_OffYoshi		= $0A
  !SSP_PipeTimer_Enter_Downwards_OnYoshi		= $0A
  !SSP_PipeTimer_Enter_Downwards_SmallPipe		= $0A

  !SSP_PipeTimer_Exit_Leftwards				= $04
  !SSP_PipeTimer_Exit_Rightwards			= $04
  !SSP_PipeTimer_Exit_Upwards_OffYoshi			= $09
  !SSP_PipeTimer_Exit_Upwards_OnYoshi			= $0A
  !SSP_PipeTimer_Exit_Downwards_OffYoshi_SmallMario	= $06
  !SSP_PipeTimer_Exit_Downwards_OffYoshi_BigMario	= $08
  !SSP_PipeTimer_Exit_Downwards_OnYoshi_SmallMario	= $07
  !SSP_PipeTimer_Exit_Downwards_OnYoshi_BigMario	= $08
endif

;;; end screen scrolling pipe stuff ;;;
