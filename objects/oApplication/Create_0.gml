/// @desc Entry point of the application

window = new AppWindow();
window.init();

const test_img_fname = get_open_filename("*.bmp", "");

if (test_img_fname == "") {
	game_end(1);
}

const buf = buffer_load(test_img_fname);
const _bmp_parser = new BmpParser();

buffer_seek(buf, buffer_seek_start, 0);
const parse_res = _bmp_parser.parse(buf);

if (parse_res.result != ImageLoadResult.Success) {
	show_error(parse_res.err.toString(), true);
}

buffer_seek(buf, buffer_seek_start, 0);
const image_res = _bmp_parser.load(buf);

if (image_res.result != ImageLoadResult.Success) {
	show_error(image_res.err.toString(), true);
}

const image = image_res.data;
const save_res = _bmp_parser.save(image, new BmpSaveParams());
image.destroy();

if (save_res.result != ImageSaveResult.Success) {
	show_error(save_res.err.toString(), true);
}

const save_buf = save_res.data;
const save_fname = get_save_filename("*.bmp", "");

if (save_fname == "") {
	game_end(1);
}

buffer_save(save_buf, save_fname);
buffer_delete(save_buf);