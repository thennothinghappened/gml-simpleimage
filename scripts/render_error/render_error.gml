/// fun function that renders an error to a sprite :)
/// @param {string} err
function render_error(err) {
	
	static info = "Error reading file!";
	static info_width = string_width(info);
	static info_height = string_height(info);
	
	static padding = 16;
	
	var str_width = string_width(err);
	var str_height = string_height(err);
	
	var width = max(str_width, info_width) + (padding * 2);
	var height = str_height + info_height + (padding * 2);
	
	var surf = surface_create(width, height);
	
	surface_set_target(surf);
	
		draw_rectangle(1, 1, width - 2, height - 2, true);
	
		draw_text(padding, padding, info);
		draw_line(padding, padding + info_height, padding + info_width, padding + info_height);
	
		draw_text(padding, padding + info_height, err);
	
	surface_reset_target();
	
	var spr = sprite_create_from_surface(surf, 0, 0, width, height, false, false, 0, 0);
	
	surface_free(surf);
	
	return spr;
}