/// @desc Main application

#region Initial window setup

application_surface_enable(false);
application_surface_draw_enable(false);

window_width = window_get_width();
window_height = window_get_height();

/// fps to run at normally
normal_fps = 60;

/// fps to run at while panning/zooming around
draw_fps = 240;

#endregion

#region Image State

/// List of handles for async buffer loading
buffer_load_handles = ds_map_create();

/// List of handles for async sprite loading (used purely by the default loader!)
sprite_load_handles = ds_map_create();

/// current directory file list
fdir = [];
fdir_path = undefined;

/// current index of file in the directory
findex = undefined;

enum AppDirState {
	NotReady,
	LoadingDirectory,
	LoadingImage,
	ViewedImageInvalid,
	NoImage,
	DirEmpty,
	Ok
}

/// Current status for our directory and loading situation.
app_dir_state = AppDirState.NotReady;

/// Schedule a load on a file to load its buffer
/// @param {Struct.File} file
/// @param {bool} full Whether to load the full contents of the file, or load enough for magic parsing.
/// @param {Function} cb Callback when finished.
/// @param {Function} [batch_cb] Callback to run if this load is apart of a batch, and all are complete.
file_schedule_load = function(file, full, cb, batch_cb = undefined) {
	
	// TODO: handle queueing this
	assert(file.buf_load_handle == undefined, $"Handle for async buffer load for file {file.fpath} already exists!");
	
	show_message($"loading file {file.fpath} in full = {strbool(full)}");
	
	var handle_id = buffer_load_async(file.buf, file.fpath, 0, (full ? BUFFER_ASYNC_MAX_SIZE : PARSER_MAGIC_RESERVED));
	file.buf_load_handle = handle_id;
	
	buffer_load_handles[? handle_id] = {
		file: file,
		cb: cb,
		batch_cb: batch_cb
	};
}

/// Load a given directory's files, parsing their buffers magic.
/// This means discarding our current directory and loading this one.
/// @param {String} dpath
/// @param {Array<Struct.File>} dir
/// @param {String|undefined} [selected_fpath] Specific file within the directory to load as current viewed, if specified.
directory_load = function(dpath, dir, selected_fpath = undefined) {
	
	var old_dir = simpleimage_legacy.fdir;
	dir_cleanup(old_dir);
	
	fdir_path = dpath;
	
	app_dir_state = AppDirState.LoadingDirectory;
	
	// Callback wrapper.
	var on_complete = method({ dir: dir, selected_fpath: selected_fpath }, function() {
		simpleimage_legacy.directory_load_finished(dir, selected_fpath);
	});
	
	array_foreach(dir, method({ dir: dir, selected_fpath: selected_fpath, on_complete: on_complete }, function(file) {
		
		file.create_buffer();
		
		// Initially load enough of the file to parse magic.
		simpleimage_legacy.file_schedule_load(file, false, function(file) {
			
			var res = file.find_parser();
			
			if (res.status != ImageParseResult.Success) {
				
				file.spr = render_error(string(res));
				file.cleanup_buffer();
				
				return;
			}
			
		}, on_complete);
	}));
	
}

/// Callback for when loading a directory has finished!
/// @param {Array<Struct.File>} dir
/// @param {String|undefined} [selected_fpath] Specific file within the directory to load as current viewed, if specified.
directory_load_finished = function(dir, selected_fpath) {
	
	fdir = dir;
	
	// We do a full load on the current viewed image, which is `selected_fpath` or the first result.
	if (array_length(fdir) == 0) {
		
		findex = undefined;
		app_dir_state = AppDirState.DirEmpty;
		canvas_set_sprite(builtin_errors.dir_empty);
		
		return;
	}
	
	if (selected_fpath == undefined) {
		
		findex = 0;
		image_load(fdir[findex]);
		
		return;
	}
	
	findex = array_find_index(fdir, method({ selected_fpath: selected_fpath }, function(file) {
		return file.fpath == selected_fpath;
	}));
	
	if (findex == -1) {
		
		findex = undefined;
		app_dir_state = AppDirState.NoImage;
		canvas_set_sprite(builtin_errors.file_missing);
		
		return;
	}
	
	image_load(fdir[findex]);
	
	return;
}

