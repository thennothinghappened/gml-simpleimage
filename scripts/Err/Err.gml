/// Generic Error type
/// @param {String} _msg Readable error message
/// @param {Struct.Err|Struct.Exception|undefined} [_cause] Cause of the error
function Err(_msg, _cause = undefined) constructor {
	msg = _msg;
	cause = _cause;
	callstack = debug_get_callstack();
	array_delete(callstack, 0, 1);
	
	toString = function() {
		return $"Error: {msg}\n at {string_join_ext("\n at ", callstack)}" + (cause == undefined ? "" : $"\nCause: {cause}") + "\n";
	}
}
