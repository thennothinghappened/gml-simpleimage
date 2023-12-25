/// Abstract class for data related to an image, including which parser created it.
/// @param {Struct.ImageParser} parser The parser that created this image
function ImageData(parser) constructor {
	self.parser = parser;
}