enum ImageLoadResult {
	Success,
	InvalidImage,
	Unsupported
}

enum ImageFileType {
	PNG,
	JPG,
	GIF,
	BMP,
}

function ImageParseData(url) constructor {
	self.url = url;
	self.buf = buffer_load(url);
	
	cleanup = function() {
		buffer_delete(self.buf);
	}
}

/// list of detectors for given known filetypes
global.image_detectors = [];
global.image_detectors[ImageFileType.PNG] = function(data) {
	return { status: ImageLoadResult.InvalidImage };
};

/// list of parsers for given known filetypes
global.image_parsers = [];
global.image_parsers[ImageFileType.PNG] = default_image_load;
global.image_parsers[ImageFileType.JPG] = default_image_load;

/// find the image parser for a given image
function image_find_parser(data) {
	
	
}

/// load an image using the default GM loading method (sprite_add)
/// @param {Struct.ImageParseData} data
function default_image_load(data) {
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

/// Safe wrapper to add any given supported image!
/// @param {string} url
/// @returns { Struct { status: ImageLoadResult, img?: Asset.GMSprite } }
function image_load(url) {
	
	var data = new ImageParseData(url);
	var parser = undefined;
	
	for (var i = 0; i < array_length(global.image_detectors); i ++) {
		var detector = global.image_detectors[i];
		
		if (detector == undefined) {
			continue;
		}
		
		var res = detector(data);
		
		if (res.status != ImageLoadResult.Success) {
			buffer_seek(data.buf, buffer_seek_start, 0);
			continue;
		}
		
		parser = res.parser;
		break;
	}
	
	if (parser == undefined) {
		return { status: ImageLoadResult.Unsupported };
	}
	
	var res = parser(data);
	data.cleanup();
	
	if (res.status != ImageLoadResult.Success) {
		return { status: ImageLoadResult.InvalidImage };
	}
	
	return {
		status: ImageLoadResult.Success,
		img: res.img
	};
}