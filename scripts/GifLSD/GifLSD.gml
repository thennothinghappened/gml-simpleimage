
/// Logical Screen Descriptor of a GIF
/// @param {Real} width Width of the image canvas.
/// @param {Real} height Height of the image canvas.
/// @param {Struct.GifGlobalColourTableInfo?} gct_info Information about the global colour table if present.
/// @param {Real} pixel_aspect_ratio TODO!
function GifLSD(
	width,
	height,
	gct_info,
	pixel_aspect_ratio
) constructor {
	self.width = width;
	self.height = height;
	self.gct_info = gct_info
	self.pixel_aspect_ratio = pixel_aspect_ratio;
}

/// Information about the Global Colour Table for a GIF file.
/// @param {Real} bits_per_pixel Number of bits per pixel in the GCT.
/// @param {Bool} is_sorted Whether the colour table is sorted in order of decreasing importance.
/// @param {Real} size Size in entries of the GCT.
/// @param {Real} background_colour_index Index in the table of the global background colour.
function GifGlobalColourTableInfo(
	bits_per_pixel,
	is_sorted,
	size,
	background_colour_index
) constructor {
	self.bits_per_pixel = bits_per_pixel;
	self.is_sorted = is_sorted;
	self.size = size;
}