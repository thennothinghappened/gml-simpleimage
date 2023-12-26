//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
// parser based on documentation at https://giflib.sourceforge.net/whatsinagif/bits_and_bytes.html, //
// and YAL's sprite_add_gif (https://github.com/YAL-GameMaker/sprite_add_gif), thanks!              //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////

/// Parser for a GIF file
function GifParser() : ImageParser() constructor {
	
	/// Attempt to parse the given buffer as a GIF.
	/// 
	/// Returns whether the image can be parsed as a GIF.
	/// 
	/// @param {Id.Buffer} b Input image buffer to parse
	parse = function(b) {
		return {
			result: ImageLoadResult.NotImplementedError
		};
	}
	
	/// Attempt to load the full image from the given buffer as a GIF.
	/// 
	/// Returns an Image instance if successful.
	/// 
	/// @param {Id.Buffer} b
	/// @param {Struct.GifImageData} image_data Data from initial parsing the image.
	load = function(b, image_data) {
		return {
			result: ImageLoadResult.NotImplementedError
		};
	}
	
	/// Attempt to save the image as a GIF.
	/// 
	/// Returns a buffer containing the image.
	/// 
	/// @param {Struct.Image} image Image to save.
	save = function(image) {
		return {
			result: ImageSaveResult.NotImplementedError
		};
	}

}