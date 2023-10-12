/// @desc 

#macro X 0
#macro Y 1

SLASH = "/";

if (os_type == os_windows) {
	SLASH = @'\';
}

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

#region State

enum State {
	Idle,
	ClickPanning,
	Zooming
}

/// What we're currently doing!
state = State.Idle;

/// the file we're currently viewing
file = undefined;
dir_name = undefined;
dir_list = undefined;

/// load a given file passed in if so!
if (parameter_count() >= 2) {
	
	for (var i = 1; i < parameter_count(); i ++) {
		var str = parameter_string(i);
		var _dir_name = filename_path(str);
		
		if (!file_exists(str)) {
			continue;
		}
		
		var res = image_url_find_parser(str);
		
		if (res.status != ImageLoadResult.Success) {
			continue;
		}
		
		file = str;
	}
}

enum LoadDirListResult {
	Success,
	NoChange,
	NonExistentError
}

/// load the directory listing for a given filepath, if changed.
load_dir_list = function(filepath, force = false) {
	var new_dir_name = filename_dir(filepath);
	
	if (new_dir_name == dir_name && !force) {
		return LoadDirListResult.NoChange;
	}
	
	if (!directory_exists(new_dir_name)) {
		return LoadDirListResult.NonExistentError;
	}
	
	dir_name = new_dir_name;
	dir_list = [];
	
	var file = file_find_first($"{new_dir_name}{SLASH}*.*", fa_none);
	
	while (file != "") {
		var inner_filepath = $"{new_dir_name}{SLASH}{file}";
		
		if (file_exists(inner_filepath)) {
			
			var res = image_url_find_parser(inner_filepath);
			
			if (res.status == ImageLoadResult.Success) {
				array_push(dir_list, inner_filepath);
			}
		}
		
		file = file_find_next();
	}
	
	file_find_close();
	
	return LoadDirListResult.Success;
}

handlers = [];

