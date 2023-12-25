
/// Abstract implementation of an image.
/// @param {Asset.GMSprite} sprite Sprite to display this image.
/// @param {Struct.ImageData} data Data associated with this image.
function Image(sprite, data) constructor {
	
	self.sprite = sprite;
	self.data = data;
	
	/// Cleanup the sprite for this image. To be called on disposal.
	destroy = function() {
		sprite_delete(sprite);
	}
	
}