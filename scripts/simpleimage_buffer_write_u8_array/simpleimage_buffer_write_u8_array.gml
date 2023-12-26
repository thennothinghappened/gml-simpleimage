enum BufferWriteResult {
	Success,
	BufferWriteError
}

/// Write a list of u8 values
/// @param {Id.Buffer} b Buffer to write
/// @param {Array<Real>} bytes List of bytes to write
function simpleimage_buffer_write_u8_array(b, bytes) {
	
	const num = array_length(bytes);
	
	for (var i = 0; i < num; i ++) {
		
		const byte = bytes[i];
		
		try {
			buffer_write(b, buffer_u8, byte)
		} catch (err_cause) {
			return {
				result: BufferWriteResult.BufferWriteError,
				err: new Err($"Failed to write byte {byte} (index {i} of {bytes})", err_cause)
			};
		}
	}
	
	return {
		result: BufferWriteResult.Success
	};
}