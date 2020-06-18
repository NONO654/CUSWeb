define('DS/EPInputs/EPGestureDoubleTapEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GestureDoubleTapEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.elapsedTime = undefined;
		this.position = new Vector2D();
	};

	GestureDoubleTapEvent.prototype = Object.create(GestureEvent.prototype);
	GestureDoubleTapEvent.prototype.constructor = GestureDoubleTapEvent;
	GestureDoubleTapEvent.prototype.type = 'GestureDoubleTapEvent';

	GestureDoubleTapEvent.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	GestureDoubleTapEvent.prototype.getPosition = function () {
		return this.position.clone();
	};

	EventServices.registerEvent(GestureDoubleTapEvent);

	// Expose in EP namespace.
	EP.GestureDoubleTapEvent = GestureDoubleTapEvent;

	return GestureDoubleTapEvent;
});