handlers[State.Idle] = function() {
	
	if (click[MouseButtons.Left][0] == ClickState.Pressed) {
		game_set_speed(draw_fps, gamespeed_fps);
		state = State.ClickPanning;
		
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

handlers[State.ClickPanning] = function() {
	
	if (click[MouseButtons.Left][0] == ClickState.Released) {
		
		game_set_speed(normal_fps, gamespeed_fps);
		state = State.Idle;
		
		return;
	}
	
	canvas_translate(current_mouse_x - prev_mouse_x, current_mouse_y - prev_mouse_y);
}


#endregion

#region Mouse

enum MouseButtons {
	Left,
	Middle,
	Right
}

enum ClickState {
	None,
	Pressed,
	Held,
	Released
}

prev_mouse_x = window_mouse_get_x();
prev_mouse_y = window_mouse_get_y();

current_mouse_x = prev_mouse_x;
current_mouse_y = prev_mouse_y;

/// mapping for click states, util stuff
_clickstatemap = [];
_clickstatemap[MouseButtons.Left] = mb_left;
_clickstatemap[MouseButtons.Middle] = mb_middle;
_clickstatemap[MouseButtons.Right] = mb_right;

/// click state this frame [state, time (for last Held), start drag pos_x, start drag pos_y]
click = [];
click[MouseButtons.Left]	= [ClickState.None, 0, current_mouse_x, current_mouse_y];
click[MouseButtons.Middle]	= [ClickState.None, 0, current_mouse_x, current_mouse_y];
click[MouseButtons.Right]	= [ClickState.None, 0, current_mouse_x, current_mouse_y];

/// load the current mouse state for a button
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

/// load the mouse position state
mouse_pos_state_load = function() {
	prev_mouse_x = current_mouse_x;
	prev_mouse_y = current_mouse_y;

	current_mouse_x = window_mouse_get_x();
	current_mouse_y = window_mouse_get_y();
}

/// load the current mouse state
mouse_state_load = function() {
	mouse_btn_state_load(MouseButtons.Left);
	mouse_btn_state_load(MouseButtons.Middle);
	mouse_btn_state_load(MouseButtons.Right);
	
	mouse_pos_state_load();
}

#endregion

#region Canvas setup and manipulation

canvas_width = sprite_get_width(fail_img);
canvas_height = sprite_get_height(fail_img);

/// how much we've panned the canvas on screen!
canvas_pan_x = 0;
canvas_pan_y = 0;

/// how much we've zoomed the canvas!
canvas_scale = 1;

/// sprite id for the canvas
canvas = fail_img;

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

/// move the canvas
canvas_translate = function(x, y) {
	canvas_pan_x += x;
	canvas_pan_y += y;
}

/// convert a point in window space to a point in canvas space!
/// @param {real} x
/// @param {real} y
/// @returns {array<real>}
point_to_canvas = function(x, y) {
	return [
		(x - canvas_pan_x) / canvas_scale,
		(y - canvas_pan_y) / canvas_scale,
	];
}

/// convert a point in canvas space back to window space!
/// @param {real} x
/// @param {real} y
/// @returns {array<real>}
point_from_canvas = function(x, y) {
	return [
		(x * canvas_scale) + canvas_pan_x,
		(y * canvas_scale) + canvas_pan_y
	];
}

/// load the canvas from a file!
/// @param {string} filepath
/// @returns {Enum.ImageLoadResult}
canvas_load_from_file = function(filepath) {
	
	var img = fail_img;
	
	var res = image_load(filepath);
	file = filepath;
	
	if (res.status == ImageLoadResult.Success) {
		img = res.img;
	} else {
		img = render_error(res.err);
	}
	
	if (sprite_exists(canvas) && canvas != fail_img) {
		sprite_delete(canvas);
	}
	
	canvas_width = sprite_get_width(img);
	canvas_height = sprite_get_height(img);
	
	canvas = img;
	
	bg_refresh();
	
	canvas_rescale();
	canvas_center();
	
	return res.status;
}

/// center the canvas
canvas_center = function() {
	canvas_pan_x = (window_width / 2) - (canvas_width / 2 * canvas_scale);
	canvas_pan_y = (window_height / 2) - (canvas_height / 2 * canvas_scale);
}

/// scale the canvas to fit the screen
canvas_rescale = function() {
	canvas_scale = min(window_width / canvas_width, window_height / canvas_height);
}

#endregion

#region GUI

// temp
bg_surface = surface_create(canvas_width, canvas_height);

bg_ensure_exists = function() {
	
	if (!surface_exists(bg_surface)) {
		bg_surface = surface_create(canvas_width, canvas_height);
	}
	
	surface_set_target(bg_surface);

	draw_sprite_tiled(bg, 0, 0, 0);

	surface_reset_target();
}

/// force a refresh of the background
bg_refresh = function() {
	surface_free(bg_surface);
}

/// gui's draw surface
gui_surface = surface_create(window_width, window_height);

/// whether we need to redraw the gui
gui_redraw = true;

/// draw the gui
gui_draw = function() {
	
	if (file != undefined) {
		draw_text(0, 0, file);
	}
	
	gui_redraw = false;
}

/// ensure the gui layer exists, if not, mark for redraw
gui_ensure_exists = function() {
	if (surface_exists(gui_surface)) {
		return;
	}
	
	gui_surface = surface_create(window_width, window_height);
	gui_redraw = true;
}

#endregion

#region Event handlers

/// called upon window resize.
/// @param {real} new_width
/// @param {real} new_height
on_window_resize = function(new_width, new_height) {
    window_width = new_width;
    window_height = new_height;
	
	surface_free(gui_surface);
}

/// called when the user loads a file
on_load_canvas = function(filepath) {
	
	gui_redraw = true;
	
	load_dir_list(filepath);
	canvas_load_from_file(filepath);

}

/// called when the user hits load
on_file_picker = function() {
	
	var filepath = get_open_filename("*", "");
	
	if (filepath == "") {
		return;
	}
	
	on_load_canvas(filepath);

}

/// called on pressing fullscreen key
on_fullscreen_toggle = function() {
	window_set_fullscreen(!window_get_fullscreen());
}

/// called on viewing the context menu
on_view_context = function() {
	state = State.Idle;
}

/// called on panning with arrow keys
on_arrow_pan = function(xdir, ydir) {
	
	static pan_speed = 16;
	
	canvas_translate(xdir * pan_speed, ydir * pan_speed);
}

/// called on viewing the next or previous image in the folder
on_view_next = function(dir) {
	if (file == undefined || dir_list == undefined) {
		return;
	}
	
	var ind = modwrap((array_get_index(dir_list, file) + dir), array_length(dir_list));
	
	on_load_canvas(dir_list[ind]);
}

/// called on zooming in and out on the canvas
/// @param {real} delta
/// @param {real} window_center_x center x position in window space
/// @param {real} window_center_y center y position in window space
on_zoom = function(delta, window_center_x, window_center_y) {
	static zoom_multiplier = 0.08;
	var zoom_factor = delta * zoom_multiplier;
	
	canvas_zoom(zoom_factor, window_center_x, window_center_y);
}

#endregion

#region Final Init!

canvas_rescale();
canvas_center();

if (file == undefined) {
	on_file_picker();
	return;
}

on_load_canvas(file);

#endregion
