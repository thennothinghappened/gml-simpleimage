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
	
	/// List of known application extensions
	static application_extensions = {
		
	};
	
	/// Attempt to parse the given buffer as a GIF.
	/// 
	/// Returns whether the image can be parsed as a GIF.
	/// 
	/// @param {Id.Buffer} b Input image buffer to parse
	parse = function(b) {
		
		const header_res = parse_header(b, buffer_tell(b));
		
		if (header_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to read GIF header", header_res.err)
			};
		}
		
		const header = header_res.data;
		const lsd_res = parse_lsd(b, buffer_tell(b));
		
		if (lsd_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to read GIF Logical Screen Descriptor", lsd_res.err)
			};
		}
		
		const lsd = lsd_res.data;
		
		return {
			result: ImageLoadResult.Success,
			data: new GifImageData(header, lsd, self)
		};
	}
	
	/// Attempt to load the full image from the given buffer as a GIF.
	/// 
	/// Returns an Image instance if successful.
	/// 
	/// @param {Id.Buffer} b
	/// @param {Struct.GifImageData} image_data Data from initial parsing the image.
	load = function(b, image_data) {
		
		// Offset before unread data.
		static initial_offset = get_header_size() + get_lsd_size() + __U8_SIZE;
		
		const header = image_data.header;
		const lsd = image_data.lsd;
		
		// Start reading after the headers.
		var read_pos = initial_offset;
		
		if (lsd.gct_info != undefined) {
			
			// Skip over the GCT since we already know about it.
			const gct_info = lsd.gct_info;
			read_pos += gct_info.get_bytesize();
		}
		
		buffer_seek(b, buffer_seek_start, read_pos);
		
		const next_block_res = parse_gif_block(b);
		
		if (next_block_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to read GIF block", next_block_res.err)
			};
		}
		
		show_debug_message($"GIF file:\n{header}\n{lsd}\n{next_block_res.data}");
		
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
	/// @param {Real} block_start_offset Start of this block.
	parse_header = function(b, block_start_offset) {
		
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
			data: new GifHeader(block_start_offset, version)
		};
	}
	
	/// Parse the GIF file Logical Screen Descriptor
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_lsd = function(b, block_start_offset) {
		
		try {
			
			const width					= buffer_read(b, buffer_u16);
			const height				= buffer_read(b, buffer_u16);
			const packed				= buffer_read(b, buffer_u8);
			const gct_bgcol_index		= buffer_read(b, buffer_u8);
			// TODO: use?
			const pixel_aspect_ratio	= (buffer_read(b, buffer_u8) + 15) / 64;
			
			const unpacked = parse_lsd_packed_byte(packed);
			const gct_table_offset = buffer_tell(b);
			
			const gct_info = (unpacked.gct_enabled) ? new GifGlobalColourTableInfo(
				unpacked.gct_is_sorted,
				unpacked.gct_size,
				gct_table_offset,
				gct_bgcol_index,
				unpacked.gct_src_image_colour_resolution
			) : undefined;
			
			return {
				result: ImageParseResult.Success,
				data: new GifLSD(
					block_start_offset,
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
	
	/// Parse the packed byte of the Logical Screen Descriptor.
	/// @param {Real} packed
	parse_lsd_packed_byte = function(packed) {
		return {
			gct_enabled:						bool(     (packed & 0b10000000) >> 7),
			gct_src_image_colour_resolution:	(         (packed & 0b01110000) >> 4) + 1,
			gct_is_sorted:						bool(     (packed & 0b00001000) >> 3),
			gct_size:							power(2, ((packed & 0b00000111) >> 0) + 1)
		};
	}
	
	/// Returns the size of a GIF file's header.
	get_header_size = function() {
		
		static header_size =
			array_length(magic) * __U8_SIZE +		// "GIF"
			__U8_SIZE * 3;							// "89a" / "87a"
			
		return header_size;
		
	}
	
	/// Returns the size of a GIF file's Logical Screen Descriptor
	get_lsd_size = function() {
		
		static lsd_size =
			__U16_SIZE +		// width
			__U16_SIZE +		// height
			__U8_SIZE +			// packed_byte
			__U8_SIZE;			// pixel_aspect_ratio
		
		return lsd_size;
	}
	
	/// Parse the next block in the GIF file.
	/// @param {Id.Buffer} b
	parse_gif_block = function(b) {
		
		var type = -1;
		
		try {
			type = buffer_read(b, buffer_u8);
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read block type indicator at {buffer_tell(b)}", err_cause)
			};
		}
		
		const block_start_offset = buffer_tell(b);
		
		switch (type) {
			case GifBlockType.Extension: return parse_gif_extension(b, block_start_offset);
			case GifBlockType.ImageDescriptor: return parse_image_descriptor(b, block_start_offset);
			case GifBlockType.Trailer: return parse_trailer(b, block_start_offset);
		}
		
		return {
			result: ImageLoadResult.InvalidContentError,
			err: new Err($"GIF block type {type} at {block_start_offset} is invalid.")
		};
		
	}
	
	/// Parse a GIF extension.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_gif_extension = function(b, block_start_offset) {
		
		var extension_type = -1;
		
		try {
			extension_type = buffer_read(b, buffer_u8);
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read extension type indicator at {buffer_tell(b)}", err_cause)
			};
		}
		
		const ext_block_start_offset = buffer_tell(b);
		
		switch (extension_type) {
			case GifExtensionType.PlainTextExtension:		return parse_gif_extension_plain_text(b, ext_block_start_offset);
			case GifExtensionType.GraphicsControlExtension:	return parse_gif_extension_graphics_control(b, ext_block_start_offset);
			case GifExtensionType.CommentExtension:			return parse_gif_extension_comment(b, ext_block_start_offset);
			case GifExtensionType.ApplicationExtension:		return parse_gif_extension_application(b, ext_block_start_offset);
		}
		
		return {
			result: ImageLoadResult.NotImplementedError,
			err: new Err($"Unknown GIF extension type {extension_type} at {ext_block_start_offset}")
		};
	}
	
	/// Parse the Plain Text GIF extension.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_gif_extension_plain_text = function(b, block_start_offset) {
		return {
			result: ImageLoadResult.NotImplementedError,
			err: new Err("Plain-text GIF extension type not implemented")
		};
	}
	
	/// Parse the Comment GIF extension.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_gif_extension_comment = function(b, block_start_offset) {
		
		const sub_blocks_res = parse_sub_blocks(b);
		if (sub_blocks_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err($"Failed to read sub-blocks for Comment Extension at {block_start_offset}", sub_blocks_res.err)
			};
		}
		
		const sub_blocks = sub_blocks_res.data;
		
		var text = "";
		
		for (var i = 0, sub_blocks_count = array_length(sub_blocks); i < sub_blocks_count; i ++) {
			
			const sub_block = sub_blocks[i];
			
			buffer_seek(b, buffer_seek_start, sub_block.offset);
			
			const data_res = simpleimage_buffer_read_u8_array(b, __U8_SIZE * sub_block.size);
			if (data_res.result != BufferReadResult.Success) {
				return {
					result: ImageLoadResult.BufferReadError,
					err: new Err($"Failed to read comment extension data sub-block {sub_block}", data_res.err)
				};
			}
			
			text += simpleimage_stringify_u8_array(data_res.data);
			
		}
		
		return {
			result: ImageLoadResult.Success,
			data: new GifCommentExtension(block_start_offset, text)
		};
		
	}
	
	/// Parse a GIF application extension.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_gif_extension_application = function(b, block_start_offset) {
		
		/// Block size for the initial block needs to be 11 (id + auth).
		static expected_block_size = __U8_SIZE * (8 + 3);
		
		var initial_block_size = -1;
		
		try {
			initial_block_size = buffer_read(b, buffer_u8);
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read application block size at {buffer_tell(b)}", err_cause)
			};
		}
		
		if (initial_block_size != expected_block_size) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err($"Application extension initial block size (id + auth) expected to be {expected_block_size}, found {initial_block_size}")
			};
		}
		
		// Identifier of which application extension this is.
		// Identifiers are always 8 bytes long.
		const identifier_res = simpleimage_buffer_read_u8_array(b, __U8_SIZE * 8);
		
		if (identifier_res.result != BufferReadResult.Success) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read application identifier for block at {block_start_offset}", identifier_res.err)
			};
		}
		
		const identifier = simpleimage_stringify_u8_array(identifier_res.data);
		
		// Application "authentication" (in use, this just seems to mean version)
		// authentication is always 3 bytes long.
		const authentication_res = simpleimage_buffer_read_u8_array(b, __U8_SIZE * 3);
		
		if (authentication_res.result != BufferReadResult.Success) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read application authentication for block at {block_start_offset}", authentication_res.err)
			};
		}
		
		const authentication = simpleimage_stringify_u8_array(authentication_res.data);
		
		const sub_blocks_res = parse_sub_blocks(b, block_start_offset + initial_block_size + __U8_SIZE);
		if (sub_blocks_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read application extension sub-blocks for block at {block_start_offset}", sub_blocks_res.err)
			};
		}
		
		const sub_blocks = sub_blocks_res.data;
		
		const app_sub_blocks_res = parse_application_sub_blocks(b, sub_blocks);
		if (app_sub_blocks_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err($"Failed to parse application extension sub-blocks for block at {block_start_offset}, sub-blocks are {sub_blocks}", app_sub_blocks_res.err)
			};
		}
		
		const app_sub_blocks = app_sub_blocks_res.data;
		
		return {
			result: ImageLoadResult.Success,
			data: new GifApplicationExtension(block_start_offset, identifier, authentication)
		};
	}
	
	/// Parse a GIF sub-block.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this sub-block.
	parse_sub_block = function(b, block_start_offset) {
		
		var subblock_size;
		
		try {
			subblock_size = buffer_peek(b, block_start_offset, buffer_u8)
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read sub-block size at {block_start_offset}", err_cause)
			};
		}
		
		return {
			result: ImageLoadResult.Success,
			data: new GifSubBlock(block_start_offset + __U8_SIZE, subblock_size)
		};
		
	}
	
	/// Parse a list of sub blocks.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of the block list.
	parse_sub_blocks = function(b, block_start_offset) {
		
		const read_sub_blocks = [];
		var read_pos = block_start_offset;
		
		while (true) {
			
			const sub_block_res = parse_sub_block(b, read_pos);
			
			if (sub_block_res.result != ImageLoadResult.Success) {
				return {
					result: ImageLoadResult.InvalidContentError,
					err: new Err($"Failed to read next sub-block, read_sub_blocks={read_sub_blocks}", sub_block_res.err)
				};
			}
			
			const sub_block = sub_block_res.data;
			read_pos = sub_block.offset + sub_block.size;
			
			array_push(read_sub_blocks, sub_block);
			
			if (sub_block.size == 0) {
				return {
					result: ImageLoadResult.Success,
					data: read_sub_blocks
				};
			}
			
		}
		
	}
	
	/// Parse a list of sub-blocks to application sub-blocks.
	/// @param {Id.Buffer} b
	/// @param {Array<Struct.GifSubBlock} sub_blocks
	parse_application_sub_blocks = function(b, sub_blocks) {
		
		// App. sub-blocks do not include the last terminator block.
		const sub_blocks_count = array_length(sub_blocks) - 1;
		const application_sub_blocks = array_create(sub_blocks_count);
		
		for (var i = 0; i < sub_blocks_count; i ++) {
			
			const sub_block = sub_blocks[i];
			
			if (sub_block.size == 0) {
				return {
					result: ImageLoadResult.InvalidContentError,
					err: new Err($"Failed to read application sub-block {sub_block} ({i} of {sub_blocks_count}, size cannot be 0")
				};
			}
			
			var sub_block_id = -1;
			
			try {
				// ID is located directly after the start of the block
				sub_block_id = buffer_peek(b, sub_block.offset, buffer_u8);
			} catch (err_cause) {
				return {
					result: ImageLoadResult.BufferReadError,
					err: new Err($"Failed to read application sub-block {sub_block} ({i} of {sub_blocks_count}, failed reading sub_block_id", err_cause)
				};
			}
			
			application_sub_blocks[i] = new GifApplicationSubBlock(
				sub_block.offset,
				sub_block.size,
				sub_block_id
			);
		}
		
		return {
			result: ImageLoadResult.Success,
			data: application_sub_blocks
		};
		
	}
	
	/// Parse a GIF graphics control extension
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_gif_extension_graphics_control = function(b, block_start_offset) {
		
		
		
		return {
			result: ImageLoadResult.NotImplementedError,
			err: new Err("Graphics control extension type not implemented")
		};
	}
	
	/// Parse a GIF image descriptor.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_image_descriptor = function(b, block_start_offset) {
		
		try {
			
			const left					= buffer_read(b, buffer_u16);
			const top					= buffer_read(b, buffer_u16);
			const width					= buffer_read(b, buffer_u16);
			const height				= buffer_read(b, buffer_u16);
			const packed				= buffer_read(b, buffer_u8);
			
			const unpacked = parse_image_descriptor_packed_byte(packed);
			
			const ct_table_offset = buffer_tell(b);
			
			const ct_info = (unpacked.ct_enabled) ? new GifColourTableInfo(
				unpacked.ct_is_sorted,
				unpacked.ct_size,
				ct_table_offset
			) : undefined;
			
			return {
				result: ImageLoadResult.Success,
				data: new GifImageDescriptor(
					block_start_offset,
					left,
					top,
					width,
					height,
					unpacked.interlaced,
					ct_info,
					unpacked.reserved
				)
			};
			
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err($"Failed to read image descriptor at {block_start_offset}", err_cause)
			};
		}
	}
	
	/// Parse the packed byte of an image descriptor.
	/// @param {Real} packed
	parse_image_descriptor_packed_byte = function(packed) {
		return {
			ct_enabled:		bool(		 (packed & 0b10000000) >> 7),
			interlaced:		bool(		 (packed & 0b01000000) >> 6),
			ct_is_sorted:	bool(		 (packed & 0b00100000) >> 5),
			reserved:					 (packed & 0b00011000) >> 3,
			ct_size:		power(2,	((packed & 0b00000111) >> 0) + 1)
		};
	}
	
	/// Deal with a GIF trailer.
	/// @param {Id.Buffer} b
	/// @param {Real} block_start_offset Start of this block.
	parse_trailer = function(b, block_start_offset) {
		return {
			result: ImageLoadResult.Success,
			data: new GifTrailer(block_start_offset)
		};
	}

}

/// Valid GIF file versions.
enum GifVersion {
	Version87A = 0,
	Version89A = 1
}