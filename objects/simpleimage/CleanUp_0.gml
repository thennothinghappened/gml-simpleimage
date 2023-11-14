/// @desc Clean up the async callbacks

ds_map_destroy(buffer_load_handles);
ds_map_destroy(sprite_load_handles);

struct_foreach(builtin_errors, function(err) {
	sprite_delete(msg);
});