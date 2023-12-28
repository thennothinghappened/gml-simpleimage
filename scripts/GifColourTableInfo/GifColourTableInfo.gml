
/// Information about a Colour Table for a GIF file.
/// @param {Bool} is_sorted Whether the colour table is sorted in order of decreasing importance.
/// @param {Real} size Size in entries of the colour table.
/// @param {Real} table_offset Where the table starts in the GIF file.
function GifColourTableInfo(
	is_sorted,
	size,
	table_offset
) constructor {
	
	static colour_bytesize = __U8_SIZE * 3;
	
	self.is_sorted = is_sorted;
	self.size = size;
	self.table_offset = table_offset;
	
	/// Returns the size in bytes of the associated colour table,
	/// which is equal to the number of entries as u8 * (r+g+b)
	get_bytesize = function() {
		return size * colour_bytesize;
	}
}

/// Information about the Global Colour Table for a GIF file.
/// @param {Bool} is_sorted Whether the colour table is sorted in order of decreasing importance.
/// @param {Real} size Size in entries of the GCT.
/// @param {Real} table_offset Where the table starts in the GIF file.
/// @param {Real} background_colour_index Index in the table of the global background colour.
/// @param {Real} src_image_colour_resolution Bit depth of the image before it was converted to a GIF (?) (seems mostly unused)
function GifGlobalColourTableInfo(
	is_sorted,
	size,
	table_offset,
	background_colour_index,
	src_image_colour_resolution
) : GifColourTableInfo(is_sorted, size, table_offset) constructor {
	self.background_colour_index = background_colour_index;
	self.src_image_colour_resolution = src_image_colour_resolution;
}