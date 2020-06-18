define('DS/EPInputs/EPGestureEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPEventServices/EPEvent'
], function (EP, EventServices, Event) {
	'use strict';

	var GestureEvent = function (iParameters) {

		Event.call(this, iParameters);
	};

	GestureEvent.prototype = Object.create(Event.prototype);
	GestureEvent.prototype.constructor = GestureEvent;
	GestureEvent.prototype.type = 'GestureEvent';

	EventServices.registerEvent(GestureEvent);

	// Expose in EP namespace.
	EP.GestureEvent = GestureEvent;

	return GestureEvent;
});
