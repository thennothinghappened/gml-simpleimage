/// load an image using the default GM loading method (sprite_add)
/// @param {Struct.File} data
function default_image_parser(data) {
	try {
		var img = sprite_add(data.fpath, 1, false, false, 0, 0);
		
		if (!sprite_exists(img)) {
			throw "Failed to load sprite";
		}
		
		return {
			status: ImageParseResult.Success,
			img: img
		};
		
	} catch (err) {
		
		return {
			status: ImageParseResult.ParseFailedError,
			err: err
		};
	}
}