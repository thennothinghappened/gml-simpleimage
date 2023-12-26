
enum SpriteSurfaceCreationResult {
	Success,
	NoSuchIndexError,
	FailedToCreateSurfaceError
}

/// Abstract implementation of an image.
/// @param {Asset.GMSprite} sprite Sprite to display this image.
/// @param {Struct.ImageData} data Data associated with this image.
function Image(sprite, data) constructor {
	
	self.sprite = sprite;
	self.data = data;
	
	self.width = sprite_get_width(sprite);
	self.height = sprite_get_height(sprite);
	
	/// Cleanup the sprite for this image. To be called on disposal.
	destroy = function() {
		sprite_delete(sprite);
	}
	
	/// Convert a frame of our image sprite to a surface, always as a surface_rgba8unorm.
	/// @param {Real} index Which sprite index to get
	get_surface = function(index) {
		
		const indicies = sprite_get_number(sprite);
		if (index >= indicies) {
			return {
				result: SpriteSurfaceCreationResult.NoSuchIndexError,
				err: new Err($"Sprite {sprite_get_name(sprite)} has no index {index} (max is {indicies - 1})")
			};
		}
		
		const original_surface = surface_get_target();
		const should_return_surface = surface_exists(original_surface);
		
		const new_surface = surface_create(width, height, surface_rgba8unorm);
		
		if (should_return_surface) {
			surface_reset_target();
		}
		
		surface_set_target(new_surface);
		draw_sprite(sprite, index, 0, 0);
		surface_reset_target();
		
		if (should_return_surface) {
			surface_set_target(original_surface);
		}
		
		if (!surface_exists(new_surface)) {
			return {
				result: SpriteSurfaceCreationResult.FailedToCreateSurfaceError,
				err: new Err($"New surface of dimensions {width}x{height} stopped existing!")
			};
		}
		
		return {
			result: SpriteSurfaceCreationResult.Success,
			data: new_surface
		};
		
	}
	
	/// Convert a frame of our image sprite to a buffer representation of the surface, always as a surface_rgba8unorm.
	/// @param {Real} index Which sprite index to get
	get_buffer = function(index) {
		
		// R+G+B+A
		static bytes_per_pixel = __U8_SIZE * 4;
		
		const indicies = sprite_get_number(sprite);
		if (index >= indicies) {
			return {
				result: SpriteSurfaceCreationResult.NoSuchIndexError,
				err: new Err($"Sprite {sprite_get_name(sprite)} has no index {index} (max is {indicies - 1})")
			};
		}
		
		const surface_res = get_surface(index);
		if (surface_res.result != SpriteSurfaceCreationResult.Success) {
			return {
				result: SpriteSurfaceCreationResult.FailedToCreateSurfaceError,
				err: new Err("Failed to create the surface needed for the buffer", surface_res.err)
			};
		}
		
		const surface = surface_res.data;
		const buffer = buffer_create(width * height * bytes_per_pixel, buffer_fixed, 1);
		buffer_get_surface(buffer, surface, 0);
		
		surface_free(surface);
		
		return {
			result: SpriteSurfaceCreationResult.Success,
			data: buffer
		};
		
	}
	
}