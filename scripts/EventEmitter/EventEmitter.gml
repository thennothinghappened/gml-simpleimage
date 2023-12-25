enum EventEmitResult {
	Ok,
	EventDoesntExist
}

enum EventAddResult {
	Ok,
	EventAlreadyAdded
}

enum EventAddListenerResult {
	Ok,
	EventDoesntExist
}

enum EventRemoveListenerResult {
	Ok,
	EventDoesntExist,
	ListenerDoesntExist
}

function EventEmitter() constructor {
	
	events = {};
	
	/// [Protected] Emit a given event name to all listeners.
	/// @param {String} event Event name to emit.
	/// @param {Struct?} params Parameters to send
	/// @returns {Enum.EventEmitResult}
	emit = function(event, params) {
		
		if (!struct_exists(events, event)) {
			return EventEmitResult.EventDoesntExist;
		}
		
		array_foreach(events[$ event], method({ params }, function(listener) {
			listener(params);
		}));
		
		return EventEmitResult.Ok;
	}
	
	/// Subscribe to an event as a listener.
	/// @param {String} event Event to listen to.
	/// @param {Function} listener Callback to listen with.
	/// @returns {Enum.EventAddListenerResult}
	add = function(event, listener) {
		if (!struct_exists(events, event)) {
			return EventAddListenerResult.EventDoesntExist;
		}
		
		array_push(events[$ event], listener);
		return EventAddListenerResult.Ok;
	}
	
	/// Remove a listen to an event.
	/// @param {String} event Event listening to.
	/// @param {Function} listener Callback to remove from the list.
	/// @returns {Enum.EventRemoveListenerResult}
	remove = function(event, listener) {
		if (!struct_exists(events, event)) {
			return EventRemoveListenerResult.EventDoesntExist;
		}
		
		const listeners = events[$ event];
		const idx = array_find_index(listeners, method({ desired_listener: listener }, function(listener) {
			return listener == desired_listener;
		}));
		
		if (idx == -1) {
			return EventRemoveListenerResult.ListenerDoesntExist;
		}
		
		array_delete(listeners, idx, 1);
		return EventRemoveListenerResult.Ok;
	}
	
	/// [Protected] Add an event name to the list of events.
	/// @param {String} event Event name to add.
	/// @returns {Enum.EventAddResult}
	event_add = function(event) {
		if (struct_exists(events, event)) {
			return EventAddResult.EventAlreadyAdded;
		}
		
		events[$ event] = [];
		return EventAddResult.Ok;
	}
	
}