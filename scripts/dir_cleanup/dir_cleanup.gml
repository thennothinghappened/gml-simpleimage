/// Cleanup a list of files in a directory.
/// @param {Array<Struct.File>} dir
function dir_cleanup(dir) {
	array_foreach(dir, function(file) {
		file.cleanup();
	});
}