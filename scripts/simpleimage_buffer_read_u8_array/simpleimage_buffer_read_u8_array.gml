enum BufferReadResult {
	Success,
	BufferReadError
}

/// Read a list of u8 values
/// @param {Id.Buffer} b Buffer to read
/// @param {Real} count Number of bytes to read
function simpleimage_buffer_read_u8_array(b, count) {
	
	const out_array = array_create(count, -1);
	
	for (var i = 0; i < count; i ++) {
		
		try {
			out_array[i] = buffer_read(b, buffer_u8);
		} catch (err_cause) {
			return {
				result: BufferReadResult.BufferReadError,
				err: new Err($"Failed to read byte index {i} of total {count}, reads so far (-1 is unread): {out_array}", err_cause)
			};
		}
	}
	
	return {
		result: BufferReadResult.Success,
		data: out_array
	};
}