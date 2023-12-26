
/// Information Header of a BMP file
/// @param {Real} header_size Size in bytes of the infoheader
/// @param {Real} width Width of the image in pixels
/// @param {Real} height Height of the image in pixels
/// @param {Real} colour_planes Number of colour planes (always 1 for this filetype!)
/// @param {Real} bits_per_pixel How many bits each pixel takes up
/// @param {Enum.BmpCompressionMethod} compression Type of compression used on the image
/// @param {Real} image_bytesize Image size in bytes
/// @param {Real} ppm_w Width in Pixels Per Meter
/// @param {Real} ppm_h Height in Pixels Per Meter
/// @param {Real} num_colours Number of colours in the image
/// @param {Real} important_colours Number of "important colours"
function BmpInfoHeader(
	header_size,
	width,
	height,
	colour_planes,
	bits_per_pixel,
	compression,
	image_bytesize,
	ppm_w,
	ppm_h,
	num_colours,
	important_colours
) constructor {
	self.header_size = header_size;
	self.width = width;
	self.height = height;
	self.colour_planes = colour_planes;
	self.bits_per_pixel = bits_per_pixel;
	self.compression = compression;
	self.image_bytesize = image_bytesize;
	self.ppm_w = ppm_w;
	self.ppm_h = ppm_h;
	self.num_colours = num_colours;
	self.important_colours = important_colours;
}