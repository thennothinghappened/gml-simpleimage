/// detect ✨magic✨
/// @param {Id.Buffer} buf
/// @param {Array<real|undefined>} magic
/// @returns {bool}
function magic_detector(buf, magic) {
	
	for (var i = 0; i < array_length(magic); i ++) {
		var byte = buffer_read(buf, buffer_u8);
		
		if (byte != magic[i] && magic[i] != undefined) {
			return false;
		}
	}
	
	return true;
}