/// Load a given viewed file!
/// @param {Struct.File} file
image_load = function(file) {
	
	app_dir_state = AppDirState.LoadingImage;
	
	if (!file.has_parser()) {
		simpleimage_legacy.image_set(file);
		return;
	}
	
	// Do a full load of the file to view it!
	file_schedule_load(file, true, function(file) {
		
		simpleimage_legacy.app_dir_state = AppDirState.Ok;
		
		var res = file.parse();
		file.cleanup_buffer();
		
		if (res.status != ImageParseResult.Success) {
			
			simpleimage_legacy.app_dir_state = AppDirState.ViewedImageInvalid;
			
			file.spr = render_error(res.err);
		}
		
		simpleimage_legacy.image_set(file);
		
	});
}

/// Set the canvas to the given file.
/// @param {Struct.File} file
image_set = function(file) {
	
	gui_redraw = true;
	
	if (file.parseable == undefined) {
		return image_load(file);
	}
	
	if (file.parseable != ImageParseResult.Success) {
		app_dir_state = AppDirState.ViewedImageInvalid;
	}
	
	canvas_set_sprite(file.spr);
}

#endregion

#region Movement State

enum MoveState {
	Idle,
	ClickPanning,
	Zooming
}

/// What we're currently doing!
move_state = MoveState.Idle;

move_handlers = [];

move_handlers[MoveState.Idle] = function() {
	
	if (click[MouseButtons.Left][0] == ClickState.Pressed) {
		game_set_speed(draw_fps, gamespeed_fps);
		move_state = MoveState.ClickPanning;
		
		return;
	}
	
	if (click[MouseButtons.Right][0] == ClickState.Released) {
		on_view_context();
		return;
	}
	
	var scroll_delta = real(mouse_wheel_up()) - real(mouse_wheel_down());
	
	if (scroll_delta != 0) {
		on_zoom(scroll_delta, current_mouse_x, current_mouse_y);
		return;
	}
}

move_handlers[MoveState.ClickPanning] = function() {
	
	if (click[MouseButtons.Left][0] == ClickState.Released) {
		
		game_set_speed(normal_fps, gamespeed_fps);
		move_state = MoveState.Idle;
		
		return;
	}
	
	canvas_translate(current_mouse_x - prev_mouse_x, current_mouse_y - prev_mouse_y);
}


#endregion

#region Mouse

prev_mouse_x = window_mouse_get_x();
prev_mouse_y = window_mouse_get_y();

current_mouse_x = prev_mouse_x;
current_mouse_y = prev_mouse_y;

/// Mapping for click states, util stuff
_clickstatemap = [];
_clickstatemap[MouseButtons.Left] = mb_left;
_clickstatemap[MouseButtons.Middle] = mb_middle;
_clickstatemap[MouseButtons.Right] = mb_right;

/// Click state this frame [state, time (for last Held), start drag pos_x, start drag pos_y]
click = [];
click[MouseButtons.Left]	= [ClickState.None, 0, current_mouse_x, current_mouse_y];
click[MouseButtons.Middle]	= [ClickState.None, 0, current_mouse_x, current_mouse_y];
click[MouseButtons.Right]	= [ClickState.None, 0, current_mouse_x, current_mouse_y];

/// Load the current mouse state for a button
mouse_btn_state_load = function(index) {
	
	if (device_mouse_check_button_released(0, _clickstatemap[index])) {
		click[index][0] = ClickState.Released;
		return;
	}
	
	if (device_mouse_check_button_pressed(0, _clickstatemap[index])) {
		click[index][0] = ClickState.Pressed;
		click[index][2] = current_mouse_x;
		click[index][3] = current_mouse_y;
		return;
	}
	
	if (device_mouse_check_button(0, _clickstatemap[index])) {
		click[index][0] = ClickState.Held;
		click[index][1] += 1;
		return;
	}
	
	click[index][0] = ClickState.None;
	click[index][1] = 0;
	
}

