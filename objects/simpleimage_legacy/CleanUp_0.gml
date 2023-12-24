/// @desc Clean up the async callbacks

ds_map_destroy(buffer_load_handles);
ds_map_destroy(sprite_load_handles);

struct_foreach(builtin_errors, function(errName) {
	
	show_message(err.toString());
	//sprite_delete(err.msg);
});