
/// Dud class for an image created from an existing sprite.
/// This exists for compatibility with GM internal sprites.
function SpriteParser() : ImageParser() constructor {
	
	/// Create an Image instance from a given sprite.
	/// @param {Asset.GMSprite} sprite
	load_from_sprite = function(sprite) {
		return {
			result: ImageLoadResult.Success,
			data: new Image(sprite, new ImageData(self))
		};
	}
	
}