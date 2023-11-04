/// A singular file, in our context, this means a file that may
/// or may not be loadable as a valid image.
/// @param {string} fpath Full path to the file's location
function File(fpath) constructor {
	
	self.fpath = fpath;
	
	/// The parser for this filetype
	self.parser = undefined;
	
	/// Whether or not this image is parseable. The status here is an ImageParseResult, or undefined if not yet checked.
	self.parseable = undefined;
	
	/// Loaded buffer for this file
	self.buf = undefined;
	
	/// Async handle for this buffer load.
	self.buf_load_handle = undefined;
	
	/// Loaded sprite for this file (if parseable)
	self.spr = undefined;
	
	/// MUST be called before disposing of this file, or just clearing out its memory for switching.
	cleanup = function() {
		if (has_buffer()) {
			buffer_delete(self.buf);
		}
		
		if (has_sprite()) {
			sprite_delete(self.spr);
		}
	}
	
	/// Create the buffer for this file
	create_buffer = function() {
		assert(!has_buffer(), $"Tried to create a new buffer on file {self.fpath} that already exists");
		self.buf = buffer_create(BUFFER_ASYNC_DEF_SIZE, buffer_grow, 1);
	}
	
	has_buffer = function() {
		return buffer_exists(self.buf);
	}
	
	has_sprite = function() {
		return sprite_exists(self.spr);
	}
	
	/// Find the parser for this file. Requires buffer to be loaded.
	find_parser = function() {
		
		assert(has_buffer(), $"Tried to find parser for file {self.fpath} without existing buffer");
		
		var parser;
		
		for (var i = 0; i < global.__type_detectors_count__; i ++) {
			var detector = global.__type_detectors__[i];
			
			parser = detector(self.buf);
			
			if (parser == undefined) {
				continue;
			}
			
			break;
		}
		
		if (parser == undefined) {
			self.parseable = ImageParseResult.UnsupportedError;
			
			return { status: ImageParseResult.UnsupportedError };
		}
		
		self.parseable = ImageParseResult.Success;
		self.parser = parser;
		
		return {
			status: ImageParseResult.Success,
			parser: parser
		};
	}
}