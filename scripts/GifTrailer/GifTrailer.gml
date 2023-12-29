
/// End of a GIF file!
/// @param {Real} offset Where in the file the block begins.
function GifTrailer(offset) : GifBlock(GifBlockType.Trailer, offset) constructor {
	toString = function() {
		return $"GIF end-of-file trailer block (at {offset})";
	}
}