
/// Header of a BMP file
/// @param {Real} size Size in bytes of the BMP file
/// @param {Real} _reserved1 Reserved byte 1
/// @param {Real} _reserved2 Reserved byte 2
/// @param {Real} offset Image data offset in buffer
function BmpHeader(
	size,
	_reserved1 = 0x00,
	_reserved2 = 0x00,
	offset
) constructor {
	self.size = size;
	self._reserved1 = _reserved1;
	self._reserved2 = _reserved2;
	self.offset = offset;
}