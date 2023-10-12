enum ImageLoadResult {
	Success,
	InvalidImage,
	Unsupported,
	ParseFailed
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
global.image_detectors[ImageFileType.PNG] = png_detector;
global.image_detectors[ImageFileType.JPG] = jpg_detector;
global.image_detectors[ImageFileType.GIF] = gif_detector;
global.image_detectors[ImageFileType.BMP] = bmp_detector;

/// list of parsers for given known filetypes
global.image_parsers = [];
global.image_parsers[ImageFileType.PNG] = default_image_parser;
global.image_parsers[ImageFileType.JPG] = default_image_parser;
global.image_parsers[ImageFileType.GIF] = gif_parser;
global.image_parsers[ImageFileType.BMP] = bmp_parser;

/// find a suitable parser for a given image url (or none)
/// @param {Struct.ImageParseData} data
function image_find_parser(data) {
	var parser = undefined;
	
	for (var i = 0; i < array_length(global.image_detectors); i ++) {
		var detector = global.image_detectors[i];
		
		if (detector == undefined) {
			continue;
		}
		
		var res = detector(data);
		
		if (res != ImageLoadResult.Success) {
			buffer_seek(data.buf, buffer_seek_start, 0);
			continue;
		}
		
		return {
			status: ImageLoadResult.Success,
			parser: global.image_parsers[i]
		};
	}
	
	return {
		status: ImageLoadResult.Unsupported
	};
}

/// Safe wrapper to add any given supported image!
/// @param {string} url
/// @returns { Struct { status: ImageLoadResult, img?: Asset.GMSprite } }
function image_load(url) {
	
	var data = new ImageParseData(url);
	var parser_res = image_find_parser(data);
	
	if (parser_res.status != ImageLoadResult.Success) {
		data.cleanup();
		return parser_res;
	}
	
	var res;
	
	try {
		res = parser_res.parser(data);
	} catch(err) {
		data.cleanup();
		
		return {
			status: ImageLoadResult.ParseFailed,
			err: err
		};
	}
	
	data.cleanup();
	
	if (res.status != ImageLoadResult.Success) {
		return res;
	}
	
	return {
		status: ImageLoadResult.Success,
		img: res.img
	};
}