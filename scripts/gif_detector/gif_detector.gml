/// detect magic bytes of a GIF file
function gif_detector(buf) {
	// https://en.wikipedia.org/wiki/List_of_file_signatures
	
	static G = ord("G");
	static I = ord("I");
	static F = ord("F");
	
	static magics = [
		[G, I, F, 0x38, 0x37, 0x61],
		[G, I, F, 0x38, 0x39, 0x61]
	];
	
	static magics_num = array_length(magics);
	
	return magic_list_detector(magics, magics_num, buf);
}