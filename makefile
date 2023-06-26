LUNAR_MAGIC=lunar_magic_333
ASAR=asar -I${CURDIR}/headers --symbols=wla
TEST_EMU=snes9x-gtk
DBG_EMU=mesen
FLIPS=flips
CLEAN_ROM_NAME=smw.smc
ROM_BASE_PATH=rom_src
CLEAN_ROM_FULL=${ROM_BASE_PATH}/${CLEAN_ROM_NAME}

ROM_NAME_BASE=ons
ROM_NAME=${ROM_NAME_BASE}.smc
SYM_NAME=${ROM_NAME_BASE}.sym
ROM_RAW_BASE_SRC=rom_src/smw_1m_lmfastrom.smc
ROM_RAW_BASE_SRC_P=rom_src/fastrom_lm333.bps
ASAR+=--symbols-path=${SYM_NAME}

ASM_HEADERS=$(wildcard ${asm_dir}/headers/*.asm) $(wildcard ${asm_dir}/headers/**/*.asm)

SPRITES_DIR=asm/sprites
sprites_asm_main_file=${SPRITES_DIR}/sprites.asm
sprites_asm_sources= \
	${sprites_asm_main_file} \
	${SPRITES_DIR}/*.def \
	$(wildcard ${SPRITES_DIR}/engine/*.asm) \
	$(wildcard ${SPRITES_DIR}/engine/spritesets/*.asm) \
	$(wildcard ${SPRITES_DIR}/include/*.def) \
	$(wildcard ${SPRITES_DIR}/include/free_areas/*.free) \
	$(wildcard ${SPRITES_DIR}/macros/*.asm) \
	$(wildcard ${SPRITES_DIR}/sprites/*.asm) \
	$(wildcard ${SPRITES_DIR}/sprites/ambient/*.asm) \
	$(wildcard ${SPRITES_DIR}/dyn_gfx/*.bin)

tweaks_asm_sources= \
	$(wildcard ${asm_dir}/tweaks/*.asm) \
	$(wildcard ${asm_dir}/tweaks/optimizations/*.asm)

core_asm_sources= \
	$(wildcard ${asm_dir}/core/*.asm) \
	$(wildcard ${asm_dir}/core/objs/*.asm) \


.PHONY: ons test debug apply_asm

ons: ${CLEAN_ROM_FULL} ${ROM_NAME} ${CORE_BUILD_RULES} apply_asm

test: ons
	${TEST_EMU} ${ROM_NAME} >/dev/null 2>&1 &

debug: ons
	${DBG_EMU} ${ROM_NAME} &

apply_asm: ${ROM_NAME} ${sprites_asm_sources} ${tweaks_asm_sources}
	${ASAR} asm/asm.asm ${ROM_NAME}

${ROM_NAME}: ${ROM_RAW_BASE_SRC}
	cp ${ROM_RAW_BASE_SRC} ${ROM_NAME}
	#asar asm/smw_clean.asm ${ROM_NAME}

${ROM_RAW_BASE_SRC}: ${ROM_RAW_BASE_SRC_P}
	flips --apply ${ROM_RAW_BASE_SRC_P} ${CLEAN_ROM_FULL} ${ROM_RAW_BASE_SRC}

clean:
	rm -f ${ROM_NAME} ${SYM_NAME}
