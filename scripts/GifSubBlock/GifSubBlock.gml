
/// Singular GIF sub-block
/// @param {Real} offset Where in the file the sub-block begins.
/// @param {Real} size How large the sub-block is.
function GifSubBlock(offset, size) constructor {
	self.offset = offset;
	self.size = size;
	
	toString = function() {
		return $"{instanceof(self)}(offset={offset}, size={size})";
	}
}