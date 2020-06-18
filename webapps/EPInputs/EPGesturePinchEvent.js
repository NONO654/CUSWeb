define('DS/EPInputs/EPGesturePinchEvent', [
	'DS/EP/EP',
	'DS/EPEventServices/EPEventServices',
	'DS/EPInputs/EPGestureEvent',
	'MathematicsES/MathVector2DJSImpl'
], function (EP, EventServices, GestureEvent, Vector2D) {
	'use strict';

	var GesturePinchEvent = function (iParameters) {

		GestureEvent.call(this, iParameters);

		this.elapsedTime = undefined;
		this.firstPosition = new Vector2D();
		this.secondPosition = new Vector2D();
		this.distance = undefined;
	};

	GesturePinchEvent.prototype = Object.create(GestureEvent.prototype);
	GesturePinchEvent.prototype.constructor = GesturePinchEvent;
	GesturePinchEvent.prototype.type = 'GesturePinchEvent';

	GesturePinchEvent.prototype.getElapsedTime = function () {
		return this.elapsedTime;
	};

	GesturePinchEvent.prototype.getFirstPosition = function () {
		return this.firstPosition.clone();
	};

	GesturePinchEvent.prototype.getSecondPosition = function () {
		return this.secondPosition.clone();
	};

	GesturePinchEvent.prototype.getDistance = function () {
		return this.distance;
	};

	EventServices.registerEvent(GesturePinchEvent);

	// Expose in EP namespace.
	EP.GesturePinchEvent = GesturePinchEvent;

	return GesturePinchEvent;
});
