/// Generic Error type
/// @param {String} _msg Readable error message
/// @param {Struct.Err|Struct.Exception|undefined} [_cause] Cause of the error
function Err(_msg, _cause = undefined) constructor {
	msg = _msg;
	cause = _cause;
	site = debug_get_callstack(2)[1];
	
	toString = function() {
		return $"Error: {msg}\n at {site}" + (cause == undefined ? "" : $"\nCause: {cause}") + "\n";
	}
}
