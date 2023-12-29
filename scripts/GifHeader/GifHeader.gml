
/// Header of a GIF file
/// @param {Real} offset Where in the file the Header appears (should ALWAYS be 0)
/// @param {Enum.GifVersion} version
function GifHeader(offset, version) : GifBlock(GifBlockType.Header, offset) constructor {
	
	static versions = [];
	versions[GifVersion.Version87A] = "87a";
	versions[GifVersion.Version89A] = "89a";
	
	self.version = version;
	
	/// Get the string version of a GIF version.
	/// @param {Enum.GifVersion} version
	stringify_version = function(version) {
		static versions = ["87a", "89a"];
		return versions[version];
	}
	
	toString = function() {
		return $"GifHeader(version={stringify_version(version)})";
	}
}