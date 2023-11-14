//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
// parser based on documentation at https://giflib.sourceforge.net/whatsinagif/bits_and_bytes.html, //
// and YAL's sprite_add_gif (https://github.com/YAL-GameMaker/sprite_add_gif), thanks!              //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////

/// load an image as a GIF
/// @param {Struct.File} data
function gif_parser(data) {
	var b = data.buf;
	
	buffer_seek(b, buffer_seek_start, 0);
	
	var header_res = gif_parse_header(b);
	var header;
	
	if (header_res.status != ImageParseResult.Success) {
		return header_res;
	}
	
	header = header_res.header;
	
	if (header.version != "89a") {
		return {
			status: ImageParseResult.UnsupportedError,
			err: $"GIF version {header.version} is not currently supported"
		};
	}
	
	var lsd_res = gif_parse_logical_screen_descriptor(b);
	var lsd;
	
	if (lsd_res.status != ImageParseResult.Success) {
		return lsd_res;
	}
	
	lsd = lsd_res.lsd;
	
	var gct = undefined;
	
	if (lsd.gct_enabled) {
		var gct_res = gif_parse_colour_table(b, lsd.gct_entries);
		
		if (gct_res.status != ImageParseResult.Success) {
			return gct_res;
		}
		
		gct = gct_res.col_table;
	}
	
	
	
	return {
		status: ImageParseResult.ParseFailedError,
		err: "GIF support isn't finished yet!"
	};
}

/// parse a gif file's header
function gif_parse_header(b) {
	
	try {
	
		var h_G				= buffer_read(b, buffer_u8);
		var h_I				= buffer_read(b, buffer_u8);
		var h_F				= buffer_read(b, buffer_u8);
	
		var version = "";
	
		version				+= chr(buffer_read(b, buffer_u8));
		version				+= chr(buffer_read(b, buffer_u8));
		version				+= chr(buffer_read(b, buffer_u8));
		
		return {
			status: ImageParseResult.Success,
			header: {
				version: version
			}
		};
	
	} catch (err) {
		return {
			status: ImageParseResult.ParseFailedError,
			err: err
		};
	}
}

/// parse a gif's Logical Screen Descriptor
function gif_parse_logical_screen_descriptor(b) {
	
	try {
	
		var lsd_width		= buffer_read(b, buffer_u16);
		var lsd_height		= buffer_read(b, buffer_u16);
	
		var lsd_packed		= buffer_read(b, buffer_u8);
	
		var lsd_gct_enabled	= (lsd_packed & 0b10000000) >> 7;
		var lsd_colres		= (lsd_packed & 0b01110000) >> 4;
		var lsd_sortflag	= (lsd_packed & 0b00001000) >> 3;
		var lsd_gct_size_fmt= (lsd_packed & 0b00000111) >> 0;
	
		var lsd_bgcol		= buffer_read(b, buffer_u8);
		var lsd_aspectratio	= buffer_read(b, buffer_u8);
	
		return {
			status: ImageParseResult.Success,
			lsd: {
				width:							lsd_width,
				height:							lsd_height,
				gct_enabled:					bool(lsd_gct_enabled),
				gct_entries:					power(2, lsd_colres + 1),
				__gct_size_fmt:					lsd_gct_size_fmt,
				__colour_sort_flag:				bool(lsd_sortflag),
				__background_colour_index:		lsd_bgcol,
				__pixel_aspect_ratio:			(lsd_aspectratio + 15) / 64
			}
		};
	
	} catch (err) {
		return {
			status: ImageParseResult.ParseFailedError,
			err: err
		};
	}
}

/// parse a gif file's Colour Table
/// @param {Id.Buffer} b
/// @param {real} entries number of entries in the table
function gif_parse_colour_table(b, entries) {
	
	var bytesize = entries * 3;
	var ct = buffer_create(bytesize, buffer_fixed, 1);
	
	try {
	
		buffer_copy(b, buffer_tell(b), bytesize, ct, 0);
		buffer_seek(b, buffer_seek_relative, bytesize);
	
	} catch (err) {
		buffer_delete(ct);
		
		return {
			status: ImageParseResult.ParseFailedError,
			err: err
		};
	}
	
	return {
		status: ImageParseResult.Success,
		col_table: ct
	};
}