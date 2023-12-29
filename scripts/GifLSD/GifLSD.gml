
/// Logical Screen Descriptor of a GIF
/// @param {Real} offset Where in the file the LSD appears (should ALWAYS be __U8_SIZE * [G,I,F,8,9,a] = 6)
/// @param {Real} width Width of the image canvas.
/// @param {Real} height Height of the image canvas.
/// @param {Struct.GifGlobalColourTableInfo?} gct_info Information about the global colour table if present.
/// @param {Real} pixel_aspect_ratio TODO!
function GifLSD(
	offset,
	width,
	height,
	gct_info,
	pixel_aspect_ratio
) : GifBlock(GifBlockType.LSD, offset) constructor {
	self.width = width;
	self.height = height;
	self.gct_info = gct_info
	self.pixel_aspect_ratio = pixel_aspect_ratio;
	
	toString = function() {
		return $"GifLSD(width={width}, height={height}, gct_info={gct_info}, pixel_aspect_ratio={pixel_aspect_ratio})";
	}
}