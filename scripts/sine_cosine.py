#!/usr/bin/python3

from sys import argv, exit, stdout, stderr
from math import degrees, radians, sin

import argparse

def tohex(val, nbits):
	v = hex((val + (1 << nbits)) % (1 << nbits)).replace("0x", "")
	r = len(v)
	v = "$" + ("0" * (int(nbits/4) - r)) + v
	return v

def dump_row(rowvals, tblwidth, ffile):
	s = "\tdw "
	for val in rowvals:
		#print(hex(int(val*100.0)))
		print
		#s += "${:04x},".format(tohex(int(val*256.0), 16))
		s += "{}, ".format(tohex(int(val*256.0), 16))
	print (s[0:len(s)-2], file=ffile)
	#print("{}: {}".format(tblwidth+1, rowvals), file=sys.st)

def get_args(argv):
	p = argparse.ArgumentParser(description = 'sine table generator')
	p.add_argument('--size', dest='size', type=str, default='full', \
		choices=['fullquarter', 'full', 'half', 'quarter'], help='size of table')
	#p.add_argument('--grade', dest='grade', type=float, default=1.0, help='coarseness of table, in degrees')
	p.add_argument('--num-entries', dest='num_entries', type=int, default=1024, help='number of table entries')
	p.add_argument('--table-name', dest='table_name', type=str, default='sine_table', help='label name of output table')
	a = p.parse_args(argv)
	return a;

def main(argv):
	args = get_args(argv)
	s_sz = args.size
	#step_deg = args.grade
	sz_deg = 0.0
	if s_sz == 'fullquarter':
		sz_deg = 360.0 + 90.0
	elif s_sz == 'full':
		sz_deg = 360.0
	elif s_sz == 'half':
		sz_deg = 180.0
	elif s_sz == 'quarter':
		sz_deg = 90.0
	else:
		print("bad table size value: " + s_sz, file=stderr)
	step_deg = sz_deg / (args.num_entries)
	#print("step: {}".format(step_deg), file=stderr)
	x = 0.0
	tbl_width = 16;
	row = []
	nvals = 0
	print("!{}_size = {}\n{}:".format(args.table_name, args.num_entries, args.table_name), file=stdout)
	while x < sz_deg:
		#print("deg: {} rad: {}".format(x, radians(x)), file=stderr)
		row.append(round(sin(radians(x)), 4))
		if len(row) == tbl_width:
			dump_row(row, int(nvals / tbl_width), stdout)
			row = []
		x += step_deg
		nvals += 1
	#dump_row(row, int(nvals / tbl_width), stdout)
	#print("nvals: " + str(nvals));
	return 0;


if __name__ == '__main__':
	exit(main(argv[1:]))
