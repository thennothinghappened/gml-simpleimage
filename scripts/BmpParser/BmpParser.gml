//////////////////////////////////////////////////////////////////////////////////////////
//                                                                                      //
// Parser based on the documentation at https://paulbourke.net/dataformats/bmp, thanks! //
//                                                                                      //
//////////////////////////////////////////////////////////////////////////////////////////

/// Parser for a BMP file
function BmpParser() : ImageParser() constructor {
	
	// BMP files start with magic "BM"
	static magic = [ord("B"), ord("M")];
	
	/// Attempt to parse the given buffer as a BMP.
	/// 
	/// Returns whether the image can be parsed as this type.
	/// 
	/// @param {Id.Buffer} b Input image buffer to parse
	parse = function(b) {
		
		const header_res = parse_header(b);
		if (header_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to parse BMP header", header_res.err)
			};
		}
		
		const header = header_res.data;
		
		const infoheader_res = parse_infoheader(b);
		if (infoheader_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to parse BMP infoheader", infoheader_res.err)
			};
		}
		
		const infoheader = infoheader_res.data;
		
		// We can't create images over the surface size limit, so bail.
		if (infoheader.width > __SURFACE_LARGEST_RES || infoheader.height > __SURFACE_LARGEST_RES) {
			return {
				result: ImageLoadResult.SpriteCreationError,
				err: new Err($"Cannot create sprites over the size {__SURFACE_LARGEST_RES}x{__SURFACE_LARGEST_RES}, given dimensions {infoheader.width}x{infoheader.height} are too big!")
			};
		}
		
		return {
			result: ImageLoadResult.Success,
			data: new BmpImageData(self, header, infoheader)
		};
	}
	

	/// Attempt to load the full image from the given buffer as a BMP.
	/// 
	/// Returns an Image instance if successful.
	/// 
	/// @param {Id.Buffer} b The buffer to read the image from.
	/// @param {Struct.BmpImageData} image_data Data from initial parsing the image.
	load = function(b, image_data) {
		
		const header = image_data.header;
		const infoheader = image_data.infoheader;
		
		const image_res = parse_image(header, infoheader, b);
		if (image_res.result != ImageLoadResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Failed to parse BMP image data", image_res.err)
			};
		}
		
		return {
			result: ImageLoadResult.Success,
			data: new Image(image_res.data, image_data)
		};
	}
	
	/// Attempt to save the image as a BMP.
	/// 
	/// Returns a buffer containing the image.
	/// 
	/// @param {Struct.Image} image Image to save.
	/// @param {Struct.BmpSaveParams} params Parameters for how the image should be saved. Unique per image type.
	save = function(image, params) {
		
		static header_bytesize = get_header_bytesize();
		static infoheader_bytesize = get_infoheader_bytesize();
		
		// We only save the first image of the sprite.
		const buffer_res = image.get_buffer(0);
		
		if (buffer_res.result != SpriteSurfaceCreationResult.Success) {
			return {
				result: ImageSaveResult.GetSurfaceError,
				err: new Err("Failed to get the sprite's buffer", buffer_res.err)
			};
		}
		
		// TODO: do this all properly to support other modes!!
		const offset = header_bytesize + infoheader_bytesize;
		
		const input_buffer = buffer_res.data;
		const encode_res = encode(input_buffer, image.width, image.height, params);
		
		buffer_delete(input_buffer);
		
		if (encode_res.result != ImageSaveResult.Success) {
			return {
				result: ImageSaveResult.EncodeError,
				err: new Err("Failed to encode image", encode_res.err)
			};
		}
		
		const encoded_buf = encode_res.data;
		const image_bytesize = int64(buffer_get_size(encoded_buf));
		const filesize = int64(header_bytesize) + int64(infoheader_bytesize) + image_bytesize;
		
		if (filesize >= __32_BIT_SIGNED_INT_LIMIT) {
			
			buffer_delete(encoded_buf);
			
			return {
				result: ImageSaveResult.TooLargeError,
				err: new Err($"Final image is too large, size {filesize} exceeds max size {__32_BIT_SIGNED_INT_LIMIT}")
			};
		}
		
		const header = new BmpHeader(
			filesize,
			0x00,
			0x00,
			offset
		);
		
		const infoheader = new BmpInfoHeader(
			infoheader_bytesize,
			image.width,
			image.height,
			1,
			params.bits_per_pixel,
			params.compression,
			image_bytesize,
			image.width,	// TODO
			image.height,	// TODO
			0xFFFFFF,		// TODO
			0x00			// TODO
		);
		
		const ob = buffer_create(filesize, buffer_fixed, 1);
		
		const header_res = write_header(ob, header);
		
		if (header_res.result != ImageSaveResult.Success) {
			return {
				result: ImageSaveResult.EncodeError,
				err: new Err("Failed to write header", header_res.err)
			};
		}
		
		const infoheader_res = write_infoheader(ob, infoheader);
		
		if (infoheader_res.result != ImageSaveResult.Success) {
			return {
				result: ImageSaveResult.EncodeError,
				err: new Err("Failed to write infoheader", infoheader_res.err)
			};
		}
		
		buffer_copy(encoded_buf, 0, image_bytesize, ob, buffer_tell(ob));
		buffer_delete(encoded_buf);
		
		return {
			result: ImageSaveResult.Success,
			data: ob
		};
		
	}
	
	/// Parse the BMP file header.
	/// @param {Id.Buffer} b
	parse_header = function(b) {
		
		const magic_res = simpleimage_validate_magic(b, magic);
		
		if (magic_res.result != MagicValidationResult.Success) {
			return {
				result: ImageLoadResult.InvalidContentError,
				err: new Err("Magic validation failed", magic_res.err)
			};
		}
		
		try {
			
			const size			= int64(buffer_read(b, buffer_u32));
			const _reserved1	= buffer_read(b, buffer_u16);
			const _reserved2	= buffer_read(b, buffer_u16);
			const offset		= buffer_read(b, buffer_u32);
			
			return {
				result: ImageLoadResult.Success,
				data: new BmpHeader(
					size,
					_reserved1,
					_reserved2,
					offset
				)
			};
			
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err("Failed to read BMP header", err_cause)
			};
		}
	}
	
	/// Parse the BMP file infoheader.
	/// @param {Id.Buffer} b
	parse_infoheader = function(b) {
		
		try {
			
			const header_size		= buffer_read(b, buffer_u32);
			const width				= int64(buffer_read(b, buffer_s32));
			const height			= int64(buffer_read(b, buffer_s32));
			const colour_planes		= buffer_read(b, buffer_u16);
			const bits_per_pixel	= buffer_read(b, buffer_u16);
			const compression		= buffer_read(b, buffer_u32);
			const image_bytesize	= buffer_read(b, buffer_u32);
			const ppm_w				= buffer_read(b, buffer_s32);
			const ppm_h				= buffer_read(b, buffer_s32);
			const num_colours		= buffer_read(b, buffer_u32);
			const important_colours	= buffer_read(b, buffer_u32);
			
			return {
				result: ImageLoadResult.Success,
				data: new BmpInfoHeader(
					header_size,
					width,
					height,
					colour_planes,
					bits_per_pixel,
					compression,
					image_bytesize,
					ppm_w,
					ppm_h,
					num_colours,
					important_colours
				)
			};
		
		} catch (err_cause) {
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err("Failed to read BMP infoheader", err_cause)
			};
		}
	}
	
	/// Parse the image data of the BMP!
	/// @param {Struct.BMPHeader} header
	/// @param {Struct.BMPInfoHeader} infoheader
	/// @param {Id.Buffer} b
	parse_image = function(header, infoheader, b) {
		
		switch (infoheader.compression) {
			case BmpCompressionMethod.RGB: return parse_uncompressed_rgb_image(header, infoheader, b);
		}
		
		return {
			result: ImageLoadResult.NotImplementedError,
			err: new Err($"Parsing BMP compression type {infoheader.compression} not implemented!")
		};
		
	}
	
	/// Parse image data for an uncompressed RGB BMP
	/// @param {Struct.BMPHeader} header
	/// @param {Struct.BMPInfoHeader} infoheader
	/// @param {Id.Buffer} b
	parse_uncompressed_rgb_image = function(header, infoheader, b) {
		
		switch (infoheader.bits_per_pixel) {
			case 24: return parse_24bit_uncompressed_image(header, infoheader, b);
		}
		
		return {
			result: ImageLoadResult.InvalidContentError,
			err: new Err($"Unknown bits per pixel {infoheader.bits_per_pixel}")
		};
	}
	
	/// Parse a 24 bit uncompressed BMP image.
	/// @param {Struct.BMPHeader} header
	/// @param {Struct.BMPInfoHeader} infoheader
	/// @param {Id.Buffer} ib
	parse_24bit_uncompressed_image = function(header, infoheader, ib) {
		
		// R+G+B
		static src_bytes_per_pixel = __U8_SIZE * 3;
		
		/// R+G+B+A
		static dest_bytes_per_pixel = __U8_SIZE * 4;
		
		const width = infoheader.width;
		const height = infoheader.height;
		const offset = header.offset;
		
		const out_buffer_size = width * height * dest_bytes_per_pixel;
		
		// Creating a buffer this big crashes GM as it tries to downconvert to an i32.
		// https://github.com/YoYoGames/GameMaker-Bugs/issues/2590
		if (out_buffer_size > __32_BIT_SIGNED_INT_LIMIT) {
			return {
				result: ImageLoadResult.BufferCreationError,
				err: new Err($"Cannot allocate a buffer of size {out_buffer_size} (larger than {__32_BIT_SIGNED_INT_LIMIT})")
			};
		}
		
		const ob = buffer_create(out_buffer_size, buffer_fixed, 1);
		
		try {
			
			// Fill with solid white so we have full opacity.
			buffer_fill(ob, 0, buffer_u8, 0xFF, out_buffer_size);
			
			// BMPs store images upside down (Don't really know why to be honest.)
			// Copy each row, bottom up (flip vertically):
			// 
			// 5[ #.#..#..# ]    1[ #....#..# ]
			// 4[ #.#..#... ]    2[ #.......# ]
			// 3[ ###..#..# ] -> 3[ ###..#..# ]
			// 2[ #.......# ]    4[ #.#..#... ]
			// 1[ #....#..# ]    5[ #.#..#..# ]
			for (var yy = 0; yy < height; yy ++) {
				
				const src_offset = width * src_bytes_per_pixel * (height - yy - 1);
				const dest_offset = width * dest_bytes_per_pixel * yy;
				
				// Red
				buffer_copy_stride(ib, src_offset + __U8_SIZE * 2, __U8_SIZE, src_bytes_per_pixel, width, ob, dest_offset + __U8_SIZE * 0, dest_bytes_per_pixel);
		
				// Green
				buffer_copy_stride(ib, src_offset + __U8_SIZE * 1, __U8_SIZE, src_bytes_per_pixel, width, ob, dest_offset + __U8_SIZE * 1, dest_bytes_per_pixel);
		
				// Blue
				buffer_copy_stride(ib, src_offset + __U8_SIZE * 0, __U8_SIZE, src_bytes_per_pixel, width, ob, dest_offset + __U8_SIZE * 2, dest_bytes_per_pixel);
				
			}
			
			
		} catch (err_cause) {
			
			buffer_delete(ob);
			
			return {
				result: ImageLoadResult.BufferReadError,
				err: new Err("Failed to read BMP image data", err_cause)
			};
		}
		
		var os = -1;
		var sprite = -1;
		
		try {
			
			// Avoiding storing duplicate data where possible for large images.
			os = surface_create(width, height, surface_rgba8unorm);
			buffer_set_surface(ob, os, 0);
			buffer_delete(ob);
		
			sprite = sprite_create_from_surface(os, 0, 0, width, height, false, false, 0, 0);
			surface_free(os);
			
		} catch (err_cause) {
			
			if (buffer_exists(ob)) {
				buffer_delete(ob);
			}
			
			if (surface_exists(os)) {
				surface_free(os);
			}
			
			if (sprite_exists(sprite)) {
				sprite_delete(sprite);
			}
			
			return {
				result: ImageLoadResult.SpriteCreationError,
				err: new Err("Failed to create image sprite", err_cause)
			};
		}
		
		return {
			result: ImageLoadResult.Success,
			data: sprite
		};
	}

	/// Returns the filesize of the BMP header.
	get_header_bytesize = function() {
		
		// (14 bytes)
		static header_size = 
			__U16_SIZE +		// "BM"
			__U32_SIZE +		// size
			__U16_SIZE +		// _reserved1
			__U16_SIZE +		// _reserved2
			__U32_SIZE			// offset
		
		
		
		return header_size;
	}
	
	/// Returns the filesize of the BMP infoheader.
	get_infoheader_bytesize = function() {
		
		// Note: we're only worrying about the later BMP revision (larger infoheader) for simplicity sake.
		
		// (40 bytes)
		static infoheader_size =
			__U32_SIZE +		// header_size
			__S32_SIZE +		// width
			__S32_SIZE +		// height
			__U16_SIZE +		// colour_planes
			__U16_SIZE +		// bits_per_pixel
			__U32_SIZE +		// compression
			__U32_SIZE +		// image_bytesize
			__S32_SIZE +		// ppm_w
			__S32_SIZE +		// ppm_h
			__U32_SIZE +		// num_colours
			__U32_SIZE			// important_colours
		
		return infoheader_size;
	}

	/// Write the header of a BMP file.
	/// @param {Id.Buffer} b Buffer to write to
	/// @param {Struct.BmpHeader} header Header to write
	write_header = function(b, header) {
		
		const magic_res = simpleimage_buffer_write_u8_array(b, magic);
		
		if (magic_res.result != BufferWriteResult.Success) {
			return {
				result: ImageSaveResult.EncodeError,
				err: new Err("Failed to write magic bytes to BMP header", err_cause)
			};
		}
		
		try {
			buffer_write(b, buffer_u32, header.size);
			buffer_write(b, buffer_u16, header._reserved1);
			buffer_write(b, buffer_u16, header._reserved2);
			buffer_write(b, buffer_u32, header.offset);
		} catch (err_cause) {
			return {
				result: ImageSaveResult.EncodeError,
				err: new Err("Failed to write BMP header", err_cause)
			};
		}
		
		return {
			result: ImageSaveResult.Success
		};
	}
	
	/// Write the infoheader of a BMP file.
	/// @param {Id.Buffer} b Buffer to write to
	/// @param {Struct.BmpInfoHeader} infoheader Infoheader to write
	write_infoheader = function(b, infoheader) {
		
		try {
			
			buffer_write(b, buffer_u32, infoheader.header_size);
			buffer_write(b, buffer_s32, infoheader.width);
			buffer_write(b, buffer_s32, infoheader.height);
			buffer_write(b, buffer_u16, infoheader.colour_planes);
			buffer_write(b, buffer_u16, infoheader.bits_per_pixel);
			buffer_write(b, buffer_u32, infoheader.compression);
			buffer_write(b, buffer_u32, infoheader.image_bytesize);
			buffer_write(b, buffer_s32, infoheader.ppm_w);
			buffer_write(b, buffer_s32, infoheader.ppm_h);
			buffer_write(b, buffer_u32, infoheader.num_colours);
			buffer_write(b, buffer_u32, infoheader.important_colours);
			
		} catch (err_cause) {
			return {
				result: ImageSaveResult.EncodeError,
				err: new Err("Failed to write BMP infoheader", err_cause)
			};
		}
		
		return {
			result: ImageSaveResult.Success
		};
		
	}

	/// Encode a given image as BMP.
	/// @param {Id.Buffer} ib Input surface buffer as surface_rgba8unorm.
	/// @param {Real} width Width of the image.
	/// @param {Real} height Height of the image.
	/// @param {Struct.BmpSaveParams} params Parameters for how the image should be encoded.
	encode = function(ib, width, height, params) {
		
		// Encoding method massively depends on compression so I'm splitting it out here.
		switch (params.compression) {
			case BmpCompressionMethod.RGB: return encode_rgb(ib, width, height, params);
		}
		
		return {
			result: ImageSaveResult.NotImplementedError,
			err: new Err($"BMP Compression Method {params.compression} not implemented!")
		};
		
	}
	
	/// Encode an uncompressed RGB BMP.
	/// @param {Id.Buffer} ib Input surface buffer as surface_rgba8unorm.
	/// @param {Real} width Width of the image.
	/// @param {Real} height Height of the image.
	/// @param {Struct.BmpSaveParams} params Parameters for how the image should be encoded.
	encode_rgb = function(ib, width, height, params) {
		
		// BPP changes method yet again!
		switch (params.bits_per_pixel) {
			case 24: return encode_rgb_24bpp(ib, width, height, params);
		}
		
		return {
			result: ImageSaveResult.NotImplementedError,
			err: new Err($"Bits-per-pixel {params.bits_per_pixel} not implemented for compression type RGB")
		};
	}
	
	/// Encode an uncompressed 24 bits-per-pixel RGB BMP.
	/// @param {Id.Buffer} ib Input surface buffer as surface_rgba8unorm.
	/// @param {Real} width Width of the image.
	/// @param {Real} height Height of the image.
	/// @param {Struct.BmpSaveParams} params Parameters for how the image should be encoded.
	encode_rgb_24bpp = function(ib, width, height, params) {
		
		// R+G+B+A
		static src_bytes_per_pixel = __U8_SIZE * 4;
		
		/// R+G+B
		static dest_bytes_per_pixel = __U8_SIZE * 3;
		
		const num_pixels = width * height;
		const bytesize = int64(num_pixels * dest_bytes_per_pixel);
		
		if (bytesize >= __32_BIT_SIGNED_INT_LIMIT) {
			return {
				result: ImageSaveResult.TooLargeError,
				err: new Err($"Unable to create a BMP of size {bytesize}, greater than {__32_BIT_SIGNED_INT_LIMIT}")
			};
		}
		
		const ob = buffer_create(bytesize, buffer_fixed, 1);
		
		// Copy each row, bottom up (flip vertically)
		// 
		// 1[ #....#..# ]    5[ #.#..#..# ]
		// 2[ #.......# ]    4[ #.#..#... ]
		// 3[ ###..#..# ] -> 3[ ###..#..# ]
		// 4[ #.#..#... ]    2[ #.......# ]
		// 5[ #.#..#..# ]    1[ #....#..# ]
		for (var yy = 0; yy < height; yy ++) {
			
			const src_offset = width * src_bytes_per_pixel * (height - yy - 1);
			const dest_offset = width * dest_bytes_per_pixel * yy;
			
			// Red
			buffer_copy_stride(ib, src_offset + __U8_SIZE * 2, __U8_SIZE, src_bytes_per_pixel, width, ob, dest_offset + __U8_SIZE * 0, dest_bytes_per_pixel);
		
			// Green
			buffer_copy_stride(ib, src_offset + __U8_SIZE * 1, __U8_SIZE, src_bytes_per_pixel, width, ob, dest_offset + __U8_SIZE * 1, dest_bytes_per_pixel);
		
			// Blue
			buffer_copy_stride(ib, src_offset + __U8_SIZE * 0, __U8_SIZE, src_bytes_per_pixel, width, ob, dest_offset + __U8_SIZE * 2, dest_bytes_per_pixel);
		}
		
		return {
			result: ImageSaveResult.Success,
			data: ob
		};
	}

}

/// List of compression methods BMP files support (there's uh, quite a few...)
// https://en.wikipedia.org/wiki/BMP_file_format#Compression
// https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-wmf/4e588f70-bd92-4a6f-b77f-35d0feaf7a57
enum BmpCompressionMethod {
	/// Uncompressed RGB
	RGB = 0,
	/// Run-length-encoded RGB with 8 bits per pixel
	RunLengthEncoded8BPP = 1,
	/// Run-length-encoded RGB with 4 bits per pixel
	RunLengthEncoded4BPP = 2,
	/// RGB bit field masks (todo: ?)
	BitFields = 3,
	/// JPEG pass-through
	JPEG = 4,
	/// PNG pass-through
	PNG = 5,
	/// "RGBA bit field masks" (?)
	AlphaBitFields = 6,
	/// Uncompressed CMYK
	CMYK = 11,
	/// Run-length-encoded CMYK with 8 bits per pixel
	RunLengthEncodedCMYK8BPP = 12,
	/// Run-length-encoded CMYK with 4 bits per pixel
	RunLengthEncodedCMYK4BPP = 12
}