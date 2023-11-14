/// fun function that renders a message to a sprite :)
/// @param {string} title
/// @param {string} msg
function render_message(title, msg) {
	
	static fail_width = sprite_get_width(fail_img);
	
	static info = title;
	static info_width = string_width(info) + fail_width;
	static info_height = string_height(info);
	
	static padding = 32;
	
	var str_width = string_width(msg);
	var str_height = string_height(msg);
	
	var width = max(str_width, info_width) + (padding * 2);
	var height = str_height + info_height + (padding * 2);
	
	var surf = surface_create(width, height);
	
	surface_set_target(surf);
	
		draw_rectangle(1, 1, width - 2, height - 2, true);
	
		draw_sprite(fail_img, 0, padding, padding);
		draw_text(padding + fail_width, padding, info);
		draw_line(padding, padding + info_height, padding + info_width, padding + info_height);
	
		draw_text(padding, padding + info_height, msg);
	
	surface_reset_target();
	
	var spr = sprite_create_from_surface(surf, 0, 0, width, height, false, false, 0, 0);
	
	surface_free(surf);
	
	return spr;
}

/// @param {string} err
function render_error(err) {
	return render_message("Error reading file!", err);
}