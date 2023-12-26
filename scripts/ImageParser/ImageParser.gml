
enum ImageLoadResult {
	Success,
	BufferReadError,
	InvalidContentError,
	NotImplementedError,
	BufferCreationError,
	SpriteCreationError
}

enum ImageSaveResult {
	Success,
	GetSurfaceError,
	TooLargeError,
	EncodeError,
	NotImplementedError
}

/// Abstract class of something that can load and save images.
function ImageParser() constructor {
	
	/// Attempt to parse the given buffer as this image type.
	/// 
	/// Returns whether the image can be parsed as this type.
	/// 
	/// @param {Id.Buffer} b Input image buffer to parse
	parse = function(b) {
		return {
			result: ImageLoadResult.NotImplementedError
		};
	}
	
	/// Attempt to load the full image from the given buffer as this image type.
	/// 
	/// Returns an Image instance if successful.
	/// 
	/// @param {Id.Buffer} b
	load = function(b) {
		return {
			result: ImageLoadResult.NotImplementedError
		};
	}
	
	/// Attempt to save the image as this given image type.
	/// 
	/// Returns a buffer containing the image.
	/// 
	/// @param {Struct.Image} image Image to save.
	/// @param {Struct} params Parameters for how the image should be saved. Unique per image type.
	save = function(image, params) {
		return {
			result: ImageSaveResult.NotImplementedError
		};
	}
	
}