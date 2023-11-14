/// Types for using arrays indicies for [x, y]
#macro X 0
#macro Y 1

/// Max size to read from a buffer (1 GB)
#macro BUFFER_ASYNC_MAX_SIZE 1073741824

/// Default size for the grow buffer to load into
#macro BUFFER_ASYNC_DEF_SIZE 1024

/// How many bytes we'll reserve at least to read magic of a file
#macro PARSER_MAGIC_RESERVED 16

/// OS's version of slashes, because Windows :)
global.__SLASH__ = "/";
#macro SLASH global.__SLASH__

if (os_type == os_windows) {
	global.__SLASH__ = @'\';
}

/// Result type for loading a file
enum FileLoadResult {
	Loaded,				/// The file loaded successfully
	NonExistentError,	/// The file doesn't exist
	ReadFailedError		/// Failed to read the file buffer into memory (e.g. permissions error)
}

/// Result type for parsing an image
enum ImageParseResult {
	Success,			/// Parse successful
	InvalidError,		/// The image is not valid for the filetype
	UnsupportedError,	/// The image format is not currently supported
	ParseFailedError	/// An error occurred in the parser trying to parse the image
}

#region Mouse

enum MouseButtons {
	Left,
	Middle,
	Right
}

enum ClickState {
	None,
	Pressed,
	Held,
	Released
}

#endregion

#region Type detection

// Note: these are run through in the order seen here, so attention paid
// to ordering by most commonly expected file format.
// 
// Could potentially speed up by using file extension as a first pick, but
// whether performance gain there is anything special is probably not.
global.__type_detectors__ = [
	png_detector,
	jpg_detector,
	gif_detector,
	bmp_detector
];

global.__type_detectors_count__ = array_length(global.__type_detectors__);

#endregion