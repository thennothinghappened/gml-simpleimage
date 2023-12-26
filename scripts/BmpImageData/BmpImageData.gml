/// Data relating to a BMP image.
/// @param {Struct.BmpParser} parser
/// @param {Struct.BMPHeader} header
/// @param {Struct.BMPInfoHeader} infoheader
function BmpImageData(parser, header, infoheader) : ImageData(parser) constructor {
	
	self.header = header;
	self.infoheader = infoheader;
	
	/// Convert this to save parameters for a BMP.
	to_save_params = function() {
		return new BmpSaveParams(
			infoheader.bits_per_pixel,
			infoheader.compression
		);
	}
	
	toString = function() {
		return $"BMP image ({infoheader.width}x{infoheader.height}, {infoheader.bits_per_pixel} bits)";
	}
}