/// Load the mouse position state
mouse_pos_state_load = function() {
	prev_mouse_x = current_mouse_x;
	prev_mouse_y = current_mouse_y;

	current_mouse_x = window_mouse_get_x();
	current_mouse_y = window_mouse_get_y();
}

/// Load the current mouse state
mouse_state_load = function() {
	mouse_btn_state_load(MouseButtons.Left);
	mouse_btn_state_load(MouseButtons.Middle);
	mouse_btn_state_load(MouseButtons.Right);
	
	mouse_pos_state_load();
}

#endregion

#region Canvas setup and manipulation

builtin_errors = {
	none_loaded: render_message("No file loaded!", "Please load a file :)"),
	file_missing: render_message("Selected file is missing", "Can't find the file you chose ;-;"),
	dir_empty: render_message("Directory is empty", "Nothing here!"),
	no_compat: render_message("Nothing compatible here", "The directory doesn't contain anything readable!"),
};

/// sprite id for the canvas (should point to the file's sprite)
canvas = builtin_errors.none_loaded;

canvas_width = sprite_get_width(canvas);
canvas_height = sprite_get_height(canvas);

/// how much we've panned the canvas on screen!
canvas_x = 0;
canvas_y = 0;

/// how much we've zoomed the canvas!
canvas_scale = 1;

/// zoom in or out of the canvas around a point in window space
/// @param {real} scale_factor
/// @param {real} window_center_x center x position in window space
/// @param {real} window_center_y center y position in window space
canvas_zoom = function(scale_factor, window_center_x, window_center_y) {
	
	static min_zoom = 0.01;
	static max_zoom = 1000;
	
	// see: https://stackoverflow.com/questions/19999694/how-to-scale-about-point
	
	var pt = point_to_canvas(window_center_x, window_center_y);

	canvas_translate(pt[X] * canvas_scale , pt[Y] * canvas_scale);
	canvas_scale = clamp(canvas_scale + (canvas_scale * scale_factor), min_zoom, max_zoom);
	canvas_translate(-pt[X] * canvas_scale, -pt[Y] * canvas_scale);
}

/// Move the canvas by given x and y amount.
canvas_translate = function(x, y) {
	canvas_x += x;
	canvas_y += y;
}

/// Convert a point in window space to a point in canvas space!
/// @param {real} x
/// @param {real} y
/// @returns {array<real>}
point_to_canvas = function(x, y) {
	return [
		(x - canvas_x) / canvas_scale,
		(y - canvas_y) / canvas_scale,
	];
}

/// Convert a point in canvas space back to window space!
/// @param {real} x
/// @param {real} y
/// @returns {array<real>}
point_from_canvas = function(x, y) {
	return [
		(x * canvas_scale) + canvas_x,
		(y * canvas_scale) + canvas_y
	];
}

/// Center the canvas
canvas_center = function() {
	canvas_x = (window_width / 2) - (canvas_width / 2 * canvas_scale);
	canvas_y = (window_height / 2) - (canvas_height / 2 * canvas_scale);
}

/// Scale the canvas to fit the screen
canvas_rescale = function() {
	canvas_scale = min(window_width / canvas_width, window_height / canvas_height);
}

/// Set the canvas to a new sprite!
/// @param {Asset.GMSprite} spr
canvas_set_sprite = function(spr) {
	canvas = spr;
	canvas_width = sprite_get_width(canvas);
	canvas_height = sprite_get_height(canvas);
	
	canvas_rescale();
	canvas_center();
	
	bg_refresh();
}

#endregion

#region GUI

/// Checkboard background to show transparency.
bg_surface = surface_create(canvas_width, canvas_height);

bg_ensure_exists = function() {
	
	if (!surface_exists(bg_surface)) {
		bg_surface = surface_create(canvas_width, canvas_height);
	}
	
	surface_set_target(bg_surface);

	draw_sprite_tiled(bg, 0, 0, 0);

	surface_reset_target();
}

/// Force a refresh of the checkerboard background.
bg_refresh = function() {
	surface_free(bg_surface);
}

/// GUI's draw surface.
gui_surface = surface_create(window_width, window_height);

