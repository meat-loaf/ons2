#!/usr/bin/python3

import sys
import os

def sneslorom2pc(addr, headered):
	bank = (addr & 0xFF0000)>>16
	ptr = addr & 0x00FFFF
	if (bank == 0x7E or bank == 0x7F) or ptr < 0x8000:
		raise ValueError("Bad lorom address {:06x}: in RAM". format(addr))
	return (ptr-0x8000) + (bank*0x8000) + (512 if headered else 0)

def rom_has_copier_header(file):
	return (os.fstat(file.fileno()).st_size & 512) == 512

def pull_cfg_info(file, sid):
	if sid > 0xC8 or sid < 0x00:
		raise ValueError("Bad sprite id: {:02x}".format(sid))

	cfg_table_ptrs = (0x07F26C, 0x07F335, 0x07F3FE, 0x07F4C7, 0x07F590, 0x07F659)
	cfg_bytes = []
	for ptr in cfg_table_ptrs:
		ptr_pc = sneslorom2pc(ptr+sid, rom_has_copier_header(file))
		file.seek(ptr_pc, 0)
		val = file.read(1)
		cfg_bytes.append(val.hex())
	return cfg_bytes

def main(argv):
	if len(argv) != 3:
		print("Need SMW rom file and sprite id to pull cfg bits from.", file=sys.stderr)
		return 1
	args_real = argv[1:]
	id_ix = 1
	info = None
	for arg in args_real:
		try:
			with open(arg, 'rb') as rom_file:
				info = pull_cfg_info(rom_file, int(args_real[id_ix], 16))
				break
		except FileNotFoundError:
			if id_ix == 0:
				print("Error: neither argument could be opened as a file (tried {}, {}).".format(args_real[0], args_real[1]), file=sys.stderr)
				return 1
			id_ix = 0
			continue
		except ValueError as e:
			print("Error: {}".format(e))
			return 1

	print(info)
	return 0

if __name__ == '__main__':
	sys.exit(main(sys.argv))
