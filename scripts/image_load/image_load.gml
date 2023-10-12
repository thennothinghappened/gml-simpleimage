enum ImageLoadResult {
	Loaded,
	InvalidImage
}

/// Safe wrapper for sprite_add
/// @param {string} url
/// @returns { Struct { result: ImageLoadResult, img: Asset.GMSprite } }
function image_load(url) {
	try {
		var img = sprite_add(url, 1, false, false, 0, 0);
		if (!sprite_exists(img)) {
			throw "Failed to load sprite";
		}
		
		return { result: ImageLoadResult.Loaded, img: img };
	} catch (e) {
		return { result: ImageLoadResult.InvalidImage };
	}
}