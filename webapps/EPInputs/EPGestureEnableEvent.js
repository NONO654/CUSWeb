define('DS/EPInputs/EPGestureEnableEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent'
], function (EP, EventServices, GestureEvent) {
	'use strict';

	var GestureEnableEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);
	};

	GestureEnableEvent.prototype = Object.create(GestureEvent.prototype);
	GestureEnableEvent.prototype.constructor = GestureEnableEvent;
	GestureEnableEvent.prototype.type = 'GestureEnableEvent';

	EventServices.registerEvent(GestureEnableEvent);

	// Expose in EP namespace.
	EP.GestureEnableEvent = GestureEnableEvent;

	return GestureEnableEvent;
});
