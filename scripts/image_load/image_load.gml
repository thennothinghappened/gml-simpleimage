/// How many bytes we'll reserve at least to read magic of a file
#macro PARSER_MAGIC_RESERVED 16

enum ImageLoadResult {
	Success,
	InvalidImage,
	Unsupported,
	ParseFailed,
	FileReadFailed
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
function image_url_find_parser(url) {
	var buf = buffer_create(PARSER_MAGIC_RESERVED, buffer_fixed, 1);
			
	try {
		
		buffer_load_partial(buf, url, 0, PARSER_MAGIC_RESERVED, 0);
		
	} catch (err) {
		
		buffer_delete(buf);
		
		return {
			status: ImageLoadResult.FileReadFailed,
			err: "Failed to load the file buffer to read magic!"
		};
	}
	
	var res = image_find_parser(buf);
	buffer_delete(buf);
	
	return res;
}

/// find a suitable parser for a given image buffer
/// @param {Id.Buffer} buf
function image_find_parser(buf) {
	var parser = undefined;
	
	for (var i = 0; i < array_length(global.image_detectors); i ++) {
		var detector = global.image_detectors[i];
		
		if (detector == undefined) {
			continue;
		}
		
		var res = detector(buf);
		
		if (res != ImageLoadResult.Success) {
			buffer_seek(buf, buffer_seek_start, 0);
			continue;
		}
		
		return {
			status: ImageLoadResult.Success,
			parser: global.image_parsers[i]
		};
	}
	
	return {
		status: ImageLoadResult.Unsupported,
		err: "Found no suitable parser for this filetype"
	};
}

/// Safe wrapper to add any given supported image!
/// @param {string} url
/// @returns { Struct { status: ImageLoadResult, img?: Asset.GMSprite } }
function image_load(url) {
	
	var data = new ImageParseData(url);
	if (!buffer_exists(data.buf)) {
		return {
			status: ImageLoadResult.FileReadFailed,
			err: "Failed to load the file buffer!"
		};
	}
	
	var parser_res = image_find_parser(data.buf);
	
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