/// @desc 

#macro X 0
#macro Y 1

#region Initial window setup

application_surface_enable(false);
application_surface_draw_enable(false);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

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

handlers = [];

handlers[State.Idle] = function() {
	
	if (click[MouseButtons.Right][0] == ClickState.Pressed) {
		game_set_speed(draw_fps, gamespeed_fps);
		
		state = State.ClickPanning;
		return;
	}
	
	var scroll_delta = real(mouse_wheel_up()) - real(mouse_wheel_down());
	
	if (scroll_delta != 0) {
		on_zoom(scroll_delta, current_mouse_x, current_mouse_y);
		return;
	}
}

handlers[State.ClickPanning] = function() {
	
	/// min distance before the pan won't open context menu
	static pan_dist_threshold = 16;
	
	if (click[MouseButtons.Right][0] == ClickState.Released) {
		
		game_set_speed(normal_fps, gamespeed_fps);
		
		state = State.Idle;
		
		if (point_distance(
			click[MouseButtons.Right][2],
			click[MouseButtons.Right][3],
			current_mouse_x,
			current_mouse_y) < pan_dist_threshold) {
				
			on_view_context();
		}
		
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

canvas_width = window_width;
canvas_height = window_height;

/// how much we've panned the canvas on screen!
canvas_pan_x = 0;
canvas_pan_y = 0;

/// how much we've zoomed the canvas!
canvas_scale = 1;

/// surface id for the canvas
canvas = -1;

/// backup buffer to reload canvas from if freed
canvas_backup_buf = -1;

/// create the backup buffer for the canvas
canvas_create_backup = function() {
	if (buffer_exists(canvas_backup_buf)) {
		buffer_delete(canvas_backup_buf);
	}
	
	canvas_backup_buf = buffer_create(surface_buffer_size(canvas_width, canvas_height), buffer_fixed, 1);
	canvas_backup();
}

/// backup the surface into memory
canvas_backup = function() {
	buffer_get_surface(canvas_backup_buf, canvas, 0);
}

/// make sure the canvas exists. if not, restore from the backup
canvas_ensure_exists = function() {
	if (surface_exists(canvas)) {
		return;
	}
	
	buffer_set_surface(canvas_backup_buf, canvas, 0);
}

/// zoom in or out of the canvas around a point in window space
/// @param {real} scale_factor
/// @param {real} window_center_x center x position in window space
/// @param {real} window_center_y center y position in window space
canvas_zoom = function(scale_factor, window_center_x, window_center_y) {
	
	static min_zoom = 0.01;
	static max_zoom = 100;
	
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
/// @returns {real[]}
point_to_canvas = function(x, y) {
	return [
		(x - canvas_pan_x) / canvas_scale,
		(y - canvas_pan_y) / canvas_scale,
	];
}

/// convert a point in canvas space back to window space!
/// @param {real} x
/// @param {real} y
/// @returns {real[]}
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
	
	var res = image_load(filepath);
	
	if (res.result != ImageLoadResult.Loaded) {
		return res.result;
	}
	
	canvas_replace(res.img);
	
	sprite_delete(res.img);
	
	return res.result;
}

/// replace the canvas with a new image! (i.e. load a new img)
/// @param {Id.Sprite} img
canvas_replace = function(img) {
	canvas_width = sprite_get_width(img);
	canvas_height = sprite_get_height(img);
	
	surface_free(canvas);
	canvas = surface_create(canvas_width, canvas_height);
	
	surface_set_target(canvas);
	draw_sprite(img, 0, 0, 0);
	surface_reset_target();
	
	canvas_backup();
	bg_refresh();
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
/// @param {number} new_width
/// @param {number} new_height
on_window_resize = function(new_width, new_height) {
    window_width = new_width;
    window_height = new_height;
	
	surface_free(gui_surface);
}

/// called when the user hits load
on_load_canvas = function() {
	
	var filepath = get_open_filename("*", "Canvas");
	
	if (filepath == "") {
		return;
	}
	
	canvas_load_from_file(filepath);
}

/// called on viewing the context menu
on_view_context = function() {
	state = State.Idle;
	
}

/// called on zooming in and out on the canvas
/// @param {real} delta
/// @param {real} window_center_x center x position in window space
/// @param {real} window_center_y center y position in window space
on_zoom = function(delta, window_center_x, window_center_y) {
	static zoom_multiplier = 0.04;
	var zoom_factor = delta * zoom_multiplier;
	
	canvas_zoom(zoom_factor, window_center_x, window_center_y);
}

#endregion

#region Final Init!

canvas = surface_create(canvas_width, canvas_height);
canvas_create_backup();

#endregion