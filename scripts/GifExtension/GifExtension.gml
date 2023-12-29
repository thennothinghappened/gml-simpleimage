
/// Types of GIF extensions.
enum GifExtensionType {
	/// Seemingly unused extension to display text over the GIF.
	PlainTextExtension		= 0x01,
	/// Graphic control extension specifies settings for animations & display.
	GraphicsControlExtension= 0xF9,
	/// Comment extension allows readable embedding text inside the GIF file.
	CommentExtension		= 0xFE,
	/// Custom application extension.
	ApplicationExtension	= 0xFF,
}

/// Abstract class for a GIF extension block
/// @param {Enum.GifExtensionType} extension_type Type of this extension
/// @param {Real} offset Where in the file the block begins.
function GifExtension(extension_type, offset) : GifBlock(GifBlockType.Extension, offset) constructor {
	self.extension_type = extension_type;
	
	toString = function() {
		return $"GifExtension(offset={offset}, extension_type={extension_type})";
	}
}