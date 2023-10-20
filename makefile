LUNAR_MAGIC=lunar_magic_333
ASAR=asar -I${CURDIR}/headers --symbols=wla
TEST_EMU=snes9x-gtk
DBG_EMU=mesen
FLIPS=flips
CLEAN_ROM_NAME=smw.smc
ROM_BASE_PATH=rom_src
CLEAN_ROM_FULL=${ROM_BASE_PATH}/${CLEAN_ROM_NAME}
ASM_TS=.asm.ts
GFX_TS=.gfx.ts
MWL_FAKE_TS=.mwl.ts

ROM_NAME_BASE=ons
ROM_NAME=${ROM_NAME_BASE}.smc
SYM_NAME=${ROM_NAME_BASE}.sym
ROM_RAW_BASE_SRC=rom_src/smw_1m_lmfastrom.smc
ROM_RAW_BASE_SRC_P=rom_src/fastrom_lm333.bps
ASAR+=--symbols-path=${SYM_NAME}
asm_dir=asm

GFX= \
	$(wildcard gfx/*.bin) \
	$(wildcard Graphics/*.bin) \
	$(wildcard ExGraphics/*.bin)

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

CUSTOM_SPR_COLLECTION_FILES=${ROM_NAME}.ssc ${ROM_NAME}.mwt ${ROM_NAME}.mw2
CUSTOM_SPR_COLLECTION_JSON_DEFS_DIR=sprite_collections
CUSTOM_SPR_COLLECTION_DEF_FILES=$(wildcard ${CUSTOM_SPR_COLLECTION_JSON_DEFS_DIR}/*.json)
CUSTOM_SPR_COLLECTION_SSC_BASE=${ROM_BASE_PATH}/base.ssc


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


MWL_DIR=lvl
MWL_FNAME_BASE=l

.PHONY: ons test debug

ons: ${CLEAN_ROM_FULL} ${ROM_NAME} ${CORE_BUILD_RULES} ${ASM_TS} ${GFX_TS} ${MWL_FAKE_TS} ${CUSTOM_SPR_COLLECTION_FILES}

test: ons
	${TEST_EMU} ${ROM_NAME} >/dev/null 2>&1 &

debug: ons
	${DBG_EMU} ${ROM_NAME} &

${ASM_TS}: ${ROM_NAME} ${ALL_ASM_DEPS} ${GFX_TS}
	${ASAR} asm/asm.asm ${ROM_NAME}
	touch $@

${GFX_TS}: ${GFX}
	${LUNAR_MAGIC} -ImportAllGraphics ${ROM_NAME}
	touch $@

${ROM_NAME}: ${ROM_RAW_BASE_SRC}
	cp ${ROM_RAW_BASE_SRC} ${ROM_NAME}
	asar asm/smw_clean.asm ${ROM_NAME}

${ROM_RAW_BASE_SRC}: ${ROM_RAW_BASE_SRC_P}
	flips --apply ${ROM_RAW_BASE_SRC_P} ${CLEAN_ROM_FULL} ${ROM_RAW_BASE_SRC}

${MWL_FAKE_TS}: ${MWL_DIR}/${MWL_FNAME_BASE}\ *.mwl
	${LUNAR_MAGIC} -ImportMultLevels ${ROM_NAME} ./${MWL_DIR}
	touch $@

${CUSTOM_SPR_COLLECTION_FILES}&: ${ASM_TS} ${CUSTOM_SPR_COLLECTION_DEF_FILES}
	./scripts/generate_sprite_collection.py --name-prefix ${ROM_NAME_BASE} --base-ssc ${CUSTOM_SPR_COLLECTION_SSC_BASE} -x 7 -y 7 ${CUSTOM_SPR_COLLECTION_DEF_FILES}


clean:
	rm -f ${ROM_NAME} ${SYM_NAME} .*.ts
