
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