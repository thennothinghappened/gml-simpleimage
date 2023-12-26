
/// Parameters for saving a BMP file.
/// @param {Real} [bits_per_pixel] How many bits each pixel takes up
/// @param {Enum.BmpCompressionMethod} [compression] Type of compression used on the image
function BmpSaveParams(
	bits_per_pixel = 24,
	compression = BmpCompressionMethod.RGB,
) constructor {
	self.bits_per_pixel = bits_per_pixel;
	self.compression = compression;
}