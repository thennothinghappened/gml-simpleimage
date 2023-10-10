/// @desc 

if (keyboard_check_pressed(vk_f7)) {
	return on_load_canvas();
}

if (keyboard_check_pressed(ord("F"))) {
	return on_fullscreen_toggle();
}

mouse_state_load();

handlers[state]();