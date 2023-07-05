LUNAR_MAGIC=lunar_magic_333
ASAR=asar -I${CURDIR}/headers --symbols=wla
TEST_EMU=snes9x-gtk
DBG_EMU=mesen
FLIPS=flips
CLEAN_ROM_NAME=smw.smc
ROM_BASE_PATH=rom_src
CLEAN_ROM_FULL=${ROM_BASE_PATH}/${CLEAN_ROM_NAME}
ASM_TS=.asm.ts

ROM_NAME_BASE=ons
ROM_NAME=${ROM_NAME_BASE}.smc
SYM_NAME=${ROM_NAME_BASE}.sym
ROM_RAW_BASE_SRC=rom_src/smw_1m_lmfastrom.smc
ROM_RAW_BASE_SRC_P=rom_src/fastrom_lm333.bps
ASAR+=--symbols-path=${SYM_NAME}
asm_dir=asm

ASM_HEADERS=$(wildcard ${asm_dir}/headers/*.asm) $(wildcard ${asm_dir}/headers/**/*.asm)

SPRITES_DIR=${asm_dir}/sprites
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

blocks_dir=${asm_dir}/blocks
blocks_asm_main_file=${blocks_dir}/blocks.asm
blocks_asm_sources= \
	${blocks_asm_main_file} \
	$(wildcard ${blocks_dir}/*.def) \
	$(wildcard ${blocks_dir}/engine/*.asm) \
	$(wildcard ${blocks_dir}/macros/*.asm) \
	$(wildcard ${blocks_dir}/include/*.def) \
	$(wildcard ${blocks_dir}/blocks/*.asm) \

headers_asm_sources= \
	$(wildcard ${asm_dir}/headers/*.asm)

tweaks_asm_sources= \
	$(wildcard ${asm_dir}/tweaks/*.asm) \
	$(wildcard ${asm_dir}/tweaks/optimizations/*.asm)

core_asm_sources= \
	$(wildcard ${asm_dir}/core/*.asm) \
	$(wildcard ${asm_dir}/core/gm/*.asm) \
	$(wildcard ${asm_dir}/core/objs/*.asm) \
	$(wildcard ${asm_dir}/core/spr/*.asm) \

ALL_ASM_DEPS= \
	${sprites_asm_sources} \
	${blocks_asm_sources} \
	${tweaks_asm_sources} \
	${core_asm_sources} \
	${headers_asm_sources} \

.PHONY: ons test debug

ons: ${CLEAN_ROM_FULL} ${ROM_NAME} ${CORE_BUILD_RULES} ${ASM_TS}

test: ons
	${TEST_EMU} ${ROM_NAME} >/dev/null 2>&1 &

debug: ons
	${DBG_EMU} ${ROM_NAME} &

${ASM_TS}: ${ROM_NAME} ${ALL_ASM_DEPS}
	${ASAR} asm/asm.asm ${ROM_NAME}
	touch $@

${ROM_NAME}: ${ROM_RAW_BASE_SRC}
	cp ${ROM_RAW_BASE_SRC} ${ROM_NAME}
	asar asm/smw_clean.asm ${ROM_NAME}

${ROM_RAW_BASE_SRC}: ${ROM_RAW_BASE_SRC_P}
	flips --apply ${ROM_RAW_BASE_SRC_P} ${CLEAN_ROM_FULL} ${ROM_RAW_BASE_SRC}

clean:
	rm -f ${ROM_NAME} ${SYM_NAME} .*.ts
