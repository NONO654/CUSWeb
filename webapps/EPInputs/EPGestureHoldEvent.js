define('DS/EPInputs/EPGestureHoldEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GestureHoldEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.elapsedTime = undefined;
		this.position = new Vector2D();
	};

	GestureHoldEvent.prototype = Object.create(GestureEvent.prototype);
	GestureHoldEvent.prototype.constructor = GestureHoldEvent;
	GestureHoldEvent.prototype.type = 'GestureHoldEvent';

	GestureHoldEvent.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	GestureHoldEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	EventServices.registerEvent(GestureHoldEvent);

	// Expose in EP namespace.
	EP.GestureHoldEvent = GestureHoldEvent;

	return GestureHoldEvent;
});
