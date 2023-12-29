
/// Types of blocks in a GIF file.
enum GifBlockType {
	/// GIF file header (cannot occur as a normal block, appears once at the start of a file.)
	Header				= -1,
	/// GIF logical screen descriptor (cannot occur as a normal block, appears once after the Header.)
	LSD					= -2,
	/// GIF global colour table (cannot occur as a normal block, appears once after the LSD if enabled.)
	GlobalColourTable	= -3,
	/// GIF colour data (cannot occur as a normal block, appears after an ImageDescriptor.)
	ImageData			= -4,
	/// GIF extension
	Extension			= 0x21,
	/// GIF image descriptor (provides data for the next image frame)
	ImageDescriptor		= 0x2C,
	/// GIF trailer (end of file)
	Trailer				= 0x3B
}

/// Abstract class for a GIF block
/// @param {Enum.GifBlockType} type Type of this block
/// @param {Real} offset Where in the file the block begins.
function GifBlock(type, offset) constructor {
	self.type = type;
	self.offset = offset;
	
	toString = function() {
		return $"GifBlock(type={type}, offset={offset})";
	}
}