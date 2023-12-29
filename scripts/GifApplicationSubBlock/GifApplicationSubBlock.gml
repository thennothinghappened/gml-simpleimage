
/// Singular GIF application extension sub-block
/// @param {Real} offset Where in the file the sub-block begins.
/// @param {Real} size How large the sub-block is.
/// @param {Real} sub_block_id Id of this sub-block.
function GifApplicationSubBlock(offset, size, sub_block_id) : GifSubBlock(offset, size) constructor {
	self.sub_block_id = sub_block_id;
	
	toString = function() {
		return $"{instanceof(self)}(offset={offset}, size={size}, sub_block_id={sub_block_id})";
	}
}