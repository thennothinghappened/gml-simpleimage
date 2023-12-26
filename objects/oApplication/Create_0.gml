/// @desc Entry point of the application

window = new AppWindow();
window.init();

const _bmp_parser = new BmpParser();

const test_img_fname = get_open_filename("*.bmp", "");

if (test_img_fname == "") {
	game_end(1);
	exit;
}

const image_buffer = buffer_load(test_img_fname);
const parse_res = _bmp_parser.parse(image_buffer);

if (parse_res.result != ImageLoadResult.Success) {
	show_error(parse_res.err.toString(), true);
	exit;
}

buffer_seek(image_buffer, buffer_seek_start, 0);

const image_data = parse_res.data;
const image_res = _bmp_parser.load(image_buffer, image_data);

if (image_res.result != ImageLoadResult.Success) {
	show_error(image_res.err.toString(), true);
	exit;
}

const image = image_res.data;
const save_res = _bmp_parser.save(image, image.data.to_save_params());
image.destroy();

if (save_res.result != ImageSaveResult.Success) {
	show_error(save_res.err.toString(), true);
	exit;
}

const save_buf = save_res.data;
const save_fname = get_save_filename("*.bmp", "");

if (save_fname == "") {
	game_end(1);
	exit;
}

buffer_save(save_buf, save_fname);
buffer_delete(save_buf);

game_end(0);
exit;