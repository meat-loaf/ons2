;freedata
%set_free_start("bank7")
!sine_table_size = 1280
!sine_table_circ = !sine_table_size-(!sine_table_size/5)
!sine_table_quarter = !sine_table_circ/4
sine_table:
	dw $0000, $0001, $0003, $0004, $0006, $0007, $0009, $000a, $000c, $000e, $000f, $0011, $0012, $0014, $0015, $0017
	dw $0019, $001a, $001c, $001d, $001f, $0020, $0022, $0024, $0025, $0027, $0028, $002a, $002b, $002d, $002e, $0030
	dw $0031, $0033, $0035, $0036, $0038, $0039, $003b, $003c, $003e, $003f, $0041, $0042, $0044, $0045, $0047, $0048
	dw $004a, $004b, $004d, $004e, $0050, $0051, $0053, $0054, $0056, $0057, $0059, $005a, $005c, $005d, $005f, $0060
	dw $0061, $0063, $0064, $0066, $0067, $0069, $006a, $006c, $006d, $006e, $0070, $0071, $0073, $0074, $0075, $0077
	dw $0078, $007a, $007b, $007c, $007e, $007f, $0080, $0082, $0083, $0084, $0086, $0087, $0088, $008a, $008b, $008c
	dw $008e, $008f, $0090, $0092, $0093, $0094, $0095, $0097, $0098, $0099, $009b, $009c, $009d, $009e, $009f, $00a1
	dw $00a2, $00a3, $00a4, $00a6, $00a7, $00a8, $00a9, $00aa, $00ab, $00ad, $00ae, $00af, $00b0, $00b1, $00b2, $00b3
	dw $00b5, $00b6, $00b7, $00b8, $00b9, $00ba, $00bb, $00bc, $00bd, $00be, $00bf, $00c0, $00c1, $00c2, $00c3, $00c4
	dw $00c5, $00c6, $00c7, $00c8, $00c9, $00ca, $00cb, $00cc, $00cd, $00ce, $00cf, $00d0, $00d1, $00d2, $00d3, $00d3
	dw $00d4, $00d5, $00d6, $00d7, $00d8, $00d9, $00d9, $00da, $00db, $00dc, $00dd, $00dd, $00de, $00df, $00e0, $00e1
	dw $00e1, $00e2, $00e3, $00e3, $00e4, $00e5, $00e6, $00e6, $00e7, $00e8, $00e8, $00e9, $00ea, $00ea, $00eb, $00eb
	dw $00ec, $00ed, $00ed, $00ee, $00ee, $00ef, $00ef, $00f0, $00f1, $00f1, $00f2, $00f2, $00f3, $00f3, $00f4, $00f4
	dw $00f4, $00f5, $00f5, $00f6, $00f6, $00f7, $00f7, $00f7, $00f8, $00f8, $00f9, $00f9, $00f9, $00fa, $00fa, $00fa
	dw $00fb, $00fb, $00fb, $00fb, $00fc, $00fc, $00fc, $00fd, $00fd, $00fd, $00fd, $00fd, $00fe, $00fe, $00fe, $00fe
	dw $00fe, $00fe, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $0100
	dw $0100, $0100, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00fe
	dw $00fe, $00fe, $00fe, $00fe, $00fe, $00fd, $00fd, $00fd, $00fd, $00fd, $00fc, $00fc, $00fc, $00fb, $00fb, $00fb
	dw $00fb, $00fa, $00fa, $00fa, $00f9, $00f9, $00f9, $00f8, $00f8, $00f7, $00f7, $00f7, $00f6, $00f6, $00f5, $00f5
	dw $00f4, $00f4, $00f4, $00f3, $00f3, $00f2, $00f2, $00f1, $00f1, $00f0, $00ef, $00ef, $00ee, $00ee, $00ed, $00ed
	dw $00ec, $00eb, $00eb, $00ea, $00ea, $00e9, $00e8, $00e8, $00e7, $00e6, $00e6, $00e5, $00e4, $00e3, $00e3, $00e2
	dw $00e1, $00e1, $00e0, $00df, $00de, $00dd, $00dd, $00dc, $00db, $00da, $00d9, $00d9, $00d8, $00d7, $00d6, $00d5
	dw $00d4, $00d3, $00d3, $00d2, $00d1, $00d0, $00cf, $00ce, $00cd, $00cc, $00cb, $00ca, $00c9, $00c8, $00c7, $00c6
	dw $00c5, $00c4, $00c3, $00c2, $00c1, $00c0, $00bf, $00be, $00bd, $00bc, $00bb, $00ba, $00b9, $00b8, $00b7, $00b6
	dw $00b5, $00b3, $00b2, $00b1, $00b0, $00af, $00ae, $00ad, $00ab, $00aa, $00a9, $00a8, $00a7, $00a6, $00a4, $00a3
	dw $00a2, $00a1, $009f, $009e, $009d, $009c, $009b, $0099, $0098, $0097, $0095, $0094, $0093, $0092, $0090, $008f
	dw $008e, $008c, $008b, $008a, $0088, $0087, $0086, $0084, $0083, $0082, $0080, $007f, $007e, $007c, $007b, $007a
	dw $0078, $0077, $0075, $0074, $0073, $0071, $0070, $006e, $006d, $006c, $006a, $0069, $0067, $0066, $0064, $0063
	dw $0061, $0060, $005f, $005d, $005c, $005a, $0059, $0057, $0056, $0054, $0053, $0051, $0050, $004e, $004d, $004b
	dw $004a, $0048, $0047, $0045, $0044, $0042, $0041, $003f, $003e, $003c, $003b, $0039, $0038, $0036, $0035, $0033
	dw $0031, $0030, $002e, $002d, $002b, $002a, $0028, $0027, $0025, $0024, $0022, $0020, $001f, $001d, $001c, $001a
	dw $0019, $0017, $0015, $0014, $0012, $0011, $000f, $000e, $000c, $000a, $0009, $0007, $0006, $0004, $0003, $0001
	dw $0000, $ffff, $fffd, $fffc, $fffa, $fff9, $fff7, $fff6, $fff4, $fff2, $fff1, $ffef, $ffee, $ffec, $ffeb, $ffe9
	dw $ffe7, $ffe6, $ffe4, $ffe3, $ffe1, $ffe0, $ffde, $ffdc, $ffdb, $ffd9, $ffd8, $ffd6, $ffd5, $ffd3, $ffd2, $ffd0
	dw $ffcf, $ffcd, $ffcb, $ffca, $ffc8, $ffc7, $ffc5, $ffc4, $ffc2, $ffc1, $ffbf, $ffbe, $ffbc, $ffbb, $ffb9, $ffb8
	dw $ffb6, $ffb5, $ffb3, $ffb2, $ffb0, $ffaf, $ffad, $ffac, $ffaa, $ffa9, $ffa7, $ffa6, $ffa4, $ffa3, $ffa1, $ffa0
	dw $ff9f, $ff9d, $ff9c, $ff9a, $ff99, $ff97, $ff96, $ff94, $ff93, $ff92, $ff90, $ff8f, $ff8d, $ff8c, $ff8b, $ff89
	dw $ff88, $ff86, $ff85, $ff84, $ff82, $ff81, $ff80, $ff7e, $ff7d, $ff7c, $ff7a, $ff79, $ff78, $ff76, $ff75, $ff74
	dw $ff72, $ff71, $ff70, $ff6e, $ff6d, $ff6c, $ff6b, $ff69, $ff68, $ff67, $ff65, $ff64, $ff63, $ff62, $ff61, $ff5f
	dw $ff5e, $ff5d, $ff5c, $ff5a, $ff59, $ff58, $ff57, $ff56, $ff55, $ff53, $ff52, $ff51, $ff50, $ff4f, $ff4e, $ff4d
	dw $ff4b, $ff4a, $ff49, $ff48, $ff47, $ff46, $ff45, $ff44, $ff43, $ff42, $ff41, $ff40, $ff3f, $ff3e, $ff3d, $ff3c
	dw $ff3b, $ff3a, $ff39, $ff38, $ff37, $ff36, $ff35, $ff34, $ff33, $ff32, $ff31, $ff30, $ff2f, $ff2e, $ff2d, $ff2d
	dw $ff2c, $ff2b, $ff2a, $ff29, $ff28, $ff27, $ff27, $ff26, $ff25, $ff24, $ff23, $ff23, $ff22, $ff21, $ff20, $ff1f
	dw $ff1f, $ff1e, $ff1d, $ff1d, $ff1c, $ff1b, $ff1a, $ff1a, $ff19, $ff18, $ff18, $ff17, $ff16, $ff16, $ff15, $ff15
	dw $ff14, $ff13, $ff13, $ff12, $ff12, $ff11, $ff11, $ff10, $ff0f, $ff0f, $ff0e, $ff0e, $ff0d, $ff0d, $ff0c, $ff0c
	dw $ff0c, $ff0b, $ff0b, $ff0a, $ff0a, $ff09, $ff09, $ff09, $ff08, $ff08, $ff07, $ff07, $ff07, $ff06, $ff06, $ff06
	dw $ff05, $ff05, $ff05, $ff05, $ff04, $ff04, $ff04, $ff03, $ff03, $ff03, $ff03, $ff03, $ff02, $ff02, $ff02, $ff02
	dw $ff02, $ff02, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff00
	dw $ff00, $ff00, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff01, $ff02
	dw $ff02, $ff02, $ff02, $ff02, $ff02, $ff03, $ff03, $ff03, $ff03, $ff03, $ff04, $ff04, $ff04, $ff05, $ff05, $ff05
	dw $ff05, $ff06, $ff06, $ff06, $ff07, $ff07, $ff07, $ff08, $ff08, $ff09, $ff09, $ff09, $ff0a, $ff0a, $ff0b, $ff0b
	dw $ff0c, $ff0c, $ff0c, $ff0d, $ff0d, $ff0e, $ff0e, $ff0f, $ff0f, $ff10, $ff11, $ff11, $ff12, $ff12, $ff13, $ff13
	dw $ff14, $ff15, $ff15, $ff16, $ff16, $ff17, $ff18, $ff18, $ff19, $ff1a, $ff1a, $ff1b, $ff1c, $ff1d, $ff1d, $ff1e
	dw $ff1f, $ff1f, $ff20, $ff21, $ff22, $ff23, $ff23, $ff24, $ff25, $ff26, $ff27, $ff27, $ff28, $ff29, $ff2a, $ff2b
	dw $ff2c, $ff2d, $ff2d, $ff2e, $ff2f, $ff30, $ff31, $ff32, $ff33, $ff34, $ff35, $ff36, $ff37, $ff38, $ff39, $ff3a
	dw $ff3b, $ff3c, $ff3d, $ff3e, $ff3f, $ff40, $ff41, $ff42, $ff43, $ff44, $ff45, $ff46, $ff47, $ff48, $ff49, $ff4a
	dw $ff4b, $ff4d, $ff4e, $ff4f, $ff50, $ff51, $ff52, $ff53, $ff55, $ff56, $ff57, $ff58, $ff59, $ff5a, $ff5c, $ff5d
	dw $ff5e, $ff5f, $ff61, $ff62, $ff63, $ff64, $ff65, $ff67, $ff68, $ff69, $ff6b, $ff6c, $ff6d, $ff6e, $ff70, $ff71
	dw $ff72, $ff74, $ff75, $ff76, $ff78, $ff79, $ff7a, $ff7c, $ff7d, $ff7e, $ff80, $ff81, $ff82, $ff84, $ff85, $ff86
	dw $ff88, $ff89, $ff8b, $ff8c, $ff8d, $ff8f, $ff90, $ff92, $ff93, $ff94, $ff96, $ff97, $ff99, $ff9a, $ff9c, $ff9d
	dw $ff9f, $ffa0, $ffa1, $ffa3, $ffa4, $ffa6, $ffa7, $ffa9, $ffaa, $ffac, $ffad, $ffaf, $ffb0, $ffb2, $ffb3, $ffb5
	dw $ffb6, $ffb8, $ffb9, $ffbb, $ffbc, $ffbe, $ffbf, $ffc1, $ffc2, $ffc4, $ffc5, $ffc7, $ffc8, $ffca, $ffcb, $ffcd
	dw $ffcf, $ffd0, $ffd2, $ffd3, $ffd5, $ffd6, $ffd8, $ffd9, $ffdb, $ffdc, $ffde, $ffe0, $ffe1, $ffe3, $ffe4, $ffe6
	dw $ffe7, $ffe9, $ffeb, $ffec, $ffee, $ffef, $fff1, $fff2, $fff4, $fff6, $fff7, $fff9, $fffa, $fffc, $fffd, $ffff
	dw $0000, $0001, $0003, $0004, $0006, $0007, $0009, $000a, $000c, $000e, $000f, $0011, $0012, $0014, $0015, $0017
	dw $0019, $001a, $001c, $001d, $001f, $0020, $0022, $0024, $0025, $0027, $0028, $002a, $002b, $002d, $002e, $0030
	dw $0031, $0033, $0035, $0036, $0038, $0039, $003b, $003c, $003e, $003f, $0041, $0042, $0044, $0045, $0047, $0048
	dw $004a, $004b, $004d, $004e, $0050, $0051, $0053, $0054, $0056, $0057, $0059, $005a, $005c, $005d, $005f, $0060
	dw $0061, $0063, $0064, $0066, $0067, $0069, $006a, $006c, $006d, $006e, $0070, $0071, $0073, $0074, $0075, $0077
	dw $0078, $007a, $007b, $007c, $007e, $007f, $0080, $0082, $0083, $0084, $0086, $0087, $0088, $008a, $008b, $008c
	dw $008e, $008f, $0090, $0092, $0093, $0094, $0095, $0097, $0098, $0099, $009b, $009c, $009d, $009e, $009f, $00a1
	dw $00a2, $00a3, $00a4, $00a6, $00a7, $00a8, $00a9, $00aa, $00ab, $00ad, $00ae, $00af, $00b0, $00b1, $00b2, $00b3
	dw $00b5, $00b6, $00b7, $00b8, $00b9, $00ba, $00bb, $00bc, $00bd, $00be, $00bf, $00c0, $00c1, $00c2, $00c3, $00c4
	dw $00c5, $00c6, $00c7, $00c8, $00c9, $00ca, $00cb, $00cc, $00cd, $00ce, $00cf, $00d0, $00d1, $00d2, $00d3, $00d3
	dw $00d4, $00d5, $00d6, $00d7, $00d8, $00d9, $00d9, $00da, $00db, $00dc, $00dd, $00dd, $00de, $00df, $00e0, $00e1
	dw $00e1, $00e2, $00e3, $00e3, $00e4, $00e5, $00e6, $00e6, $00e7, $00e8, $00e8, $00e9, $00ea, $00ea, $00eb, $00eb
	dw $00ec, $00ed, $00ed, $00ee, $00ee, $00ef, $00ef, $00f0, $00f1, $00f1, $00f2, $00f2, $00f3, $00f3, $00f4, $00f4
	dw $00f4, $00f5, $00f5, $00f6, $00f6, $00f7, $00f7, $00f7, $00f8, $00f8, $00f9, $00f9, $00f9, $00fa, $00fa, $00fa
	dw $00fb, $00fb, $00fb, $00fb, $00fc, $00fc, $00fc, $00fd, $00fd, $00fd, $00fd, $00fd, $00fe, $00fe, $00fe, $00fe
	dw $00fe, $00fe, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $00ff, $0100
.end:
%set_free_finish("bank7", sine_table_end)
