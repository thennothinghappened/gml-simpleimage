/// Abstract class for data related to an image, including which parser created it.
/// @param {Struct.ImageParser} parser The parser that created this image
function ImageData(parser) constructor {
	self.parser = parser;
	
	/// Convert this image data to save parameters for the filetype.
	to_save_params = function() {
		return new ImageSaveParams();
	}
}