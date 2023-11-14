/// Assert a condition is true, or throw an unrecoverable error.
/// @param {bool} condition
/// @param {string} [message]
function assert(condition, message = "Assertion failed!") {
	if (!condition) {
		show_error(message, true);
	}
}