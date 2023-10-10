/// @desc 

if (keyboard_check_pressed(ord("L"))) {
	return on_load_canvas();
}

if (keyboard_check_pressed(ord("F"))) {
	return on_fullscreen_toggle();
}

var arrow_horizontal = real(keyboard_check(vk_right)) - real(keyboard_check(vk_left));
var arrow_vertical = real(keyboard_check(vk_down)) - real(keyboard_check(vk_up));

if (arrow_horizontal != 0 && keyboard_check(vk_shift)) {
	
}

if (arrow_horizontal != 0 || arrow_vertical != 0) {
	return on_arrow_pan(-arrow_horizontal, -arrow_vertical);
}

mouse_state_load();

handlers[state]();