/// @desc 

if (keyboard_check_pressed(vk_f7)) {
	return on_load_canvas();
}

mouse_state_load();

handlers[state]();