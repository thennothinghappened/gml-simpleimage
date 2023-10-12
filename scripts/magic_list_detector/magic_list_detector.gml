/// detect magic from a list of magic bytes
/// @param {array<array<real>>} magics
/// @param {real} num_magics
/// @param {Id.Buffer} buf
/// @returns {ImageLoadResult}
function magic_list_detector(magics, num_magics, buf) {
	
	for (var i = 0; i < num_magics; i ++) {
		buffer_seek(buf, buffer_seek_start, 0);
		
		var magic = magics[i];
		
		if (magic_detector(buf, magic)) {
			return ImageLoadResult.Success;
		}
		
	}
	
	return ImageLoadResult.InvalidImage;
}