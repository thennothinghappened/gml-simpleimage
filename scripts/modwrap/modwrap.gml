/// mod but it works right
/// @param {real} a
/// @param {real} b
function modwrap(a, b){
	return a - b * floor(a / b)
}