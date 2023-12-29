
/// GIF readable text Comment extension
/// @param {Real} offset Where in the file the block begins.
/// @param {String} text Plain text.
function GifCommentExtension(offset, text) : GifExtension(GifExtensionType.CommentExtension, offset) constructor {
	self.text = text;
	
	toString = function() {
		return $"GifCommentExtension(offset={offset}, text={text})";
	}
}