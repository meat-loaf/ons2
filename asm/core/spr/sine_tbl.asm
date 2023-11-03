
math round off
%set_free_start("bank7")
!sine_table_size = 1280
!sine_table_circ = !sine_table_size-(!sine_table_size/5)
!sine_table_quarter = !sine_table_circ/4
!pi #= 2*asin(1)
sine_table:
	!ix = 0
	while !ix < !sine_table_size
	    dw round(sin(2*!pi*!ix/1024)*$0100,0)
	    !ix #= !ix+1
	endif
	undef "ix"
.end:
%set_free_finish("bank7", sine_table_end)
