//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
// parser based on the documentation at https://paulbourke.net/dataformats/bmp, thanks! //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

/// load an image as a BMP
/// @param {Struct.File} data
function bmp_parser(data) {
	var b = data.buf;
	
	buffer_seek(b, buffer_seek_start, 0);
	
	// HEADER //
	var h_type			= buffer_read(b, buffer_u16);
	var h_size			= buffer_read(b, buffer_u32);
	var h__reserved1	= buffer_read(b, buffer_u16);
	var h__reserved2	= buffer_read(b, buffer_u16);
	var h_offset		= buffer_read(b, buffer_u32);
	
	// INFOHEADER //
	var ih_size			= buffer_read(b, buffer_u32);
	var ih_width		= buffer_read(b, buffer_s32);
	var ih_height		= buffer_read(b, buffer_s32);
	var ih_planes		= buffer_read(b, buffer_u16);
	var ih_bits			= buffer_read(b, buffer_u16);
	var ih_compression	= buffer_read(b, buffer_u32);
	var ih_imagesize	= buffer_read(b, buffer_u32);
	var ih_xresolution	= buffer_read(b, buffer_s32);
	var ih_yresolution	= buffer_read(b, buffer_s32);
	var ih_ncolours		= buffer_read(b, buffer_u32);
	var ih_impcolours	= buffer_read(b, buffer_u32);
	
	if (ih_compression != 0) {
		return {
			status: ImageParseResult.UnsupportedError,
			err: "BMP Compression not implemented!"
		};
	}
	
	if (ih_bits != 24) {
		return {
			status: ImageParseResult.UnsupportedError,
			err: $"BMP bits {ih_bits} not implemented!"
		};
	}
	
	var outbuf = buffer_create(ih_width * ih_height * 4, buffer_fixed, 1);
	var surf = surface_create(ih_width, ih_height, surface_rgba8unorm);
	
	try {
		
		buffer_seek(b, buffer_seek_start, h_offset);
		
		while (buffer_tell(b) < h_size) {
			var blue	= buffer_read(b, buffer_u8);
			var green	= buffer_read(b, buffer_u8);
			var red		= buffer_read(b, buffer_u8);
			
			buffer_write(outbuf, buffer_u8, red);
			buffer_write(outbuf, buffer_u8, green);
			buffer_write(outbuf, buffer_u8, blue);
			buffer_write(outbuf, buffer_u8, 0xFF);
		}
		
		// flip the image in a lazy way bc im lazy!
		var tempsurf = surface_create(ih_width, ih_height, surface_rgba8unorm);
		buffer_set_surface(outbuf, tempsurf, 0);
		surface_set_target(surf);
		
		draw_surface_ext(tempsurf, 0, ih_height, 1, -1, 0, c_white, 1);
		
		surface_reset_target();
		surface_free(tempsurf);
	
	} finally {
		buffer_delete(outbuf);
	}
	
	var spr = sprite_create_from_surface(surf, 0, 0, ih_width, ih_height, false, false, 0, 0);
	surface_free(surf);
	
	return {
		status: ImageParseResult.Success,
		img: spr
	};
}