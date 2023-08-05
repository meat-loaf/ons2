incsrc "macros/macros.asm"

incsrc "include/sprnums.def"
incsrc "include/config.def"
incsrc "include/smw_routines.def"

incsrc "engine/engine.asm"

incsrc "list.def"

!have_dyn = 0

%write_sprite_tables()
%write_ambient_tables(ambient_rts, ambient_twk_tsz, ambient_grav_vals, ambient_dust_main_bad_ambient_default)
%write_spriteset_table(ss_data_table)
