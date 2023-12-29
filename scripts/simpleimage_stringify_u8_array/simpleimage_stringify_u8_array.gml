
/// Convert an array of u8s to a string.
/// @param {Array<Real>} array
function simpleimage_stringify_u8_array(array) {
	gml_pragma("forceinline");
	return string_join_ext("", array_map(array, chr));
}