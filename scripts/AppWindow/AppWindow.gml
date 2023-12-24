/// Controller wrapper for the application window
/// @param {Real} _fps_background Framerate to run at while the application is in the background.
/// @param {Real} _fps_foreground Framerate to run at while the application is focused.
function AppWindow(
	_fps_background = 5,
	_fps_foreground = 240
) constructor {
	
	fps_background = _fps_background;
	fps_foreground = _fps_foreground;
	
	focused = window_has_focus();
	
	width = window_get_width();
	height = window_get_height();
	
	/// Setup the application window!
	init = function() {
		// We draw directly to the screen, so no app surface needed.
		application_surface_enable(false);
		application_surface_draw_enable(false);
	}
	
	/// Update any window changes.
	update = function() {
		
		const old_focused = focused;
		focused = window_has_focus();
		
		if (focused != old_focused) {
			game_set_speed(focused ? fps_foreground : fps_background, gamespeed_fps);
		}
		
		show_debug_message(focused);
	}
	
	/// Resize the application window to a given width and height.
	/// @param {Real} w
	/// @param {Real} h
	resize = function(w, h) {
		width = w;
		height = h;
		window_set_size(w, h);
	}
	
}