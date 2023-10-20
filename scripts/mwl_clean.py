#!/bin/python3


# cleans the unused 'original data location' entries in an
# MWL file (useful when adding them to source control)

import sys;

debug = 1

mwl_string_encoding = "windows-1252"
mwl_header_generic_text = "  ©2022 FuSoYa  Defender of Relm"
mwl_header_generic_text_pos = 0x20
mwl_source_data_pointer_loc_off = 0x04
mwl_data_pointer_size = 0x04
mwl_source_pointer_size = 0x03
pointer_bank_byte_off = 2

header_pointer_loc = 0x04

nullptr = bytes("\x00"*mwl_source_pointer_size, mwl_string_encoding)

# layer 1, layer 2, sprite, and palette data offsets
data_pointer_offsets = (0x08, 0x10, 0x18, 0x20)

def data_pointer_get_bank(ptr):
	return (ptr >> 16) & 0xFF

def read_nbytes_as_le(f, nbytes=4):
	return int.from_bytes(f.read(nbytes), "little")

if len(sys.argv) < 2:
	print("Provide MWL files as arguments.")
	sys.exit(1)

for mwl_file_name in sys.argv[1:]:
	plocs = []
	with open(mwl_file_name, "rb+") as mwl_file:
		mwl_file.seek(mwl_header_generic_text_pos)
		if (mwl_file.read(len(mwl_header_generic_text)).decode(mwl_string_encoding) != mwl_header_generic_text):
			print("[{}] Header check failed: this doesn't appear to be a MWL file.".format(mwl_file_name))
			sys.exit(1)
		print ("Process {}...".format(mwl_file_name))
		mwl_file.seek(header_pointer_loc);
		header_start_off = read_nbytes_as_le(mwl_file, mwl_data_pointer_size)
		for offset in data_pointer_offsets:
			if debug:
				 print ("Pointer at: {}".format(hex(header_start_off+offset)))
			mwl_file.seek(header_start_off+offset)
			pointer = read_nbytes_as_le(mwl_file, mwl_source_pointer_size) + mwl_source_data_pointer_loc_off
			mwl_file.seek(pointer)
			source_ptr = read_nbytes_as_le(mwl_file, mwl_source_pointer_size)
			if debug:
				print("\toffset {} source ptr: {}".format(hex(pointer), hex(source_ptr)))
			if (source_ptr == 0):
				# already clean
				continue;
			elif data_pointer_get_bank(source_ptr) == 0xFF:
				print("\tSkipping pointer at {}: sourced from original data.".format(hex(pointer)))
				continue;
			plocs.append(hex(pointer))
			if debug:
				print ("\tWriting null pointer to offset {} (old val: {})".format(hex(pointer), hex(read_nbytes_as_le(mwl_file, mwl_source_pointer_size))))
				mwl_file.seek(pointer)
			mwl_file.seek(pointer)
			x = mwl_file.write(nullptr)
			if x != mwl_source_pointer_size:
				print("File {}: Couldn't write all bytes (Wrote {}, expected {}). Exiting.".format(mwl_file_name, x, mwl_source_pointer_size))
				sys.exit(1);
			#mwl_file.seek(pointer)
	if (len(plocs)) != 0:
		fstr = "{}: null pointers written to offset(s)";
		fstr += " {}"*len(plocs)
		print(fstr.format(mwl_file_name, *plocs))
	else:
		print("{}: Nothing done".format(mwl_file_name))
