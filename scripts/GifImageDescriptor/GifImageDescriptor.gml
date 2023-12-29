
/// Image Descriptor of a GIF
/// @param {Real} offset Where in the file the block begins.
/// @param {Real} left Left offset of the following image.
/// @param {Real} top Top offset of the following image.
/// @param {Real} width Width of the following image.
/// @param {Real} height Height of the following image.
/// @param {Bool} interlaced Whether the image is interlaced.
/// @param {Struct.GifColourTableInfo?} [ct_info] Information about the accompanying colour table if present.
/// @param {Real|undefined} [reserved] Reserved for future use (it wasn't used).
function GifImageDescriptor(
	offset,
	left,
	top,
	width,
	height,
	interlaced,
	ct_info = undefined,
	reserved = undefined
) : GifBlock(GifBlockType.ImageDescriptor, offset) constructor {
	self.left = left;
	self.top = top;
	self.width = width;
	self.height = height;
	self.interlaced = interlaced;
	self.ct_info = ct_info;
	self.reserved = reserved;
	
	toString = function() {
		return $"GifImageDescriptor(offset={offset}, left={left}, top={top}, width={width}, height={height}, interlaced={interlaced}, ct_info={ct_info}, reserved={reserved})";
	}
}