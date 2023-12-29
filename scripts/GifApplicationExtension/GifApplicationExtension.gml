
/// GIF base Application Extension
/// @param {Real} offset Where in the file the block begins.
/// @param {String} identifier Application identifier.
/// @param {String} authentication Application authentication.
function GifApplicationExtension(offset, identifier, authentication) : GifExtension(GifExtensionType.ApplicationExtension, offset) constructor {
	self.identifier = identifier;
	self.authentication = authentication;
	
	toString = function() {
		return $"{instanceof(self)}(offset={offset}, identifier={identifier}, authentication={authentication})";
	}
}