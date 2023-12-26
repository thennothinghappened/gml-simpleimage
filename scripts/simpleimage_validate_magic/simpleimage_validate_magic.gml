enum MagicValidationResult {
	Success,
	NotMatchingError,
	BufferReadError
}

/// Validate magic bytes against expected bytes.
/// @param {Id.Buffer} b Buffer to test
/// @param {Array<Real>} expected Expected bytes
function simpleimage_validate_magic(b, expected) {
	
	const num_expected = array_length(expected);
	
	for (var i = 0; i < num_expected; i ++) {
		
		var read_byte = -1;
		
		try {
			read_byte = buffer_read(b, buffer_u8);
		} catch (err_cause) {
			return {
				result: MagicValidationResult.BufferReadError,
				err: new Err("Failed to read buffer validating magic", err_cause)
			};
		}
		
		if (read_byte != expected[i]) {
			return {
				result: MagicValidationResult.NotMatchingError,
				err: new Err($"Magic byte at position {i} of expected {expected} should be {expected[i]}, found {read_byte}")
			};
		}
	}
	
	return {
		result: MagicValidationResult.Success
	};
}