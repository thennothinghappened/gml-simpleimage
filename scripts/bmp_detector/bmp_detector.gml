/// detect magic bytes of a BMP file
function bmp_detector(buf) {
	// https://en.wikipedia.org/wiki/List_of_file_signatures
	static magic = [0x42, 0x4D];
	
	if (!magic_detector(buf, magic)) {
		return ImageLoadResult.InvalidImage;
	}
	
	return ImageLoadResult.Success;
}