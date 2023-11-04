/// detect magic bytes of a PNG file
function png_detector(buf) {
	// https://en.wikipedia.org/wiki/List_of_file_signatures
	static magic = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
	
	if (!magic_detector(buf, magic)) {
		return undefined;
	}
	
	return default_image_parser;
}