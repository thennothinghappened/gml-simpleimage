/// detect magic bytes of a GIF file
function gif_detector(data) {
	// https://en.wikipedia.org/wiki/List_of_file_signatures
	static magics = [
		[0x47, 0x49, 0x46, 0x38, 0x37, 0x61],
		[0x47, 0x49, 0x46, 0x38, 0x39, 0x61]
	];
	
	static magics_num = array_length(magics);
	
	return magic_list_detector(magics, magics_num, data.buf);
}