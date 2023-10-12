/// load an image using the default GM loading method (sprite_add)
/// @param {Struct.ImageParseData} data
function default_image_parser(data) {
	try {
		var img = sprite_add(data.url, 1, false, false, 0, 0);
		
		if (!sprite_exists(img)) {
			throw "Failed to load sprite";
		}
		
		return {
			status: ImageLoadResult.Success,
			img: img
		};
		
	} catch (e) {
		
		return {
			status: ImageLoadResult.InvalidImage,
			img: undefined
		};
	}
}