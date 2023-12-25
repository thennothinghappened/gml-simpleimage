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

if (parse_res.result != ImageParsableResult.Parsable) {
	show_error(parse_res.err.toString(), true);
}

buffer_seek(buf, buffer_seek_start, 0);
const image_res = _bmp_parser.load(buf);

if (image_res.result != ImageLoadResult.Success) {
	show_error(image_res.err.toString(), true);
}

const image = image_res.data;
sprite_save(image.sprite, 0, get_save_filename("*.png", "out.png"));

image.destroy();