/// @desc Call given callbacks for async buffer load listeners.

var handle = async_load[? "id"];
var status = async_load[? "status"];

var file_data = buffer_load_handles[? handle];
ds_map_delete(buffer_load_handles, handle);

var file = file_data.file;
var cb = file_data.cb;
var batch_cb = file_data.batch_cb;

file.buf_load_handle = undefined;

cb(file);

if (batch_cb == undefined) {
	return;
}

// Hacky thing to run the batch callback. Should replace this later.......
var arr = ds_map_values_to_array(buffer_load_handles);
var batch_done = true;

for (var i = 0, len = array_length(arr); i < len; i ++) {
	if (arr[i].batch_cb == batch_cb) {
		batch_done = false;
		break;
	}
}

if (batch_done) {
	batch_cb();
}