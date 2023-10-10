/// @desc 

if (keyboard_check_pressed(ord("L"))) {
	return on_file_picker();
}

if (keyboard_check_pressed(ord("F"))) {
	return on_fullscreen_toggle();
}

var arrow_horizontal = real(keyboard_check(vk_left)) - real(keyboard_check(vk_right));
var arrow_vertical = real(keyboard_check(vk_up)) - real(keyboard_check(vk_down));

var arrow_horizontal_pressed = real(keyboard_check_pressed(vk_left)) - real(keyboard_check_pressed(vk_right));

if (keyboard_check(vk_shift)) {

	if (arrow_horizontal_pressed != 0) {
		return on_view_next(arrow_horizontal_pressed);
	}

} else {

	if (arrow_horizontal != 0 || arrow_vertical != 0) {
		return on_arrow_pan(arrow_horizontal, arrow_vertical);
	}

}

mouse_state_load();

handlers[state]();