/// @desc 

var _window_width = max(window_get_width(), 1);
var _window_height = max(window_get_height(), 1);

if (window_width != _window_width || window_height != _window_height) {
    on_window_resize(_window_width, _window_height);
}

gui_ensure_exists();

if (gui_redraw) {
	surface_set_target(gui_surface);
	
	draw_clear_alpha(c_white, 0);
	gui_draw();
	
	surface_reset_target();
}

bg_ensure_exists();