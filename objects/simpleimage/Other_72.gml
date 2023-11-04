/// @desc Call given callbacks for async buffer load listeners.

var handle = async_load[? "id"];
var status = async_load[? "status"];

var file = buffer_load_handles[? handle];
ds_map_delete(buffer_load_handles, handle);

show_message($"Loaded buffer for {file.fpath}");