/// Whether we need to redraw the GUI.
gui_redraw = true;

/// Draw the GUI.
gui_draw = function() {
	
	if (findex != undefined) {
		draw_text(0, 0, fdir[findex].fpath);
	}
	
	gui_redraw = false;
}

/// Ensure the gui layer exists, if not, mark for redraw.
gui_ensure_exists = function() {
	if (surface_exists(gui_surface)) {
		return;
	}
	
	gui_surface = surface_create(window_width, window_height);
	gui_redraw = true;
}

#endregion

#region Input Event handlers

/// Called upon window resize.
/// @param {real} new_width
/// @param {real} new_height
on_window_resize = function(new_width, new_height) {
    window_width = new_width;
    window_height = new_height;
	
	surface_free(gui_surface);
}

/// Called on pressing fullscreen key
on_fullscreen_toggle = function() {
	window_set_fullscreen(!window_get_fullscreen());
}

/// Called on viewing the context menu
on_view_context = function() {
	move_state = MoveState.Idle;
}

/// Called on panning with arrow keys
on_arrow_pan = function(xdir, ydir) {
	
	static pan_speed = 16;
	
	canvas_translate(xdir * pan_speed, ydir * pan_speed);
}

/// Called on zooming in and out on the canvas
/// @param {real} delta
/// @param {real} window_center_x center x position in window space
/// @param {real} window_center_y center y position in window space
on_zoom = function(delta, window_center_x, window_center_y) {
	static zoom_multiplier = 0.16;
	
	var zoom_factor = delta * zoom_multiplier;
	canvas_zoom(zoom_factor, window_center_x, window_center_y);
}

enum FilePickerResult {
	Cancelled,
	NonExistentError,
	DirectoryReadFailedError,
	Success,
}

/// Called on entering the file picker.
/// @param {Bool} [force] Whether the load is forced even if its the same directory as we have now.
/// @returns {Enum.FilePickerResult}
on_file_picker = function(force = true) {
	var fpath = get_open_filename("*", "");
	
	if (fpath == "") {
		return FilePickerResult.Cancelled;
	}
	
	if (!force && fpath == fdir_path) {
		return FilePickerResult.Cancelled;
	}
	
	// If the user selected a directory instead, we'll try loading it directly.
	var dir_res = dir_load_file_list(fpath);
	if (dir_res.status != FileLoadResult.NonExistentError) {
		
		if (dir_res.status == FileLoadResult.ReadFailedError) {
			return FilePickerResult.DirectoryReadFailedError;
		}
		
		var dir = dir_res.dir;
		
		directory_load(fpath, dir);
		
		return FilePickerResult.Success;
		
	}
	
	if (!file_exists(fpath)) {
		return FilePickerResult.NonExistentError;
	}
	
	var dpath = filename_dir(fpath);
	
	// We'll now load the directory anyway, remembering which file we wanted.
	dir_res = dir_load_file_list(dpath);
	
	if (dir_res.status == FileLoadResult.NonExistentError) {
		return FilePickerResult.NonExistentError;
	}
		
	if (dir_res.status == FileLoadResult.ReadFailedError) {
		return FilePickerResult.DirectoryReadFailedError;
	}
		
	var dir = dir_res.dir;
	
	directory_load(dpath, dir, fpath);
		
	return FilePickerResult.Success;
	
}

/// Called on going to previous or next image.
/// @param {Real} direction
on_view_next = function(direction) {
	
	var findex_new = 0;
	
	switch (app_dir_state) {
		case AppDirState.NotReady:
		case AppDirState.LoadingDirectory:
		case AppDirState.LoadingImage:
		case AppDirState.DirEmpty: {
			return;
		}
		
		case AppDirState.NoImage: {
			break;
		}
		
		case AppDirState.ViewedImageInvalid:
		case AppDirState.Ok: {
			findex_new = modwrap(findex + direction, array_length(fdir));
			break;
		}
	}
	
	findex = findex_new;
	
	var file = fdir[findex];
	image_set(file);
}

#endregion

canvas_rescale();
canvas_center();