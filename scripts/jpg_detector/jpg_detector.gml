/// detect magic bytes of a JPG file
function jpg_detector(buf) {
	// https://en.wikipedia.org/wiki/List_of_file_signatures
	static magics = [
		[0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01],
		[0xFF, 0xD8, 0xFF, 0xEE],
		[0xFF, 0xD8, 0xFF, 0xE1, undefined, undefined, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00],
		[0xFF, 0xD8, 0xFF, 0xE0],
		[0x00, 0x00, 0x00, 0x0C, 0x6A, 0x50, 0x20, 0x20, 0x0D, 0x0A, 0x87, 0x0A]
	];
	
	static magics_num = array_length(magics);
	
	return magic_list_detector(magics, magics_num, buf);
}