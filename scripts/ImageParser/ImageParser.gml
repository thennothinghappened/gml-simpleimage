
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
			result: ImageLoadResult.NotImplementedError,
			err: new Err("Parsing not implemented for this image type")
		};
	}
	
	/// Attempt to load the full image from the given buffer as this image type.
	/// 
	/// Returns an Image instance if successful.
	/// 
	/// @param {Id.Buffer} b The buffer to read the image from.
	/// @param {Struct.ImageData} image_data Data from initial parsing the image.
	load = function(b, image_data) {
		return {
			result: ImageLoadResult.NotImplementedError,
			err: new Err("Loading not implemented for this image type")
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
			result: ImageSaveResult.NotImplementedError,
			err: new Err("Saving not implemented for this image type")
		};
	}
	
}