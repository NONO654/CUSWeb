define('DS/EPInputs/EPGestureSwipeEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GestureSwipeEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.direction = new Vector2D();
		this.duration = undefined;
	};

	GestureSwipeEvent.prototype = Object.create(GestureEvent.prototype);
	GestureSwipeEvent.prototype.constructor = GestureSwipeEvent;
	GestureSwipeEvent.prototype.type = 'GestureSwipeEvent';

	GestureSwipeEvent.prototype.getDirection = function () {
		return this.direction.clone();
	};

	GestureSwipeEvent.prototype.getDuration = function () {
		return this.duration;
	};

	EventServices.registerEvent(GestureSwipeEvent);

	// Expose in EP namespace.
	EP.GestureSwipeEvent = GestureSwipeEvent;

	return GestureSwipeEvent;
});
