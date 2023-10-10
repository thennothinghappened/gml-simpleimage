/// @desc 


draw_surface_ext(bg_surface, canvas_pan_x, canvas_pan_y, canvas_scale, canvas_scale, 0, c_white, 1);

canvas_ensure_exists();
draw_surface_ext(canvas, canvas_pan_x, canvas_pan_y, canvas_scale, canvas_scale, 0, c_white, 1);

if (!surface_exists(gui_surface)) {
	// something's gone wrong, let's wait till next frame's redraw
	return;
}

gui_ensure_exists();
draw_surface(gui_surface, 0, 0);
