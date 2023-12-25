/// Data relating to a BMP image.
/// @param {Struct.BmpParser} parser
/// @param {Struct.BMPHeader} header
/// @param {Struct.BMPInfoHeader} infoheader
function BmpImageData(parser, header, infoheader) : ImageData(parser) constructor {
	self.header = header;
	self.infoheader = infoheader;
	
	toString = function() {
		return $"BMP image ({infoheader.width}x{infoheader.height}, {infoheader.bits_per_pixel} bits)";
	}
}