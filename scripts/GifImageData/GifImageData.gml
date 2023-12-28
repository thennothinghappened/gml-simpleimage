/// Data relating to a GIF image.
/// @param {Struct.GifHeader} header
/// @param {Struct.GifLSD} lsd
/// @param {Struct.GifParser} parser
function GifImageData(header, lsd, parser) : ImageData(parser) constructor {
	self.header = header;
	self.lsd = lsd;
	
	to_save_params = function() {
		return new GifSaveParams();
	}
}