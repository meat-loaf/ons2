!apply_cpu_meter = 1

!star_tile      = $EF
!star_props     = $34
org $008075|!addr
	jml cpu_meter

%set_free_start("bank7")
cpu_meter:
	LDA $2137
	LDA $213D
	STA $02ED
	LDA #!star_tile
	STA $02EE
	LDA #!star_props
	STA $02EF
	STZ $02EC
	STZ $045B
	stz !lag_flag
	jml $00806B|!bank
.done:
%set_free_finish("bank7", cpu_meter_done)
