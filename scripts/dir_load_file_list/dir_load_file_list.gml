/// Load a directory from a directory name, returns an array of files.
/// @param {string} dirname
function dir_load_file_list(dirname) {
	
	if (!directory_exists(dirname)) {
		return { status: FileLoadResult.NonExistentError };
	}
	
	var dir = [];
	
	var fname = file_find_first($"{dirname}{SLASH}*", fa_none);
	
	while (fname != "") {
		var fpath = $"{dirname}{SLASH}{fname}";
		var file = new File(fpath);
		
		array_push(dir, file);
		
		fname = file_find_next();
	}
	
	file_find_close();
	
	return dir;
}