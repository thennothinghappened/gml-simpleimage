//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                  //
// parser based on documentation at https://giflib.sourceforge.net/whatsinagif/bits_and_bytes.html, //
// and YAL's sprite_add_gif (https://github.com/YAL-GameMaker/sprite_add_gif), thanks!              //
//                                                                                                  //
//////////////////////////////////////////////////////////////////////////////////////////////////////

/// Parser for a GIF file
function GifParser() : ImageParser() constructor {
	
	static magic = [ord("G"), ord("I"), ord("F")];
	static gif_version_length = __U8_SIZE * 3;
	static gif_versions = {
		"version89a": GifVersion.Version89A,
		"version87a": GifVersion.Version87A
	};
	
	/// Attempt to parse the given buffer as a GIF.
	/// 
	/// Returns whether the image can be parsed as a GIF.
	/// 
	/// @param {Id.Buffer} b Input image buffer to parse
	parse = function(b) {
		
		const header_res = parse_header(b);
		
		if (header_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to read GIF header", header_res.err)
			};
		}
		
		const header = header_res.data;
		
		const lsd_res = parse_lsd(b);
		
		if (lsd_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to read GIF Logical Screen Descriptor", lsd_res.err)
			};
		}
		
		const lsd = lsd_res.data;
		
		show_message($"header: {header}, lsd: {lsd}");
		
		return {
			result: ImageLoadResult.NotImplementedError,
			err: new Err("Parsing not yet implemented for GIFs")
		};
	}
	
	/// Attempt to load the full image from the given buffer as a GIF.
	/// 
	/// Returns an Image instance if successful.
	/// 
	/// @param {Id.Buffer} b
	/// @param {Struct.GifImageData} image_data Data from initial parsing the image.
	load = function(b, image_data) {
		return {
			result: ImageLoadResult.NotImplementedError,
			err: new Err("Loading not yet implemented for GIFs")
		};
	}
	
	/// Attempt to save the image as a GIF.
	/// 
	/// Returns a buffer containing the image.
	/// 
	/// @param {Struct.Image} image Image to save.
	save = function(image) {
		return {
			result: ImageSaveResult.NotImplementedError,
			err: new Err("Saving not yet implemented for GIFs")
		};
	}
	
	/// Parse the GIF file header.
	/// @param {Id.Buffer} b
	parse_header = function(b) {
		
		const magic_res = simpleimage_validate_magic(b, magic);
		
		if (magic_res.result != MagicValidationResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Magic validation failed", magic_res.err)
			};
		}
		
		const version_res = simpleimage_buffer_read_u8_array(b, gif_version_length);
		
		if (version_res.result != BufferReadResult.Success) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err("Failed to read GIF version", version_res.err)
			};
		}
		
		const version_chars = array_map(version_res.data, chr);
		const version_str = string_join_ext("", version_chars);
		const version = gif_versions[$ $"version{version_str}"];
		
		if (version == undefined) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err($"Invalid GIF version {version_str}")
			};
		}
		
		return {
			result: ImageLoadResult.Success,
			data: new GifHeader(version)
		};
	}
	
	/// Parse the GIF file Logical Screen Descriptor
	/// @param {Id.Buffer} b
	parse_lsd = function(b) {
		
		try {
			
			const width					= buffer_read(b, buffer_u16);
			const height				= buffer_read(b, buffer_u16);
			
			const packed_byte			= buffer_read(b, buffer_u8);
			const gct_enabled			= bool(     (packed_byte & 0b10000000) >> 7);
			const gct_bits_per_pixel	= (         (packed_byte & 0b01110000) >> 4) + 1;
			const gct_is_sorted			= bool(     (packed_byte & 0b00001000) >> 3);
			const gct_size				= power(2, ((packed_byte & 0b00000111) >> 0) + 1);
			const gct_bgcol_index		= buffer_read(b, buffer_u8);
			
			// TODO: use?
			const pixel_aspect_ratio	= (buffer_read(b, buffer_u8) + 15) / 64;
			
			const gct_info = (gct_enabled) ? new GifGlobalColourTableInfo(
				gct_bits_per_pixel,
				gct_is_sorted,
				gct_size,
				gct_bgcol_index
			) : undefined
			
			return {
				result: ImageParseResult.Success,
				data: new GifLSD(
					 width,
					 height,
					 gct_info,
					 pixel_aspect_ratio
				)
			};
		
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err("Failed to read GIF logical screen descriptor", err_cause)
			};
		}
		
	}

}

/// Valid GIF file versions
enum GifVersion {
	Version89A,
	Version87A
}